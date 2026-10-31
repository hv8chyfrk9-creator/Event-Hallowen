-- ==========================================
-- DELTA HUB - Event Hallowen - init.lua
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local HALLOWEEN_PLACE_ID = 128614435234859
local NEXT_URL = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/tab_farm.lua"
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"

local S = getgenv().DeltaHub
if type(S) ~= "table" then S = {}; getgenv().DeltaHub = S end
S.world = "hallowen"
S.placeId = HALLOWEEN_PLACE_ID
S.scriptReady = false
S.loadProgress = 0
S.UI = S.UI or {}
S.Signals = S.Signals or {}
S.BASE_URL = BASE

if game.PlaceId ~= HALLOWEEN_PLACE_ID and not getgenv().DeltaHubForceLoad then
	warn("[Delta Hub] PlaceId incorrecto:", game.PlaceId)
	return
end

S.targetNamesToDestroy = {
	"TarantulaS13", "WindZonesS14", "Lava_Stage15",
	"MovingWallsS6", "EyeLaserStageS10", "Zone", "TwompsS7",
}

S.routeCFrames = S.routeCFrames or {}
S.routeModes = S.routeModes or {}
do
	local function loadPart(name)
		local ok, body = pcall(function() return game:HttpGet(BASE .. name) end)
		if ok and type(body) == "string" and #body > 50 and not body:find("<!DOCTYPE") then
			local fn = loadstring(body)
			if fn then pcall(fn) end
		end
	end
	loadPart("route_data.lua")
	loadPart("route_data_ext.lua")
	loadPart("route_data_ext2.lua")
end

S.orderedWinBlocks = {
	{ real = "WinBlock1", display = "+1 Wins", order = 1 },
	{ real = "WinBlock2", display = "+3 Wins", order = 2 },
	{ real = "WinBlock3", display = "+10 Wins", order = 3 },
	{ real = "WinBlock4", display = "+20 Wins", order = 4 },
	{ real = "WinBlock5", display = "+50 Wins", order = 5 },
	{ real = "WinBlock6", display = "+100 Wins", order = 6 },
	{ real = "WinBlock7", display = "+150 Wins", order = 7 },
	{ real = "WinBlock8", display = "+300 Wins", order = 8 },
	{ real = "WinBlock9", display = "+500 Wins", order = 9 },
	{ real = "WinBlock10", display = "+1K Wins", order = 10 },
	{ real = "WinBlock11", display = "+2.5K Wins", order = 11 },
	{ real = "WinBlock12", display = "+10K Wins", order = 12 },
	{ real = "WinBlock13", display = "+25K Wins", order = 13 },
	{ real = "WinBlock14", display = "+50K Wins", order = 14 },
	{ real = "WinBlock15", display = "+150K Wins", order = 15 },
}

function S.waitAliveHrp(returnCf)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and hum and hum.Health > 0 then return hrp end
	if not char or not hum or hum.Health <= 0 then player.CharacterAdded:Wait() end
	char = player.Character
	if not char then return nil end
	hrp = char:WaitForChild("HumanoidRootPart", 8)
	local newHum = char:WaitForChild("Humanoid", 8)
	task.wait(0.35)
	if hrp and returnCf then hrp.CFrame = returnCf; hrp.AssemblyLinearVelocity = Vector3.zero end
	if newHum and newHum.Health <= 0 then return S.waitAliveHrp(returnCf) end
	return hrp
end

function S.runExactCleanup()
	local list = S.targetNamesToDestroy
	if not list then return end
	for _, obj in pairs(Workspace:GetDescendants()) do
		local name = obj.Name
		for i = 1, #list do
			if name == list[i] then pcall(function() obj:Destroy() end) end
		end
		if string.sub(name, 1, 4) == "Pair" then pcall(function() obj:Destroy() end) end
	end
end

