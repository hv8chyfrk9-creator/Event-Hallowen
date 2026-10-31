-- DELTA HUB tab_farm thin loader (solo farm_a + farm_b)
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
	if not ok or type(body) ~= "string" then return nil end
	if #body < 50 then return nil end
	if body:find("<!DOCTYPE") or body:find("PLACEHOLDER") then return nil end
	return body
end

-- 51-54: solo lo que ve el jugador
setProgress(51, "Farm", "Cargando interfaz...")
local a = http(BASE .. "farm_a.lua")
if not a then
	setProgress(52, "Error", "No se pudo cargar la interfaz")
	warn("[Delta Hub] farm_a falló")
	return
end

setProgress(52, "Farm", "Cargando pestaña Farm...")
local b = http(BASE .. "farm_b.lua")
if not b then
	setProgress(52, "Error", "No se pudo cargar pestaña Farm")
	warn("[Delta Hub] farm_b falló")
	return
end

setProgress(53, "Farm", "Preparando pestaña Farm...")
local body = a .. b
local fn, err = loadstring(body)
if not fn then
	warn("[Delta Hub] farm loadstring:", err)
	setProgress(53, "Error", "Error al preparar Farm")
	return
end

setProgress(54, "Farm", "Iniciando pestaña Farm...")
local ok, runErr = pcall(fn)
if not ok then
	warn("[Delta Hub] farm run:", runErr)
	setProgress(54, "Error", "Error al iniciar Farm")
	return
end

setProgress(55, "Farm", "Pestaña Farm lista")
