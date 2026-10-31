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
S._logLines = S._logLines or {}

if game.PlaceId ~= HALLOWEEN_PLACE_ID and not getgenv().DeltaHubForceLoad then
	warn("[Delta Hub] PlaceId incorrecto:", game.PlaceId)
	return
end

S.targetNamesToDestroy = {
	"TarantulaS13", "WindZonesS14", "Lava_Stage15",
	"MovingWallsS6", "EyeLaserStageS10", "Zone", "TwompsS7",
}

function S.log(msg, level)
	level = level or "INFO"
	local line = string.format("[%s] %s", level, tostring(msg))
	table.insert(S._logLines, line)
	if #S._logLines > 120 then table.remove(S._logLines, 1) end
	pcall(function()
		local term = S.UI and S.UI.DebugTerm
		local scroll = S.UI and S.UI.DebugScroll
		if term then
			term.Text = table.concat(S._logLines, "\n")
			task.defer(function()
				if not scroll or not scroll.Parent then return end
				local absY = term.AbsoluteSize.Y
				if absY < 1 then absY = #S._logLines * 14 end
				scroll.CanvasSize = UDim2.new(0, 0, 0, math.max(absY + 20, scroll.AbsoluteSize.Y))
				local maxScroll = math.max(0, scroll.CanvasSize.Y.Offset - scroll.AbsoluteSize.Y)
				scroll.CanvasPosition = Vector2.new(0, maxScroll)
			end)
		end
	end)
	pcall(function() print("[DeltaHub]", line) end)
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

	local loadFrame = Instance.new("Frame")
	loadFrame.Name = "LoadPanel"
	loadFrame.Parent = bg
	loadFrame.Size = UDim2.new(0.42, 0, 0.7, 0)
	loadFrame.Position = UDim2.new(0.04, 0, 0.15, 0)
	loadFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	loadFrame.BorderSizePixel = 0
	Instance.new("UICorner", loadFrame).CornerRadius = UDim.new(0, 10)
	local loadStroke = Instance.new("UIStroke")
	loadStroke.Parent = loadFrame
	loadStroke.Color = Color3.fromRGB(50, 50, 60)
	loadStroke.Thickness = 1

	local title = Instance.new("TextLabel")
	title.Parent = loadFrame
	title.Size = UDim2.new(1, -32, 0, 36)
	title.Position = UDim2.new(0, 16, 0, 24)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "Delta Hub"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 28
	title.TextXAlignment = Enum.TextXAlignment.Left

	local sub = Instance.new("TextLabel")
	sub.Name = "Sub"
	sub.Parent = loadFrame
	sub.Size = UDim2.new(1, -32, 0, 28)
	sub.Position = UDim2.new(0, 16, 0, 70)
	sub.BackgroundTransparency = 1
	sub.Font = Enum.Font.Gotham
	sub.Text = "Iniciando..."
	sub.TextColor3 = Color3.fromRGB(180, 180, 190)
	sub.TextSize = 16
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextWrapped = true
	S.UI.LoadingSub = sub

	local barBg = Instance.new("Frame")
	barBg.Parent = loadFrame
	barBg.Size = UDim2.new(1, -32, 0, 14)
	barBg.Position = UDim2.new(0, 16, 0, 120)
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
	pct.Parent = loadFrame
	pct.Size = UDim2.new(1, -32, 0, 28)
	pct.Position = UDim2.new(0, 16, 0, 145)
	pct.BackgroundTransparency = 1
	pct.Font = Enum.Font.GothamBold
	pct.Text = "0.0%"
	pct.TextColor3 = Color3.fromRGB(220, 220, 230)
	pct.TextSize = 18
	pct.TextXAlignment = Enum.TextXAlignment.Left
	S.UI.LoadingPct = pct

	local hint = Instance.new("TextLabel")
	hint.Parent = loadFrame
	hint.Size = UDim2.new(1, -32, 0, 40)
	hint.Position = UDim2.new(0, 16, 1, -60)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.Text = "La terminal de la derecha muestra cada paso y error."
	hint.TextColor3 = Color3.fromRGB(120, 120, 130)
	hint.TextSize = 12
	hint.TextXAlignment = Enum.TextXAlignment.Left
	hint.TextWrapped = true

	local termFrame = Instance.new("Frame")
	termFrame.Name = "DebugTermFrame"
	termFrame.Parent = bg
	termFrame.Size = UDim2.new(0.46, 0, 0.7, 0)
	termFrame.Position = UDim2.new(0.50, 0, 0.15, 0)
	termFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	termFrame.BorderSizePixel = 0
	Instance.new("UICorner", termFrame).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke")
	stroke.Parent = termFrame
	stroke.Color = Color3.fromRGB(50, 50, 60)
	stroke.Thickness = 1
	S.UI.DebugTermFrame = termFrame
	S._termExpanded = true
	S._termFullSize = UDim2.new(0.46, 0, 0.7, 0)
	S._termMiniSize = UDim2.new(0.46, 0, 0, 36)

	local termTitle = Instance.new("TextLabel")
	termTitle.Parent = termFrame
	termTitle.Size = UDim2.new(1, -80, 0, 28)
	termTitle.Position = UDim2.new(0, 10, 0, 4)
	termTitle.BackgroundTransparency = 1
	termTitle.Font = Enum.Font.GothamBold
	termTitle.Text = "Terminal / Debug"
	termTitle.TextColor3 = Color3.fromRGB(120, 200, 120)
	termTitle.TextSize = 13
	termTitle.TextXAlignment = Enum.TextXAlignment.Left

	local minBtn = Instance.new("TextButton")
	minBtn.Name = "MinBtn"
	minBtn.Parent = termFrame
	minBtn.Size = UDim2.new(0, 60, 0, 24)
	minBtn.Position = UDim2.new(1, -70, 0, 6)
	minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	minBtn.Font = Enum.Font.GothamBold
	minBtn.Text = "Min"
	minBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
	minBtn.TextSize = 11
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 5)
	minBtn.MouseButton1Click:Connect(function()
		S._termExpanded = not S._termExpanded
		if S._termExpanded then
			termFrame.Size = S._termFullSize
			minBtn.Text = "Min"
			if S.UI.DebugScroll then S.UI.DebugScroll.Visible = true end
		else
			termFrame.Size = S._termMiniSize
			minBtn.Text = "Max"
			if S.UI.DebugScroll then S.UI.DebugScroll.Visible = false end
		end
	end)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "DebugScroll"
	scroll.Parent = termFrame
	scroll.Size = UDim2.new(1, -16, 1, -40)
	scroll.Position = UDim2.new(0, 8, 0, 34)
	scroll.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
	scroll.BackgroundTransparency = 0.3
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 8
	scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 100)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)
	S.UI.DebugScroll = scroll

	local term = Instance.new("TextLabel")
	term.Name = "DebugTerm"
	term.Parent = scroll
	term.Size = UDim2.new(1, -12, 0, 0)
	term.Position = UDim2.new(0, 6, 0, 4)
	term.AutomaticSize = Enum.AutomaticSize.Y
	term.BackgroundTransparency = 1
	term.Font = Enum.Font.Code
	term.Text = ""
	term.TextColor3 = Color3.fromRGB(180, 220, 180)
	term.TextSize = 11
	term.TextXAlignment = Enum.TextXAlignment.Left
	term.TextYAlignment = Enum.TextYAlignment.Top
	term.TextWrapped = true
	S.UI.DebugTerm = term
