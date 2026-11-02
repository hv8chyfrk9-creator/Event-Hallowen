-- tab_farm_tsunami.lua v9
-- Hold:
--   normal: CF uno antes del mas cercano al +10
--   fast:   el CF mas cercano al +10
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm

F._tsunamiHoldUntil = 0
F._tsunamiPos = nil
F._tsunamiVel = Vector3.zero
F._tsunamiSpeed = 0
F._tsunamiDir = Vector3.zero
F._tsunamiDist = nil
F._lastTsunamiPos = nil
F._lastTsunamiTick = nil
F._tsunamiInFront = false
F._tsunamiBehind = false
F._tsunamiOnNormal = false
F._tsunamiOnFastOnly = false
F._cf10Index = nil
F._holdAtIndex = nil
F._forceHoldPos = nil

local NEAR_CF = 22
local FRONT_RANGE = 80

local function findTsunami()
	local stage = Workspace:FindFirstChild("TsunamiStage4", true)
	if stage then
		for _, d in ipairs(stage:GetDescendants()) do
			local n = string.lower(d.Name)
			if n == "tsunami" or (string.find(n, "tsunami", 1, true) and (d:IsA("BasePart") or d:IsA("Model"))) then
				return d
			end
		end
		if stage:IsA("BasePart") or stage:IsA("Model") then return stage end
	end
	local folder = Workspace:FindFirstChild("NPC & Piege") or Workspace:FindFirstChild("NPC & Piege", true)
	if folder then
		for _, d in ipairs(folder:GetDescendants()) do
			if string.find(string.lower(d.Name), "tsunami", 1, true) then return d end
		end
	end
	for _, d in ipairs(Workspace:GetDescendants()) do
		local n = string.lower(d.Name)
		if n == "tsunami" or string.find(n, "tsunami", 1, true) then return d end
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

local function findPlus10WinPos()
	local blocks = S.orderedWinBlocks or {}
	local realName = "WinBlock3"
	for _, info in ipairs(blocks) do
		local d = tostring(info.display or "")
		if d:find("+10") and not d:upper():find("K") and not d:upper():find("M") then
			realName = info.real
			break
		end
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == realName then
			if obj:IsA("BasePart") then return obj.Position, realName end
			local ok, piv = pcall(function() return obj:GetPivot() end)
			if ok and piv then return piv.Position, realName end
			local p = obj:FindFirstChildWhichIsA("BasePart", true)
			if p then return p.Position, realName end
		end
	end
	return nil, realName
end

local function getActiveRoute()
	if S.getRouteCFramesForMode then
		local list = select(1, S.getRouteCFramesForMode(F.routeMode or "normal"))
		if list and #list > 0 then return list end
	end
	return S.routeCFrames
end

local function getRouteModes()
	return S.routeModes or {}
end

-- Devuelve: closest (real), holdNormal = closest-1
local function computeCf10Index(route)
	local pos10 = select(1, findPlus10WinPos())
	if not pos10 or not route or #route == 0 then return nil, nil end
	local bestI, bestD = 1, math.huge
	for i = 1, #route do
		local d = (route[i].Position - pos10).Magnitude
		if d < bestD then bestD, bestI = d, i end
	end
	local holdNormal = math.max(1, bestI - 1)
	return bestI, holdNormal
end

local function classifyTsunamiVsRoute(tPos, route)
	if not tPos or not route then return false, false end
	local modes = getRouteModes()
	local onNormal, onFast = false, false
	local full = S.routeCFrames or route
	for i = 1, #full do
		local cf = full[i]
		if cf and (cf.Position - tPos).Magnitude <= NEAR_CF then
			local m = modes[i]
			if m then
				if m.normal then onNormal = true end
				if m.fast then onFast = true end
			else
				onNormal = true
			end
		end
	end
	return onNormal, (onFast and not onNormal)
end

