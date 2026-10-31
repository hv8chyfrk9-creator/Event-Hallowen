-- tab_farm_tsunami.lua - TsunamiStage4.Tsunami avoidance (improved)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm
local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

F._tsunamiPos = nil
F._tsunamiObj = nil
F._lastTsunamiScan = 0
F._lastTsunamiDist = math.huge
F._tsunamiApproaching = false
F._tsunamiHoldUntil = 0

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

local function refreshTsunami()
	local now = tick()
	if now - (F._lastTsunamiScan or 0) < 0.2 then
		return F._tsunamiPos, F._tsunamiObj
	end
	F._lastTsunamiScan = now
	local t = findTsunami()
	F._tsunamiObj = t
	local pos = tsunamiWorldPos(t)
	if pos then
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local newDist = (hrp.Position - pos).Magnitude
			local oldDist = F._lastTsunamiDist or newDist
			F._tsunamiApproaching = newDist < (oldDist - 0.5)
			F._lastTsunamiDist = newDist
		end
	end
	F._tsunamiPos = pos
	return F._tsunamiPos, t
end

local function raycastTsunamiNear(hrp)
	if not hrp then return false, nil, 0 end
	local origin = hrp.Position + Vector3.new(0, 2, 0)
	local cf = hrp.CFrame
	local checks = {
		{ dir = cf.LookVector, len = 70 },
		{ dir = (cf.LookVector + cf.RightVector * 0.35).Unit, len = 55 },
		{ dir = (cf.LookVector - cf.RightVector * 0.35).Unit, len = 55 },
		{ dir = cf.RightVector, len = 40 },
		{ dir = -cf.RightVector, len = 40 },
		{ dir = -cf.LookVector, len = 30 },
	}
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	params.IgnoreWater = true
	local closestDist = math.huge
	local closestPos = nil
	local hit = false
	for _, c in ipairs(checks) do
		local result = Workspace:Raycast(origin, c.dir * c.len, params)
		if result and result.Instance then
			local cur = result.Instance
			for _ = 1, 12 do
				if not cur then break end
				if (cur.Name == "Tsunami" and cur.Parent and cur.Parent.Name == "TsunamiStage4")
					or cur.Name == "TsunamiStage4" then
					hit = true
					local d = (result.Position - origin).Magnitude
					if d < closestDist then
						closestDist = d
						closestPos = result.Position
					end
					break
				end
				cur = cur.Parent
			end
		end
	end
	return hit, closestPos, closestDist
end

local function isInFront(hrp, tPos)
	if not hrp or not tPos then return false end
	local toT = (tPos - hrp.Position)
	if toT.Magnitude < 0.1 then return true end
	return hrp.CFrame.LookVector:Dot(toT.Unit) > 0.15
end

function S.tsunamiDangerSpeed(hrp, baseSpeed)
	if not hrp then return baseSpeed, false end
	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local tPos = select(1, refreshTsunami())
	local hitRay, hitPos, rayDist = raycastTsunamiNear(hrp)

	local distToT = math.huge
	if tPos then distToT = (hrp.Position - tPos).Magnitude end
	if hitRay and rayDist then distToT = math.min(distToT, rayDist) end

	local inFront = isInFront(hrp, tPos) or (hitRay and hitPos and isInFront(hrp, hitPos))
	local approaching = F._tsunamiApproaching
	local danger = false

	if inFront and distToT <= 55 then
		danger = true
	elseif distToT <= 28 then
		danger = true
	elseif hitRay and rayDist <= 45 then
		danger = true
	end

	if not danger then
		return baseSpeed, false
	end

	-- Frente + acercandose: PARAR
	if inFront and (approaching or distToT < 35) then
		if distToT < 40 then
			F._tsunamiHoldUntil = now + 0.85
			return 0, true
		end
		return math.min(baseSpeed, 6), true
	end

	local safe = 18
	if distToT < 10 then
		safe = 0
		F._tsunamiHoldUntil = now + 0.5
	elseif distToT < 16 then
		safe = 6
	elseif distToT < 24 then
		safe = 12
	end
	return math.min(baseSpeed, safe), true
end

print("[Delta Hub] Tsunami avoidance v2 loaded")
