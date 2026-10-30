-- ==========================================
-- DELTA HUB - Event Hallowen - init.lua (Archivo 1)
-- 0% -> 50%: datos + limpieza + encadena tab_farm.lua
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	warn("[Delta Hub] No PlayerGui")
	return
end

local HALLOWEEN_PLACE_ID = 128614435234859
local NEXT_URL = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/tab_farm.lua"
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	S = {}
	getgenv().DeltaHub = S
end
S.world = "hallowen"
S.placeId = HALLOWEEN_PLACE_ID
S.scriptReady = false
S.loadProgress = 0
S.UI = S.UI or {}
S.Signals = S.Signals or {}
S.BASE_URL = BASE

-- ---------- PlaceId ----------
local function checkPlaceId()
	if game.PlaceId == HALLOWEEN_PLACE_ID then
		return true
	end
	if getgenv().DeltaHubForceLoad then
		return true
	end
	return false
end

if not checkPlaceId() then
	warn("[Delta Hub] PlaceId incorrecto:", game.PlaceId, "esperado", HALLOWEEN_PLACE_ID)
	return
end

-- ---------- Cleanup list ----------
S.targetNamesToDestroy = {
	"TarantulaS13",
	"WindZonesS14",
	"Lava_Stage15",
	"MovingWallsS6",
	"EyeLaserStage10",
	"Zone",
	"TwompsS7",
}

-- ---------- Datos del mundo (CFrames en route_data.lua) ----------
S.routeCFrames = S.routeCFrames or {}
S.routeModes = S.routeModes or {}
do
	local url = BASE .. "route_data.lua"
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and type(body) == "string" and #body > 50 and not body:find("<!DOCTYPE") then
		local fn, err = loadstring(body)
		if fn then
			local ok2, e2 = pcall(fn)
			if not ok2 then warn("[Delta Hub] route_data run", e2) end
		else
			warn("[Delta Hub] route_data load", err)
		end
	else
		warn("[Delta Hub] route_data download failed")
	end
end

-- WinBlocks
S.orderedWinBlocks = {
	{ real = "WinBlock1", display = "+1 Wins", order = 1 },
	{ real = "WinBlock2", display = "+5 Wins", order = 2 },
	{ real = "WinBlock3", display = "+10 Wins", order = 3 },
	{ real = "WinBlock4", display = "+25 Wins", order = 4 },
	{ real = "WinBlock5", display = "+50 Wins", order = 5 },
	{ real = "WinBlock6", display = "+100 Wins", order = 6 },
	{ real = "WinBlock7", display = "+250 Wins", order = 7 },
	{ real = "WinBlock8", display = "+500 Wins", order = 8 },
	{ real = "WinBlock9", display = "+1K Wins", order = 9 },
	{ real = "WinBlock10", display = "+2.5K Wins", order = 10 },
	{ real = "WinBlock11", display = "+5K Wins", order = 11 },
	{ real = "WinBlock12", display = "+10K Wins", order = 12 },
	{ real = "WinBlock13", display = "+25K Wins", order = 13 },
	{ real = "WinBlock14", display = "+50K Wins", order = 14 },
	{ real = "WinBlock15", display = "+100K Wins", order = 15 },
}

function S.waitAliveHrp(returnCf)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and hum and hum.Health > 0 then
		return hrp
	end
	if not char or not hum or hum.Health <= 0 then
		player.CharacterAdded:Wait()
	end
	char = player.Character
	if not char then
		return nil
	end
	hrp = char:WaitForChild("HumanoidRootPart", 8)
	local newHum = char:WaitForChild("Humanoid", 8)
	task.wait(0.35)
	if hrp and returnCf then
		hrp.CFrame = returnCf
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
	if newHum and newHum.Health <= 0 then
		return S.waitAliveHrp(returnCf)
	end
	return hrp
end

function S.runExactCleanup()
	local list = S.targetNamesToDestroy
	if not list then
		return
	end
	for _, obj in pairs(Workspace:GetDescendants()) do
		local name = obj.Name
		for i = 1, #list do
			if name == list[i] then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
		if string.sub(name, 1, 4) == "Pair" then
			pcall(function()
				obj:Destroy()
			end)
		end
	end
end

