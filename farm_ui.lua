-- DELTA HUB farm_ui: pestaña Farm (solo UI + señales al cerebro)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.UI = S.UI or {}
S.Farm = S.Farm or {}
S.Signals = S.Signals or {}
local F = S.Farm

F.routeMode = F.routeMode or "normal"
F.routeSpeed = F.routeSpeed or 250
F.infinite = F.infinite or false
F.delayTime = F.delayTime or 0
F.selectedRealName = F.selectedRealName or "WinBlock1"
F.selectedDisplayName = F.selectedDisplayName or "+1 Wins"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
setProgress(54, "Farm", "Creando pestaña Farm...")

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = o
end

function F.notify(msg)
	pcall(function()
		local sg = S.UI.ScreenGui
		if not sg then return end
		local n = Instance.new("TextLabel")
		n.Parent = sg
		n.Size = UDim2.new(0, 220, 0, 28)
		n.Position = UDim2.new(0.5, -110, 0.12, 0)
		n.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		n.TextColor3 = Color3.fromRGB(240, 240, 245)
		n.Font = Enum.Font.Gotham
		n.TextSize = 12
		n.Text = tostring(msg)
		corner(n, 6)
		task.delay(2, function() pcall(function() n:Destroy() end) end)
	end)
end

local function ensureHub()
	if S.UI.ScreenGui and S.UI.ScreenGui.Parent then return end
	local sg = Instance.new("ScreenGui")
	sg.Name = "DeltaHubMinimal"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 999
	sg.Parent = playerGui
	S.UI.ScreenGui = sg

	local main = Instance.new("Frame")
	main.Name = "MainFrame"
	main.Parent = sg
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	main.BackgroundTransparency = 0.12
	main.Position = UDim2.new(0.5, -200, 0.5, -180)
	main.Size = UDim2.new(0, 400, 0, 360)
	main.Active = true
	main.Draggable = true
	corner(main, 10)
	S.UI.MainFrame = main

	local top = Instance.new("Frame")
	top.Parent = main
	top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	top.Size = UDim2.new(1, 0, 0, 34)
	corner(top, 10)

	local title = Instance.new("TextLabel")
	title.Parent = top
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.Font = Enum.Font.GothamBold
	title.Text = "Delta Hub"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left

	local minBtn = Instance.new("TextButton")
	minBtn.Parent = top
	minBtn.Size = UDim2.new(0, 34, 0, 24)
	minBtn.Position = UDim2.new(1, -40, 0.5, -12)
	minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	minBtn.Text = "_"
	minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 14
	corner(minBtn, 5)
	local minimized = false
	minBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			main.Size = UDim2.new(0, 400, 0, 34)
			if S.UI.Side then S.UI.Side.Visible = false end
			if S.UI.Content then S.UI.Content.Visible = false end
		else
			main.Size = UDim2.new(0, 400, 0, 360)
			if S.UI.Side then S.UI.Side.Visible = true end
			if S.UI.Content then S.UI.Content.Visible = true end
		end
	end)

	local side = Instance.new("Frame")
	side.Parent = main
	side.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	side.Position = UDim2.new(0, 0, 0, 34)
	side.Size = UDim2.new(0, 88, 1, -34)
	S.UI.Side = side
	local sideLay = Instance.new("UIListLayout")
	sideLay.Parent = side
	sideLay.Padding = UDim.new(0, 6)
	sideLay.SortOrder = Enum.SortOrder.LayoutOrder
	local pad = Instance.new("UIPadding")
	pad.Parent = side
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)

	local content = Instance.new("Frame")
	content.Parent = main
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 88, 0, 34)
	content.Size = UDim2.new(1, -88, 1, -34)
	S.UI.Content = content

	S.UI.pages = S.UI.pages or {}
	S.UI.tabBtns = S.UI.tabBtns or {}

	function S.UI.showPage(name)
		for n, p in pairs(S.UI.pages) do
			p.Visible = (n == name)
		end
		for n, b in pairs(S.UI.tabBtns) do
			b.BackgroundColor3 = (n == name) and Color3.fromRGB(50, 90, 140) or Color3.fromRGB(28, 28, 34)
		end
	end

	function S.UI.addTab(name, order)
		local btn = Instance.new("TextButton")
		btn.Parent = side
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(240, 240, 245)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.LayoutOrder = order or 1
		corner(btn, 6)
		S.UI.tabBtns[name] = btn

		local page = Instance.new("ScrollingFrame")
		page.Parent = content
		page.BackgroundTransparency = 1
		page.Size = UDim2.new(1, 0, 1, 0)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 4
		page.Visible = false
		local lay = Instance.new("UIListLayout")
		lay.Parent = page
		lay.Padding = UDim.new(0, 8)
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		local pp = Instance.new("UIPadding")
		pp.Parent = page
		pp.PaddingTop = UDim.new(0, 8)
		pp.PaddingLeft = UDim.new(0, 8)
		pp.PaddingRight = UDim.new(0, 8)
		S.UI.pages[name] = page

		btn.MouseButton1Click:Connect(function()
			S.UI.showPage(name)
		end)
		return page
	end
end

ensureHub()
local farmPage = S.UI.addTab("Farm", 1)
S.UI.showPage("Farm")
if S.UI.MainFrame then S.UI.MainFrame.Visible = true end

