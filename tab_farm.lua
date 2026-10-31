-- DELTA HUB tab_farm thin (a + b1 + b2)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local function setProgress(p,t,s) if S.setProgress then S.setProgress(p,t,s) end end
local function http(u)
	local ok, body = pcall(function() return game:HttpGet(u) end)
	if not ok or type(body) ~= "string" or #body < 50 then return nil end
	if body:find("<!DOCTYPE") or body:find("PLACEHOLDER") then return nil end
	return body
end
setProgress(51, "Farm", "Cargando Farm A...")
local a = http(BASE.."farm_a.lua")
if not a then setProgress(52,"Error","farm_a"); return end
setProgress(52, "Farm", "Cargando Farm B1...")
local b1 = http(BASE.."farm_b1.lua")
if not b1 then
	-- fallback farm_b completo
	b1 = http(BASE.."farm_b.lua")
	if not b1 then setProgress(52,"Error","farm_b"); return end
	local fn, err = loadstring(a..b1)
	if not fn then warn(err) return end
	pcall(fn)
	return
end
setProgress(53, "Farm", "Cargando Farm B2...")
local b2 = http(BASE.."farm_b2.lua") or ""
local fn, err = loadstring(a..b1..b2)
if not fn then warn("[Delta Hub] farm loadstring", err) setProgress(53,"Error","loadstring") return end
local ok, e = pcall(fn)
if not ok then warn("[Delta Hub] farm run", e) end
