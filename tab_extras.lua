-- ==========================================
-- DELTA HUB - Event Hallowen - tab_extras.lua
-- Anti-lag unificado + selector colapsable
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_extras: falta hub")
	return
end

S.Extras = S.Extras or {}
local X = S.Extras
X.renderOn = X.renderOn or false
X.renderWhite = X.renderWhite ~= false
X.statsOn = X.statsOn or false
X.antiLagOn = X.antiLagOn or false
X.antiOpts = X.antiOpts or { decorations = true, halloween = true, keycaps = true }
X.antiSelOpen = X.antiSelOpen or false

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end
local function notify(text)
	if S.notify then S.notify(text) else warn("[Delta Hub]", text) end
end
local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
end
local function fmtNum(n)
	return tostring(n)
end

local function makeToggleRow(parent, text, order, get, set)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	row.Size = UDim2.new(1, -4, 0, 34)
	row.LayoutOrder = order or 1
	corner(row, 6)
	local label = Instance.new("TextLabel")
	label.Parent = row
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -70, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Font = Enum.Font.Gotham
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	local btn = Instance.new("TextButton")
	btn.Parent = row
	btn.Size = UDim2.new(0, 50, 0, 22)
	btn.Position = UDim2.new(1, -56, 0.5, -11)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	local function refresh()
		local on = get()
		btn.Text = on and "ON" or "OFF"
		btn.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
		btn.BackgroundColor3 = on and Color3.fromRGB(30, 80, 40) or Color3.fromRGB(50, 40, 40)
	end
	refresh()
	corner(btn, 6)
	btn.MouseButton1Click:Connect(function()
		set(not get())
		refresh()
	end)
	return row, btn, refresh
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

local function deleteNamed(names)
	local n = 0
	for _, obj in ipairs(Workspace:GetDescendants()) do
		for _, name in ipairs(names) do
			if obj.Name == name then pcall(function() obj:Destroy() end); n = n + 1 end
		end
	end
	return n
end

local function stripKeycaps()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "KeyCaps" or (obj.Parent and obj.Parent.Name == "KeyCaps") then
			if obj:IsA("BasePart") then obj.Transparency = 1; obj.CanCollide = false end
			for _, d in ipairs(obj:GetDescendants()) do
				if d:IsA("BasePart") then d.Transparency = 1; d.CanCollide = false end
			end
		end
	end
end

local function runAntiLagOnce()
	if X.antiOpts.decorations then deleteNamed({ "Decorations", "Props" }) end
	if X.antiOpts.halloween then deleteNamed({ "Halloween", "HalloweenMeshes", "HallowenMeshes" }) end
	if X.antiOpts.keycaps then stripKeycaps() end
end

setProgress(88, "Extras", "Creando pestaña...")
local extrasPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Extras = extrasPage

local tabExtras = Instance.new("TextButton")
tabExtras.Parent = S.UI.Sidebar
tabExtras.Size = UDim2.new(0, 92, 0, 42)
tabExtras.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
tabExtras.Font = Enum.Font.GothamBold
tabExtras.Text = "Extras"
tabExtras.TextColor3 = Color3.fromRGB(255, 255, 255)
tabExtras.TextSize = 14
tabExtras.LayoutOrder = 4
corner(tabExtras, 6)
tabExtras.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	extrasPage.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Extras" end
end)

setProgress(90, "Extras", "Antilag...")
local antiBody = section(extrasPage, "Anti lag", 1)

local optLabels = {
	{ key = "decorations", text = "Decorations / Props" },
	{ key = "halloween", text = "Halloween / Meshes" },
	{ key = "keycaps", text = "Keycaps transparentes" },
}

local function countSelected()
	local c = 0
	for _, v in pairs(X.antiOpts) do if v then c = c + 1 end end
	return c
end

local function summaryText()
	local parts = {}
	for _, info in ipairs(optLabels) do
		if X.antiOpts[info.key] then table.insert(parts, info.text) end
	end
	if #parts == 0 then return "Ninguna" end
	return table.concat(parts, ", ")
end

local selHeader = Instance.new("TextButton")
selHeader.Parent = antiBody
selHeader.Size = UDim2.new(1, -4, 0, 30)
selHeader.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
selHeader.Font = Enum.Font.Gotham
selHeader.TextSize = 12
selHeader.TextColor3 = Color3.fromRGB(240, 240, 245)
selHeader.TextXAlignment = Enum.TextXAlignment.Left
selHeader.LayoutOrder = 1
corner(selHeader, 6)