local function section(parent, title, order)
	local box = Instance.new("Frame")
	box.Parent = parent
	box.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	box.BackgroundTransparency = 0.2
	box.Size = UDim2.new(1, 0, 0, 0)
	box.AutomaticSize = Enum.AutomaticSize.Y
	box.LayoutOrder = order or 1
	corner(box, 8)
	local lay = Instance.new("UIListLayout")
	lay.Parent = box
	lay.Padding = UDim.new(0, 6)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	local pad = Instance.new("UIPadding")
	pad.Parent = box
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	local t = Instance.new("TextLabel")
	t.Parent = box
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, 0, 0, 18)
	t.Font = Enum.Font.GothamBold
	t.Text = title
	t.TextColor3 = Color3.fromRGB(200, 200, 210)
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.LayoutOrder = 0
	return box
end

local function makeButton(parent, text, order)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = order or 1
	corner(b, 6)
	return b
end

-- Wins
local winsBody = section(farmPage, "Wins", 1)
local blocks = S.orderedWinBlocks or { { real = "WinBlock1", display = "+1 Wins" } }
local winHead = makeButton(winsBody, "  >  WinBlock: " .. (F.selectedDisplayName or "+1 Wins"), 1)
local winList = Instance.new("Frame")
winList.Parent = winsBody
winList.BackgroundTransparency = 1
winList.Size = UDim2.new(1, 0, 0, 0)
winList.AutomaticSize = Enum.AutomaticSize.Y
winList.Visible = false
winList.LayoutOrder = 2
local winLay = Instance.new("UIListLayout")
winLay.Parent = winList
winLay.Padding = UDim.new(0, 4)
for i, info in ipairs(blocks) do
	local opt = makeButton(winList, info.display, i)
	opt.MouseButton1Click:Connect(function()
		F.selectedRealName = info.real
		F.selectedDisplayName = info.display
		winHead.Text = "  >  WinBlock: " .. info.display
		winList.Visible = false
		F.notify("Win: " .. info.display)
	end)
end
winHead.MouseButton1Click:Connect(function()
	winList.Visible = not winList.Visible
	winHead.Text = (winList.Visible and "  v  " or "  >  ") .. "WinBlock: " .. (F.selectedDisplayName or "?")
end)

local speedBox = Instance.new("TextBox")
speedBox.Parent = winsBody
speedBox.Size = UDim2.new(1, 0, 0, 28)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
speedBox.Text = tostring(F.routeSpeed or 250)
speedBox.PlaceholderText = "Velocidad (max 500)"
speedBox.TextColor3 = Color3.fromRGB(240, 240, 245)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.LayoutOrder = 3
corner(speedBox, 6)
speedBox.FocusLost:Connect(function()
	local n = tonumber(speedBox.Text)
	if n then F.routeSpeed = math.clamp(n, 1, 500) speedBox.Text = tostring(F.routeSpeed) end
end)

local modeBtn = makeButton(winsBody, "Modo: normal", 4)
local modes = { "normal", "fast", "ultra" }
local modeIdx = 1
modeBtn.MouseButton1Click:Connect(function()
	modeIdx = modeIdx % #modes + 1
	F.routeMode = modes[modeIdx]
	modeBtn.Text = "Modo: " .. F.routeMode
end)

local infBtn = makeButton(winsBody, "Recorrido infinito: OFF", 5)
infBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
infBtn.MouseButton1Click:Connect(function()
	F.infinite = not F.infinite
	if F.infinite then
		infBtn.Text = "Recorrido infinito: ON"
		infBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		infBtn.Text = "Recorrido infinito: OFF"
		infBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

local startBtn = makeButton(winsBody, "Iniciar Recorrido", 6)
startBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 50)
F.onRouteState = function(running)
	if running then
		startBtn.Text = "Detener Recorrido"
		startBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
	else
		startBtn.Text = "Iniciar Recorrido"
		startBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 50)
	end
end
startBtn.MouseButton1Click:Connect(function()
	local Brain = S.Brain
	if not Brain then F.notify("Cerebro no listo") return end
	if Brain.routeRunning then
		Brain.stopRoute(true)
		return
	end
	Brain.startRoute()
end)

-- Auto funciones (señales simples)
local autoBody = section(farmPage, "Auto funciones", 2)
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
		if S.Brain and S.Brain.routeRunning then continue end
		local names = { "TreadmillAdmin", "TreadmillCandy", "TreadmillDiamond", "TreadmillGold", "Treadmill" }
		for _, nm in ipairs(names) do
			local obj = workspace:FindFirstChild(nm, true)
			if obj then
				local conv = obj:FindFirstChild("Conveyor", true) or obj
				local pos
				if conv:IsA("BasePart") then pos = conv.Position
				else local okp, piv = pcall(function() return conv:GetPivot() end); pos = okp and piv and piv.Position end
				if pos and S.Brain and S.Brain.requestMove then
					S.Brain.requestMove({ pos = pos + Vector3.new(0, 3, 0), hold = 0.2 })
				end
				break
			end
		end
	end
end)

setProgress(57, "Farm", "Pestaña Farm lista")
print("[Delta Hub] farm_ui listo")
