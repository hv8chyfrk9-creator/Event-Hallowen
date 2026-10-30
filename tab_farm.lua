-- ==========================================
-- DELTA HUB - Event Hallowen - tab_farm.lua
-- Carga body en 2 partes y lo ejecuta
-- ==========================================

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	warn("[Delta Hub] tab_farm: falta init")
	return
end

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

local function httpGet(url)
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(body) ~= "string" then
		return nil, tostring(body)
	end
	if body:find("<!DOCTYPE") or body:sub(1, 6) == "<html>" then
		return nil, "HTML"
	end
	return body, nil
end

setProgress(51, "Farm", "Cargando Farm 1/2...")
local c1, e1 = httpGet(BASE .. "farm_chunk1.txt")
if not c1 then
	warn("[Delta Hub] farm_chunk1", e1)
	setProgress(52, "Error", "Falta farm_chunk1")
	return
end

setProgress(52, "Farm", "Cargando Farm 2/2...")
local c2, e2 = httpGet(BASE .. "farm_chunk2.txt")
if not c2 then
	warn("[Delta Hub] farm_chunk2", e2)
	setProgress(52, "Error", "Falta farm_chunk2")
	return
end

local body = c1 .. c2
if #body < 500 then
	setProgress(52, "Error", "Farm body incompleto")
	return
end

setProgress(53, "Farm", "Ejecutando Farm...")
local fn, err = loadstring(body)
if not fn then
	warn("[Delta Hub] farm loadstring", err)
	setProgress(53, "Error", "Error loadstring Farm")
	return
end

local okRun, runErr = pcall(fn)
if not okRun then
	warn("[Delta Hub] farm run", runErr)
	setProgress(53, "Error", "Error run Farm")
	return
end
