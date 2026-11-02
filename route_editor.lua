-- Delta Hub · Route Editor (compacto, arrastrable, min/max)
-- Usa S.routeCFrames / S.routeModes / S.Brain si existen

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local S = getgenv().DeltaHub
if type(S) ~= "table" then S = {}; getgenv().DeltaHub = S end
S.routeCFrames = S.routeCFrames or {}
S.routeModes = S.routeModes or {}
S.Farm = S.Farm or {}

local F = S.Farm
F.routeMode = F.routeMode or "normal"
F.routeSpeed = F.routeSpeed or 250
F.selectedRealName = F.selectedRealName or "WinBlock1"
F.selectedDisplayName = F.selectedDisplayName or "+1 Wins"

local old = pg:FindFirstChild("DeltaRouteEditor")
if old then old:Destroy() end

local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = o
	return c
end

local sg = Instance.new("ScreenGui")
sg.Name = "DeltaRouteEditor"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 1200
sg.Parent = pg

local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = sg
main.Size = UDim2.new(0, 280, 0, 340)
main.Position = UDim2.new(0.5, -140, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
main.BackgroundTransparency = 0.08
main.Active = true
main.Draggable = true
corner(main, 10)

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1, 0, 0, 32)
top.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
corner(top, 10)

local title = Instance.new("TextLabel")
title.Parent = top
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Route Editor"
title.TextColor3 = Color3.fromRGB(240, 240, 245)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton")
minBtn.Parent = top
minBtn.Size = UDim2.new(0, 32, 1, 0)
minBtn.Position = UDim2.new(1, -34, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.Font = Enum.Font.GothamBold
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
minBtn.TextSize = 16

local logo = Instance.new("TextButton")
logo.Parent = sg
logo.Size = UDim2.new(0, 44, 0, 44)
logo.Position = UDim2.new(0, 24, 0, 24)
logo.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
logo.Font = Enum.Font.GothamBold
logo.Text = "RE"
logo.TextColor3 = Color3.fromRGB(240, 240, 245)
logo.TextSize = 14
logo.Visible = false
logo.Active = true
logo.Draggable = true
corner(logo, 99)

minBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	logo.Visible = true
end)
logo.MouseButton1Click:Connect(function()
	main.Visible = true
	logo.Visible = false
end)

-- Tabs
local tabBar = Instance.new("Frame")
tabBar.Parent = main
tabBar.BackgroundTransparency = 1
tabBar.Size = UDim2.new(1, -12, 0, 28)
tabBar.Position = UDim2.new(0, 6, 0, 36)
local tabLay = Instance.new("UIListLayout")
tabLay.Parent = tabBar
tabLay.FillDirection = Enum.FillDirection.Horizontal
tabLay.Padding = UDim.new(0, 4)

local pages = {}
local function makeTab(name, order)
	local b = Instance.new("TextButton")
	b.Parent = tabBar
	b.Size = UDim2.new(0, 84, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	b.Font = Enum.Font.GothamBold
	b.Text = name
	b.TextColor3 = Color3.fromRGB(230, 230, 240)
	b.TextSize = 11
	b.LayoutOrder = order
	corner(b, 6)
	local page = Instance.new("ScrollingFrame")
	page.Parent = main
	page.BackgroundTransparency = 1
	page.Size = UDim2.new(1, -12, 1, -72)
	page.Position = UDim2.new(0, 6, 0, 68)
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.ScrollBarThickness = 3
	page.Visible = false
	local lay = Instance.new("UIListLayout")
	lay.Parent = page
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 6)
	pages[name] = page
	b.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		page.Visible = true
		for _, ch in ipairs(tabBar:GetChildren()) do
			if ch:IsA("TextButton") then ch.BackgroundColor3 = Color3.fromRGB(40, 40, 48) end
		end
		b.BackgroundColor3 = Color3.fromRGB(170, 45, 45)
	end)
	return b, page
end

local function label(parent, text, order)
	local l = Instance.new("TextLabel")
	l.Parent = parent
	l.BackgroundTransparency = 1
	l.Size = UDim2.new(1, 0, 0, 16)
	l.Font = Enum.Font.GothamBold
	l.Text = text
	l.TextColor3 = Color3.fromRGB(200, 200, 210)
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.LayoutOrder = order
	return l
end

local function box(parent, placeholder, order)
	local t = Instance.new("TextBox")
	t.Parent = parent
	t.Size = UDim2.new(1, 0, 0, 28)
	t.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	t.PlaceholderText = placeholder
	t.Text = ""
	t.TextColor3 = Color3.fromRGB(240, 240, 245)
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.ClearTextOnFocus = false
	t.LayoutOrder = order
	corner(t, 6)
	return t
end

