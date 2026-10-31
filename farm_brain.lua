-- DELTA HUB farm_brain: unico dueño del movimiento
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

S.Farm = S.Farm or {}
S.Brain = S.Brain or {}
S.Signals = S.Signals or {}
local F = S.Farm
local B = S.Brain

B.busy = false
B.routeRunning = false
F.routeRunning = false
F.routeMode = F.routeMode or "normal"
F.routeSpeed = F.routeSpeed or 250
F.infinite = F.infinite or false
F.delayTime = F.delayTime or 0
F.selectedRealName = F.selectedRealName or "WinBlock1"

local function notify(msg)
	if S.Farm and S.Farm.notify then S.Farm.notify(msg) return end
	pcall(function() print("[Brain]", msg) end)
end

local function approachSpeed(distance, nextDist)
	local maxSpeed = tonumber(F.routeSpeed) or 250
	local mode = F.routeMode or "normal"
	local floorSpeed = 0
	if mode == "fast" then floorSpeed = 50
	elseif mode == "ultra" or mode == "super" then floorSpeed = 150 end
	local brake = 18
	if nextDist and nextDist < 12 then brake = 10 end
	if distance >= brake then return maxSpeed end
	local t = math.clamp(distance / brake, 0, 1)
	return math.max(maxSpeed * t * t, floorSpeed)
end

local function findWinBlockPos(wbName)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == wbName then
			if obj:IsA("BasePart") then return obj.Position, obj end
			local okp, piv = pcall(function() return obj:GetPivot() end)
			if okp and piv then return piv.Position, obj end
			local part = obj:FindFirstChildWhichIsA("BasePart", true)
			if part then return part.Position, obj end
		end
	end
	return nil, nil
end

local function clearBV(hrp)
	if not hrp then return end
	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if bv then bv:Destroy() end
	hrp.AssemblyLinearVelocity = Vector3.zero
end

function B.stopRoute(hard)
	F.routeRunning = false
	B.routeRunning = false
	B.busy = false
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	clearBV(hrp)
	if S.Signals.SetNoclip then S.Signals.SetNoclip(false) end
	if S.Farm and S.Farm.onRouteState then S.Farm.onRouteState(false) end
	if hard then notify("Recorrido detenido") end
end

local function runOneLap()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum or hum.Health <= 0 then return false end
	if S.Signals.SetNoclip then S.Signals.SetNoclip(true) end

	local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode))
	if not activeRoute or #activeRoute == 0 then activeRoute = S.routeCFrames end
	if not activeRoute or #activeRoute == 0 then notify("Sin CFrames") return false end

	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1250
		bv.Parent = hrp
	end
	hrp.CFrame = activeRoute[1]
	task.wait(0.12)

	local wbName = F.selectedRealName or "WinBlock1"
	local targetRouteIndex = #activeRoute
	local winPos = nil
	local lastWbSearch = 0

	local function searchWin()
		local pos = select(1, findWinBlockPos(wbName))
		if not pos then return end
		winPos = pos
		local bestI, bestD = 1, math.huge
		for ri = 1, #activeRoute do
			local d = (activeRoute[ri].Position - pos).Magnitude
			if d < bestD then bestD, bestI = d, ri end
		end
		targetRouteIndex = bestI
	end
	searchWin()

	for i = 2, #activeRoute do
		if not F.routeRunning then break end
		if i > targetRouteIndex then break end
		if hum.Health <= 0 then
			if S.waitAliveHrp then
				hrp = S.waitAliveHrp(activeRoute[math.max(1, i - 1)])
				hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hrp then
					bv = hrp:FindFirstChildOfClass("BodyVelocity")
					if not bv then
						bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bv.Parent = hrp
					end
				else
					return false
				end
			else
				return false
			end
		end
		if tick() - lastWbSearch >= 1 then
			lastWbSearch = tick()
			searchWin()
			if i > targetRouteIndex then break end
		end
		local targetPos = activeRoute[i].Position
		local guard = 0
		while hrp and hrp.Parent and (hrp.Position - targetPos).Magnitude > 2.5 and F.routeRunning and hum and hum.Health > 0 and guard < 600 do
			guard = guard + 1
			if tick() - lastWbSearch >= 1 then
				lastWbSearch = tick()
				searchWin()
				if i > targetRouteIndex then break end
			end
			local dist = (hrp.Position - targetPos).Magnitude
			local nextD = activeRoute[i + 1] and (activeRoute[i + 1].Position - targetPos).Magnitude
			local spd = approachSpeed(dist, nextD)
			if S.tsunamiDangerSpeed then spd = select(1, S.tsunamiDangerSpeed(hrp, spd)) end
			if F._tsunamiSkipNext then F._tsunamiSkipNext = false break end
			if dist > 0.05 then bv.Velocity = (targetPos - hrp.Position).Unit * spd else bv.Velocity = Vector3.zero end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	if not winPos then winPos = select(1, findWinBlockPos(wbName)) end
	if winPos and hrp and F.routeRunning then
		local t0 = tick()
		while hrp and hrp.Parent and (hrp.Position - winPos).Magnitude > 2 and tick() - t0 < 25 and F.routeRunning do
			if bv then bv.Velocity = (winPos - hrp.Position).Unit * 20 end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
		task.wait(1.2)
	end
	clearBV(hrp)
	if S.Signals.SetNoclip then S.Signals.SetNoclip(false) end
	return true
end

function B.startRoute()
	if B.routeRunning then return false end
	F.routeRunning = true
	B.routeRunning = true
	B.busy = true
	if S.Farm and S.Farm.onRouteState then S.Farm.onRouteState(true) end
	task.spawn(function()
		repeat
			runOneLap()
			if not F.routeRunning then break end
			if F.delayTime and F.delayTime > 0 then task.wait(F.delayTime) end
		until not F.infinite or not F.routeRunning
		B.stopRoute(false)
	end)
	return true
end

-- Otras pestañas piden movimiento
function B.requestMove(opts)
	opts = opts or {}
	if B.routeRunning then
		if F.infinite then
			B._queuedMove = opts
			return false, "route_infinite_queue"
		end
		return false, "route_busy"
	end
	B.busy = true
	task.spawn(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and opts.cf then
			hrp.CFrame = opts.cf
		elseif hrp and opts.pos then
			hrp.CFrame = CFrame.new(opts.pos)
		end
		task.wait(opts.hold or 0.3)
		B.busy = false
		if B._queuedMove and not B.routeRunning then
			local q = B._queuedMove
			B._queuedMove = nil
			B.requestMove(q)
		end
	end)
	return true, "ok"
end

function B.isBusy()
	return B.busy or B.routeRunning
end

-- Tsunami opcional
task.spawn(function()
	local base = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
	local ok, body = pcall(function() return game:HttpGet(base .. "tab_farm_tsunami.lua") end)
	if ok and type(body) == "string" and #body > 50 and not body:find("<!DOCTYPE") then
		local fn = loadstring(body)
		if fn then pcall(fn) end
	end
end)

S.log = S.log or function() end
if S.log then S.log("Cerebro listo", "OK") end
print("[Delta Hub] farm_brain listo")
