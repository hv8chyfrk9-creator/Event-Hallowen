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

local function runOneLap()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum or hum.Health <= 0 then return false end
	if S.Signals.SetNoclip then S.Signals.SetNoclip(true) end

	local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode))
	if not activeRoute or #activeRoute == 0 then activeRoute = S.routeCFrames end
	if not activeRoute or #activeRoute == 0 then
		notify("Sin CFrames")
		return false
	end

	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1250
		bv.Parent = hrp
	end

	hrp.CFrame = activeRoute[1]
	task.wait(0.15)

	local wbName = F.selectedRealName or "WinBlock1"
	local targetRouteIndex = #activeRoute
	local winPos = nil
	local lastWbSearch = 0

	local function searchWinAndPickNearestCF()
		local pos = select(1, findWinBlockPos(wbName))
		if not pos then return end
		winPos = pos
		local bestI, bestD = 1, math.huge
		for ri = 1, #activeRoute do
			local d = (activeRoute[ri].Position - pos).Magnitude
			if d < bestD then bestD, bestI = d, ri end
		end
		if bestI >= 1 then targetRouteIndex = bestI end
	end

	searchWinAndPickNearestCF()

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
			searchWinAndPickNearestCF()
			if i > targetRouteIndex then break end
		end

		local target = activeRoute[i]
		local targetPos = target.Position
		local guard = 0
		while hrp and hrp.Parent and (hrp.Position - targetPos).Magnitude > 2.5 and F.routeRunning and hum and hum.Health > 0 and guard < 600 do
			guard = guard + 1
			if tick() - lastWbSearch >= 1 then
				lastWbSearch = tick()
				searchWinAndPickNearestCF()
				if i > targetRouteIndex then break end
			end
			local dist = (hrp.Position - targetPos).Magnitude
			local nextD = activeRoute[i + 1] and (activeRoute[i + 1].Position - targetPos).Magnitude
			local spd = approachSpeed(dist, nextD)
			if S.tsunamiDangerSpeed then spd = select(1, S.tsunamiDangerSpeed(hrp, spd)) end
			if dist > 0.05 then
				bv.Velocity = (targetPos - hrp.Position).Unit * spd
			else
				bv.Velocity = Vector3.zero
			end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	if not winPos then winPos = select(1, findWinBlockPos(wbName)) end
	if winPos and hrp and F.routeRunning then
		local t0 = tick()
		while hrp and hrp.Parent and (hrp.Position - winPos).Magnitude > 2 and tick() - t0 < 30 and F.routeRunning do
			if bv then bv.Velocity = (winPos - hrp.Position).Unit * 20 end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
		F._lastWinPos = winPos
		notify("WinBlock tocado")
		local waitStart = tick()
		while tick() - waitStart < 2 and F.routeRunning do
			if hrp and hrp.Parent then
				local p = hrp.Position
				local inBox = math.abs(p.X - winPos.X) <= 5 and math.abs(p.Y - winPos.Y) <= 5 and math.abs(p.Z - winPos.Z) <= 5
				if not inBox and bv then
					bv.Velocity = (winPos - hrp.Position).Unit * 20
				elseif bv then
					bv.Velocity = Vector3.zero
				end
			end
			task.wait(0.1)
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	if bv then bv:Destroy() end
	return true
end

startBtn.MouseButton1Click:Connect(function()
	if F.routeRunning then
		stopRoute()
		notify("Recorrido detenido")
		return
	end
	F.routeRunning = true
	startBtn.Text = "Detener Recorrido"
	startBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
	task.spawn(function()
		repeat
			local ok = runOneLap()
			if not F.routeRunning then break end
			if F.delayTime and F.delayTime > 0 then task.wait(F.delayTime) end
		until not F.infinite or not F.routeRunning
		stopRoute()
	end)
end)

local autoBody = section(farmPage, "Auto funciones", 2)
F.autoRebirth = F.autoRebirth or false
F.autoTreadmill = F.autoTreadmill or false

local rebirthBtn = makeButton(autoBody, "Auto Rebirth: OFF", 1)
rebirthBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
rebirthBtn.MouseButton1Click:Connect(function()
	F.autoRebirth = not F.autoRebirth
	if F.autoRebirth then
		rebirthBtn.Text = "Auto Rebirth: ON"
		rebirthBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		rebirthBtn.Text = "Auto Rebirth: OFF"
		rebirthBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

local treadBtn = makeButton(autoBody, "Auto Treadmill: OFF", 2)
treadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
treadBtn.MouseButton1Click:Connect(function()
	F.autoTreadmill = not F.autoTreadmill
	if F.autoTreadmill then
		treadBtn.Text = "Auto Treadmill: ON"
		treadBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		treadBtn.Text = "Auto Treadmill: OFF"
		treadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

task.spawn(function()
	while true do
		task.wait(1.5)
		if F.autoRebirth then
			pcall(function()
				local ev = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
				ev = ev and ev:FindFirstChild("Rebirth")
				if ev then ev:FireServer() end
			end)
		end
	end
end)

task.spawn(function()
	while true do
		task.wait(2)
		if not F.autoTreadmill then continue end
		local names = { "TreadmillAdmin", "TreadmillCandy", "TreadmillDiamond", "TreadmillGold", "Treadmill" }
		local target = nil
		for _, nm in ipairs(names) do
			local obj = Workspace:FindFirstChild(nm, true)
			if obj then
				local conv = obj:FindFirstChild("Conveyor", true) or obj
				target = conv
				break
			end
		end
		if target then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and not F.routeRunning then
				local pos
				if target:IsA("BasePart") then pos = target.Position
				else
					local okp, piv = pcall(function() return target:GetPivot() end)
					pos = okp and piv and piv.Position
				end
				if pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
			end
		end
	end
end)

setProgress(58, "Farm", "Cargando Player...")

task.spawn(function()
	local ok, body = pcall(function() return game:HttpGet(NEXT_URL) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] no tab_player")
		setProgress(62.5, "Error", "Falta tab_player")
		return
	end
	local fn, err = loadstring(body)
	if not fn then warn("[Delta Hub] tab_player load", err) return end
	setProgress(62.5, "Farm", "Entrando a Player...")
	local okRun, runErr = pcall(fn)
	if not okRun then warn("[Delta Hub] tab_player run", runErr) end
end)

print("[Delta Hub] Farm listo")
