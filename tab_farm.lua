-- ==========================================
-- DELTA HUB - Event Hallowen - tab_farm.lua
-- Thin loader: restores farm body + Tsunami
-- ==========================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	warn("[Delta Hub] tab_farm: falta init (DeltaHub)")
	return
end

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
-- Body estable (commit con farm completo funcional)
local BODY_URL = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/6773555569498a241f116b1199d8595b681895bc/tab_farm.lua"
local TSUNAMI_URL = BASE .. "tab_farm_tsunami.lua"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

setProgress(51, "Farm", "Cargando Farm body...")

local ok, body = pcall(function()
	return game:HttpGet(BODY_URL)
end)
if not ok or type(body) ~= "string" or #body < 500 then
	warn("[Delta Hub] No se pudo descargar tab_farm body")
	return
end
if body:find("<!DOCTYPE") or body:find("<html") then
	warn("[Delta Hub] HTML en farm body")
	return
end

-- Inyectar carga de Tsunami antes de la lógica de recorrido
local inject = [[
task.spawn(function()
	local url = "]] .. TSUNAMI_URL .. [["
	local ok, body = pcall(function() return game:HttpGet(url) end)
	if ok and type(body) == "string" and #body > 50 and not body:find("<!DOCTYPE") then
		local fn = loadstring(body)
		if fn then pcall(fn) end
	end
end)
]]

local marker = 'setProgress(58, "Farm", "Logica de recorrido...")'
if body:find(marker, 1, true) then
	body = body:gsub(
		'setProgress%(58, "Farm", "Logica de recorrido%.%.%."%)',
		inject .. '\nsetProgress(58, "Farm", "Logica de recorrido...")',
		1
	)
else
	body = inject .. "\n" .. body
end

-- Inyectar freno Tsunami en el loop de velocidad
local oldLoop = [[local spd = approachSpeed(dist, nextD)
			if dist > 0.05 then
				bv.Velocity = (targetPos - hrp.Position).Unit * spd]]
if body:find("approachSpeed(dist, nextD)", 1, true) then
	body = body:gsub(
		'local spd = approachSpeed%(dist, nextD%)',
		'local spd = approachSpeed(dist, nextD)\n\t\t\tif S.tsunamiDangerSpeed then spd = select(1, S.tsunamiDangerSpeed(hrp, spd)) end',
		1
	)
end

local fn, err = loadstring(body)
if not fn then
	warn("[Delta Hub] farm body loadstring", err)
	return
end
local okRun, runErr = pcall(fn)
if not okRun then
	warn("[Delta Hub] farm body run", runErr)
end
