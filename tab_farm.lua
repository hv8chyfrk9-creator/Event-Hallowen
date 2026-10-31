-- DELTA HUB tab_farm thin loader
-- Carga farm_a y farm_b por separado (evita freeze / limite de registros)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end

local function http(u)
	local ok, body = pcall(function()
		return game:HttpGet(u)
	end)
	if not ok or type(body) ~= "string" or #body < 50 then return nil end
	if body:find("<!DOCTYPE") or body:find("PLACEHOLDER") then return nil end
	return body
end

local function runChunk(name, label, pct)
	setProgress(pct, "Farm", label)
	local body = http(BASE .. name)
	if not body then
		warn("[Delta Hub] fallo descarga:", name)
		setProgress(pct, "Error", "No se pudo cargar: " .. label)
		return false
	end
	local fn, err = loadstring(body)
	if not fn then
		warn("[Delta Hub] loadstring", name, err)
		setProgress(pct, "Error", "Error al preparar: " .. label)
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

-- Solo mensajes que ve el jugador
if not runChunk("farm_a.lua", "Cargando interfaz...", 51) then return end
if not runChunk("farm_b.lua", "Cargando pestaña Farm...", 53) then return end

setProgress(56, "Farm", "Pestaña Farm lista")
