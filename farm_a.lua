-- ==========================================
-- DELTA HUB - Event Hallowen - farm_a (UI)
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	warn("[Delta Hub] tab_farm: falta init")
	return
end

S.UI = S.UI or {}
S.Farm = S.Farm or {}
S.Signals = S.Signals or {}
local F = S.Farm
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local NEXT_URL = BASE .. "tab_player.lua"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

setProgress(51, "Farm", "Creando interfaz...")

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
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
	side.Size = UDim2.new(0, 92, 0, 200)
	side.Position = UDim2.new(0.5, -310, 0.5, -100)
	side.Visible = false
	S.UI.Sidebar = side
	local sideLay = Instance.new("UIListLayout")
	sideLay.Parent = side
	sideLay.SortOrder = Enum.SortOrder.LayoutOrder
	sideLay.Padding = UDim.new(0, 26)
	local content = Instance.new("Frame")
	content.Name = "ContentArea"
	content.Parent = main
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 10, 0, 40)
	content.Size = UDim2.new(1, -20, 1, -50)
	S.UI.ContentArea = content
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
		main.Visible = false; side.Visible = false; logo.Visible = true
	end)
	logo.MouseButton1Click:Connect(function()
		main.Visible = true; side.Visible = true; logo.Visible = false
	end)
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
	return sc
end

ensureHub()
setProgress(53, "Farm", "Pestana Farm...")

local farmPage = createScrollingPage(S.UI.ContentArea)
farmPage.Visible = true
S.UI.FarmPage = farmPage
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Farm = farmPage

local tabFarm = makeTabButton("Farm", 1)
S.UI.TabFarm = tabFarm
tabFarm.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	farmPage.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Farm" end
end)

F.selectedRealName = F.selectedRealName or "WinBlock1"
F.selectedDisplayName = F.selectedDisplayName or "+1 Wins"
F.gameSpeed = F.gameSpeed or 250
F.routeMode = F.routeMode or "normal"
F.delayTime = F.delayTime or 0
F.infinite = F.infinite or false
F.routeRunning = false

local function notify(text)
	local sg = S.UI.ScreenGui
	if not sg then return end
	local old = sg:FindFirstChild("DeltaNotification")
	if old then old:Destroy() end
	local n = Instance.new("TextLabel")
	n.Name = "DeltaNotification"
	n.Parent = sg
	n.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	n.Position = UDim2.new(0.5, -150, 0, 50)
	n.Size = UDim2.new(0, 300, 0, 34)
	n.Font = Enum.Font.GothamBold
	n.Text = text
	n.TextColor3 = Color3.fromRGB(100, 255, 100)
	n.TextSize = 12
	corner(n, 6)
	task.delay(3, function() if n then n:Destroy() end end)
end
S.notify = S.notify or notify

local function section(parent, title, order)
	local wrap = Instance.new("Frame")
	wrap.Parent = parent
	wrap.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	wrap.BackgroundTransparency = 0.25
	wrap.Size = UDim2.new(1, -8, 0, 0)
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
	head.Size = UDim2.new(1, 0, 0, 20)
	head.Font = Enum.Font.GothamBold
	head.Text = title
	head.TextColor3 = Color3.fromRGB(255, 255, 255)
	head.TextSize = 13
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.LayoutOrder = 0
	return wrap
end

local function makeButton(parent, text, order, bg)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.BackgroundColor3 = bg or Color3.fromRGB(28, 28, 34)
	b.Size = UDim2.new(1, -10, 0, 32)
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.TextSize = 12
	b.LayoutOrder = order or 1
	corner(b, 6)
	return b
end

local function makeBox(parent, placeholder, text, order)
	local t = Instance.new("TextBox")
	t.Parent = parent
	t.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	t.Size = UDim2.new(1, -10, 0, 32)
	t.Font = Enum.Font.Gotham
	t.PlaceholderText = placeholder
	t.Text = text or ""
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
	t.TextSize = 13
	t.LayoutOrder = order or 1
	corner(t, 6)
	return t
end

setProgress(55, "Farm", "Controles...")