local selList = Instance.new("Frame")
selList.Parent = antiBody
selList.BackgroundTransparency = 1
selList.Size = UDim2.new(1, 0, 0, 0)
selList.AutomaticSize = Enum.AutomaticSize.Y
selList.Visible = X.antiSelOpen
selList.LayoutOrder = 2
local selLay = Instance.new("UIListLayout")
selLay.Parent = selList
selLay.SortOrder = Enum.SortOrder.LayoutOrder
selLay.Padding = UDim.new(0, 4)

local function refreshHeader()
	local arrow = X.antiSelOpen and "▼" or "▶"
	selHeader.Text = "  " .. arrow .. "  Opciones: " .. summaryText()
	selList.Visible = X.antiSelOpen
end

local antiSwitchRefresh

for i, info in ipairs(optLabels) do
	local row = Instance.new("TextButton")
	row.Parent = selList
	row.Size = UDim2.new(1, -4, 0, 28)
	row.BackgroundColor3 = X.antiOpts[info.key] and Color3.fromRGB(40, 90, 50) or Color3.fromRGB(36, 36, 44)
	row.Font = Enum.Font.Gotham
	row.Text = (X.antiOpts[info.key] and "[x] " or "[ ] ") .. info.text
	row.TextColor3 = Color3.fromRGB(240, 240, 245)
	row.TextSize = 12
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.LayoutOrder = i
	corner(row, 6)
	row.MouseButton1Click:Connect(function()
		local was = X.antiOpts[info.key]
		if was and countSelected() <= 1 then
			notify("Debe quedar al menos 1 opción")
			return
		end
		X.antiOpts[info.key] = not was
		row.BackgroundColor3 = X.antiOpts[info.key] and Color3.fromRGB(40, 90, 50) or Color3.fromRGB(36, 36, 44)
		row.Text = (X.antiOpts[info.key] and "[x] " or "[ ] ") .. info.text
		refreshHeader()
		if X.antiLagOn then
			X.antiLagOn = false
			if antiSwitchRefresh then antiSwitchRefresh() end
			notify("Anti lag OFF (cambiaste opciones)")
		end
	end)
end

selHeader.MouseButton1Click:Connect(function()
	X.antiSelOpen = not X.antiSelOpen
	refreshHeader()
end)
refreshHeader()

local _, _, refreshAnti = makeToggleRow(antiBody, "Anti lag activo", 10, function() return X.antiLagOn end, function(v)
	X.antiLagOn = v
	if v then
		runAntiLagOnce()
		notify("Anti lag ON")
		task.spawn(function()
			while X.antiLagOn do
				if X.antiOpts.keycaps then stripKeycaps() end
				if X.antiOpts.decorations or X.antiOpts.halloween then runAntiLagOnce() end
				task.wait(0.5)
			end
		end)
	else
		notify("Anti lag OFF")
	end
end)
antiSwitchRefresh = refreshAnti

setProgress(93, "Extras", "Pantalla / Stats...")
local screenBody = section(extrasPage, "Pantalla", 2)

local renderGui = Instance.new("ScreenGui")
renderGui.Name = "DeltaHubNoRender"
renderGui.ResetOnSpawn = false
renderGui.IgnoreGuiInset = true
renderGui.DisplayOrder = 500
renderGui.Parent = playerGui
local noRender = Instance.new("Frame")
noRender.Parent = renderGui
noRender.Size = UDim2.new(1, 0, 1, 0)
noRender.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
noRender.Visible = false
noRender.ZIndex = 1
noRender.Active = false

local colorRow = Instance.new("Frame")
colorRow.Parent = screenBody
colorRow.BackgroundTransparency = 1
colorRow.Size = UDim2.new(1, -8, 0, 0)
colorRow.AutomaticSize = Enum.AutomaticSize.Y
colorRow.Visible = false
colorRow.LayoutOrder = 2
local colorLay = Instance.new("UIListLayout")
colorLay.Parent = colorRow
colorLay.Padding = UDim.new(0, 4)
local function applyRender()
	noRender.BackgroundColor3 = X.renderWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	noRender.Visible = X.renderOn
