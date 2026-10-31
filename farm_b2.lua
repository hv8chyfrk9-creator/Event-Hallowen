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

F.selectedTreadmill = F.selectedTreadmill or "Auto"
local treadNames = { "Auto", "Treadmill", "TreadmillGold", "TreadmillDiamond", "TreadmillCandy", "TreadmillAdmin" }
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
		local names
		if F.selectedTreadmill and F.selectedTreadmill ~= "Auto" then
			names = { F.selectedTreadmill }
		else
			names = { "TreadmillAdmin", "TreadmillCandy", "TreadmillDiamond", "TreadmillGold", "Treadmill" }
		end
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

setProgress(58, "Farm", "Cargando pestaña Player...")

task.spawn(function()
	local ok, body = pcall(function() return game:HttpGet(NEXT_URL) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] no tab_player")
		setProgress(62.5, "Error", "No se pudo cargar Player")
		return
	end
	local fn, err = loadstring(body)
	if not fn then warn("[Delta Hub] tab_player load", err) return end
	setProgress(62.5, "Farm", "Iniciando pestaña Player...")
	local okRun, runErr = pcall(fn)
	if not okRun then warn("[Delta Hub] tab_player run", runErr) end
end)

print("[Delta Hub] Farm listo")