function S.getRouteIndicesForMode(mode)
	local key = "normal"
	if mode == "fast" then
		key = "fast"
	elseif mode == "ultra" or mode == "super" then
		key = "super"
	end
	local frames = S.routeCFrames
	local modes = S.routeModes
	local idxs = {}
	for i = 1, #frames do
		local m = modes[i]
		if not m or m[key] then
			idxs[#idxs + 1] = i
		end
	end
	if #idxs == 0 then
		for i = 1, #frames do
			idxs[i] = i
		end
	end
	return idxs
end

function S.getRouteCFramesForMode(mode)
	local idxs = S.getRouteIndicesForMode(mode)
	local frames = S.routeCFrames
	local list = {}
	for i = 1, #idxs do
		list[i] = frames[idxs[i]]
	end
	return list, idxs
end

-- ---------- Loading UI (original) ----------
local function createLoadingUi()
	local old = playerGui:FindFirstChild("DeltaHubLoadingGui")
	if old then
		old:Destroy()
	end
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
	bg.BorderSizePixel = 0
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
	p = math.clamp(tonumber(p) or 0, 0, 100)
	S.loadProgress = p
	if S.UI.LoadingBar then
		S.UI.LoadingBar.Size = UDim2.new(p / 100, 0, 1, 0)
	end
	if S.UI.LoadingPct then
		S.UI.LoadingPct.Text = string.format("%.1f%%", p)
	end
	if S.UI.LoadingSub and sub then
		S.UI.LoadingSub.Text = tostring(sub)
	end
end

function S.fadeAndDestroyLoading()
	local gui = S.UI.LoadingGui
	if not gui then return end
	local bg = gui:FindFirstChildOfClass("Frame")
	if bg then
		for i = 0, 10 do
			bg.BackgroundTransparency = i / 10
			task.wait(0.08)
		end
	end
	pcall(function() gui:Destroy() end)
	S.UI.LoadingGui = nil
end

createLoadingUi()
S.setProgress(2, "Init", "Cargando rutas...")
if not S.routeCFrames or #S.routeCFrames == 0 then
	warn("[Delta Hub] Sin CFrames tras route_data")
end
S.setProgress(8, "Init", "Limpieza del mapa...")

local cleanupChoice = "normal"
do
	local gui = S.UI.LoadingGui
	local holder = Instance.new("Frame")
	holder.Parent = gui
	holder.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	holder.Position = UDim2.new(0.5, -140, 0.55, 0)
	holder.Size = UDim2.new(0, 280, 0, 120)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = holder
	local t = Instance.new("TextLabel")
	t.Parent = holder
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, -10, 0, 28)
	t.Position = UDim2.new(0, 5, 0, 6)
	t.Font = Enum.Font.GothamBold
	t.Text = "Limpieza inicial"
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.TextSize = 14
	local chosen = nil
	for i, name in ipairs({ "normal", "fast", "super" }) do
		local b = Instance.new("TextButton")
		b.Parent = holder
		b.Size = UDim2.new(0.9, 0, 0, 26)
		b.Position = UDim2.new(0.05, 0, 0, 30 + (i - 1) * 28)
		b.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		b.Font = Enum.Font.Gotham
		b.Text = name
		b.TextColor3 = Color3.fromRGB(240, 240, 245)
		b.TextSize = 12
		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 5)
		cc.Parent = b
		b.MouseButton1Click:Connect(function()
			chosen = name
		end)
	end
	local t0 = tick()
	while chosen == nil and tick() - t0 < 8 do
		task.wait(0.1)
	end
	cleanupChoice = chosen or "normal"
	holder:Destroy()
end

S.setProgress(15, "Init", "Limpiando (" .. cleanupChoice .. ")...")
local routeForClean = select(1, S.getRouteCFramesForMode(cleanupChoice))
if not routeForClean or #routeForClean == 0 then
	routeForClean = S.routeCFrames
end
local step = 2
if cleanupChoice == "fast" then step = 3
elseif cleanupChoice == "super" then step = 5 end

task.spawn(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 8)
	if hrp and routeForClean then
		for i = 1, #routeForClean, step do
			if hrp and hrp.Parent then
				hrp.CFrame = routeForClean[i]
			end
			S.runExactCleanup()
			local p = 15 + (i / math.max(1, #routeForClean)) * 30
			S.setProgress(p, "Init", "Limpieza " .. i .. "/" .. #routeForClean)
			task.wait(0.05)
		end
	end
	S.runExactCleanup()
	S.setProgress(48, "Init", "Cargando Farm...")
	local ok, body = pcall(function() return game:HttpGet(NEXT_URL) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] init: no tab_farm", body)
		S.setProgress(50, "Error", "Falta tab_farm.lua")
		return
	end
	if body:sub(1, 9) == "<!DOCTYPE" or body:sub(1, 6) == "<html>" then
		warn("[Delta Hub] init: HTML en tab_farm")
		S.setProgress(50, "Error", "Sube tab_farm.lua")
		return
	end
	local fn, err = loadstring(body)
	if not fn then
		warn("[Delta Hub] init loadstring tab_farm", err)
		return
	end
	S.setProgress(50, "Init", "Entrando a Farm...")
	local okRun, runErr = pcall(fn)
	if not okRun then
		warn("[Delta Hub] tab_farm run", runErr)
	end
end)