end
local bW = Instance.new("TextButton")
bW.Parent = colorRow
bW.Size = UDim2.new(1, 0, 0, 26)
bW.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
bW.Text = "Blanco"
bW.TextColor3 = Color3.fromRGB(255, 255, 255)
bW.Font = Enum.Font.Gotham
bW.TextSize = 12
corner(bW, 5)
bW.MouseButton1Click:Connect(function() X.renderWhite = true; applyRender() end)
local bB = Instance.new("TextButton")
bB.Parent = colorRow
bB.Size = UDim2.new(1, 0, 0, 26)
bB.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
bB.Text = "Negro"
bB.TextColor3 = Color3.fromRGB(255, 255, 255)
bB.Font = Enum.Font.Gotham
bB.TextSize = 12
corner(bB, 5)
bB.MouseButton1Click:Connect(function() X.renderWhite = false; applyRender() end)

makeToggleRow(screenBody, "No render", 1, function() return X.renderOn end, function(v)
	X.renderOn = v
	colorRow.Visible = v
	applyRender()
end)

local statsGui = Instance.new("ScreenGui")
statsGui.Name = "DeltaHubStats"
statsGui.ResetOnSpawn = false
statsGui.IgnoreGuiInset = true
statsGui.DisplayOrder = 1200
statsGui.Parent = playerGui
local cardStats = Instance.new("TextLabel")
cardStats.Parent = statsGui
cardStats.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
cardStats.BackgroundTransparency = 0.25
cardStats.Position = UDim2.new(0, 12, 0, 80)
cardStats.Size = UDim2.new(0, 210, 0, 72)
cardStats.Font = Enum.Font.GothamBold
cardStats.Text = "Wins ruta: 0\nSesion: 0s\nSpecialKeys: 0"
cardStats.TextColor3 = Color3.fromRGB(255, 255, 255)
cardStats.TextSize = 12
cardStats.TextYAlignment = Enum.TextYAlignment.Top
cardStats.Visible = false
cardStats.Active = true
cardStats.Draggable = true
corner(cardStats, 6)
local perfCard = Instance.new("TextLabel")
perfCard.Parent = statsGui
perfCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
perfCard.BackgroundTransparency = 0.25
perfCard.Position = UDim2.new(0, 12, 0, 12)
perfCard.Size = UDim2.new(0, 140, 0, 54)
perfCard.Font = Enum.Font.GothamBold
perfCard.Text = "FPS: --\nMS: --\nMB: --"
perfCard.TextColor3 = Color3.fromRGB(255, 255, 255)
perfCard.TextSize = 11
perfCard.Visible = false
perfCard.Active = true
perfCard.Draggable = true
corner(perfCard, 6)

makeToggleRow(screenBody, "Stats", 3, function() return X.statsOn end, function(v)
	X.statsOn = v
	cardStats.Visible = v
	perfCard.Visible = v
end)

setProgress(96, "Extras", "Bucles finales...")
if not S._extrasLoopsStarted then
	S._extrasLoopsStarted = true
	local t0 = tick()
	local frames = 0
	RunService.RenderStepped:Connect(function() frames = frames + 1 end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			if X.statsOn then
				local fps = frames * 2
				frames = 0
				local farm = S.Farm or {}
				local ev = S.Events or {}
				local mb = math.floor(collectgarbage("count") / 1024)
				perfCard.Text = string.format("FPS: %d\nMS: %d\nMB: %d", fps, math.floor(1000 / math.max(fps, 1)), mb)
				cardStats.Text = string.format(
					"Wins ruta: %s\nSesion: %ds\nSpecialKeys: %d",
					fmtNum(farm.routeWinsSession or 0),
					math.floor(tick() - t0),
					ev.specialKeyCount or 0
				)
			end
		end
	end)
end

setProgress(99, "Extras", "Finalizando...")
task.spawn(function()
	if S.fadeAndDestroyLoading then S.fadeAndDestroyLoading() end
	if S.UI.MainFrame then S.UI.MainFrame.Visible = true end
	if S.UI.Sidebar then S.UI.Sidebar.Visible = true end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Farm" end
	S.scriptReady = true
	notify("Hallowen world listo")
	setProgress(100, "Listo", "Delta Hub activo")
end)
