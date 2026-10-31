-- tab_farm_tsunami.lua v3 - 3 raycasts fijos mundiales
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm
local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

F._tsunamiHoldUntil = 0
F._lastTsunamiScan = 0
F._tsunamiPos = nil
F._blueHold = false

local function findTsunami()
	local root = Workspace:FindFirstChild("NPC & Piege")
		or Workspace:FindFirstChild("NPC & Piege", true)
	if root then
		local stage = root:FindFirstChild("TsunamiStage4")
		if stage then
			local t = stage:FindFirstChild("Tsunami")
			if t then return t end
		end
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "Tsunami" and obj.Parent and obj.Parent.Name == "TsunamiStage4" then
			return obj
		end
	end
	return nil
end

local function tsunamiWorldPos(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj.Position end
	local ok, pivot = pcall(function() return obj:GetPivot() end)
	if ok and pivot then return pivot.Position end
	local part = obj:FindFirstChildWhichIsA("BasePart", true)
	if part then return part.Position end
	return nil
end

local function isTsunamiInstance(inst)
	local cur = inst
	for _ = 1, 12 do
		if not cur then return false end
		if cur.Name == "Tsunami" and cur.Parent and cur.Parent.Name == "TsunamiStage4" then return true end
		if cur.Name == "TsunamiStage4" then return true end
		cur = cur.Parent
	end
	return false
end

-- 3 raycasts FIJOS en mundo (no rotan con el personaje)
local FIXED_RAYS = {
	{ dir = Vector3.new(-1, 0, 0), kind = "red", len = 55 },
	{ dir = Vector3.new(0, 1, 0), kind = "blue", len = 40 },
	{ dir = Vector3.new(1, 0, 0), kind = "blue", len = 55 },
}

local function castFixed(hrp)
	if not hrp then return {} end
	local origin = hrp.Position + Vector3.new(0, 2, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	params.IgnoreWater = true
	local hits = {}
	for _, r in ipairs(FIXED_RAYS) do
		local result = Workspace:Raycast(origin, r.dir * r.len, params)
		if result and result.Instance and isTsunamiInstance(result.Instance) then
			local dist = (result.Position - origin).Magnitude
			hits[#hits + 1] = { kind = r.kind, dist = dist, pos = result.Position, dir = r.dir }
		end
	end
	local t = findTsunami()
	local tPos = tsunamiWorldPos(t)
	F._tsunamiPos = tPos
	if tPos then
		local d = (hrp.Position - tPos).Magnitude
		hits[#hits + 1] = { kind = "pos", dist = d, pos = tPos }
	end
	return hits
end

function S.tsunamiDangerSpeed(hrp, baseSpeed)
	if not hrp then return baseSpeed, false end
	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local hits = castFixed(hrp)
	local redNear, blueNear = false, false
	local minBlue, minRed = math.huge, math.huge

	for _, h in ipairs(hits) do
		if h.kind == "red" then
			redNear = true
			minRed = math.min(minRed, h.dist)
		elseif h.kind == "blue" then
			blueNear = true
			minBlue = math.min(minBlue, h.dist)
		elseif h.kind == "pos" and h.dist < 30 then
			blueNear = true
			minBlue = math.min(minBlue, h.dist)
		end
	end

	-- AZUL: cerca -> frenar + 0.5s al pasar
	if blueNear and minBlue < 35 then
		if minBlue < 22 then
			F._tsunamiHoldUntil = now + 0.5
			F._blueHold = true
			return 0, true
		end
		return math.min(baseSpeed, 8), true
	end

	if F._blueHold and not blueNear then
		F._blueHold = false
		F._tsunamiHoldUntil = now + 0.5
		return 0, true
	end

	-- ROJO: acelerar / saltar al siguiente CF
	if redNear and minRed < 45 then
		F._tsunamiSkipNext = true
		return math.max(baseSpeed, math.min(500, baseSpeed * 1.35)), true
	end

	F._tsunamiSkipNext = false
	return baseSpeed, false
end

print("[Delta Hub] Tsunami v3 (3 raycasts fijos) loaded")
