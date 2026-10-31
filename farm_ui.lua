-- DELTA HUB farm_ui: UI + señales al cerebro (sin mover al jugador)
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
	return c
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
	main.Visible = false
	corner(main, 10)
	S.UI.MainFrame = main

	local top = Instance.new("Frame")
	top.Parent = main
	top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	top.Size = UDim2.new(1, 0, 0, 34)
	corner(top, 10)

	local title = Instance.new("TextLabel")
	title.Name = "SectionTitle"
	title.Parent = top
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 12, 0, 0)
	title.Size = UDim2.new(1, -90, 1, 0)
	title.Font = Enum.Font.GothamBold
	title.Text = "Farm"
	title.TextColor3 = Color3.fromRGB(240, 240, 245)
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	S.UI.SectionTitle = title

	local minBtn = Instance.new("TextButton")
	minBtn.Parent = top
	minBtn.BackgroundTransparency = 1
	minBtn.Position = UDim2.new(1, -34, 0, 0)
	minBtn.Size = UDim2.new(0, 34, 1, 0)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.Text = "-"
	minBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
	minBtn.TextSize = 16

	local side = Instance.new("Frame")
	side.Name = "Sidebar"
	side.Parent = sg
	side.BackgroundTransparency = 1
	side.Size = UDim2.new(0, 92, 0, 220)
	side.Position = UDim2.new(0.5, -310, 0.5, -100)
	side.Visible = false
	S.UI.Sidebar = side
	local sideLay = Instance.new("UIListLayout")
	sideLay.Parent = side
	sideLay.SortOrder = Enum.SortOrder.LayoutOrder
	sideLay.Padding = UDim.new(0, 20)

	local content = Instance.new("Frame")
	content.Name = "ContentArea"
	content.Parent = main
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 10, 0, 40)
	content.Size = UDim2.new(1, -20, 1, -50)
	S.UI.ContentArea = content
	S.UI.Content = content

	local logo = Instance.new("TextButton")
	logo.Name = "FloatingLogo"
	logo.Parent = sg
	logo.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	logo.Position = UDim2.new(0, 30, 0, 30)
	logo.Size = UDim2.new(0, 45, 0, 45)
	logo.Font = Enum.Font.GothamBold
	logo.Text = "HW"
	logo.TextColor3 = Color3.fromRGB(240, 240, 245)
	logo.TextSize = 15
	logo.Visible = false
	logo.Active = true
	logo.Draggable = true
	corner(logo, 99)
	S.UI.FloatingLogo = logo

	minBtn.MouseButton1Click:Connect(function()
		main.Visible = false
		side.Visible = false
		logo.Visible = true
	end)
	logo.MouseButton1Click:Connect(function()
		main.Visible = true
		side.Visible = true
		logo.Visible = false
	end)
end

local function createScrollingPage(parent)
	local sc = Instance.new("ScrollingFrame")
	sc.Parent = parent
	sc.BackgroundTransparency = 1
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.ScrollBarThickness = 4
	sc.Visible = false
	local lay = Instance.new("UIListLayout")
	lay.Parent = sc
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 8)
	local pad = Instance.new("UIPadding")
	pad.Parent = sc
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 8)
	return sc
end

local function makeTabButton(name, order)
	local b = Instance.new("TextButton")
	b.Parent = S.UI.Sidebar
	b.Size = UDim2.new(0, 92, 0, 42)
	b.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
	b.Font = Enum.Font.GothamBold
	b.Text = name
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.TextSize = 14
	b.LayoutOrder = order
	corner(b, 6)
	return b
end

local function section(parent, title, order)
	local wrap = Instance.new("Frame")
	wrap.Parent = parent
	wrap.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	wrap.BackgroundTransparency = 0.25
	wrap.Size = UDim2.new(1, -4, 0, 0)
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.LayoutOrder = order or 1
	corner(wrap, 8)
	local lay = Instance.new("UIListLayout")
	lay.Parent = wrap
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 6)
	local pad = Instance.new("UIPadding")
	pad.Parent = wrap
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	local head = Instance.new("TextLabel")
	head.Parent = wrap
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, 0, 0, 18)
	head.Font = Enum.Font.GothamBold
	head.Text = title
	head.TextColor3 = Color3.fromRGB(255, 255, 255)
	head.TextSize = 13
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.LayoutOrder = 0
	return wrap
end

local function makeButton(parent, text, order)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1, -4, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = order or 1
	corner(b, 6)
	return b
end

ensureHub()

local farmPage = createScrollingPage(S.UI.ContentArea)
farmPage.Visible = true
S.UI.FarmPage = farmPage
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Farm = farmPage

local function showOnlyPage(page, title)
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	if S.UI.ContentArea then
		for _, ch in ipairs(S.UI.ContentArea:GetChildren()) do
			if ch:IsA("ScrollingFrame") then ch.Visible = false end
		end
	end
	if page then page.Visible = true end
	if S.UI.SectionTitle and title then S.UI.SectionTitle.Text = title end
end
S.UI.showOnlyPage = showOnlyPage

local tabFarm = makeTabButton("Farm", 1)
tabFarm.MouseButton1Click:Connect(function()
	showOnlyPage(farmPage, "Farm")
end)

local winsBody = section(farmPage, "Wins", 1)
local blocks = S.orderedWinBlocks or { { real = "WinBlock1", display = "+1 Wins" } }
local winHead = makeButton(winsBody, "  >  WinBlock: " .. (F.selectedDisplayName or "+1 Wins"), 1)
local winList = Instance.new("Frame")
winList.Parent = winsBody
winList.BackgroundTransparency = 1
winList.Size = UDim2.new(1, -4, 0, 0)
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
speedBox.Size = UDim2.new(1, -4, 0, 28)
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
				else
					local okp, piv = pcall(function() return conv:GetPivot() end)
					pos = okp and piv and piv.Position
				end
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
