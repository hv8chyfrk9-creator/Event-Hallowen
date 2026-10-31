-- DELTA HUB tab_farm thin loader
-- Descarga farm_a + farm_b y los junta en UN loadstring (comparten locals)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end

local function http(name)
	local url = BASE .. name
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok then
		warn("[Delta Hub] HttpGet error:", name, body)
		return nil
	end
	if type(body) ~= "string" or #body < 50 then
		warn("[Delta Hub] body vacio:", name)
		return nil
	end
	if body:find("<!DOCTYPE") or body:find("PLACEHOLDER") then
		warn("[Delta Hub] body invalido:", name)
		return nil
	end
	return body
end

setProgress(51, "Farm", "Cargando interfaz...")
local partA = http("farm_a.lua")
if not partA then
	setProgress(52, "Error", "No se pudo cargar la interfaz")
	return
end

setProgress(52, "Farm", "Cargando pestaña Farm...")
local partB = http("farm_b.lua")
if not partB then
	setProgress(53, "Error", "No se pudo cargar pestaña Farm")
	return
end

setProgress(54, "Farm", "Preparando pestaña Farm...")
local combined = partA .. "\n" .. partB
local fn, err = loadstring(combined)
if not fn then
	warn("[Delta Hub] loadstring farm:", err)
	setProgress(54, "Error", "Error al preparar Farm")
	return
end

setProgress(55, "Farm", "Iniciando pestaña Farm...")
local ok, runErr = pcall(fn)
if not ok then
	warn("[Delta Hub] run farm:", runErr)
	setProgress(55, "Error", "Error al iniciar Farm")
	return
end

setProgress(57, "Farm", "Pestaña Farm lista")
