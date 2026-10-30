-- ==========================================
-- DELTA HUB - Event Hallowen - tab_extras.lua
-- Solo pestaña Extras | 87.5% -> 100% + fade loading
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

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
X.antiDeco = X.antiDeco or false
X.antiHall = X.antiHall or false
X.antiKeys = X.antiKeys or false
X.renderOn = X.renderOn or false
X.renderWhite = X.renderWhite ~= false
X.statsOn = X.statsOn or false

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

local function notify(text)
	if S.notify then S.notify(text) else warn("[Delta Hub]", text) end
end

setProgress(88, "Extras", "Creando pestaña Extras...")

local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
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

local function makeSwitch(parent, text, order)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	row.Size = UDim2.new(1, -4, 0, 36)
	row.LayoutOrder = order or 1
	corner(row, 6)
	local label = Instance.new("TextLabel")
	label.Parent = row
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -58, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	local hit = Instance.new("TextButton")
	hit.Parent = row
	hit.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
	hit.Position = UDim2.new(1, -46, 0.5, -11)
	hit.Size = UDim2.new(0, 36, 0, 22)
	hit.Text = ""
	corner(hit, 99)
	local knob = Instance.new("Frame")
	knob.Parent = hit
	knob.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
	knob.Position = UDim2.new(0, 2, 0, 2)
	knob.Size = UDim2.new(0, 18, 0, 18)
	corner(knob, 99)
	local function paint(on)
		hit.BackgroundColor3 = on and Color3.fromRGB(70, 190, 90) or Color3.fromRGB(70, 70, 78)
		knob.Position = on and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
	end
	return row, paint, hit
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

local extrasPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Extras = extrasPage
S.UI.ExtrasPage = extrasPage

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
S.UI.TabExtras = tabExtras
tabExtras.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	extrasPage.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Extras" end
end)

do
	local side = S.UI.Sidebar
	if side then
		local tabH, gap, n = 42, 26, 4
		local stack = n * tabH + (n - 1) * gap
		side.Size = UDim2.new(0, 92, 0, stack)
		side.Position = UDim2.new(0.5, -310, 0.5, -stack / 2)
	end
end

setProgress(90, "Extras", "Antilag...")

local antiBody = section(extrasPage, "Antilag", 1)
local _, paintDeco, hitDeco = makeSwitch(antiBody, "Anti Decorations + Props", 1)
local _, paintHall, hitHall = makeSwitch(antiBody, "Anti Halloween + Meshes", 2)
local _, paintKeys, hitKeys = makeSwitch(antiBody, "Anti KeyCaps (loop)", 3)

hitDeco.MouseButton1Click:Connect(function()
	X.antiDeco = not X.antiDeco
	paintDeco(X.antiDeco)
end)
hitHall.MouseButton1Click:Connect(function()
	X.antiHall = not X.antiHall
	paintHall(X.antiHall)
end)
hitKeys.MouseButton1Click:Connect(function()
	X.antiKeys = not X.antiKeys
	paintKeys(X.antiKeys)
end)
paintDeco(X.antiDeco)
paintHall(X.antiHall)
paintKeys(X.antiKeys)

local function deleteNamed(names)
	for _, obj in pairs(Workspace:GetDescendants()) do
		for _, name in ipairs(names) do
			if obj.Name == name then
				pcall(function() obj:Destroy() end)
			end
		end
	end
end

local function hideKeycaps()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local ln = string.lower(obj.Name or "")
		if ln == "keycaps" or string.find(ln, "keycaps", 1, true) then
			if obj:IsA("BasePart") then
				obj.Transparency = 1
				obj.CanCollide = false
				obj.CanTouch = false
				obj.CanQuery = false
			end
			for _, d in ipairs(obj:GetDescendants()) do
				if d:IsA("BasePart") then
					d.Transparency = 1
					d.CanCollide = false
					d.CanTouch = false
					d.CanQuery = false
				end
			end
		end
	end
end

setProgress(93, "Extras", "Pantalla / Stats...")

local screenBody = section(extrasPage, "Pantalla", 2)
local _, paintRender, hitRender = makeSwitch(screenBody, "No render", 1)

local colorRow = Instance.new("Frame")
colorRow.Parent = screenBody
colorRow.BackgroundTransparency = 1
colorRow.Size = UDim2.new(1, -4, 0, 28)
colorRow.Visible = false
colorRow.LayoutOrder = 2

local renderGui = Instance.new("ScreenGui")
renderGui.Name = "DeltaHubNoRender"
renderGui.ResetOnSpawn = false
renderGui.DisplayOrder = 1
renderGui.IgnoreGuiInset = true
renderGui.Parent = playerGui
local noRender = Instance.new("Frame")
noRender.Parent = renderGui
noRender.Size = UDim2.new(1, 0, 1, 0)
noRender.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
noRender.Visible = false
noRender.ZIndex = 1
noRender.Active = false

local function paintRenderFrame()
	noRender.BackgroundColor3 = X.renderWhite and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
	noRender.Visible = X.renderOn
end

