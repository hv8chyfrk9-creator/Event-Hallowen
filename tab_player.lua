-- ==========================================
-- DELTA HUB - Event Hallowen - tab_player.lua
-- Solo pestaÃ±a Player | 62.5% -> 75%
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_player: falta hub (tab_farm/init)")
	return
end

S.Player = S.Player or {}
local P = S.Player
P.speedEnabled = P.speedEnabled or false
P.jumpEnabled = P.jumpEnabled or false
P.noclipEnabled = P.noclipEnabled or false
P.infJumpEnabled = P.infJumpEnabled or false
P.customSpeed = P.customSpeed or 16
P.customJump = P.customJump or 50

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local NEXT_URL = BASE .. "tab_events.lua"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

setProgress(64, "Player", "Creando pestaÃ±a Player...")

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

local function makeBox(parent, placeholder, text, order)
	local t = Instance.new("TextBox")
	t.Parent = parent
	t.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	t.Size = UDim2.new(1, -4, 0, 32)
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

-- Page
local playerPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Player = playerPage
S.UI.PlayerPage = playerPage

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

local tabPlayer = makeTabButton("Player", 2)
S.UI.TabPlayer = tabPlayer
tabPlayer.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	playerPage.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Player" end
end)

setProgress(68, "Player", "Movimiento...")

-- Movement section
local moveBody = section(playerPage, "Movimiento", 1)

local _, paintSpeed, speedHit = makeSwitch(moveBody, "Speed boost", 1)
local speedBox = makeBox(moveBody, "WalkSpeed (1-1000)", tostring(P.customSpeed), 2)
speedBox.FocusLost:Connect(function()
	P.customSpeed = math.clamp(tonumber(speedBox.Text) or P.customSpeed or 16, 1, 1000)
	speedBox.Text = tostring(P.customSpeed)
end)
speedHit.MouseButton1Click:Connect(function()
	P.speedEnabled = not P.speedEnabled
	paintSpeed(P.speedEnabled)
	if not P.speedEnabled then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			-- devolver control al juego (valor tipico)
			hum.WalkSpeed = 16
		end
	end
end)
paintSpeed(P.speedEnabled)

local _, paintJump, jumpHit = makeSwitch(moveBody, "Jump power", 3)
local jumpBox = makeBox(moveBody, "JumpPower (1-500)", tostring(P.customJump), 4)
jumpBox.FocusLost:Connect(function()
	P.customJump = math.clamp(tonumber(jumpBox.Text) or P.customJump or 50, 1, 500)
	jumpBox.Text = tostring(P.customJump)
end)
jumpHit.MouseButton1Click:Connect(function()
	P.jumpEnabled = not P.jumpEnabled
	paintJump(P.jumpEnabled)
	if not P.jumpEnabled then
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = 50
		end
	end
end)
paintJump(P.jumpEnabled)

local _, paintNoclip, noclipHit = makeSwitch(moveBody, "Noclip", 5)
noclipHit.MouseButton1Click:Connect(function()
	P.noclipEnabled = not P.noclipEnabled
	paintNoclip(P.noclipEnabled)
end)
paintNoclip(P.noclipEnabled)

local _, paintInf, infHit = makeSwitch(moveBody, "Infinite jump", 6)
infHit.MouseButton1Click:Connect(function()
	P.infJumpEnabled = not P.infJumpEnabled
	paintInf(P.infJumpEnabled)
end)
paintInf(P.infJumpEnabled)

-- Signal para Farm (noclip en recorrido)
S.Signals.SetNoclip = function(on)
	P.noclipEnabled = on and true or false
	paintNoclip(P.noclipEnabled)
end

setProgress(72, "Player", "Loops de movimiento...")

-- Apply loops
if not S._playerLoopsStarted then
	S._playerLoopsStarted = true
	RunService.Stepped:Connect(function()
		local char = player.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			if P.speedEnabled then
				hum.WalkSpeed = P.customSpeed
			end
			if P.jumpEnabled then
				hum.UseJumpPower = true
				hum.JumpPower = P.customJump
			end
		end
		if P.noclipEnabled then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)

	UserInputService.JumpRequest:Connect(function()
		if not P.infJumpEnabled then return end
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end)
end

-- Init humanoid defaults from character if present
do
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if not P._speedCaptured then
			P.customSpeed = hum.WalkSpeed
			P.customJump = hum.JumpPower
			P._speedCaptured = true
			speedBox.Text = tostring(P.customSpeed)
			jumpBox.Text = tostring(P.customJump)
		end
	end
end

setProgress(74, "Player", "Player lista")

local function loadNext(url)
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] tab_player: no se pudo bajar", url)
		setProgress(75, "Error", "Falta tab_events.lua")
		return
	end
	if body:sub(1, 9) == "<!DOCTYPE" or body:sub(1, 6) == "<html>" then
		warn("[Delta Hub] tab_player: HTML", url)
		setProgress(75, "Error", "Sube tab_events.lua")
		return
	end
	local fn, err = loadstring(body)
	if not fn then
		warn("[Delta Hub] tab_player loadstring", err)
		return
	end
	local okRun, runErr = pcall(fn)
	if not okRun then
		warn("[Delta Hub] tab_events run", runErr)
	end
end

setProgress(75, "Player", "Cargando Events...")
loadNext(NEXT_URL)
