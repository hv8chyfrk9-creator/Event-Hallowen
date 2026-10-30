-- DELTA HUB tab_farm thin
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local function setProgress(p,t,s) if S.setProgress then S.setProgress(p,t,s) end end
setProgress(51, "Farm", "Cargando Farm A...")
local ok1, a = pcall(function() return game:HttpGet(BASE.."farm_a.lua") end)
if not ok1 or type(a) ~= "string" or #a < 100 then warn("[Delta Hub] farm_a fail") setProgress(52,"Error","farm_a") return end
setProgress(52, "Farm", "Cargando Farm B...")
local ok2, b = pcall(function() return game:HttpGet(BASE.."farm_b.lua") end)
if not ok2 or type(b) ~= "string" or #b < 100 then warn("[Delta Hub] farm_b fail") setProgress(52,"Error","farm_b") return end
local fn, err = loadstring(a..b)
if not fn then warn("[Delta Hub] farm loadstring", err) setProgress(52,"Error","loadstring") return end
local ok, e = pcall(fn)
if not ok then warn("[Delta Hub] farm run", e) setProgress(52,"Error","run") end
