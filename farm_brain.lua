-- DELTA HUB farm_brain Halloween
-- Sin hitbox de meta · 1.2s tras último CF · reinicio si infinito
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

B.pendingEvent = nil
B._lastLapDied = false
B._noclipOn = false

local NOCLIP_AFTER_CF = 16
local POST_ROUTE_WAIT = 1.2 -- tras último CF / win (silencioso)

pcall(function()
	local folder = Workspace:FindFirstChild("DeltaHubHWHitbox")
	if folder then folder:Destroy() end
end)

local function notify(msg)
	if S.Farm and S.Farm.notify then S.Farm.notify(msg) return end
	pcall(function() print("[Brain]", msg) end)
end

local function setNoclip(on)
	if B._noclipOn == on then return end
	B._noclipOn = on
	if S.Signals.SetNoclip then S.Signals.SetNoclip(on) end
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
	F._forceHoldPos = nil
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	clearBV(hrp)
	setNoclip(false)
	if S.Farm and S.Farm.onRouteState then S.Farm.onRouteState(false) end
	if hard then notify("Recorrido detenido") end
end

function B.reportFoundEvent(data)
	if type(data) ~= "table" then return end
	if not data.pos and data.cf then data.pos = data.cf.Position end
	if not data.pos then return end
	B.pendingEvent = data
	notify("Evento guardado para después del recorrido")
end

local function goCollectPending()
	local pend = B.pendingEvent
	B.pendingEvent = nil
	if not pend or not pend.pos then return false end
	local stillThere = true
	if pend.obj and pend.obj.Parent == nil then stillThere = false end
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	local returnCf = hrp.CFrame
	pcall(function()
		hrp.CFrame = CFrame.new(pend.pos + Vector3.new(0, 3, 0))
		hrp.AssemblyLinearVelocity = Vector3.zero
	end)
	task.wait(0.25)
	if pend.obj and pend.obj.Parent == nil then stillThere = false end
	if not stillThere then
		pcall(function() hrp.CFrame = returnCf end)
		notify("Evento ya no está, se omite")
		return false
	end
	task.wait(0.6)
	notify("Evento recogido")
	return true
end

local function runOneLap()
	B._lastLapDied = false
	B._noclipOn = false
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum or hum.Health <= 0 then
		B._lastLapDied = true
		return false
	end
	setNoclip(false)

	local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode))
	if not activeRoute or #activeRoute == 0 then activeRoute = S.routeCFrames end
	if not activeRoute or #activeRoute == 0 then notify("Sin CFrames") return false end

	local startCf = activeRoute[1]

	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1250
		bv.Parent = hrp
	end

	hrp.CFrame = startCf
	hrp.AssemblyLinearVelocity = Vector3.zero
	task.wait(1)
	if not F.routeRunning then return false end
	hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then
		B._lastLapDied = true
		return false
	end
	bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1250
		bv.Parent = hrp
	end

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

		if i > NOCLIP_AFTER_CF then
			setNoclip(true)
		else
			setNoclip(false)
		end

		hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			B._lastLapDied = true
			clearBV(hrp)
			setNoclip(false)
			notify("Muerte: recorrido terminado")
			return false
		end
		hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then B._lastLapDied = true; return false end

		if tick() - lastWbSearch >= 1 then
			lastWbSearch = tick()
			searchWin()
			if i > targetRouteIndex then break end
		end

		local targetPos = activeRoute[i].Position
		F._nextRoutePos = targetPos
		local guard = 0
		while hrp and hrp.Parent and F.routeRunning and guard < 1200 do
			guard = guard + 1
			hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				B._lastLapDied = true
				clearBV(hrp)
				setNoclip(false)
				notify("Muerte: recorrido terminado")
				return false
			end
			hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then B._lastLapDied = true; return false end

			local aimPos = targetPos
			if F._forceHoldPos then
				aimPos = F._forceHoldPos
			end

			local dist = (hrp.Position - aimPos).Magnitude
			if not F._forceHoldPos and dist <= 2.5 then break end

			if tick() - lastWbSearch >= 1 then
				lastWbSearch = tick()
				searchWin()
				if i > targetRouteIndex and not F._forceHoldPos then break end
			end

			local nextD = activeRoute[i + 1] and (activeRoute[i + 1].Position - targetPos).Magnitude
			local spd = approachSpeed(dist, nextD)
			F._nextRoutePos = aimPos

			if S.tsunamiDangerSpeed then
				spd = select(1, S.tsunamiDangerSpeed(hrp, spd, targetPos))
			end
			if F._forceHoldPos then
				aimPos = F._forceHoldPos
				dist = (hrp.Position - aimPos).Magnitude
			end
			if F._tsunamiSkipNext then
				F._tsunamiSkipNext = false
				break
			end

			if not bv or not bv.Parent then
				bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Parent = hrp
			end
			if dist > 0.05 and spd > 0.5 then
				bv.Velocity = (aimPos - hrp.Position).Unit * spd
			else
				bv.Velocity = Vector3.zero
			end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	setNoclip(true)

	if not winPos then winPos = select(1, findWinBlockPos(wbName)) end
	if winPos and hrp and F.routeRunning then
		local t0 = tick()
		while hrp and hrp.Parent and (hrp.Position - winPos).Magnitude > 3 and tick() - t0 < 6 and F.routeRunning do
			hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				B._lastLapDied = true
				clearBV(hrp)
				setNoclip(false)
				return false
			end
			if not bv or not bv.Parent then
				bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Parent = hrp
			end
			local d = (winPos - hrp.Position).Magnitude
			local spd = math.clamp(d * 2, 40, tonumber(F.routeSpeed) or 200)
			bv.Velocity = (winPos - hrp.Position).Unit * spd
			RunService.Heartbeat:Wait()
			hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	clearBV(hrp)
	setNoclip(false)

	-- espera post-ruta (sin aviso al jugador)
	if F.routeRunning then
		local tWait = tick()
		while F.routeRunning and tick() - tWait < POST_ROUTE_WAIT do
			hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				B._lastLapDied = true
				return false
			end
			task.wait(0.1)
		end
	end

	return true
