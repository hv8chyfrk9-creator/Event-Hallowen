-- g2_routes master (loads 4 chunks)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.routeCFrames = S.routeCFrames or {}
S.routeModes = S.routeModes or {}
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local function get(name)
	local ok, body = pcall(function() return game:HttpGet(BASE..name) end)
	if ok and type(body)=="string" and #body>20 then return body end
	return nil
end
local i = 0
for c = 1, 4 do
	local body = get("g2_routes_c"..c..".lua")
	if not body then warn("[G2] missing chunk", c) continue end
	local fn = loadstring(body)
	if not fn then warn("[G2] bad chunk", c) continue end
	local ok, raw = pcall(fn)
	if not ok or type(raw)~="string" then warn("[G2] chunk run", c) continue end
	for line in string.gmatch(raw, "[^\n]+") do
		i = i + 1
		local a, flags = string.match(line, "^(.-)|(%d%d%d)$")
		if a and flags then
			local t = {}
			for n in string.gmatch(a, "[^,]+") do t[#t+1] = tonumber(n) end
			if #t >= 12 then
				S.routeCFrames[i] = CFrame.new(t[1],t[2],t[3],t[4],t[5],t[6],t[7],t[8],t[9],t[10],t[11],t[12])
			elseif #t >= 3 then
				S.routeCFrames[i] = CFrame.new(t[1],t[2],t[3])
			end
			S.routeModes[i] = {
				normal = string.sub(flags,1,1)=="1",
				fast = string.sub(flags,2,2)=="1",
				super = string.sub(flags,3,3)=="1",
			}
		end
	end
end
print("[G2] routes loaded", i)
