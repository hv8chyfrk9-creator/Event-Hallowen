-- DELTA HUB tab_farm thin loader
-- Descarga farm_a + farm_b con HttpGet robusto + mirrors
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end

local REPO = "hv8chyfrk9-creator/Event-Hallowen"
local BRANCH = "main"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end

local function isValidBody(body)
	if type(body) ~= "string" or #body < 50 then return false end
	if body:find("<!DOCTYPE") or body:find("<html") then return false end
	if body:find("PLACEHOLDER") then return false end
	return true
end

local function tryHttpGet(url)
	-- 1) game:HttpGet
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if ok and isValidBody(body) then return body end

	-- 2) game:HttpGet con cache bypass
	ok, body = pcall(function()
		return game:HttpGet(url, true)
	end)
	if ok and isValidBody(body) then return body end

	-- 3) request / syn.request / http_request
	local reqFn = (syn and syn.request)
		or (http and http.request)
		or http_request
		or (fluxus and fluxus.request)
		or request
	if type(reqFn) == "function" then
		ok, body = pcall(function()
			local res = reqFn({
				Url = url,
				Method = "GET",
				Headers = { ["User-Agent"] = "Mozilla/5.0" },
			})
			if type(res) == "table" then
				return res.Body or res.body
			end
			return nil
		end)
		if ok and isValidBody(body) then return body end
	end

	return nil
end

local function http(name)
	local urls = {
		"https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/" .. name,
		"https://cdn.jsdelivr.net/gh/" .. REPO .. "@" .. BRANCH .. "/" .. name,
		"https://raw.githubusercontent.com/" .. REPO .. "/" .. BRANCH .. "/" .. name .. "?t=" .. tostring(math.floor(tick())),
	}
	for i = 1, #urls do
		local body = tryHttpGet(urls[i])
		if body then
			return body
		end
		task.wait(0.15)
	end
	warn("[Delta Hub] no se pudo descargar:", name)
	return nil
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