end

function B.startRoute()
	if B.routeRunning then return false end
	F.routeRunning = true
	B.routeRunning = true
	B.busy = true
	B._lastLapDied = false
	F._forceHoldPos = nil
	if S.Farm and S.Farm.onRouteState then S.Farm.onRouteState(true) end
	task.spawn(function()
		repeat
			runOneLap()
			if not F.routeRunning then break end
			if B._lastLapDied then
				if F.infinite then
					notify("Muerte: reiniciando recorrido infinito...")
					local t0 = tick()
					while tick() - t0 < 8 do
						local c = player.Character
						local h = c and c:FindFirstChildOfClass("Humanoid")
						if h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") then break end
						task.wait(0.2)
					end
					task.wait(0.4)
				else
					break
				end
			else
				if B.pendingEvent then goCollectPending() end
				if F.infinite and F.delayTime and F.delayTime > 0 then
					task.wait(F.delayTime)
				end
			end
		until not F.infinite or not F.routeRunning
		B.stopRoute(false)
	end)
	return true
end

function B.requestMove(opts)
	opts = opts or {}
	if B.routeRunning then
		if F.infinite then B._queuedMove = opts; return false, "route_infinite_queue" end
		return false, "route_busy"
	end
	B.busy = true
	task.spawn(function()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and opts.cf then hrp.CFrame = opts.cf
		elseif hrp and opts.pos then hrp.CFrame = CFrame.new(opts.pos) end
		task.wait(opts.hold or 0.3)
		B.busy = false
		if B._queuedMove and not B.routeRunning then
			local q = B._queuedMove; B._queuedMove = nil; B.requestMove(q)
		end
	end)
	return true, "ok"
end

function B.isBusy()
	return B.busy or B.routeRunning
end

task.spawn(function()
	local base = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
	local ok, body = pcall(function() return game:HttpGet(base .. "tab_farm_tsunami.lua") end)
	if ok and type(body) == "string" and #body > 50 then
		local head = string.lower(string.sub(body, 1, 80))
		if not string.find(head, "<html", 1, true) then
			local fn = loadstring(body)
			if fn then pcall(fn) end
		end
	end
end)

print("[Delta Hub] farm_brain listo (sin hitbox · 1.2s post-ruta)")
