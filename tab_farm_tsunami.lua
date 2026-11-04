-- tab_farm_tsunami.lua v14.2
-- sin azul · rojo x2 (80)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm

local VIS = false
local FRONT_LEN = 80
local GREEN_LEN = 60
local FRONT_ANGLES = { 0, 15, -15, 30, -30 }
local THICK = 0.25

local WORLD_FWD = Vector3.new(0, 0, 1)
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
	p.Transparency = 1
	p.Size = Vector3.new(THICK, THICK, 1)
	p.Parent = folder
	rayParts[name] = p
	return p
end

for i = 1, #FRONT_ANGLES do makeRayPart("Front_" .. i, Color3.fromRGB(255, 70, 70)) end
makeRayPart("Left", Color3.fromRGB(70, 255, 120))

local function setRayVisual(part, origin, dir, len, hit)
	if not part then return end
	local d = dir.Magnitude > 1e-4 and dir.Unit or Vector3.new(0, 0, 1)
	local useLen = hit and hit.Distance or len
	useLen = math.max(useLen, 0.2)
	part.Size = Vector3.new(THICK, THICK, useLen)
	part.CFrame = CFrame.new(origin + d * (useLen * 0.5), origin + d * useLen)
	part.Transparency = 1
end

local function rotY(v, deg)
	local r = math.rad(deg)
	local c, s = math.cos(r), math.sin(r)
	return Vector3.new(v.X * c - v.Z * s, 0, v.X * s + v.Z * c)
end

local cachedTsunami, lastScan = nil, 0
local function findTsunami()
	if cachedTsunami and cachedTsunami.Parent then return cachedTsunami end
	if tick() - lastScan < 0.35 then return cachedTsunami end
	lastScan = tick()
	cachedTsunami = nil
	local stage = Workspace:FindFirstChild("TsunamiStage4", true)
	if stage then
		for _, d in ipairs(stage:GetDescendants()) do
			if string.lower(d.Name) == "tsunami" then cachedTsunami = d return d end
		end
	end
	for _, d in ipairs(Workspace:GetDescendants()) do
		if string.lower(d.Name) == "tsunami" then cachedTsunami = d return d end
	end
	return nil
end

local function stripTouchInterest(root)
	if not root then return end
	pcall(function()
		for _, d in ipairs(root:GetDescendants()) do
			if d:IsA("TouchTransmitter") or d.ClassName == "TouchInterest" then pcall(function() d:Destroy() end) end
		end
	end)
end

local function isTsunamiPart(inst)
	if not inst then return false end
	if string.lower(inst.Name) == "tsunami" then return true end
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

F._forceHoldPos = nil
F._tsunamiSkipNext = false
F._redHoldUntil = 0
F._greenPauseUntil = 0
F._greenWasHit = false
F._redWasHit = false

function S.tsunamiDangerSpeed(hrp, baseSpeed, nextCfPos)
	if not hrp then return baseSpeed or 0, false end
	local now = tick()
	local origin = hrp.Position + Vector3.new(0, 1.5, 0)
	local ts = findTsunami()
	if ts then stripTouchInterest(ts) end
	local cf13 = S.routeCFrames and S.routeCFrames[13]
	local nearZone = cf13 and (hrp.Position - cf13.Position).Magnitude < 280

	local frontHit = false
	for i, ang in ipairs(FRONT_ANGLES) do
		local dir = rotY(WORLD_FWD, ang)
		local hit = rayHitTsunami(origin, dir, FRONT_LEN)
		setRayVisual(rayParts["Front_" .. i], origin, dir, FRONT_LEN, hit)
		if hit then frontHit = true end
	end
	local greenHit = rayHitTsunami(origin, WORLD_LEFT, GREEN_LEN)
	setRayVisual(rayParts.Left, origin, WORLD_LEFT, GREEN_LEN, greenHit)

	if not nearZone or not F.routeRunning then
		F._forceHoldPos = nil
		F._redHoldUntil = 0
		F._greenPauseUntil = 0
		F._greenWasHit = false
		F._redWasHit = false
		return baseSpeed or 0, false
	end
	if now < (F._redHoldUntil or 0) and cf13 then
		F._forceHoldPos = cf13.Position
		local dist = (hrp.Position - cf13.Position).Magnitude
		if dist > 2.5 then return math.min(baseSpeed or 200, 70), true end
		return 0, true
	end
	if now < (F._greenPauseUntil or 0) then
		F._forceHoldPos = F._greenPausePos or hrp.Position
		return 0, true
	end
	if frontHit and cf13 then
		if not F._redWasHit then F._redWasHit = true F._redHoldUntil = now + 3 end
		F._forceHoldPos = cf13.Position
		F._tsunamiSkipNext = false
		local dist = (hrp.Position - cf13.Position).Magnitude
		if dist > 2.5 then return math.min(baseSpeed or 200, 70), true end
		return 0, true
	else F._redWasHit = false end
	if greenHit then
		if not F._greenWasHit then
			F._greenWasHit = true
			F._greenPauseUntil = now + 1
			F._greenPausePos = hrp.Position
		end
		if now < F._greenPauseUntil then
			F._forceHoldPos = F._greenPausePos or hrp.Position
			return 0, true
		end
		F._forceHoldPos = nil
		return math.min(baseSpeed or 200, 50), false
	else
		if F._greenWasHit then F._greenWasHit = false F._greenPauseUntil = 0 F._forceHoldPos = nil end
	end
	if not frontHit and not greenHit then F._forceHoldPos = nil end
	return baseSpeed or 0, false
end

RunService.Heartbeat:Connect(function()
	local ts = findTsunami()
	if ts then stripTouchInterest(ts) end
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then S.tsunamiDangerSpeed(hrp, 0, nil) end
end)

print("[Delta Hub] Tsunami v14.2 sin azul rojo80")