local function btn(parent, text, order, color)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = color or Color3.fromRGB(40, 40, 50)
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.TextColor3 = Color3.fromRGB(245, 245, 250)
	b.TextSize = 12
	b.LayoutOrder = order
	corner(b, 6)
	return b
end

local function notify(msg)
	pcall(function()
		local n = Instance.new("TextLabel")
		n.Parent = sg
		n.Size = UDim2.new(0, 200, 0, 26)
		n.Position = UDim2.new(0.5, -100, 0.1, 0)
		n.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		n.Text = tostring(msg)
		n.TextColor3 = Color3.fromRGB(240, 240, 245)
		n.Font = Enum.Font.Gotham
		n.TextSize = 11
		corner(n, 6)
		task.delay(2, function() pcall(function() n:Destroy() end) end)
	end)
end

-- ===== TAB FRAMES =====
local tabF, pageF = makeTab("Frames", 1)
label(pageF, "Nº de CFrame (1..N)", 1)
local idxBox = box(pageF, "ej: 14", 2)
local infoLbl = Instance.new("TextLabel")
infoLbl.Parent = pageF
infoLbl.BackgroundTransparency = 1
infoLbl.Size = UDim2.new(1, 0, 0, 36)
infoLbl.Font = Enum.Font.Code
infoLbl.Text = "Sin frame cargado"
infoLbl.TextColor3 = Color3.fromRGB(160, 180, 160)
infoLbl.TextSize = 10
infoLbl.TextWrapped = true
infoLbl.TextXAlignment = Enum.TextXAlignment.Left
infoLbl.LayoutOrder = 3

label(pageF, "X / Y / Z", 4)
local xBox = box(pageF, "X", 5)
local yBox = box(pageF, "Y", 6)
local zBox = box(pageF, "Z", 7)

local loadBtn = btn(pageF, "Cargar frame", 8, Color3.fromRGB(50, 70, 110))
local applyBtn = btn(pageF, "Aplicar XYZ", 9, Color3.fromRGB(40, 100, 55))
local tpBtn = btn(pageF, "TP a este frame", 10, Color3.fromRGB(90, 60, 120))
local exportBtn = btn(pageF, "Exportar ruta completa", 11, Color3.fromRGB(140, 50, 50))

local function getIdx()
	local n = tonumber(idxBox.Text)
	if not n then return nil end
	n = math.floor(n)
	if n < 1 or n > #(S.routeCFrames or {}) then return nil end
	return n
end

local function showFrame(i)
	local cf = S.routeCFrames[i]
	if not cf then return end
	local p = cf.Position
	xBox.Text = string.format("%.4f", p.X)
	yBox.Text = string.format("%.4f", p.Y)
	zBox.Text = string.format("%.4f", p.Z)
	local m = S.routeModes[i] or {}
	local modes = {}
	if m.normal then table.insert(modes, "N") end
	if m.fast then table.insert(modes, "F") end
	if m.super then table.insert(modes, "S") end
	infoLbl.Text = string.format("CF %d / %d  modes:%s\n%.2f, %.2f, %.2f",
		i, #S.routeCFrames, table.concat(modes, "") ~= "" and table.concat(modes, "") or "?",
		p.X, p.Y, p.Z)
end

loadBtn.MouseButton1Click:Connect(function()
	local i = getIdx()
	if not i then notify("Índice inválido") return end
	showFrame(i)
	notify("Frame " .. i)
end)

applyBtn.MouseButton1Click:Connect(function()
	local i = getIdx()
	if not i then notify("Índice inválido") return end
	local x, y, z = tonumber(xBox.Text), tonumber(yBox.Text), tonumber(zBox.Text)
	if not x or not y or not z then notify("XYZ inválidos") return end
	local old = S.routeCFrames[i]
	local look = old and old.LookVector or Vector3.new(0, 0, -1)
	S.routeCFrames[i] = CFrame.new(Vector3.new(x, y, z), Vector3.new(x, y, z) + look)
	showFrame(i)
	notify("CF " .. i .. " actualizado")
end)

tpBtn.MouseButton1Click:Connect(function()
	local i = getIdx()
	if not i then notify("Índice inválido") return end
	local cf = S.routeCFrames[i]
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp and cf then
		hrp.CFrame = cf
		hrp.AssemblyLinearVelocity = Vector3.zero
		notify("TP CF " .. i)
	end
end)

