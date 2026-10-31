-- DELTA HUB tab_farm: cerebro + UI por separado, con errores claros
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
	if S.httpGet then
		return S.httpGet(name)
	end
	local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
	local ok, body = pcall(function() return game:HttpGet(BASE .. name) end)
	if ok and type(body) == "string" and #body > 40 and not body:find("<!DOCTYPE") then
		return body
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

-- 1) Cerebro
if not runFile("farm_brain.lua", "Cargando cerebro (movimiento)...", 51) then
	return
end
if not (S.Brain and S.Brain.startRoute) then
	setProgress(52, "Error", "Cerebro incompleto")
	reportError("farm_brain", "S.Brain.startRoute no existe despues de cargar")
	return
end
reportOk("S.Brain listo")

-- 2) UI
if not runFile("farm_ui.lua", "Cargando pestaña Farm...", 54) then
	reportError("farm_ui", "intento fallback farm_a")
	if not runFile("farm_a.lua", "Cargando interfaz (fallback)...", 54) then
		return
	end
end

if not (S.UI and S.UI.ContentArea) then
	setProgress(55, "Error", "Hub UI incompleto")
	reportError("farm_ui", "S.UI.ContentArea no existe (hub no se creo)")
	return
end
reportOk("Hub UI listo (ContentArea OK)")
setProgress(58, "Farm", "Pestaña Farm lista")

-- 3) Player
task.spawn(function()
	task.wait(0.15)
	setProgress(60, "Farm", "Cargando pestaña Player...")
	local body, herr = http("tab_player.lua")
	if not body then
		setProgress(62, "Error", "No descargo tab_player")
		reportError("descarga tab_player.lua", herr)
		return
	end
	reportOk("tab_player descargado (" .. #body .. "b)")
	local fn, lerr = loadstring(body)
	if not fn then
		setProgress(62, "Error", "loadstring tab_player")
		reportError("loadstring tab_player", tostring(lerr))
		return
	end
	setProgress(63, "Farm", "Iniciando Player...")
	local ok, runErr = pcall(fn)
	if not ok then
		setProgress(63, "Error", "Error en tab_player")
		reportError("ejecutar tab_player", tostring(runErr))
		return
	end
	reportOk("tab_player OK")
end)
