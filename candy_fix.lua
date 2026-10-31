-- candy_fix.lua: caja 100x100x100 + lista + BV entre items
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Events = S.Events or {}
local E = S.Events

if S._candyFixStarted then return end
S._candyFixStarted = true

local function objectPosition(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj.Position end
	local ok, piv = pcall(function() return obj:GetPivot() end)
	if ok and piv then return piv.Position end
	local p = obj:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

local function findCandyTargets()
	local list = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local n = string.lower(obj.Name or "")
		if string.find(n, "eventcoin", 1, true) then
			local plane = obj:FindFirstChild("Plane", true) or obj
			local pos = objectPosition(plane)
			if pos then
				list[#list + 1] = { obj = plane, pos = pos, id = tostring(plane:GetFullName()) }
			end
		end
	end
	return list
end

local function inBox(center, pos, half)
	local d = pos - center
	return math.abs(d.X) <= half and math.abs(d.Y) <= half and math.abs(d.Z) <= half
end

local function goBV(hrp, pos)
	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.Parent = hrp
	end
	local t0 = tick()
	while hrp.Parent and (hrp.Position - pos).Magnitude > 3 and tick() - t0 < 10 do
		bv.Velocity = (pos - hrp.Position).Unit * 90
		RunService.Heartbeat:Wait()
	end
	bv.Velocity = Vector3.zero
end

task.spawn(function()
	while true do
		task.wait(0.5)
		if not E.candy then continue end
		if S.Farm and S.Farm.routeRunning then continue end
		if E._candyBusy then continue end
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local all = findCandyTargets()
		if #all == 0 then continue end

		-- Prioridad: los de la caja 100x100x100 (half 50)
		local box, rest = {}, {}
		for _, it in ipairs(all) do
			if inBox(hrp.Position, it.pos, 50) then box[#box + 1] = it else rest[#rest + 1] = it end
		end
		local list = (#box > 0) and box or rest
		if #list == 0 then continue end

		E._candyBusy = true
		local returnPos = hrp.Position
		local seen = {}
		local i = 1
		while i <= #list do
			if not E.candy then break end
			if S.Farm and S.Farm.routeRunning then break end
			local it = list[i]
			if it and not seen[it.id] then
				seen[it.id] = true
				local pos = objectPosition(it.obj) or it.pos
				if pos then
					if i == 1 then
						hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
					else
						goBV(hrp, pos)
					end
					task.wait(0.5)
					hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if not hrp then break end
					-- re-scan caja
					for _, n in ipairs(findCandyTargets()) do
						if inBox(hrp.Position, n.pos, 50) and not seen[n.id] then
							list[#list + 1] = n
						end
					end
				end
			end
			i = i + 1
		end
		if hrp and returnPos then
			hrp.CFrame = CFrame.new(returnPos + Vector3.new(0, 3, 0))
		end
		E._candyBusy = false
	end
end)

print("[Delta Hub] candy_fix loaded")