end

function S.setProgress(p, title, sub)
	if p ~= nil then S.loadProgress = math.clamp(tonumber(p) or 0, 0, 100) end
	if S.UI.LoadingBar then S.UI.LoadingBar.Size = UDim2.new((S.loadProgress or 0) / 100, 0, 1, 0) end
	if S.UI.LoadingPct then S.UI.LoadingPct.Text = string.format("%.1f%%", S.loadProgress or 0) end
	if S.UI.LoadingSub and sub then S.UI.LoadingSub.Text = tostring(sub) end
	if sub then S.log(string.format("%.1f%% | %s", S.loadProgress or 0, tostring(sub)), "LOAD") end
end

function S.fadeAndDestroyLoading()
	local gui = S.UI.LoadingGui
	if not gui then return end
	S.log("Carga completa. Cerrando pantalla...", "OK")
	task.wait(0.6)
	local bg = gui:FindFirstChildOfClass("Frame")
	if bg then for i = 0, 10 do bg.BackgroundTransparency = i / 10; task.wait(0.08) end end
	pcall(function() gui:Destroy() end)
	S.UI.LoadingGui = nil
	S.UI.DebugTerm = nil
end

function S.httpGet(nameOrUrl)
	local urls = {}
	if type(nameOrUrl) == "string" and nameOrUrl:find("^https?://") then
		urls = { nameOrUrl, nameOrUrl .. (nameOrUrl:find("%?") and "&" or "?") .. "t=" .. tostring(math.floor(tick())) }
		local path = nameOrUrl:match("raw%.githubusercontent%.com/[^/]+/[^/]+/[^/]+/(.+)$")
		if path then table.insert(urls, 2, "https://cdn.jsdelivr.net/gh/" .. REPO .. "@main/" .. path) end
	else
		local name = tostring(nameOrUrl)
		urls = {
			BASE .. name,
			"https://cdn.jsdelivr.net/gh/" .. REPO .. "@main/" .. name,
			BASE .. name .. "?t=" .. tostring(math.floor(tick())),
		}
	end
	local function isValid(body)
		if type(body) ~= "string" or #body < 40 then return false end
		if body:find("<!DOCTYPE") or body:find("<html") then return false end
		if body:find("PLACEHOLDER") then return false end
		return true
	end
	local function tryOne(url)
		local ok, body = pcall(function() return game:HttpGet(url) end)
		if ok and isValid(body) then return body, "HttpGet" end
		local err1 = not ok and tostring(body) or ("len=" .. tostring(body and #body))
		ok, body = pcall(function() return game:HttpGet(url, true) end)
		if ok and isValid(body) then return body, "HttpGet/true" end
		local err2 = not ok and tostring(body) or ("len=" .. tostring(body and #body))
		local reqFn = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
		if type(reqFn) == "function" then
			ok, body = pcall(function()
				local res = reqFn({ Url = url, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } })
				if type(res) == "table" then return res.Body or res.body end
				return nil
			end)
			if ok and isValid(body) then return body, "request" end
			err2 = err2 .. " | req=" .. tostring(not ok and body or (body and #body))
		end
		return nil, err1 .. " / " .. err2
	end
	S.log("Descargando: " .. tostring(nameOrUrl):sub(1, 60), "HTTP")
	for i, url in ipairs(urls) do
		local body, info = tryOne(url)
		if body then
			S.log(string.format("OK %s (%d bytes) via %s", tostring(nameOrUrl):match("([^/]+)$") or tostring(nameOrUrl), #body, info), "OK")
			return body
		end
		S.log(string.format("Fallo mirror %d: %s", i, tostring(info):sub(1, 90)), "WARN")
		task.wait(0.2)
	end
	S.log("FALLO total: " .. tostring(nameOrUrl):sub(1, 50), "ERR")
	return nil
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
	for i = 1, #(frames or {}) do
		local m = modes[i]
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
S.log("Delta Hub init iniciado", "OK")
S.log("PlaceId=" .. tostring(game.PlaceId), "INFO")
S.setProgress(2, "Init", "Preparando mundo...")

S.routeCFrames = S.routeCFrames or {}
S.routeModes = S.routeModes or {}
do
	local function loadPart(name)
		S.log("Ruta: " .. name, "LOAD")
		local body = S.httpGet(name)
		if body then
			local fn, err = loadstring(body)
			if fn then
				local ok, e = pcall(fn)
				if not ok then S.log("Error ruta " .. name .. ": " .. tostring(e), "ERR") end
			else
				S.log("loadstring ruta: " .. tostring(err), "ERR")
			end
		end
	end
	loadPart("route_data.lua")
	loadPart("route_data_ext.lua")
	loadPart("route_data_ext2.lua")
	S.log("CFrames cargados: " .. tostring(#(S.routeCFrames or {})), "OK")
end

S.setProgress(8, "Init", "Limpieza del mapa...")

local cleanupChoice = "normal"
do
	local gui = S.UI.LoadingGui
	local holder = Instance.new("Frame")
	holder.Parent = gui
	holder.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	holder.Position = UDim2.new(0.05, 0, 0.55, 0)
	holder.Size = UDim2.new(0, 280, 0, 168)
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
	S.log("Limpieza elegida: " .. cleanupChoice, "OK")
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
	S.log("Limpieza frames: " .. tostring(total) .. " step=" .. tostring(step), "INFO")
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
	S.setProgress(48, "Init", "Cargando interfaz...")
	S.log("Descargando tab_farm.lua ...", "LOAD")
	local body = S.httpGet("tab_farm.lua")
	if not body then
		S.setProgress(50, "Error", "No se pudo cargar la interfaz")
		S.log("tab_farm.lua NO descargado", "ERR")
		return
	end
	local fn, err = loadstring(body)
	if not fn then
		S.log("loadstring tab_farm: " .. tostring(err), "ERR")
		S.setProgress(50, "Error", "Error al preparar interfaz")
		return
	end
	S.setProgress(50, "Init", "Iniciando interfaz...")
	S.log("Ejecutando tab_farm...", "LOAD")
	local ok, runErr = pcall(fn)
	if not ok then
		S.log("Error tab_farm run: " .. tostring(runErr), "ERR")
		S.setProgress(50, "Error", "Error al iniciar interfaz")
	else
		S.log("tab_farm OK", "OK")
	end
end)
