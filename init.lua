-- ==========================================
-- DELTA HUB - Event Hallowen - init.lua
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local HALLOWEEN_PLACE_ID = 128614435234859
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local REPO = "hv8chyfrk9-creator/Event-Hallowen"

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
	title.TextSize = 22
	local sub = Instance.new("TextLabel")
	sub.Name = "Sub"
	sub.Parent = bg
	sub.Size = UDim2.new(1, -40, 0, 22)
	sub.Position = UDim2.new(0, 20, 0.42, 34)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.Gotham
	sub.Text = "Iniciando..."
	sub.TextColor3 = Color3.fromRGB(180, 180, 190)
	sub.TextSize = 14
	S.UI.LoadingSub = sub
	local barBg = Instance.new("Frame")
	barBg.Parent = bg
	barBg.Size = UDim2.new(0.55, 0, 0, 12)
	barBg.Position = UDim2.new(0.225, 0, 0.42, 68)
	barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 6)
	local bar = Instance.new("Frame")
	bar.Name = "Bar"
	bar.Parent = barBg
	bar.Size = UDim2.new(0, 0, 1, 0)
	bar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 6)
	S.UI.LoadingBar = bar
	local pct = Instance.new("TextLabel")
	pct.Name = "Pct"
	pct.Parent = bg
	pct.Size = UDim2.new(1, -40, 0, 20)
	pct.Position = UDim2.new(0, 20, 0.42, 88)
	pct.BackgroundTransparency = 1
	pct.Font = Enum.Font.GothamBold
	pct.Text = "0.0%"
	pct.TextColor3 = Color3.fromRGB(220, 220, 230)
	pct.TextSize = 13
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
	if bg then for i = 0, 10 do bg.BackgroundTransparency = i / 10; task.wait(0.06) end end
	pcall(function() gui:Destroy() end)
	S.UI.LoadingGui = nil
end

function S.httpGet(nameOrUrl)
	local urls = {}
	if type(nameOrUrl) == "string" and nameOrUrl:find("^https?://") then
		urls = { nameOrUrl, nameOrUrl .. (nameOrUrl:find("%?") and "&" or "?") .. "t=" .. tostring(math.floor(tick())) }
	else
		local name = tostring(nameOrUrl)
		urls = {
			BASE .. name,
			"https://cdn.jsdelivr.net/gh/" .. REPO .. "@main/" .. name,
			BASE .. name .. "?t=" .. tostring(math.floor(tick())),
		}
	end
	local function isValid(body)
		return type(body) == "string" and #body >= 40 and not body:find("<!DOCTYPE") and not body:find("PLACEHOLDER")
	end
	for _, url in ipairs(urls) do
		local ok, body = pcall(function() return game:HttpGet(url) end)
		if ok and isValid(body) then return body end
		ok, body = pcall(function() return game:HttpGet(url, true) end)
		if ok and isValid(body) then return body end
		local reqFn = (syn and syn.request) or (http and http.request) or http_request or request
		if type(reqFn) == "function" then
			ok, body = pcall(function()
				local res = reqFn({ Url = url, Method = "GET" })
				return type(res) == "table" and (res.Body or res.body) or nil
			end)
			if ok and isValid(body) then return body end
		end
		task.wait(0.15)
	end
	return nil
end

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
	task.wait(0.3)
	if hrp and returnCf then hrp.CFrame = returnCf; hrp.AssemblyLinearVelocity = Vector3.zero end
	if newHum and newHum.Health <= 0 then return S.waitAliveHrp(returnCf) end
	return hrp
end

function S.runExactCleanup()
	for _, obj in pairs(Workspace:GetDescendants()) do
		local name = obj.Name
		for i = 1, #S.targetNamesToDestroy do
			if name == S.targetNamesToDestroy[i] then pcall(function() obj:Destroy() end) end
		end
		if string.sub(name, 1, 4) == "Pair" then pcall(function() obj:Destroy() end) end
	end
end

function S.getRouteIndicesForMode(mode)
	local key = "normal"
	if mode == "fast" then key = "fast"
	elseif mode == "ultra" or mode == "super" then key = "super" end
	local frames, modes, idxs = S.routeCFrames, S.routeModes, {}
	for i = 1, #(frames or {}) do
		local m = modes and modes[i]
		if not m or m[key] then idxs[#idxs + 1] = i end
	end
	if #idxs == 0 then for i = 1, #(frames or {}) do idxs[i] = i end end
	return idxs
end

function S.getRouteCFramesForMode(mode)
	local idxs = S.getRouteIndicesForMode(mode)
	local frames, list = S.routeCFrames or {}, {}
	for i = 1, #idxs do list[i] = frames[idxs[i]] end
	return list, idxs
end

createLoadingUi()
S.setProgress(2, "Init", "Preparando mundo...")

S.routeCFrames = S.routeCFrames or {}
S.routeModes = S.routeModes or {}
do
	local function loadPart(name)
		local body = S.httpGet(name)
		if body then
			local fn = loadstring(body)
			if fn then pcall(fn) end
		end
	end
	loadPart("route_data.lua")
	loadPart("route_data_ext.lua")
	loadPart("route_data_ext2.lua")
end

-- Limpieza automática (sin menú): modo fast
S.setProgress(10, "Init", "Limpieza del mapa...")
local cleanupChoice = "fast"
local routeForClean = select(1, S.getRouteCFramesForMode(cleanupChoice))
if not routeForClean or #routeForClean == 0 then routeForClean = S.routeCFrames end
local step, waitTime = 3, 0.2

task.spawn(function()
	local function getHrp()
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp and hum and hum.Health > 0 then return hrp end
		return S.waitAliveHrp(nil)
	end
	local hrp = getHrp()
	local total = (routeForClean and #routeForClean) or 0
	if hrp and routeForClean and total > 0 then
		local i = 1
		while i <= total do
			hrp = getHrp()
			if not hrp then task.wait(0.4)
			else
				pcall(function() hrp.AssemblyLinearVelocity = Vector3.zero; hrp.CFrame = routeForClean[i] end)
				S.runExactCleanup()
				S.setProgress(10 + (i / total) * 35, "Init", "Limpieza " .. i .. "/" .. total)
				task.wait(waitTime)
				local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if h and h.Health <= 0 then getHrp(); task.wait(0.25) else i = i + step end
			end
		end
	end
	S.runExactCleanup()

	S.setProgress(48, "Init", "Cargando interfaz...")
	local body = S.httpGet("tab_farm.lua")
	if not body then
		S.setProgress(50, "Error", "No se pudo cargar la interfaz")
		return
	end
	local fn, err = loadstring(body)
	if not fn then
		S.setProgress(50, "Error", "Error al preparar interfaz")
		warn(err)
		return
	end
	S.setProgress(50, "Init", "Iniciando...")
	local ok, runErr = pcall(fn)
	if not ok then
		S.setProgress(50, "Error", "Error al iniciar")
		warn(runErr)
	end
end)
