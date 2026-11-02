-- tab_farm_tsunami.lua v11
-- Rojo = hold CF13 | Azul = trail lento detrás | Verde = CF más cercano a la derecha
-- Rays el doble de grosor, ejes de mundo fijos

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm

local VIS = true
local FRONT_LEN = 20
local RIGHT_LEN = 30
local LEFT_LEN = 40
local FRONT_ANGLES = { 0, 15, -15, 30, -30 }
local RAY_THICK = 0.5 -- el doble de antes (~0.22)

local WORLD_FWD = Vector3.new(0, 0, 1)
local WORLD_RIGHT = Vector3.new(1, 0, 0)
local WORLD_LEFT = Vector3.new(-1, 0, 0)

local oldFolder = Workspace:FindFirstChild("DeltaHubTsunamiRays")
if oldFolder then pcall(function() oldFolder:Destroy() end) end
local folder = Instance.new("Folder")
folder.Name = "DeltaHubTsunamiRays"
folder.Parent = Workspace

local rayParts = {}
local function makeRayPart(name, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = VIS and 0.5 or 1
	p.Size = Vector3.new(RAY_THICK, RAY_THICK, 1)
	p.Parent = folder
	rayParts[name] = p
	return p
end

for i = 1, #FRONT_ANGLES do
	makeRayPart("Front_" .. i, Color3.fromRGB(255, 70, 70))
end
makeRayPart("Right", Color3.fromRGB(70, 170, 255))
makeRayPart("Left", Color3.fromRGB(70, 255, 120))

local function setRayVisual(part, origin, dir, len, hit)
	if not part then return end
	local d = dir.Magnitude > 1e-4 and dir.Unit or Vector3.new(0, 0, 1)
	local useLen = hit and hit.Distance or len
	useLen = math.max(useLen, 0.2)
	part.Size = Vector3.new(RAY_THICK, RAY_THICK, useLen)
	part.CFrame = CFrame.new(origin + d * (useLen * 0.5), origin + d * useLen)
	part.Transparency = VIS and (hit and 0.3 or 0.5) or 1
end

local function rotY(v, deg)
	local r = math.rad(deg)
	local c, s = math.cos(r), math.sin(r)
	return Vector3.new(v.X * c - v.Z * s, 0, v.X * s + v.Z * c)
end

local cachedTsunami = nil
local lastScan = 0

local function findTsunami()
	if cachedTsunami and cachedTsunami.Parent then return cachedTsunami end
	if tick() - lastScan < 0.35 then return cachedTsunami end
	lastScan = tick()
	cachedTsunami = nil
	local stage = Workspace:FindFirstChild("TsunamiStage4", true)
	if stage then
		for _, d in ipairs(stage:GetDescendants()) do
			if string.lower(d.Name) == "tsunami" then
				cachedTsunami = d
				return d
			end
		end
	end
	for _, d in ipairs(Workspace:GetDescendants()) do
		if string.lower(d.Name) == "tsunami" then
			cachedTsunami = d
			return d
		end
	end
	return nil
end

local function tsunamiPos(t)
	if not t then return nil end
	if t:IsA("BasePart") then return t.Position end
	local ok, piv = pcall(function() return t:GetPivot() end)
	if ok and piv then return piv.Position end
	local p = t:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

local function stripTouchInterest(root)
	if not root then return end
	pcall(function()
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("TouchTransmitter") or d.ClassName == "TouchInterest" then
				pcall(function() d:Destroy() end)
			end
		end
		if root:IsA("BasePart") then
			for _, c in ipairs(root:GetChildren()) do
				if c:IsA("TouchTransmitter") or c.ClassName == "TouchInterest" then
					pcall(function() c:Destroy() end)
				end
			end
		end
	end)
end

local function isTsunamiPart(inst)
	if not inst then return false end
	local n = string.lower(inst.Name)
	if n == "tsunami" then return true end
	local p = inst.Parent
	while p and p ~= Workspace do
		local pn = string.lower(p.Name)
		if pn == "tsunami" or string.find(pn, "tsunamistage", 1, true) then return true end
		p = p.Parent
	end
	return false
end

local function rayHitTsunami(origin, dir, len)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local exclude = { folder }
	if player.Character then table.insert(exclude, player.Character) end
	params.FilterDescendantsInstances = exclude
	params.IgnoreWater = true
	local result = Workspace:Raycast(origin, dir.Unit * len, params)
	if result and isTsunamiPart(result.Instance) then return result end
	return nil
end

-- CF más cercano al jugador que esté hacia la derecha (WORLD_RIGHT)
local function nearestCFTowardRight(hrpPos)
	local frames = S.routeCFrames
	if not frames then return nil end
	local bestPos, bestScore = nil, -math.huge
	for i = 1, 200 do
		local cf = frames[i]
		if cf then
			local p = cf.Position
			local to = p - hrpPos
			local flat = Vector3.new(to.X, 0, to.Z)
			local dist = flat.Magnitude
			if dist > 1 and dist < 200 then
				local align = flat.Unit:Dot(WORLD_RIGHT) -- más positivo = más a la derecha
				local score = align * 100 - dist * 0.15
				if align > 0.05 and score > bestScore then
					bestScore = score
					bestPos = p
				end
			end
		end
	end
	return bestPos
end

F._forceHoldPos = nil
F._tsunamiHoldAt13 = false
F._tsunamiTrailPos = nil
F._tsunamiSkipNext = false
F._wasBlueTracking = false

function S.tsunamiDangerSpeed(hrp, baseSpeed, nextCfPos)
	if not hrp then return baseSpeed or 0, false end

	local origin = hrp.Position + Vector3.new(0, 1.5, 0)
	local ts = findTsunami()
	if ts then stripTouchInterest(ts) end

	local cf13 = S.routeCFrames and S.routeCFrames[13]
	local nearZone = cf13 and (hrp.Position - cf13.Position).Magnitude < 250

	local frontHit = false
	for i, ang in ipairs(FRONT_ANGLES) do
		local dir = rotY(WORLD_FWD, ang)
		local hit = rayHitTsunami(origin, dir, FRONT_LEN)
		setRayVisual(rayParts["Front_" .. i], origin, dir, FRONT_LEN, hit)
		if hit then frontHit = true end
	end

	local rightHit = rayHitTsunami(origin, WORLD_RIGHT, RIGHT_LEN)
	setRayVisual(rayParts.Right, origin, WORLD_RIGHT, RIGHT_LEN, rightHit)

	local leftHit = rayHitTsunami(origin, WORLD_LEFT, LEFT_LEN)
	setRayVisual(rayParts.Left, origin, WORLD_LEFT, LEFT_LEN, leftHit)

	if not nearZone or not F.routeRunning then
		F._forceHoldPos = nil
		F._tsunamiHoldAt13 = false
		F._tsunamiTrailPos = nil
		F._wasBlueTracking = false
		return baseSpeed or 0, false
	end

	-- ROJO: hold estricto en CF13
	if frontHit and cf13 then
		F._tsunamiHoldAt13 = true
		F._forceHoldPos = cf13.Position
		F._tsunamiTrailPos = nil
		F._tsunamiSkipNext = false
		F._wasBlueTracking = false
		local dist = (hrp.Position - cf13.Position).Magnitude
		if dist > 2.5 then
			return math.min(baseSpeed or 200, 70), true
		end
		return 0, true -- HOLD
	end
	F._tsunamiHoldAt13 = false

	-- AZUL: ir despacio detrás del tsunami mientras lo vea
	if rightHit then
		local tpos = tsunamiPos(ts)
		if tpos then
			local behind = Vector3.new(tpos.X, hrp.Position.Y, tpos.Z) - WORLD_FWD * 30
			F._tsunamiTrailPos = behind
			F._forceHoldPos = behind
			F._tsunamiSkipNext = false
			F._wasBlueTracking = true
			return math.min(baseSpeed or 200, 40), true -- lento
		end
	end

	-- Azul dejó de verlo → avanzar ruta
	if not rightHit and F._wasBlueTracking then
		F._wasBlueTracking = false
		F._forceHoldPos = nil
		F._tsunamiTrailPos = nil
		F._tsunamiSkipNext = true
		return baseSpeed or 0, false
	end

	-- VERDE: CF más cercano hacia la derecha, ir rápido
	if leftHit then
		local rightCF = nearestCFTowardRight(hrp.Position)
		if rightCF then
			F._forceHoldPos = rightCF
			F._tsunamiTrailPos = nil
			F._tsunamiSkipNext = false
			F._wasBlueTracking = false
			return math.max(baseSpeed or 200, 180), true -- rápido
		else
			-- fallback: saltar al siguiente CF de la ruta
			F._forceHoldPos = nil
			F._tsunamiSkipNext = true
			return baseSpeed or 0, false
		end
	end

	if not rightHit and not frontHit and not leftHit then
		F._forceHoldPos = nil
	end

	return baseSpeed or 0, false
end

RunService.Heartbeat:Connect(function()
	local ts = findTsunami()
	if ts then stripTouchInterest(ts) end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		S.tsunamiDangerSpeed(hrp, 0, nil)
	end
end)

print("[Delta Hub] Tsunami v11 · rojo hold13 / azul trail / verde CF derecha")