for _, name in ipairs({ "Blanco", "Negro" }) do
	local b = Instance.new("TextButton")
	b.Parent = colorRow
	b.Size = UDim2.new(0, 70, 0, 24)
	b.Position = name == "Blanco" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 78, 0, 0)
	b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	b.Font = Enum.Font.Gotham
	b.Text = name
	b.TextSize = 11
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	corner(b, 4)
	b.MouseButton1Click:Connect(function()
		X.renderWhite = (name == "Blanco")
		paintRenderFrame()
	end)
end

hitRender.MouseButton1Click:Connect(function()
	X.renderOn = not X.renderOn
	paintRender(X.renderOn)
	colorRow.Visible = X.renderOn
	paintRenderFrame()
end)
paintRender(X.renderOn)

local _, paintStats, hitStats = makeSwitch(screenBody, "Stats", 3)

local sessionStart = tick()
local statsGui = Instance.new("ScreenGui")
statsGui.Name = "DeltaHubStats"
statsGui.ResetOnSpawn = false
statsGui.DisplayOrder = 100000
statsGui.IgnoreGuiInset = true
pcall(function() statsGui.Parent = game:GetService("CoreGui") end)
if not statsGui.Parent then statsGui.Parent = playerGui end

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
perfCard.BackgroundTransparency = 0.2
perfCard.Position = UDim2.new(0, 8, 0, 8)
perfCard.Size = UDim2.new(0, 150, 0, 54)
perfCard.Font = Enum.Font.GothamBold
perfCard.Text = "FPS: --\nMS: --\nMB: --"
perfCard.TextColor3 = Color3.fromRGB(255, 255, 255)
perfCard.TextSize = 12
perfCard.TextYAlignment = Enum.TextYAlignment.Top
perfCard.Visible = false
perfCard.Active = true
perfCard.Draggable = true
corner(perfCard, 6)

local function formatWins(n)
	n = tonumber(n) or 0
	local units = { { 1e12, "T" }, { 1e9, "B" }, { 1e6, "M" }, { 1e3, "K" } }
	for _, u in ipairs(units) do
		if n >= u[1] then
			return string.format("%.2f%s", n / u[1], u[2])
		end
	end
	return tostring(math.floor(n))
end

hitStats.MouseButton1Click:Connect(function()
	X.statsOn = not X.statsOn
	paintStats(X.statsOn)
	cardStats.Visible = X.statsOn
	perfCard.Visible = X.statsOn
	if X.statsOn then
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= S.UI.ScreenGui and gui ~= renderGui and gui ~= statsGui and gui.Name ~= "DeltaHubLoadingGui" then
				gui.Enabled = false
			end
		end
	else
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui ~= renderGui then
				gui.Enabled = true
			end
		end
	end
end)
paintStats(X.statsOn)

setProgress(96, "Extras", "Bucles finales...")

if not S._extrasLoopsStarted then
	S._extrasLoopsStarted = true
	task.spawn(function()
		while true do
			task.wait(0.3)
			if X.antiDeco then
				deleteNamed({ "Decorations", "Props" })
			end
			if X.antiHall then
				deleteNamed({ "Halloween", "HallowenMeshes" })
			end
			if X.antiKeys then
				hideKeycaps()
			end
		end
	end)

	local fpsFrames, fpsLast = 0, tick()
	task.spawn(function()
		while true do
			task.wait(1)
			if X.statsOn then
				local farm = S.Farm or {}
				local ev = S.Events or {}
				cardStats.Text = "Wins ruta: " .. formatWins(farm.routeWinsSession or 0)
					.. "\nSesion: " .. tostring(math.floor(tick() - sessionStart)) .. "s"
					.. "\nSpecialKeys: " .. tostring(ev.specialKeyCount or 0)
					.. " | Wins keys: " .. formatWins(ev.specialKeyWins or 0)
				fpsFrames = fpsFrames + 1
				local now = tick()
				if now - fpsLast >= 1 then
					local fps = math.floor(fpsFrames / math.max(0.001, now - fpsLast))
					local ping = 0
					pcall(function() ping = player:GetNetworkPing() * 1000 end)
					local mb = 0
					pcall(function()
						if stats then mb = math.floor(stats().lua.mem / 1024) end
					end)
					perfCard.Text = "FPS: " .. fps .. "\nMS: " .. math.floor(ping) .. "\nMB: " .. mb
					fpsFrames = 0
					fpsLast = now
				end
			end
		end
	end)
end

setProgress(99, "Extras", "Finalizando...")

task.spawn(function()
	task.wait(0.15)
	if S.fadeAndDestroyLoading then
		S.fadeAndDestroyLoading()
	else
		S.scriptReady = true
		if S.UI.LoadingGui then
			pcall(function() S.UI.LoadingGui:Destroy() end)
		end
	end
	if S.UI.MainFrame then
		S.UI.MainFrame.Visible = true
	end
	if S.UI.Sidebar then
		S.UI.Sidebar.Visible = true
	end
	if S.UI.Pages then
		for _, p in pairs(S.UI.Pages) do
			if typeof(p) == "Instance" then p.Visible = false end
		end
		if S.UI.Pages.Farm then
			S.UI.Pages.Farm.Visible = true
		end
	end
	if S.UI.SectionTitle then
		S.UI.SectionTitle.Text = "Farm"
	end
	S.scriptReady = true
	notify("Hallowen world listo")
	setProgress(100, "Listo", "Delta Hub activo")
end)