function S.getRouteIndicesForMode(mode)
	local key = "normal"
	if mode == "fast" then key = "fast"
	elseif mode == "ultra" or mode == "super" then key = "super" end
	local frames, modes, idxs = S.routeCFrames, S.routeModes, {}
	for i = 1, #frames do
		local m = modes[i]
		if not m or m[key] then idxs[#idxs + 1] = i end
	end
	if #idxs == 0 then for i = 1, #frames do idxs[i] = i end end
	return idxs
end

function S.getRouteCFramesForMode(mode)
	local idxs = S.getRouteIndicesForMode(mode)
	local frames, list = S.routeCFrames, {}
	for i = 1, #idxs do list[i] = frames[idxs[i]] end
	return list, idxs
end

local function createLoadingUi()
	local old = playerGui:FindFirstChild("DeltaHubLoadingGui")
	if old then old:Destroy() end
	local gui = Instance.new("ScreenGui")
	gui.Name = "DeltaHubLoadingGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 2000
	gui.Parent = playerGui
	S.UI.LoadingGui = gui
	local bg = Instance.new("Frame")
	bg.Parent = gui
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
	local title = Instance.new("TextLabel")
	title.Parent = bg
	title.Size = UDim2.new(1, -40, 0, 28)
	title.Position = UDim2.new(0, 20, 0.42, 0)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "Delta Hub"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	local sub = Instance.new("TextLabel")
	sub.Name = "Sub"
	sub.Parent = bg
	sub.Size = UDim2.new(1, -40, 0, 22)
	sub.Position = UDim2.new(0, 20, 0.42, 32)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.Gotham
	sub.Text = "Iniciando..."
	sub.TextColor3 = Color3.fromRGB(180, 180, 190)
	sub.TextSize = 13
	S.UI.LoadingSub = sub
	local barBg = Instance.new("Frame")
	barBg.Parent = bg
	barBg.Size = UDim2.new(0.6, 0, 0, 10)
	barBg.Position = UDim2.new(0.2, 0, 0.42, 64)
	barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Parent = barBg
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	S.UI.LoadingBar = bar
	local pct = Instance.new("TextLabel")
	pct.Name = "Pct"
	pct.Parent = bg
	pct.Size = UDim2.new(1, -40, 0, 20)
	pct.Position = UDim2.new(0, 20, 0.42, 80)
	pct.BackgroundTransparency = 1
	pct.Font = Enum.Font.GothamBold
	pct.Text = "0.0%"
	pct.TextColor3 = Color3.fromRGB(220, 220, 230)
	pct.TextSize = 12
	S.UI.LoadingPct = pct
end

function S.setProgress(p, title, sub)
	if p ~= nil then S.loadProgress = math.clamp(tonumber(p) or 0, 0, 100) end
	if S.UI.LoadingBar then S.UI.LoadingBar.Size = UDim2.new((S.loadProgress or 0) / 100, 0, 1, 0) end
	if S.UI.LoadingPct then S.UI.LoadingPct.Text = string.format("%.1f%%", S.loadProgress or 0) end
	if S.UI.LoadingSub and sub then S.UI.LoadingSub.Text = tostring(sub) end
end

function S.fadeAndDestroyLoading()
	local gui = S.UI.LoadingGui
	if not gui then return end
	local bg = gui:FindFirstChildOfClass("Frame")
	if bg then for i = 0, 10 do bg.BackgroundTransparency = i / 10; task.wait(0.08) end end
	pcall(function() gui:Destroy() end)
	S.UI.LoadingGui = nil
end

createLoadingUi()
S.setProgress(2, "Init", "Cargando rutas...")
S.setProgress(8, "Init", "Limpieza del mapa...")

local cleanupChoice = "normal"
do
	local gui = S.UI.LoadingGui
	local holder = Instance.new("Frame")
	holder.Parent = gui
	holder.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	holder.Position = UDim2.new(0.5, -160, 0.55, 0)
	holder.Size = UDim2.new(0, 320, 0, 168)
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
	local title = Instance.new("TextLabel")
	title.Parent = holder
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, -16, 0, 28)
	title.Position = UDim2.new(0, 8, 0, 8)
	title.Font = Enum.Font.GothamBold
	title.Text = "Limpieza inicial"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 15
	local chosen = nil
	for i, opt in ipairs({
		{ key = "normal", label = "Normal  (seguro)", color = Color3.fromRGB(40, 100, 55) },
		{ key = "fast", label = "Rapida", color = Color3.fromRGB(40, 80, 140) },
		{ key = "super", label = "Super rapida", color = Color3.fromRGB(120, 60, 140) },
	}) do
		local b = Instance.new("TextButton")
		b.Parent = holder
		b.Size = UDim2.new(1, -20, 0, 32)
		b.Position = UDim2.new(0, 10, 0, 56 + (i - 1) * 36)
		b.BackgroundColor3 = opt.color
		b.Font = Enum.Font.GothamBold
		b.Text = opt.label
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.TextSize = 13
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(function() chosen = opt.key end)
	end
	local t0 = tick()
	while chosen == nil and tick() - t0 < 12 do task.wait(0.1) end
	cleanupChoice = chosen or "normal"
	holder:Destroy()
end

S.setProgress(12, "Init", "Limpiando (" .. cleanupChoice .. ")...")
local routeForClean = select(1, S.getRouteCFramesForMode(cleanupChoice))
if not routeForClean or #routeForClean == 0 then routeForClean = S.routeCFrames end
local step, waitTime = 2, 0.35
if cleanupChoice == "fast" then step, waitTime = 3, 0.22
elseif cleanupChoice == "super" then step, waitTime = 5, 0.15 end

task.spawn(function()
	local function getHrp()
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and hum and hum.Health > 0 then return hrp end
		S.setProgress(S.loadProgress or 20, "Init", "Reapareciendo...")
		return S.waitAliveHrp and S.waitAliveHrp(nil)
	end
	local hrp = getHrp()
	local total = (routeForClean and #routeForClean) or 0
	if hrp and routeForClean and total > 0 then
		local i = 1
		while i <= total do
			hrp = getHrp()
			if not hrp then task.wait(0.5)
			else
				pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.CFrame = routeForClean[i] end)
				S.runExactCleanup()
				S.setProgress(12 + (i / total) * 33, "Init", "Limpieza " .. i .. "/" .. total)
				task.wait(waitTime)
				local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if h and h.Health <= 0 then getHrp(); task.wait(0.3) else i = i + step end
			end
		end
	end
	S.runExactCleanup()
	S.setProgress(48, "Init", "Cargando Farm...")
	local ok, body = pcall(function() return game:HttpGet(NEXT_URL) end)
	if not ok or type(body) ~= "string" or #body < 20 then S.setProgress(50, "Error", "Falta tab_farm"); return end
	local fn = loadstring(body)
	if not fn then return end
	S.setProgress(50, "Init", "Entrando a Farm...")
	pcall(fn)
end)
