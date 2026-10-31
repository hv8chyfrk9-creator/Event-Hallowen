-- DELTA HUB tab_events thin
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local function http(u)
	local ok, body = pcall(function() return game:HttpGet(u) end)
	if not ok or type(body) ~= "string" or #body < 30 then return nil end
	if body:find("<!DOCTYPE") then return nil end
	return body
end
local ui = http(BASE .. "events_ui.lua")
local logic = http(BASE .. "events_logic.lua")
if not ui then
	warn("[Delta Hub] falta events_ui, usando fallback completo")
	ui = http(BASE .. "events_fallback.lua")
end
if not ui then warn("[Delta Hub] events UI missing") return end
local body = ui .. (logic or "")
local fn, err = loadstring(body)
if not fn then warn("[Delta Hub] events loadstring", err) return end
local ok, e = pcall(fn)
if not ok then warn("[Delta Hub] events run", e) end
