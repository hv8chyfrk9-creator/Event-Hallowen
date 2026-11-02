-- DELTA HUB tab_farm: cerebro + UI + player + events + extras
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
local function reportOk(m)
	if S.reportOk then S.reportOk(m) end
end
local function reportError(step, detail)
	if S.reportError then S.reportError(step, detail) end
end

local function http(name)
	if S.httpGet then return S.httpGet(name) end
	local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
	local ok, body = pcall(function() return game:HttpGet(BASE .. name) end)
	if ok and type(body) == "string" and #body > 40 then
		local head = string.lower(string.sub(body, 1, 80))
		if not string.find(head, "<html", 1, true) then return body end
	end
	return nil, "HttpGet fallo: " .. name
end

local function runFile(name, label, pct)
	setProgress(pct, "Farm", label)
	local body, herr = http(name)
	if not body then
		setProgress(pct, "Error", "No descargo: " .. name)
		reportError("descarga " .. name, herr or label)
		return false
	end
	reportOk(name .. " descargado (" .. #body .. "b)")
	local fn, lerr = loadstring(body)
	if not fn then
		setProgress(pct, "Error", "loadstring fallo: " .. name)
		reportError("loadstring " .. name, tostring(lerr))
		return false
	end
	local ok, runErr = pcall(fn)
	if not ok then
		setProgress(pct, "Error", "Error al ejecutar: " .. name)
		reportError("ejecutar " .. name, tostring(runErr))
		return false
	end
	reportOk(name .. " OK")
	return true
end

local function showUI()
	pcall(function()
		if S.UI.MainFrame then S.UI.MainFrame.Visible = true end
		if S.UI.Sidebar then S.UI.Sidebar.Visible = true end
		if S.UI.FloatingLogo then S.UI.FloatingLogo.Visible = false end
		if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Farm" end
		if S.UI.FarmPage then S.UI.FarmPage.Visible = true end
	end)
end

if not runFile("farm_brain.lua", "Cargando cerebro (movimiento)...", 51) then return end
if not (S.Brain and S.Brain.startRoute) then
	setProgress(52, "Error", "Cerebro incompleto")
	reportError("farm_brain", "S.Brain.startRoute no existe")
	return
end
reportOk("S.Brain listo")

if not runFile("farm_ui.lua", "Cargando pestaña Farm...", 54) then
	if not runFile("farm_a.lua", "Cargando interfaz (fallback)...", 54) then return end
end
if not (S.UI and S.UI.ContentArea) then
	setProgress(55, "Error", "Hub UI incompleto")
	reportError("farm_ui", "S.UI.ContentArea no existe")
	return
end
reportOk("Hub UI listo")
showUI() -- CRÍTICO: mostrar ya
setProgress(58, "Farm", "Pestaña Farm lista")

task.spawn(function()
	task.wait(0.1)
	runFile("tab_player.lua", "Cargando Player...", 62)
	task.wait(0.1)
	runFile("tab_events.lua", "Cargando Events...", 70)
	task.wait(0.1)
	runFile("tab_extras.lua", "Cargando Extras...", 80)
	task.wait(0.1)
	runFile("runtime_fixes.lua", "Parches UI...", 90)
	showUI()
	S.scriptReady = true
	setProgress(100, "Listo", "Delta Hub activo")
	if S.fadeAndDestroyLoading then
		task.delay(0.4, function() S.fadeAndDestroyLoading() end)
	end
	reportOk("Carga completa")
end)