exportBtn.MouseButton1Click:Connect(function()
	local frames = S.routeCFrames or {}
	local modes = S.routeModes or {}
	if #frames == 0 then notify("Sin frames") return end
	local lines = { "local routeCFrames = {" }
	for i, cf in ipairs(frames) do
		local p = cf.Position
		local m = modes[i] or {}
		local tag = (m.normal and "N" or "") .. (m.fast and "F" or "") .. (m.super and "S" or "")
		local comma = (i < #frames) and "," or ""
		table.insert(lines, string.format(
			"\tCFrame.new(%.6f, %.6f, %.6f)%s -- CF %d modes:%s",
			p.X, p.Y, p.Z, comma, i, tag ~= "" and tag or "?"
		))
	end
	table.insert(lines, "}")
	table.insert(lines, "")
	table.insert(lines, "local routeModes = {")
	for i = 1, #frames do
		local m = modes[i] or { normal = true, fast = true, super = true }
		local comma = (i < #frames) and "," or ""
		table.insert(lines, string.format(
			"\t[%d] = { normal = %s, fast = %s, super = %s }%s -- CF %d",
			i,
			m.normal and "true" or "false",
			m.fast and "true" or "false",
			m.super and "true" or "false",
			comma, i
		))
	end
	table.insert(lines, "}")
	local out = table.concat(lines, "\n")
	if setclipboard then
		pcall(function() setclipboard(out) end)
		notify("Exportado al clipboard (" .. #frames .. " CF)")
	else
		print("\n===== ROUTE EXPORT =====\n" .. out .. "\n===== END =====\n")
		notify("Export en F9 console (" .. #frames .. " CF)")
	end
end)

-- ===== TAB FARM =====
local tabR, pageR = makeTab("Farm", 2)
label(pageR, "WinBlock", 1)
local winHead = btn(pageR, ">  " .. (F.selectedDisplayName or "+1 Wins"), 2)
local winList = Instance.new("Frame")
winList.Parent = pageR
winList.BackgroundTransparency = 1
winList.Size = UDim2.new(1, 0, 0, 0)
winList.AutomaticSize = Enum.AutomaticSize.Y
winList.Visible = false
winList.LayoutOrder = 3
local winLay = Instance.new("UIListLayout")
winLay.Parent = winList
winLay.Padding = UDim.new(0, 3)

local blocks = S.orderedWinBlocks or {
	{ real = "WinBlock1", display = "+1 Wins" },
	{ real = "WinBlock2", display = "+3 Wins" },
	{ real = "WinBlock3", display = "+10 Wins" },
}
for i, info in ipairs(blocks) do
	local o = btn(winList, info.display, i, Color3.fromRGB(36, 36, 44))
	o.MouseButton1Click:Connect(function()
		F.selectedRealName = info.real
		F.selectedDisplayName = info.display
		winHead.Text = ">  " .. info.display
		winList.Visible = false
		notify(info.display)
	end)
end
winHead.MouseButton1Click:Connect(function()
	winList.Visible = not winList.Visible
	winHead.Text = (winList.Visible and "v  " or ">  ") .. (F.selectedDisplayName or "?")
end)

label(pageR, "Velocidad", 4)
local speedBox = box(pageR, "250", 5)
speedBox.Text = tostring(F.routeSpeed or 250)
speedBox.FocusLost:Connect(function()
	local n = tonumber(speedBox.Text)
	if n then F.routeSpeed = math.clamp(n, 1, 500); speedBox.Text = tostring(F.routeSpeed) end
end)

local modes = { "normal", "fast", "ultra" }
local modeIdx = 1
for i, m in ipairs(modes) do if m == F.routeMode then modeIdx = i end end
local modeBtn = btn(pageR, "Modo: " .. modes[modeIdx], 6)
modeBtn.MouseButton1Click:Connect(function()
	modeIdx = modeIdx % #modes + 1
	F.routeMode = modes[modeIdx]
	modeBtn.Text = "Modo: " .. F.routeMode
end)

local startBtn = btn(pageR, "Iniciar recorrido", 7, Color3.fromRGB(40, 100, 50))
startBtn.MouseButton1Click:Connect(function()
	local Brain = S.Brain
	if not Brain or not Brain.startRoute then
		notify("Brain no listo (carga el hub)")
		return
	end
	if Brain.routeRunning then
		Brain.stopRoute(true)
		startBtn.Text = "Iniciar recorrido"
		startBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 50)
		return
	end
	Brain.startRoute()
	startBtn.Text = "Detener recorrido"
	startBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
end)

if S.Farm then
	local prev = S.Farm.onRouteState
	S.Farm.onRouteState = function(running)
		if prev then pcall(prev, running) end
		if running then
			startBtn.Text = "Detener recorrido"
			startBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
		else
			startBtn.Text = "Iniciar recorrido"
			startBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 50)
		end
	end
end

-- default tab
pageF.Visible = true
tabF.BackgroundColor3 = Color3.fromRGB(170, 45, 45)

print("[Delta Hub] Route Editor listo · frames:", #(S.routeCFrames or {}))
