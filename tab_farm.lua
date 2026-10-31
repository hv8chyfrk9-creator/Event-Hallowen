-- DELTA HUB tab_farm thin loader
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
local function http(u)
	local ok, body = pcall(function() return game:HttpGet(u) end)
	if not ok or type(body) ~= "string" or #body < 20 then return nil end
	if body:find("<!DOCTYPE") or body:find("PLACEHOLDER") then return nil end
	return body
end
setProgress(51, "Farm", "Cargando Farm A...")
local a = http(BASE .. "farm_a.lua")
if not a then setProgress(52, "Error", "farm_a") return end
setProgress(52, "Farm", "Cargando Farm B...")
local b1a = http(BASE .. "farm_b1a.lua")
local b1b = http(BASE .. "farm_b1b.lua")
local b2 = http(BASE .. "farm_b2.lua") or ""
local body
if b1a and b1b then
	body = a .. b1a .. b1b .. b2
else
	local b = http(BASE .. "farm_b.lua")
	if not b then setProgress(52, "Error", "farm_b") return end
	body = a .. b
end
local fn, err = loadstring(body)
if not fn then warn("[Delta Hub] farm loadstring", err) setProgress(53, "Error", "loadstring") return end
local ok, e = pcall(fn)
if not ok then warn("[Delta Hub] farm run", e) end
