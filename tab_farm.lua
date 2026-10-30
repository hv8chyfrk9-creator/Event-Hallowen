-- ==========================================
-- DELTA HUB - Event Hallowen - tab_farm.lua
-- Solo pestaña Farm (Wins / Rutas) | 50% -> 62.5%
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	warn("[Delta Hub] tab_farm: falta init (DeltaHub)")
	return
end

S.UI = S.UI or {}
S.Farm = S.Farm or {}
S.Signals = S.Signals or {}

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local NEXT_URL = BASE .. "tab_player.lua"

local function setProgress(p, title, sub)
	if S.setProgress then
		S.setProgress(p, title, sub)
	end
end

setProgress(51, "Farm", "Creando interfaz base...")

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
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

local function ensureHub()
	if S.UI.ScreenGui and S.UI.ScreenGui.Parent then
		return
	end
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
	S.UI.TopBar = top

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
	S.UI.MinimizeBtn = minBtn

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
	S.UI.SidebarLayout = sideLay

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

local F = S.Farm
F.selectedRealName = F.selectedRealName or "WinBlock1"
F.selectedDisplayName = F.selectedDisplayName or "+1 Wins"
F.gameSpeed = F.gameSpeed or 250
F.routeMode = F.routeMode or "normal"
F.delayTime = F.delayTime or 0
F.infinite = F.infinite or false
F.routeRunning = false
F.finishAfterClaim = false
F.routeWinsSession = F.routeWinsSession or 0
F.winStreakBonus = F.winStreakBonus or 0
F.streakBlock = nil
F.goalEnabled = false
F.goalAmount = 0
F.goalProgress = 0

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

