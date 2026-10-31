-- farm_b complete body (concat of b1a+b1b+b2); thin loader prefers b1a+b1b+b2
-- This file is fallback if split parts missing
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
	if not activeRoute or #activeRoute == 0 then notify("Sin CFrames") return false end
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
					if not bv then bv = Instance.new("BodyVelocity") bv.MaxForce = Vector3.new(1e5,1e5,1e5) bv.Parent = hrp end
				else return false end
			else return false end
		end
		if tick() - lastWbSearch >= 1 then
			lastWbSearch = tick()
			searchWinAndPickNearestCF()
			if i > targetRouteIndex then break end
		end
		local targetPos = activeRoute[i].Position
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
			if F._tsunamiSkipNext then F._tsunamiSkipNext = false break end
			if dist > 0.05 then bv.Velocity = (targetPos - hrp.Position).Unit * spd else bv.Velocity = Vector3.zero end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end
	if not winPos then winPos = select(1, findWinBlockPos(wbName)) end
	if winPos and hrp and F.routeRunning then
		F._winsBeforeClaim = (function()
			local ls = player:FindFirstChild("leaderstats")
			local w = ls and ls:FindFirstChild("Wins")
			return w and tonumber(w.Value) or 0
		end)()
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
				if not inBox and bv then bv.Velocity = (winPos - hrp.Position).Unit * 20
				elseif bv then bv.Velocity = Vector3.zero end
			end
			task.wait(0.1)
		end
		if bv then bv.Velocity = Vector3.zero end
		local function readWins()
			local ls = player:FindFirstChild("leaderstats")
			local w = ls and ls:FindFirstChild("Wins")
			if w then return tonumber(w.Value) or 0 end
			for _, d in ipairs(player:GetDescendants()) do
				if d.Name == "Wins" and (d:IsA("NumberValue") or d:IsA("IntValue") or d:IsA("StringValue")) then
					return tonumber(d.Value) or 0
				end
			end
			return 0
		end
		local winsBefore = F._winsBeforeClaim or readWins()
		local winsAfter = readWins()
		if winsAfter <= winsBefore then
			local sg = S.UI.ScreenGui or player:FindFirstChild("PlayerGui")
			if sg then
				local prompt = Instance.new("Frame")
				prompt.Name = "WinsClaimPrompt"
				prompt.Parent = sg
				prompt.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
				prompt.Position = UDim2.new(0.5, -140, 0.4, 0)
				prompt.Size = UDim2.new(0, 280, 0, 120)
				prompt.ZIndex = 50
				Instance.new("UICorner", prompt).CornerRadius = UDim.new(0, 8)
				local lab = Instance.new("TextLabel")
				lab.Parent = prompt
				lab.BackgroundTransparency = 1
				lab.Size = UDim2.new(1, -16, 0, 40)
				lab.Position = UDim2.new(0, 8, 0, 8)
				lab.Font = Enum.Font.GothamBold
				lab.Text = "Recibiste las wins?"
				lab.TextColor3 = Color3.fromRGB(255, 255, 255)
				lab.TextSize = 14
				lab.ZIndex = 51
				local answered = nil
				local yes = Instance.new("TextButton")
				yes.Parent = prompt
				yes.Size = UDim2.new(0.4, 0, 0, 32)
				yes.Position = UDim2.new(0.05, 0, 0, 60)
				yes.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
				yes.Text = "Si"
				yes.TextColor3 = Color3.fromRGB(255, 255, 255)
				yes.Font = Enum.Font.GothamBold
				yes.ZIndex = 51
				Instance.new("UICorner", yes).CornerRadius = UDim.new(0, 6)
				local no = Instance.new("TextButton")
				no.Parent = prompt
				no.Size = UDim2.new(0.4, 0, 0, 32)
				no.Position = UDim2.new(0.55, 0, 0, 60)
				no.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
				no.Text = "No"
				no.TextColor3 = Color3.fromRGB(255, 255, 255)
				no.Font = Enum.Font.GothamBold
				no.ZIndex = 51
				Instance.new("UICorner", no).CornerRadius = UDim.new(0, 6)
				yes.MouseButton1Click:Connect(function() answered = "yes" end)
				no.MouseButton1Click:Connect(function() answered = "no" end)
				local t0 = tick()
				while answered == nil and tick() - t0 < 12 do task.wait(0.1) end
				prompt:Destroy()
				if answered == "no" then
					local why = Instance.new("Frame")
					why.Parent = sg
					why.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
					why.Position = UDim2.new(0.5, -140, 0.4, 0)
					why.Size = UDim2.new(0, 280, 0, 130)
					why.ZIndex = 50
					Instance.new("UICorner", why).CornerRadius = UDim.new(0, 8)
					local wl = Instance.new("TextLabel")
					wl.Parent = why
					wl.BackgroundTransparency = 1
					wl.Size = UDim2.new(1, -16, 0, 30)
					wl.Position = UDim2.new(0, 8, 0, 8)
					wl.Font = Enum.Font.GothamBold
					wl.Text = "Por que?"
					wl.TextColor3 = Color3.fromRGB(255, 255, 255)
					wl.TextSize = 14
					wl.ZIndex = 51
					local reason = nil
					local b1 = Instance.new("TextButton")
					b1.Parent = why
					b1.Size = UDim2.new(0.9, 0, 0, 28)
					b1.Position = UDim2.new(0.05, 0, 0, 44)
					b1.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
					b1.Text = "Falta de nivel"
					b1.TextColor3 = Color3.fromRGB(255, 255, 255)
					b1.Font = Enum.Font.Gotham
					b1.ZIndex = 51
					Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 6)
					local b2 = Instance.new("TextButton")
					b2.Parent = why
					b2.Size = UDim2.new(0.9, 0, 0, 28)
					b2.Position = UDim2.new(0.05, 0, 0, 80)
					b2.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
					b2.Text = "Otro"
					b2.TextColor3 = Color3.fromRGB(255, 255, 255)
					b2.Font = Enum.Font.Gotham
					b2.ZIndex = 51
					Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 6)
					b1.MouseButton1Click:Connect(function() reason = "level" end)
					b2.MouseButton1Click:Connect(function() reason = "other" end)
					local t1 = tick()
					while reason == nil and tick() - t1 < 12 do task.wait(0.1) end
					why:Destroy()
					if reason == "level" then F._levelBlocked = true notify("Posible falta de nivel") end
				end
			end
		else
			F._levelBlocked = false
		end
	end
	if bv then bv:Destroy() end
	return true
