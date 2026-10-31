-- DELTA HUB tab_farm thin loader
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end

local function log(msg, level)
	if S.log then S.log(msg, level or "INFO") else print("[DeltaHub]", msg) end
end

local function http(name)
	if S.httpGet then
		return S.httpGet(name)
	end
	local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
	local ok, body = pcall(function() return game:HttpGet(BASE .. name) end)
	if ok and type(body) == "string" and #body > 50 and not body:find("<!DOCTYPE") then return body end
	return nil
end

log("tab_farm: inicio", "LOAD")
setProgress(51, "Farm", "Cargando interfaz...")

local partA = http("farm_a.lua")
if not partA then
	log("farm_a.lua FALLO", "ERR")
	setProgress(52, "Error", "No se pudo cargar la interfaz")
	return
end
log("farm_a OK, len=" .. tostring(#partA), "OK")

setProgress(52, "Farm", "Cargando pestaña Farm...")
local partB = http("farm_b.lua")
if not partB then
	log("farm_b.lua FALLO", "ERR")
	setProgress(53, "Error", "No se pudo cargar pestaña Farm")
	return
end
log("farm_b OK, len=" .. tostring(#partB), "OK")

setProgress(54, "Farm", "Preparando pestaña Farm...")
local combined = partA .. "\n" .. partB
log("loadstring farm total=" .. tostring(#combined), "LOAD")
local fn, err = loadstring(combined)
if not fn then
	log("loadstring error: " .. tostring(err), "ERR")
	setProgress(54, "Error", "Error al preparar Farm")
	return
end

setProgress(55, "Farm", "Iniciando pestaña Farm...")
local ok, runErr = pcall(fn)
if not ok then
	log("run farm error: " .. tostring(runErr), "ERR")
	setProgress(55, "Error", "Error al iniciar Farm")
	return
end

log("Farm listo", "OK")
setProgress(57, "Farm", "Pestaña Farm lista")