local function formatWins(n)
	n = tonumber(n) or 0
	local units = { { 1e15, "Q" }, { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
	for _, u in ipairs(units) do
		if n >= u[1] then return string.format("%.2f%s", n / u[1], u[2]) end
	end
	return tostring(math.floor(n))
end

local function parseWinAmount(text)
	local n, suf = string.match(string.lower(text or ""), "([%d%.]+)%s*([kmbqt]?)")
	local value = tonumber(n) or 0
	local mult = { k = 1e3, m = 1e6, b = 1e9, t = 1e12, q = 1e15 }
	if suf and mult[suf] then value = value * mult[suf] end
	return value
end

local function approachSpeed(distance, nextDistance)
	local maxSpeed = math.clamp(F.gameSpeed or 250, 1, 500)
	if nextDistance and nextDistance < 5 then return maxSpeed end
	-- normal: frena poco y casi no se queda en 0 (piso 12)
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

local function addRouteWins()
	if F.streakBlock ~= F.selectedRealName then
		F.winStreakBonus = 0
		F.streakBlock = F.selectedRealName
	end
	local base = parseWinAmount(F.selectedDisplayName or "")
	local gain = base * (1 + (F.winStreakBonus or 0))
	F.routeWinsSession = (F.routeWinsSession or 0) + gain
	if F.goalEnabled then F.goalProgress = (F.goalProgress or 0) + gain end
	F.winStreakBonus = math.min(1, (F.winStreakBonus or 0) + 0.1)
	if S.UI.WinsCounter then
		S.UI.WinsCounter.Text = "Wins ruta: " .. formatWins(F.routeWinsSession) .. " | racha +" .. tostring(math.floor((F.winStreakBonus or 0) * 100)) .. "%"
		S.UI.WinsCounter.Visible = true
	end
	notify("+" .. formatWins(gain) .. " Wins")
end

local function resetWinStreak()
	F.winStreakBonus = 0
	F.streakBlock = nil
end

setProgress(55, "Farm", "Controles de Wins...")

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

local speedBox = makeBox(winsBody, "Velocidad recorrido (1-500)", tostring(F.gameSpeed), 3)
speedBox.FocusLost:Connect(function()
	F.gameSpeed = math.clamp(tonumber(speedBox.Text) or F.gameSpeed or 250, 1, 500)
	speedBox.Text = tostring(F.gameSpeed)
end)

local modeBtn = makeButton(winsBody, "Recorrido: Normal", 4)
local function paintMode()
	if F.routeMode == "fast" then modeBtn.Text = "Recorrido: Rapido"
	elseif F.routeMode == "ultra" or F.routeMode == "super" then modeBtn.Text = "Recorrido: Ultra rapido"
	else modeBtn.Text = "Recorrido: Normal" end
end
modeBtn.MouseButton1Click:Connect(function()
	if F.routeMode == "normal" then F.routeMode = "fast"
	elseif F.routeMode == "fast" then F.routeMode = "ultra"
	else F.routeMode = "normal" end
	paintMode()
end)

local delayBox = makeBox(winsBody, "Delay entre recorridos (0-10)", tostring(F.delayTime), 5)
delayBox.FocusLost:Connect(function()
	F.delayTime = math.clamp(tonumber(delayBox.Text) or 0, 0, 10)
	delayBox.Text = tostring(F.delayTime)
end)

local infBtn = makeButton(winsBody, "Recorrido Infinito: OFF", 6)
infBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
infBtn.MouseButton1Click:Connect(function()
	F.infinite = not F.infinite
	if F.infinite then
		infBtn.Text = "Recorrido Infinito: ON"
		infBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
		infBtn.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
	else
		infBtn.Text = "Recorrido Infinito: OFF"
		infBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		infBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	end
end)

local goalBox = makeBox(winsBody, "Meta de Wins (ej 10M) - 0 = off", "0", 7)
goalBox.FocusLost:Connect(function()
	local v = parseWinAmount(goalBox.Text)
	F.goalAmount = v
	F.goalEnabled = v > 0
	notify(F.goalEnabled and ("Meta: " .. formatWins(v)) or "Meta apagada")
end)

local startBtn = makeButton(winsBody, "Iniciar Recorrido", 8, Color3.fromRGB(40, 90, 50))
S.UI.StartRouteBtn = startBtn

local stopContainer = Instance.new("Frame")
stopContainer.Parent = S.UI.ScreenGui
stopContainer.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
stopContainer.Position = UDim2.new(1, -170, 0, 15)
stopContainer.Size = UDim2.new(0, 155, 0, 35)
stopContainer.Visible = false
corner(stopContainer, 6)
S.UI.StopRouteContainer = stopContainer

local stopFloat = Instance.new("TextButton")
stopFloat.Parent = stopContainer
stopFloat.BackgroundTransparency = 1
stopFloat.Size = UDim2.new(1, 0, 1, 0)
stopFloat.Font = Enum.Font.GothamBold
stopFloat.Text = "Terminar Recorrido"
stopFloat.TextColor3 = Color3.fromRGB(255, 255, 255)
stopFloat.TextSize = 12

local stopNow = Instance.new("TextButton")
stopNow.Parent = S.UI.ScreenGui
stopNow.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
stopNow.Position = UDim2.new(1, -170, 0, 56)
stopNow.Size = UDim2.new(0, 155, 0, 28)
stopNow.Font = Enum.Font.GothamBold
stopNow.Text = "Terminar recorrido ahora"
stopNow.TextColor3 = Color3.fromRGB(255, 255, 255)
stopNow.TextSize = 10
stopNow.Visible = false
corner(stopNow, 6)

local winsCounter = Instance.new("TextLabel")
winsCounter.Parent = S.UI.ScreenGui
winsCounter.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
winsCounter.Position = UDim2.new(1, -210, 0, 90)
winsCounter.Size = UDim2.new(0, 195, 0, 36)
winsCounter.Font = Enum.Font.GothamBold
winsCounter.Text = "Wins ruta: 0 | racha +0%"
winsCounter.TextColor3 = Color3.fromRGB(255, 220, 80)
winsCounter.TextSize = 11
winsCounter.Visible = false
corner(winsCounter, 6)
S.UI.WinsCounter = winsCounter

local prompt = Instance.new("Frame")
prompt.Parent = S.UI.ScreenGui
prompt.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
prompt.Position = UDim2.new(0.5, -140, 0.5, -60)
prompt.Size = UDim2.new(0, 280, 0, 120)
prompt.Visible = false
corner(prompt, 10)
S.UI.PromptContainer = prompt
local promptText = Instance.new("TextLabel")
promptText.Parent = prompt
promptText.BackgroundTransparency = 1
promptText.Size = UDim2.new(1, -16, 0, 50)
promptText.Position = UDim2.new(0, 8, 0, 8)
promptText.Font = Enum.Font.GothamBold
promptText.Text = "Moriste. Retomar recorrido?"
promptText.TextColor3 = Color3.fromRGB(255, 255, 255)
promptText.TextSize = 13
promptText.TextWrapped = true
local yesBtn = Instance.new("TextButton")
yesBtn.Parent = prompt
yesBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 55)
yesBtn.Position = UDim2.new(0, 16, 1, -44)
yesBtn.Size = UDim2.new(0.42, 0, 0, 30)
yesBtn.Font = Enum.Font.GothamBold
yesBtn.Text = "Si"
yesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
yesBtn.TextSize = 13
corner(yesBtn, 6)
local noBtn = Instance.new("TextButton")
noBtn.Parent = prompt
noBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
noBtn.Position = UDim2.new(0.52, 0, 1, -44)
noBtn.Size = UDim2.new(0.42, 0, 0, 30)
noBtn.Font = Enum.Font.GothamBold
noBtn.Text = "No"
noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noBtn.TextSize = 13
corner(noBtn, 6)

local function stopRoute(hard)
	F.routeRunning = false
	F.finishAfterClaim = false
	stopContainer.Visible = false
	stopNow.Visible = false
	stopFloat.Text = "Terminar Recorrido"
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

stopFloat.MouseButton1Click:Connect(function()
	F.finishAfterClaim = true
	stopNow.Visible = true
	stopFloat.Text = "Terminara al WinBlock"
	notify("Sigue hasta el WinBlock")
end)
stopNow.MouseButton1Click:Connect(function()
	stopRoute(true)
	notify("Recorrido detenido")
end)

setProgress(58, "Farm", "Logica de recorrido...")

local function runOneLap()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum or hum.Health <= 0 then return false end
	if S.Signals.SetNoclip then S.Signals.SetNoclip(true) end

	local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode))
	if not activeRoute or #activeRoute == 0 then activeRoute = S.routeCFrames end

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Parent = hrp
	hrp.CFrame = activeRoute[1]

	local targetObject = nil
	local closestIndex = #activeRoute
	task.spawn(function()
		while F.routeRunning and hum.Health > 0 and not targetObject do
			targetObject = Workspace:FindFirstChild(F.selectedRealName, true)
			if targetObject then
				local objPos = targetObject:IsA("BasePart") and targetObject.Position or (targetObject.PrimaryPart and targetObject.PrimaryPart.Position)
				if objPos then
					local best = math.huge
					for idx, cf in ipairs(activeRoute) do
						local d = (cf.Position - objPos).Magnitude
						if d < best then best = d; closestIndex = idx end
					end
				end
				break
			end
			task.wait(1)
		end
	end)

	local i = 2
	while i <= #activeRoute and F.routeRunning and hum.Health > 0 do
		if i > closestIndex then break end
		local targetCf = activeRoute[i]
		local targetPos = targetCf.Position
		local stuck = 0
		while hrp and (hrp.Position - targetPos).Magnitude > 2.5 and F.routeRunning and hum.Health > 0 do
			local dist = (hrp.Position - targetPos).Magnitude
			local nextD = activeRoute[i + 1] and (activeRoute[i + 1].Position - targetPos).Magnitude
			local spd = approachSpeed(dist, nextD)
			if dist <= 6 then
				hrp.CFrame = targetCf
				hrp.AssemblyLinearVelocity = Vector3.zero
				if bv then bv.Velocity = Vector3.zero end
				task.wait(0.05)
				break
			end
			if dist > 0.05 then
				bv.Velocity = (targetPos - hrp.Position).Unit * spd
			else
				bv.Velocity = Vector3.zero
			end
			stuck = stuck + 1
			if stuck % 45 == 0 then
				local moved = (hrp.Position - targetPos).Magnitude
				if moved > dist * 0.85 then
					hrp.CFrame = targetCf
					hrp.AssemblyLinearVelocity = Vector3.zero
					break
				end
			end
			RunService.Heartbeat:Wait()
		end
		if hrp and F.routeRunning then
			hrp.CFrame = targetCf
			if bv then bv.Velocity = Vector3.zero end
		end
		i = i + 1
	end

	while not targetObject and F.routeRunning and hum.Health > 0 do
		targetObject = Workspace:FindFirstChild(F.selectedRealName, true)
		task.wait(0.5)
	end

	if targetObject and F.routeRunning and hum.Health > 0 then
		local objPos = targetObject:IsA("BasePart") and targetObject.Position or (targetObject.PrimaryPart and targetObject.PrimaryPart.Position)
		if objPos then
			while hrp and (hrp.Position - objPos).Magnitude > 4 and F.routeRunning and hum.Health > 0 do
				objPos = targetObject:IsA("BasePart") and targetObject.Position or (targetObject.PrimaryPart and targetObject.PrimaryPart.Position)
				if not objPos then break end
				bv.Velocity = (objPos - hrp.Position).Unit * approachSpeed((objPos - hrp.Position).Magnitude)
				RunService.Heartbeat:Wait()
			end
		end
		bv.Velocity = Vector3.zero
	end

	if bv then bv:Destroy() end
	if not F.routeRunning then return false end
	if hum.Health <= 0 then return "dead" end

	task.wait(0.67)
	addRouteWins()
	hrp.CFrame = S.routeCFrames[1]
	local hold = 1 + (F.delayTime or 0)
	local t = 0
	while F.routeRunning and hum.Health > 0 and t < hold do
		hrp.CFrame = S.routeCFrames[1]
		task.wait(0.1)
		t = t + 0.1
	end
	return true