end

startBtn.MouseButton1Click:Connect(function()
	if F.routeRunning then stopRoute() notify("Recorrido detenido") return end
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
	if F.autoRebirth then rebirthBtn.Text = "Auto Rebirth: ON" rebirthBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	else rebirthBtn.Text = "Auto Rebirth: OFF" rebirthBtn.TextColor3 = Color3.fromRGB(255, 100, 100) end
end)
F.selectedTreadmill = F.selectedTreadmill or "Auto"
local treadNames = { "Auto", "Treadmill", "TreadmillGold", "TreadmillDiamond", "TreadmillCandy", "TreadmillAdmin" }
local treadBtn = makeButton(autoBody, "Auto Treadmill: OFF", 2)
treadBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
treadBtn.MouseButton1Click:Connect(function()
	F.autoTreadmill = not F.autoTreadmill
	if F.autoTreadmill then treadBtn.Text = "Auto Treadmill: ON" treadBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	else treadBtn.Text = "Auto Treadmill: OFF" treadBtn.TextColor3 = Color3.fromRGB(255, 100, 100) end
end)
local treadPick = makeButton(autoBody, "  >  Caminadora: " .. F.selectedTreadmill, 3)
local treadList = Instance.new("Frame")
treadList.Parent = autoBody
treadList.BackgroundTransparency = 1
treadList.Size = UDim2.new(1, -10, 0, 0)
treadList.AutomaticSize = Enum.AutomaticSize.Y
treadList.Visible = false
treadList.LayoutOrder = 4
local treadLay = Instance.new("UIListLayout")
treadLay.Parent = treadList
treadLay.Padding = UDim.new(0, 4)
for i, nm in ipairs(treadNames) do
	local opt = Instance.new("TextButton")
	opt.Parent = treadList
	opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	opt.Size = UDim2.new(1, 0, 0, 26)
	opt.Font = Enum.Font.Gotham
	opt.Text = nm
	opt.TextColor3 = Color3.fromRGB(240, 240, 245)
	opt.TextSize = 12
	opt.LayoutOrder = i
	Instance.new("UICorner", opt).CornerRadius = UDim.new(0, 5)
	opt.MouseButton1Click:Connect(function()
		F.selectedTreadmill = nm
		treadPick.Text = "  >  Caminadora: " .. nm
		treadList.Visible = false
		notify("Caminadora: " .. nm)
	end)
end
treadPick.MouseButton1Click:Connect(function()
	treadList.Visible = not treadList.Visible
	treadPick.Text = (treadList.Visible and "  v  " or "  >  ") .. "Caminadora: " .. F.selectedTreadmill
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
		local names = (F.selectedTreadmill and F.selectedTreadmill ~= "Auto") and { F.selectedTreadmill } or { "TreadmillAdmin", "TreadmillCandy", "TreadmillDiamond", "TreadmillGold", "Treadmill" }
		local target = nil
		for _, nm in ipairs(names) do
			local obj = Workspace:FindFirstChild(nm, true)
			if obj then target = obj:FindFirstChild("Conveyor", true) or obj break end
		end
		if target then
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp and not F.routeRunning then
				local pos
				if target:IsA("BasePart") then pos = target.Position
				else local okp, piv = pcall(function() return target:GetPivot() end) pos = okp and piv and piv.Position end
				if pos then hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
			end
		end
	end
end)
setProgress(58, "Farm", "Cargando Player...")
task.spawn(function()
	local ok, body = pcall(function() return game:HttpGet(NEXT_URL) end)
	if not ok or type(body) ~= "string" or #body < 20 then warn("[Delta Hub] no tab_player") setProgress(62.5, "Error", "Falta tab_player") return end
	local fn, err = loadstring(body)
	if not fn then warn("[Delta Hub] tab_player load", err) return end
	setProgress(62.5, "Farm", "Entrando a Player...")
	local okRun, runErr = pcall(fn)
	if not okRun then warn("[Delta Hub] tab_player run", runErr) end
end)
print("[Delta Hub] Farm listo")
