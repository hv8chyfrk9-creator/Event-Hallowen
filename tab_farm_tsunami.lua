-- tab_farm_tsunami.lua v4 - seguimiento por distancia al tsunami
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm

F._tsunamiHoldUntil = 0
F._lastTsunamiDist = nil
F._tsunamiMovingAway = false

local function findTsunami()
	local function match(obj)
		if not obj then return false end
		if obj.Name == "TsunamiStage4" then return true end
		local n = string.lower(obj.Name)
		if string.find(n, "tsunami", 1, true) then return true end
		return false
	end
	local folder = Workspace:FindFirstChild("NPC & Piege") or Workspace:FindFirstChild("NPC & Piege", true)
	if folder then
		for _, d in ipairs(folder:GetDescendants()) do
			if match(d) then return d end
		end
	end
	for _, d in ipairs(Workspace:GetDescendants()) do
		if match(d) then return d end
	end
	return nil
end

local function tsunamiWorldPos(t)
	if not t then return nil end
	if t:IsA("BasePart") then return t.Position end
	local ok, piv = pcall(function() return t:GetPivot() end)
	if ok and piv then return piv.Position end
	local p = t:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

task.spawn(function()
	while true do
		task.wait(0.15)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local t = findTsunami()
		local tPos = tsunamiWorldPos(t)
		F._tsunamiPos = tPos
		if hrp and tPos then
			local d = (hrp.Position - tPos).Magnitude
			if F._lastTsunamiDist then
				F._tsunamiMovingAway = (d > F._lastTsunamiDist + 1.5)
			end
			F._lastTsunamiDist = d
			F._tsunamiDist = d
		else
			F._tsunamiDist = nil
			F._tsunamiMovingAway = false
		end
	end
end)

function S.tsunamiDangerSpeed(hrp, baseSpeed)
	if not hrp then return baseSpeed, false end
	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local d = F._tsunamiDist
	local tPos = F._tsunamiPos
	if not d or not tPos then
		return baseSpeed, false
	end

	-- Muy cerca (<= 20 studs): frenar
	if d <= 20 then
		F._tsunamiHoldUntil = now + 0.35
		F._tsunamiSkipNext = false
		return 0, true
	end

	-- Zona media (20-45)
	if d <= 45 then
		if F._tsunamiMovingAway then
			F._tsunamiSkipNext = true
			return math.max(baseSpeed, math.min(500, (baseSpeed or 200) * 1.4)), true
		end
		F._tsunamiSkipNext = false
		return math.min(baseSpeed or 200, 18), true
	end

	if d <= 70 and not F._tsunamiMovingAway then
		F._tsunamiSkipNext = false
		return math.min(baseSpeed or 200, math.max(40, (baseSpeed or 200) * 0.55)), true
	end

	if F._tsunamiMovingAway then
		F._tsunamiSkipNext = true
		return baseSpeed, false
	end

	F._tsunamiSkipNext = false
	return baseSpeed, false
end

print("[Delta Hub] Tsunami v4 (distancia + alejamiento) loaded")
