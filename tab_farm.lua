-- ==========================================
-- DELTA HUB - Event Hallowen - tab_farm.lua
-- ==========================================

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	warn("[Delta Hub] tab_farm: falta init")
	return
end

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local BODY_URL = BASE .. "tab_farm_body.lua"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

setProgress(51, "Farm", "Cargando Farm...")

local ok, body = pcall(function()
	return game:HttpGet(BODY_URL)
end)

if not ok or type(body) ~= "string" or #body < 500 then
	warn("[Delta Hub] tab_farm_body download failed", ok, type(body), body and tostring(#body))
	setProgress(52, "Error", "No se pudo cargar Farm body")
	return
end

if body:find("<!DOCTYPE") or body:sub(1, 6) == "<html>" then
	warn("[Delta Hub] tab_farm_body HTML")
	setProgress(52, "Error", "Farm body HTML")
	return
end

setProgress(52, "Farm", "Ejecutando Farm...")

local fn, err = loadstring(body)
if not fn then
	warn("[Delta Hub] farm body loadstring", err)
	setProgress(52, "Error", "Error loadstring Farm")
	return
end

local okRun, runErr = pcall(fn)
if not okRun then
	warn("[Delta Hub] farm body run", runErr)
	setProgress(52, "Error", "Error run Farm")
	return
end
