-- tab_farm_tsunami.lua v5
-- <=10 wins: ignorar | ~30 studs: frenar | 20: mirar direccion | <15 cerca: skip rapido
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
F._tsunamiApproaching = false
F._minDistSeen = math.huge

local function findTsunami()
	local function match(obj)
		if not obj then return false end
		if obj.Name == "TsunamiStage4" then return true end
		local n = string.lower(obj.Name)
		return string.find(n, "tsunami", 1, true) ~= nil
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
		task.wait(0.12)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local t = findTsunami()
		local tPos = tsunamiWorldPos(t)
		F._tsunamiPos = tPos
		if hrp and tPos then
			local d = (hrp.Position - tPos).Magnitude
			if F._lastTsunamiDist then
				local delta = d - F._lastTsunamiDist
				F._tsunamiMovingAway = (delta > 1.2)
				F._tsunamiApproaching = (delta < -1.2)
			end
			F._lastTsunamiDist = d
			F._tsunamiDist = d
			if d < (F._minDistSeen or math.huge) then
				F._minDistSeen = d
			end
		else
			F._tsunamiDist = nil
			F._tsunamiMovingAway = false
			F._tsunamiApproaching = false
		end
	end
end)

function S.tsunamiDangerSpeed(hrp, baseSpeed)
	if not hrp then return baseSpeed, false end

	-- WinBlocks de 10 wins o menos: no preocuparse por tsunami
	if F._ignoreTsunami then
		F._tsunamiSkipNext = false
		return baseSpeed, false
	end

	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local d = F._tsunamiDist
	if not d then
		return baseSpeed, false
	end

	-- Si ya pasamos a menos de 15 studs: salir al siguiente CF lo mas rapido posible
	if (F._minDistSeen or math.huge) <= 15 or d <= 15 then
		F._tsunamiSkipNext = true
		F._minDistSeen = math.huge -- reset tras skip
		return math.max(baseSpeed or 200, 400), true
	end

	-- ~30 studs: detenerse / ir muy lento
	if d <= 30 then
		-- A ~20 studs: mirar si viene hacia nosotros
		if d <= 20 then
			if F._tsunamiApproaching then
				F._tsunamiHoldUntil = now + 0.4
				F._tsunamiSkipNext = false
				return 0, true
			end
			if F._tsunamiMovingAway then
				-- se aleja: salir rapido
				F._tsunamiSkipNext = true
				return math.max(baseSpeed or 200, 350), true
			end
			-- lateral / dudoso: frenar suave
			return math.min(baseSpeed or 200, 12), true
		end
		-- entre 20 y 30: casi parado
		F._tsunamiSkipNext = false
		return math.min(baseSpeed or 200, 15), true
	end

	-- 30-55: precautorio si se acerca
	if d <= 55 and F._tsunamiApproaching then
		return math.min(baseSpeed or 200, math.max(30, (baseSpeed or 200) * 0.45)), true
	end

	F._tsunamiSkipNext = false
	return baseSpeed, false
end

print("[Delta Hub] Tsunami v5 loaded")