local winsBody = section(farmPage, "Wins", 1)
local winHead = Instance.new("TextButton")
winHead.Parent = winsBody
winHead.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
winHead.Size = UDim2.new(1, -4, 0, 32)
winHead.Font = Enum.Font.GothamBold
winHead.Text = "  >  WinBlock: " .. F.selectedDisplayName
winHead.TextXAlignment = Enum.TextXAlignment.Left
winHead.TextColor3 = Color3.fromRGB(240, 240, 245)
winHead.TextSize = 13
winHead.LayoutOrder = 1
corner(winHead, 6)

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
winLay.SortOrder = Enum.SortOrder.LayoutOrder

for _, info in ipairs(S.orderedWinBlocks or {}) do
	local opt = Instance.new("TextButton")
	opt.Parent = winList
	opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	opt.Size = UDim2.new(1, 0, 0, 28)
	opt.Font = Enum.Font.Gotham
	opt.Text = info.display
	opt.TextColor3 = Color3.fromRGB(240, 240, 245)
	opt.TextSize = 12
	opt.LayoutOrder = info.order
	corner(opt, 4)
	opt.MouseButton1Click:Connect(function()
		F.selectedRealName = info.real
		F.selectedDisplayName = info.display
		winHead.Text = "  >  WinBlock: " .. info.display
		winList.Visible = false
		notify("Win: " .. info.display)
	end)
end

winHead.MouseButton1Click:Connect(function()
	winList.Visible = not winList.Visible
	winHead.Text = (winList.Visible and "  v  " or "  >  ") .. "WinBlock: " .. F.selectedDisplayName
end)

local speedBox = makeBox(winsBody, "Velocidad (1-500)", tostring(F.gameSpeed), 3)
speedBox.FocusLost:Connect(function()
	F.gameSpeed = math.clamp(tonumber(speedBox.Text) or 250, 1, 500)
	speedBox.Text = tostring(F.gameSpeed)
end)

local modeBtn = makeButton(winsBody, "Recorrido: Normal", 4)
modeBtn.MouseButton1Click:Connect(function()
	if F.routeMode == "normal" then
		F.routeMode = "fast"
		modeBtn.Text = "Recorrido: Rapido"
	elseif F.routeMode == "fast" then
		F.routeMode = "ultra"
		modeBtn.Text = "Recorrido: Ultra rapido"
	else
		F.routeMode = "normal"
		modeBtn.Text = "Recorrido: Normal"
	end
end)

local infBtn = makeButton(winsBody, "Recorrido Infinito: OFF", 5)
infBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
infBtn.MouseButton1Click:Connect(function()
	F.infinite = not F.infinite
	if F.infinite then
		infBtn.Text = "Recorrido Infinito: ON"
		infBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
	else
		infBtn.Text = "Recorrido Infinito: OFF"
		infBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	end
end)

local startBtn = makeButton(winsBody, "Iniciar Recorrido", 6, Color3.fromRGB(40, 90, 50))
S.UI.StartRouteBtn = startBtn

local function approachSpeed(distance, nextDistance)
	local maxSpeed = math.clamp(F.gameSpeed or 250, 1, 500)
	local brake, floorSpeed = 10, 12
	if F.routeMode == "fast" then
		brake, floorSpeed = 8, 50
	elseif F.routeMode == "ultra" or F.routeMode == "super" then
		brake, floorSpeed = 5, 150
	end
	if distance >= brake then return maxSpeed end
	local t = math.clamp(distance / brake, 0, 1)
	return math.max(maxSpeed * t * t, floorSpeed)
end

task.spawn(function()
	local url = BASE .. "tab_farm_tsunami.lua"
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" and #body > 50 and not body:find("<!DOCTYPE") then
		local fn = loadstring(body)
		if fn then pcall(fn) end
	end
end)

local function stopRoute()
	F.routeRunning = false
	startBtn.Text = "Iniciar Recorrido"
	startBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 50)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local bv = hrp:FindFirstChildOfClass("BodyVelocity")
		if bv then bv:Destroy() end
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
	if S.Signals.SetNoclip then S.Signals.SetNoclip(false) end
end