end

startBtn.MouseButton1Click:Connect(function()
	if F.routeRunning then return end
	F.gameSpeed = math.clamp(tonumber(speedBox.Text) or F.gameSpeed or 250, 1, 500)
	speedBox.Text = tostring(F.gameSpeed)
	F.routeRunning = true
	stopContainer.Visible = true
	startBtn.Text = "Recorrido activo..."
	startBtn.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
	task.spawn(function()
		while F.routeRunning do
			local result = runOneLap()
			if result == "dead" then
				resetWinStreak()
				prompt.Visible = true
				local choice = nil
				local c1, c2
				c1 = yesBtn.MouseButton1Click:Connect(function() choice = true; c1:Disconnect(); c2:Disconnect() end)
				c2 = noBtn.MouseButton1Click:Connect(function() choice = false; c1:Disconnect(); c2:Disconnect() end)
				while choice == nil and F.routeRunning do task.wait(0.2) end
				prompt.Visible = false
				if choice == true then
					local char = player.Character
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if not char or not hum or hum.Health <= 0 then player.CharacterAdded:Wait() end
					task.wait(0.4)
					local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if hrp and S.routeCFrames[1] then
						hrp.CFrame = S.routeCFrames[1]
						hrp.AssemblyLinearVelocity = Vector3.zero
					end
				else
					stopRoute(true)
					break
				end
			elseif result == false then
				break
			end
			local goalOk = F.goalEnabled and not F.infinite and (F.goalProgress or 0) >= (F.goalAmount or 0)
			if F.finishAfterClaim or (not F.infinite and not F.goalEnabled) or goalOk then
				if goalOk then notify("Meta alcanzada") end
				stopRoute(true)
				break
			end
			if not F.infinite and F.goalEnabled and (F.goalProgress or 0) < (F.goalAmount or 0) then
			elseif not F.infinite then
				stopRoute(true)
				break
			end
		end
	end)
end)

setProgress(62, "Farm", "Farm lista")

local function loadNext(url)
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] tab_farm: no se pudo bajar", url, body)
		setProgress(62.5, "Error", "Falta tab_player.lua")
		return
	end
	if body:sub(1, 9) == "<!DOCTYPE" or body:sub(1, 6) == "<html>" then
		warn("[Delta Hub] tab_farm: HTML en", url)
		setProgress(62.5, "Error", "Sube tab_player.lua al repo")
		return
	end
	local fn, err = loadstring(body)
	if not fn then warn("[Delta Hub] tab_farm loadstring", err) return end
	local okRun, runErr = pcall(fn)
	if not okRun then warn("[Delta Hub] tab_player run", runErr) end
end

setProgress(62.5, "Farm", "Cargando Player...")
loadNext(NEXT_URL)