task.spawn(function()
	while true do
		task.wait(0.08)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local t = findTsunami()
		local tPos = tsunamiWorldPos(t)
		local now = tick()
		local route = getActiveRoute()

		if tPos then
			if F._lastTsunamiPos and F._lastTsunamiTick then
				local dt = now - F._lastTsunamiTick
				if dt > 0.02 and dt < 1 then
					local instVel = (tPos - F._lastTsunamiPos) / dt
					F._tsunamiVel = F._tsunamiVel:Lerp(instVel, 0.4)
					F._tsunamiSpeed = F._tsunamiVel.Magnitude
					if F._tsunamiSpeed > 0.5 then F._tsunamiDir = F._tsunamiVel.Unit end
				end
			end
			F._lastTsunamiPos = tPos
			F._lastTsunamiTick = now
			F._tsunamiPos = tPos

			if hrp then
				F._tsunamiDist = (hrp.Position - tPos).Magnitude
				local moveDir = hrp.CFrame.LookVector
				if type(F._nextRoutePos) == "Vector3" then
					local to = F._nextRoutePos - hrp.Position
					if to.Magnitude > 0.5 then moveDir = to.Unit end
				end
				local flatTo = Vector3.new(tPos.X - hrp.Position.X, 0, tPos.Z - hrp.Position.Z)
				local flatMove = Vector3.new(moveDir.X, 0, moveDir.Z)
				if flatTo.Magnitude > 0.1 and flatMove.Magnitude > 0.1 then
					local align = flatMove.Unit:Dot(flatTo.Unit)
					F._tsunamiInFront = align > 0.12
					F._tsunamiBehind = align < -0.12
				else
					F._tsunamiInFront = false
					F._tsunamiBehind = false
				end
			end

			local onN, onlyF = classifyTsunamiVsRoute(tPos, route)
			F._tsunamiOnNormal = onN
			F._tsunamiOnFastOnly = onlyF

			local closest, holdNormal = computeCf10Index(route)
			F._cf10Index = holdNormal

			F._holdAtIndex = nil
			F._forceHoldPos = nil
			if closest and holdNormal and route and F.routeRunning and not F._ignoreTsunami then
				local playerBefore = true
				if hrp then
					local bestI, bestD = 1, math.huge
					for i = 1, #route do
						local d = (route[i].Position - hrp.Position).Magnitude
						if d < bestD then bestD, bestI = d, i end
					end
					playerBefore = bestI <= closest
				end

				if playerBefore then
					if onN then
						F._holdAtIndex = holdNormal
						F._forceHoldPos = route[holdNormal].Position
					elseif onlyF then
						-- fast: el mas cercano real (atrasado respecto al viejo closest+1)
						F._holdAtIndex = closest
						F._forceHoldPos = route[closest].Position
					end
				end
			end
		else
			F._tsunamiPos = nil
			F._tsunamiDist = nil
			F._tsunamiInFront = false
			F._tsunamiBehind = false
			F._tsunamiOnNormal = false
			F._tsunamiOnFastOnly = false
			F._holdAtIndex = nil
			F._forceHoldPos = nil
		end
	end
end)

function S.tsunamiDangerSpeed(hrp, baseSpeed, nextCfPos)
	if not hrp then return baseSpeed, false end
	if F._ignoreTsunami then
		F._tsunamiSkipNext = false
		return baseSpeed, false
	end

	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local d = F._tsunamiDist

	if F._forceHoldPos then
		local holdPos = F._forceHoldPos
		local distHold = (hrp.Position - holdPos).Magnitude
		if distHold > 3.5 then
			F._nextRoutePos = holdPos
			F._tsunamiSkipNext = false
			return math.min(baseSpeed or 200, 90), true
		end
		F._tsunamiSkipNext = false
		return 0, true
	end

	if not d or not F._tsunamiPos then
		return baseSpeed, false
	end

	if F._tsunamiBehind and not F._tsunamiInFront then
		F._tsunamiSkipNext = false
		return baseSpeed, false
	end

	if F._tsunamiInFront and d <= FRONT_RANGE then
		if d <= 30 then return 0, true end
		if d <= 50 then return math.min(baseSpeed or 200, 10), true end
		return math.min(baseSpeed or 200, 35), true
	end

	if d <= 22 then
		return math.min(baseSpeed or 200, 12), true
	end

	F._tsunamiSkipNext = false
	return baseSpeed, false
end

print("[Delta Hub] Tsunami v9 (hold CF-1 limpio)")
