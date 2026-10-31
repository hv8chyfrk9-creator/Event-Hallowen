-- ==========================================
-- DELTA HUB - Event Hallowen - tab_extras.lua
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
X.antiKey = X.antiKey or false

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

local function makeSwitch(parent, text, order)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 30)
	row.LayoutOrder = order or 1
	local lab = Instance.new("TextLabel")
	lab.Parent = row
	lab.BackgroundTransparency = 1
	lab.Size = UDim2.new(1, -54, 1, 0)
	lab.Font = Enum.Font.Gotham
	lab.Text = text
	lab.TextColor3 = Color3.fromRGB(240, 240, 245)
	lab.TextSize = 12
	lab.TextXAlignment = Enum.TextXAlignment.Left
	local hit = Instance.new("TextButton")
	hit.Parent = row
	hit.Size = UDim2.new(0, 48, 0, 24)
	hit.Position = UDim2.new(1, -48, 0.5, -12)
	hit.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	hit.Text = "OFF"
	hit.TextColor3 = Color3.fromRGB(255, 120, 120)
	hit.Font = Enum.Font.GothamBold
	hit.TextSize = 11
	corner(hit, 6)
	local function paint(on)
		hit.Text = on and "ON" or "OFF"
		hit.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 120, 120)
		hit.BackgroundColor3 = on and Color3.fromRGB(40, 90, 50) or Color3.fromRGB(60, 60, 70)
	end
	return row, paint, hit
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
local function deleteNamed(names)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		for _, n in ipairs(names) do
			if obj.Name == n then pcall(function() obj:Destroy() end) end
		end
	end
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

local decoBtn = Instance.new("TextButton")
decoBtn.Parent = antiBody
decoBtn.Size = UDim2.new(1, -8, 0, 28)
decoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
decoBtn.Text = "Borrar Decorations + Props"
decoBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
decoBtn.Font = Enum.Font.Gotham
decoBtn.TextSize = 12
decoBtn.LayoutOrder = 1
corner(decoBtn, 6)
decoBtn.MouseButton1Click:Connect(function()
	deleteNamed({ "Decorations", "Props" })
	notify("Decorations/Props borrados")
end)

local hallBtn = Instance.new("TextButton")
hallBtn.Parent = antiBody
hallBtn.Size = UDim2.new(1, -8, 0, 28)
hallBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
hallBtn.Text = "Borrar Halloween + HalloweenMeshes"
hallBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
hallBtn.Font = Enum.Font.Gotham
hallBtn.TextSize = 12
hallBtn.LayoutOrder = 2
corner(hallBtn, 6)
hallBtn.MouseButton1Click:Connect(function()
	deleteNamed({ "Halloween", "HalloweenMeshes", "HallowenMeshes" })
	notify("Halloween borrado")
end)

local _, paintKey, hitKey = makeSwitch(antiBody, "Keycaps transparentes (loop)", 3)
hitKey.MouseButton1Click:Connect(function()
	X.antiKey = not X.antiKey
	paintKey(X.antiKey)
	if X.antiKey then stripKeycaps() end
end)
paintKey(X.antiKey)

setProgress(93, "Extras", "Pantalla / Stats...")
local screenBody = section(extrasPage, "Pantalla", 2)
local _, paintRender, hitRender = makeSwitch(screenBody, "No render", 1)

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

hitRender.MouseButton1Click:Connect(function()
	X.renderOn = not X.renderOn
	paintRender(X.renderOn)
	colorRow.Visible = X.renderOn
	applyRender()
end)
paintRender(X.renderOn)

local _, paintStats, hitStats = makeSwitch(screenBody, "Stats", 3)
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

hitStats.MouseButton1Click:Connect(function()
	X.statsOn = not X.statsOn
	paintStats(X.statsOn)
	cardStats.Visible = X.statsOn
	perfCard.Visible = X.statsOn
	-- No se oculta la UI del juego: No Render ya tapa la pantalla
end)
paintStats(X.statsOn)

setProgress(96, "Extras", "Bucles finales...")
if not S._extrasLoopsStarted then
	S._extrasLoopsStarted = true
	local t0 = tick()
	local frames = 0
	RunService.RenderStepped:Connect(function() frames = frames + 1 end)
	task.spawn(function()
		while true do
			task.wait(0.5)
			if X.antiKey then stripKeycaps() end
			if X.statsOn then
				local fps = frames * 2
				frames = 0
				local farm = S.Farm or {}
				local ev = S.Events or {}
				local mb = math.floor(collectgarbage("count") / 1024)
				perfCard.Text = string.format("FPS: %d\nMS: %d\nMB: %d", fps, math.floor(1000 / math.max(fps, 1)), mb)
				cardStats.Text = string.format(
					"Wins ruta: %s\nSesion: %ds\nSpecialKeys: %d",
					ttostring(farm.routeWinsSession or 0),
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
