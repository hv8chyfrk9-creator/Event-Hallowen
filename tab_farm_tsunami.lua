-- tab_farm_tsunami.lua - TsunamiStage4.Tsunami avoidance
local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.Farm then return end
local F = S.Farm
local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")

F._tsunamiPos = nil
F._tsunamiObj = nil
F._lastTsunamiScan = 0

local function findTsunami()
	local root = Workspace:FindFirstChild("NPC & Piege")
	if not root then
		root = Workspace:FindFirstChild("NPC & Piege", true)
	end
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
	if now - (F._lastTsunamiScan or 0) < 1 then
		return F._tsunamiPos, F._tsunamiObj
	end
	F._lastTsunamiScan = now
	local t = findTsunami()
	F._tsunamiObj = t
	F._tsunamiPos = tsunamiWorldPos(t)
	return F._tsunamiPos, t
end

local function raycastTsunamiNear(hrp)
	if not hrp then return false, nil end
	local origin = hrp.Position
	local cf = hrp.CFrame
	local dirs = { cf.LookVector, -cf.LookVector, cf.RightVector, -cf.RightVector }
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	params.IgnoreWater = true
	for _, dir in ipairs(dirs) do
		local result = Workspace:Raycast(origin, dir * 30, params)
		if result and result.Instance then
			local cur = result.Instance
			for _ = 1, 10 do
				if not cur then break end
				if cur.Name == "Tsunami" and cur.Parent and cur.Parent.Name == "TsunamiStage4" then
					return true, result.Position
				end
				if cur.Name == "TsunamiStage4" then
					return true, result.Position
				end
				cur = cur.Parent
			end
		end
	end
	return false, nil
end

function S.tsunamiDangerSpeed(hrp, baseSpeed)
	local tPos = select(1, refreshTsunami())
	local hitRay, hitPos = raycastTsunamiNear(hrp)
	local danger = false
	local distToT = math.huge
	if tPos and hrp then
		distToT = (hrp.Position - tPos).Magnitude
		if distToT <= 30 then danger = true end
	end
	if hitRay then
		danger = true
		if hitPos and hrp then
			distToT = math.min(distToT, (hrp.Position - hitPos).Magnitude)
		end
	end
	if not danger then
		return baseSpeed, false
	end
	local safe = 20
	if distToT < 12 then
		safe = 8
	elseif distToT < 20 then
		safe = 14
	end
	return math.min(baseSpeed, safe), true
end

print("[Delta Hub] Tsunami avoidance loaded")
