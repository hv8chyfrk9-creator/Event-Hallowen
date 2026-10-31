-- DELTA HUB tab_farm: carga CEREBRO y UI por separado (2 chunks)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end

local function http(name)
	if S.httpGet then return S.httpGet(name) end
	local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
	local ok, body = pcall(function() return game:HttpGet(BASE .. name) end)
	if ok and type(body) == "string" and #body > 40 and not body:find("<!DOCTYPE") then return body end
	return nil
end

local function runFile(name, label, pct)
	setProgress(pct, "Farm", label)
	local body = http(name)
	if not body then
		warn("[Delta Hub] no", name)
		setProgress(pct, "Error", "No se pudo cargar: " .. label)
		return false
	end
	local fn, err = loadstring(body)
	if not fn then
		warn("[Delta Hub] loadstring", name, err)
		setProgress(pct, "Error", "Error: " .. label)
		return false
	end
	local ok, runErr = pcall(fn)
	if not ok then
		warn("[Delta Hub] run", name, runErr)
		setProgress(pct, "Error", "Error al iniciar: " .. label)
		return false
	end
	return true
end

-- 1) Cerebro (movimiento) — chunk propio
if not runFile("farm_brain.lua", "Cargando sistema de movimiento...", 51) then return end

-- 2) UI Farm — otro chunk
if not runFile("farm_ui.lua", "Cargando pestaña Farm...", 54) then
	-- fallback UI antigua si farm_ui no existe
	if not runFile("farm_a.lua", "Cargando interfaz (fallback)...", 54) then return end
end

setProgress(58, "Farm", "Pestaña Farm lista")

-- Encadenar Player
task.spawn(function()
	task.wait(0.2)
	setProgress(60, "Farm", "Cargando pestaña Player...")
	local body = http("tab_player.lua")
	if not body then
		setProgress(62, "Error", "No se pudo cargar Player")
		return
	end
	local fn, err = loadstring(body)
	if not fn then warn("[Delta Hub] tab_player", err) return end
	setProgress(63, "Farm", "Iniciando Player...")
	pcall(fn)
end)
