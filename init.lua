-- ==========================================
-- DELTA HUB - Event Hallowen - init.lua (Archivo 1)
-- 0% -> 50%: datos + limpieza + encadena tab_farm.lua
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then
	warn("[Delta Hub] No PlayerGui")
	return
end

local HALLOWEEN_PLACE_ID = 128614435234859
local NEXT_URL = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/tab_farm.lua"
local BASE = "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"

local S = getgenv().DeltaHub
if type(S) ~= "table" then
	S = {}
	getgenv().DeltaHub = S
end
S.world = "hallowen"
S.placeId = HALLOWEEN_PLACE_ID
S.scriptReady = false
S.loadProgress = 0
S.UI = S.UI or {}
S.Signals = S.Signals or {}
S.BASE_URL = BASE

-- ---------- PlaceId ----------
local function checkPlaceId()
	if game.PlaceId == HALLOWEEN_PLACE_ID then
		return true
	end
	if getgenv().DeltaHubForceLoad then
		return true
	end
	return false
end

if not checkPlaceId() then
	warn("[Delta Hub] PlaceId incorrecto:", game.PlaceId, "esperado", HALLOWEEN_PLACE_ID)
	return
end

-- ---------- Cleanup list ----------
S.targetNamesToDestroy = {
	"TarantulaS13",
	"WindZonesS14",
	"Lava_Stage15",
	"MovingWallsS6",
	"EyeLaserStage10",
	"Zone",
	"TwompsS7",
}

-- ---------- Datos del mundo (en S, no en locals) ----------
S.routeCFrames = {
	CFrame.new(1.723794, 10.398061, -14.657170, -0.981345, 0.000000, -0.192254, 0.000000, 1.000000, 0.000000, 0.192254, 0.000000, -0.981345), -- CFrame 1 modes:NFS
	CFrame.new(2.498288, 8.788522, 155.956909, 0.841975, 0.000000, -0.539517, 0.000000, 1.000000, 0.000000, 0.539517, -0.000000, 0.841975), -- CFrame 2 modes:N
	CFrame.new(2.472235, 8.788770, 414.924713, -0.993998, -0.000000, -0.109399, -0.000000, 1.000000, 0.000000, 0.109399, 0.000000, -0.993998), -- CFrame 3 modes:NFS
	CFrame.new(2.472236, 48.788769, 414.924713, -0.993998, 0.000000, -0.109399, 0.000000, 1.000000, -0.000000, 0.109399, -0.000000, -0.993998), -- CFrame 4 modes:N
	CFrame.new(2.210491, 48.788769, 459.923950, -0.999983, -0.000000, 0.005817, -0.000000, 1.000000, 0.000000, -0.005817, 0.000000, -0.999983), -- CFrame 5 modes:NF
	CFrame.new(2.065077, 48.788765, 484.923523, -0.999983, -0.000000, 0.005817, -0.000000, 1.000000, 0.000000, -0.005817, 0.000000, -0.999983), -- CFrame 6 modes:NFS
	CFrame.new(1.979693, 48.788769, 666.727295, -0.987106, 0.000000, -0.160066, -0.000000, 1.000000, 0.000000, 0.160066, 0.000000, -0.987106), -- CFrame 7 modes:NFS
	CFrame.new(1.979693, 8.788770, 666.727295, -0.987106, -0.000000, -0.160066, 0.000000, 1.000000, -0.000000, 0.160066, -0.000000, -0.987106), -- CFrame 8 modes:NFS
	CFrame.new(2.401369, 8.788770, 1015.547424, -0.998025, -0.000000, -0.062823, -0.000000, 1.000000, 0.000000, 0.062823, 0.000000, -0.998025), -- CFrame 9 modes:NFS
	CFrame.new(2.401369, 48.788769, 1015.547424, -0.998025, -0.000000, -0.062823, -0.000000, 1.000000, 0.000000, 0.062823, 0.000000, -0.998025), -- CFrame 10 modes:S
	CFrame.new(1.888022, 8.788770, 1029.942749, -0.999990, -0.000000, -0.004500, -0.000000, 1.000000, -0.000000, 0.004500, -0.000000, -0.999990), -- CFrame 11 modes:N
	CFrame.new(1.888025, 48.788769, 1029.942749, -0.999990, 0.000000, -0.004500, 0.000000, 1.000000, 0.000000, 0.004500, 0.000000, -0.999990), -- CFrame 12 modes:NF
	CFrame.new(4.778526, 78.788330, 1084.120239, -0.999998, -0.000000, 0.001943, -0.000000, 1.000000, -0.000000, -0.001943, -0.000000, -0.999998), -- CFrame 13 modes:NFS
	CFrame.new(-469.233154, 78.788773, 1084.786377, 0.287080, 0.000000, 0.957907, 0.000000, 1.000000, -0.000000, -0.957907, 0.000000, 0.287080), -- CFrame 14 modes:NFS
	CFrame.new(-469.233154, 8.788770, 1084.786377, 0.287080, -0.000000, 0.957907, -0.000000, 1.000000, 0.000000, -0.957907, -0.000000, 0.287080), -- CFrame 15 modes:NFS
	CFrame.new(-815.334290, 8.788770, 1085.548462, -0.021215, 0.000000, 0.999775, -0.000000, 1.000000, -0.000000, -0.999775, -0.000000, -0.021215), -- CFrame 16 modes:NFS
	CFrame.new(-1055.344360, 8.788770, 1084.210571, -0.353525, -0.000000, 0.935425, 0.000000, 1.000000, 0.000000, -0.935425, 0.000000, -0.353525), -- CFrame 17 modes:NFS
	CFrame.new(-1404.096191, 8.788770, 1085.305298, -0.204193, 0.000000, 0.978931, -0.000000, 1.000000, -0.000000, -0.978931, -0.000000, -0.204193), -- CFrame 18 modes:NFS
	CFrame.new(-1560.739136, 8.788774, 1089.958130, 0.595433, -0.000000, 0.803405, 0.000000, 1.000000, 0.000000, -0.803405, 0.000000, 0.595433), -- CFrame 19 modes:N
	CFrame.new(-1530.167114, 8.788774, 1127.149658, -0.769944, 0.000000, -0.638111, 0.000000, 1.000000, -0.000000, 0.638111, -0.000000, -0.769944), -- CFrame 20 modes:F
	CFrame.new(-1559.823120, 8.788774, 1307.095825, -0.986730, -0.000000, 0.162370, -0.000000, 1.000000, 0.000000, -0.162370, 0.000000, -0.986730), -- CFrame 21 modes:N
	CFrame.new(-1515.464722, 8.788774, 1322.853882, -0.225007, 0.000000, -0.974357, -0.000000, 1.000000, 0.000000, 0.974357, 0.000000, -0.225007), -- CFrame 22 modes:F
	CFrame.new(-1478.150757, 8.788774, 1314.697632, 0.920410, -0.000000, -0.390954, 0.000000, 1.000000, -0.000000, 0.390954, 0.000000, 0.920410), -- CFrame 23 modes:N
	CFrame.new(-1482.656128, 8.788774, 1407.314697, -0.994967, -0.000000, 0.100207, -0.000000, 1.000000, 0.000000, -0.100207, 0.000000, -0.994967), -- CFrame 24 modes:N
	CFrame.new(-1542.863525, 8.788774, 1412.845825, -0.072391, -0.000000, 0.997376, 0.000000, 1.000000, 0.000000, -0.997376, 0.000000, -0.072391), -- CFrame 25 modes:F
	CFrame.new(-1673.566528, 8.788774, 1414.027222, 0.066663, 0.000000, -0.997776, 0.000000, 1.000000, 0.000000, 0.997776, -0.000000, 0.066663), -- CFrame 26 modes:N
	CFrame.new(-1867.711548, 8.788774, 1409.603027, -0.044628, 0.000000, 0.999004, -0.000000, 1.000000, -0.000000, -0.999004, -0.000000, -0.044628), -- CFrame 27 modes:N
	CFrame.new(-1817.476562, 8.788771, 1359.951660, 0.832316, -0.000000, -0.554302, -0.000000, 1.000000, -0.000000, 0.554302, 0.000000, 0.832316), -- CFrame 28 modes:F
	CFrame.new(-2004.102295, 8.788774, 1157.550293, 0.998348, -0.000000, 0.057460, 0.000000, 1.000000, 0.000000, -0.057460, -0.000000, 0.998348), -- CFrame 29 modes:F
	CFrame.new(-1865.652588, 8.788774, 1214.202271, -0.933495, 0.000000, 0.358591, 0.000000, 1.000000, -0.000000, -0.358591, -0.000000, -0.933495), -- CFrame 30 modes:N
	CFrame.new(-2067.085693, 8.788774, 1214.307495, -0.032194, 0.000000, 0.999482, 0.000000, 1.000000, -0.000000, -0.999482, -0.000000, -0.032194), -- CFrame 31 modes:N
	CFrame.new(-2067.824951, 8.788650, 987.487427, -0.892555, 0.000000, -0.450938, 0.000000, 1.000000, 0.000000, 0.450938, 0.000000, -0.892555), -- CFrame 32 modes:N
	CFrame.new(-2150.184814, 8.788774, 979.491028, 0.119159, -0.000000, 0.992875, 0.000000, 1.000000, 0.000000, -0.992875, 0.000000, 0.119159), -- CFrame 33 modes:N
	CFrame.new(-2122.424805, 8.788774, 890.425781, 0.683254, 0.000000, -0.730180, -0.000000, 1.000000, 0.000000, 0.730180, 0.000000, 0.683254), -- CFrame 34 modes:F
	CFrame.new(-2158.113037, 7.570764, 731.783325, -0.287473, 0.000000, -0.957789, 0.000000, 1.000000, 0.000000, 0.957789, -0.000000, -0.287473), -- CFrame 35 modes:NFS
	CFrame.new(-2158.113037, -68.211243, 731.783325, -0.287473, 0.000000, -0.957789, 0.000000, 1.000000, 0.000000, 0.957789, -0.000000, -0.287473), -- CFrame 36 modes:N
	CFrame.new(-2158.284424, -68.211243, 720.066956, -0.790156, 0.000000, -0.612906, 0.000000, 1.000000, 0.000000, 0.612906, -0.000000, -0.790156), -- CFrame 37 modes:FS
	CFrame.new(-2158.700439, -67.264351, 666.636414, 0.993354, -0.000000, -0.115099, 0.000000, 1.000000, -0.000000, 0.115099, 0.000000, 0.993354), -- CFrame 38 modes:N
	CFrame.new(-2158.542236, -58.538563, 633.734497, 0.999120, -0.000000, -0.041954, -0.000000, 1.000000, -0.000000, 0.041954, 0.000000, 0.999120), -- CFrame 39 modes:NF
	CFrame.new(-2176.256104, -68.337509, 537.865112, 0.993793, -0.000000, 0.111241, 0.000000, 1.000000, -0.000000, -0.111241, 0.000000, 0.993793), -- CFrame 40 modes:N
	CFrame.new(-2177.282715, -68.305290, 508.678406, -0.976854, -0.000000, -0.213906, -0.000000, 1.000000, -0.000000, 0.213906, -0.000000, -0.976854), -- CFrame 41 modes:N
	CFrame.new(-2177.771973, -58.615578, 472.419128, 0.564029, 0.000000, -0.825755, -0.000000, 1.000000, 0.000000, 0.825755, 0.000000, 0.564029), -- CFrame 42 modes:NF
	CFrame.new(-2158.132812, -58.837502, 412.536774, 0.986553, -0.000000, 0.163440, 0.000000, 1.000000, 0.000000, -0.163440, -0.000000, 0.986553), -- CFrame 43 modes:NF
	CFrame.new(-2156.780029, -58.837502, 350.491425, 0.999445, -0.000000, 0.033318, 0.000000, 1.000000, -0.000000, -0.033318, 0.000000, 0.999445), -- CFrame 44 modes:N
	CFrame.new(-2156.677734, -58.837502, 280.591919, -0.527067, -0.000000, -0.849824, -0.000000, 1.000000, 0.000000, 0.849824, 0.000000, -0.527067), -- CFrame 45 modes:N
	CFrame.new(-2157.453613, -58.837502, 215.610672, 0.968502, 0.000000, 0.249008, -0.000000, 1.000000, 0.000000, -0.249008, -0.000000, 0.968502), -- CFrame 46 modes:NF
	CFrame.new(-2178.700195, -68.337509, 154.869110, 0.992454, 0.000000, -0.122616, -0.000000, 1.000000, -0.000000, 0.122616, 0.000000, 0.992454), -- CFrame 47 modes:NF
	CFrame.new(-2176.458496, -68.337509, 87.430786, 0.999897, -0.000000, 0.014348, 0.000000, 1.000000, -0.000000, -0.014348, 0.000000, 0.999897), -- CFrame 48 modes:N
	CFrame.new(-2157.995605, -68.327744, 67.934364, -0.759770, 0.000000, 0.650192, 0.000000, 1.000000, -0.000000, -0.650192, -0.000000, -0.759770), -- CFrame 49 modes:NFS
	CFrame.new(-2153.648926, -68.329048, 5.905844, -0.147685, -0.000000, -0.989034, -0.000000, 1.000000, -0.000000, 0.989034, 0.000000, -0.147685), -- CFrame 50 modes:N
	CFrame.new(-2177.284912, -68.329048, -36.404144, -0.316363, 0.000000, 0.948638, 0.000000, 1.000000, 0.000000, -0.948638, 0.000000, -0.316363), -- CFrame 51 modes:NF
	CFrame.new(-2192.481689, -68.329048, -222.030853, 0.298791, 0.000000, 0.954319, -0.000000, 1.000000, -0.000000, -0.954319, -0.000000, 0.298791), -- CFrame 52 modes:NF
	CFrame.new(-2173.635742, -68.329048, -252.867462, 0.997163, 0.000000, 0.075272, -0.000000, 1.000000, 0.000000, -0.075272, -0.000000, 0.997163), -- CFrame 53 modes:N
	CFrame.new(-2159.074707, -68.327744, -394.848175, 0.977728, -0.000000, -0.209878, 0.000000, 1.000000, -0.000000, 0.209878, 0.000000, 0.977728), -- CFrame 54 modes:NFS
	CFrame.new(-2157.513672, -68.299034, -719.824585, 0.265701, -0.000000, -0.964055, -0.000000, 1.000000, -0.000000, 0.964055, 0.000000, 0.265701), -- CFrame 55 modes:N
	CFrame.new(-2155.650635, -68.327232, -1026.460449, -0.140630, -0.000000, -0.990062, -0.000000, 1.000000, -0.000000, 0.990062, 0.000000, -0.140630), -- CFrame 56 modes:NF
	CFrame.new(-2154.859375, -68.299034, -1332.979004, 0.999855, -0.000000, -0.017036, 0.000000, 1.000000, -0.000000, 0.017036, 0.000000, 0.999855), -- CFrame 57 modes:N
	CFrame.new(-2158.319092, -68.327744, -1504.355469, 0.992763, 0.000000, 0.120094, -0.000000, 1.000000, -0.000000, -0.120094, 0.000000, 0.992763), -- CFrame 58 modes:NFS
	CFrame.new(-2169.666260, -68.332741, -1634.468384, 0.931206, -0.000000, 0.364494, 0.000000, 1.000000, 0.000000, -0.364494, -0.000000, 0.931206), -- CFrame 59 modes:N
	CFrame.new(-2197.297607, -47.667351, -1700.590454, 0.970139, 0.000000, 0.242551, 0.000000, 1.000000, -0.000000, -0.242551, 0.000000, 0.970139), -- CFrame 60 modes:N
	CFrame.new(-2197.297607, -47.667351, -1700.590454, 0.970139, 0.000000, 0.242551, -0.000000, 1.000000, -0.000000, -0.242551, 0.000000, 0.970139), -- CFrame 61 modes:NF
	CFrame.new(-2197.310547, -47.541206, -1763.638916, 0.997211, 0.000000, -0.074632, -0.000000, 1.000000, 0.000000, 0.074632, -0.000000, 0.997211), -- CFrame 62 modes:NF
	CFrame.new(-2197.867188, -70.453674, -1931.262207, -0.997369, -0.000000, -0.072497, -0.000000, 1.000000, -0.000000, 0.072497, 0.000000, -0.997369), -- CFrame 63 modes:N
	CFrame.new(-2197.487061, -70.437897, -1993.377930, 0.805633, -0.000000, 0.592414, 0.000000, 1.000000, 0.000000, -0.592414, -0.000000, 0.805633), -- CFrame 64 modes:N
	CFrame.new(-2197.502441, -58.354435, -2030.619507, 0.996522, 0.000000, 0.083334, -0.000000, 1.000000, -0.000000, -0.083334, 0.000000, 0.996522), -- CFrame 65 modes:NF
	CFrame.new(-2158.854248, -68.332741, -2199.634521, -0.999959, -0.000000, 0.009075, -0.000000, 1.000000, -0.000000, -0.009075, -0.000000, -0.999959), -- CFrame 66 modes:N
	CFrame.new(-2157.820312, -68.332741, -2262.027588, 0.738523, 0.000000, 0.674228, 0.000000, 1.000000, -0.000000, -0.674228, 0.000000, 0.738523), -- CFrame 67 modes:N
	CFrame.new(-2156.573486, -56.146812, -2301.862793, 0.969763, 0.000000, 0.244050, -0.000000, 1.000000, 0.000000, -0.244050, -0.000000, 0.969763), -- CFrame 68 modes:NF
	CFrame.new(-2157.894531, -68.332817, -2462.182373, -0.998098, -0.000000, -0.061645, -0.000000, 1.000000, -0.000000, 0.061645, -0.000000, -0.998098), -- CFrame 69 modes:N
	CFrame.new(-2158.653809, -68.332817, -2524.041016, 0.321548, 0.000000, -0.946893, 0.000000, 1.000000, 0.000000, 0.946893, -0.000000, 0.321548), -- CFrame 70 modes:N
	CFrame.new(-2157.582275, -56.471050, -2562.268555, 0.995030, -0.000000, 0.099577, 0.000000, 1.000000, -0.000000, -0.099577, 0.000000, 0.995030), -- CFrame 71 modes:NF
	CFrame.new(-2157.990723, -68.332886, -2737.116699, -0.998777, -0.000000, -0.049439, -0.000000, 1.000000, 0.000000, 0.049439, 0.000000, -0.998777), -- CFrame 72 modes:N
	CFrame.new(-2158.024414, -68.307816, -2801.284424, 0.996086, -0.000000, 0.088387, 0.000000, 1.000000, -0.000000, -0.088387, 0.000000, 0.996086), -- CFrame 73 modes:N
	CFrame.new(-2158.176758, -56.394001, -2838.208008, 0.984669, -0.000000, 0.174435, -0.000000, 1.000000, 0.000000, -0.174435, -0.000000, 0.984669), -- CFrame 74 modes:NF
	CFrame.new(-2157.363037, -68.332909, -2956.279053, 0.998846, -0.000000, 0.048024, 0.000000, 1.000000, -0.000000, -0.048024, 0.000000, 0.998846), -- CFrame 75 modes:NF
	CFrame.new(-2158.196777, -68.330841, -3058.660645, 0.921797, -0.000000, -0.387673, 0.000000, 1.000000, 0.000000, 0.387673, -0.000000, 0.921797), -- CFrame 76 modes:N
	CFrame.new(-2158.274658, -68.327744, -3077.696289, 0.990696, 0.000000, -0.136094, -0.000000, 1.000000, -0.000000, 0.136094, 0.000000, 0.990696), -- CFrame 77 modes:NFS
	CFrame.new(-2157.677734, -68.177742, -3093.096436, 0.450028, -0.000000, -0.893014, 0.000000, 1.000000, 0.000000, 0.893014, -0.000000, 0.450028), -- CFrame 78 modes:NFS
	CFrame.new(-2158.995850, -109.038826, -3165.531250, 0.937907, -0.000000, 0.346886, 0.000000, 1.000000, -0.000000, -0.346886, 0.000000, 0.937907), -- CFrame 79 modes:NFS
	CFrame.new(-2158.782227, -109.038818, -3340.531250, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, -0.000000, 0.001221, 0.000000, 0.999999), -- CFrame 80 modes:N
	CFrame.new(-2158.568604, -109.038857, -3515.531006, 0.999999, 0.000000, -0.001221, -0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 81 modes:NF
	CFrame.new(-2158.354980, -109.038818, -3690.530762, 0.999999, 0.000000, -0.001221, -0.000000, 1.000000, -0.000000, 0.001221, 0.000000, 0.999999), -- CFrame 82 modes:N
	CFrame.new(-2158.141357, -109.038826, -3865.530762, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 83 modes:NF
	CFrame.new(-2157.927734, -109.038811, -4040.530762, 0.999999, 0.000000, -0.001221, -0.000000, 1.000000, -0.000000, 0.001221, 0.000000, 0.999999), -- CFrame 84 modes:N
	CFrame.new(-2157.714111, -109.038834, -4215.530273, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 85 modes:NF
	CFrame.new(-2157.500488, -109.038849, -4390.530273, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 86 modes:N
	CFrame.new(-2157.286865, -109.038834, -4565.530273, 0.999999, -0.000000, -0.001221, 0.000000, 1.000000, 0.000000, 0.001221, -0.000000, 0.999999), -- CFrame 87 modes:NF
	CFrame.new(-2157.679443, -109.036713, -4647.820801, 0.766852, 0.000000, 0.641824, 0.000000, 1.000000, -0.000000, -0.641824, 0.000000, 0.766852), -- CFrame 88 modes:NFS
	CFrame.new(-2181.696533, -109.038483, -4802.574707, 0.681549, 0.000000, -0.731772, -0.000000, 1.000000, 0.000000, 0.731772, 0.000000, 0.681549), -- CFrame 89 modes:N
	CFrame.new(-2133.482666, -109.038483, -4928.677734, 0.249246, -0.000000, 0.968440, 0.000000, 1.000000, 0.000000, -0.968440, -0.000000, 0.249246), -- CFrame 90 modes:N
	CFrame.new(-2182.430664, -109.038483, -5057.438477, 0.912545, -0.000000, 0.408976, -0.000000, 1.000000, 0.000000, -0.408976, -0.000000, 0.912545), -- CFrame 91 modes:N
	CFrame.new(-2128.923828, -109.038483, -5187.791016, 0.286787, 0.000000, -0.957994, 0.000000, 1.000000, 0.000000, 0.957994, -0.000000, 0.286787), -- CFrame 92 modes:NF
	CFrame.new(-2183.152832, -109.038483, -5303.347656, 0.985065, 0.000000, -0.172184, -0.000000, 1.000000, 0.000000, 0.172184, -0.000000, 0.985065), -- CFrame 93 modes:N
	CFrame.new(-2133.355225, -109.038483, -5425.147949, 0.482307, -0.000000, -0.876002, 0.000000, 1.000000, -0.000000, 0.876002, -0.000000, 0.482307), -- CFrame 94 modes:N
	CFrame.new(-2182.405762, -109.038483, -5557.606934, 0.240303, 0.000000, -0.970698, 0.000000, 1.000000, 0.000000, 0.970698, -0.000000, 0.240303), -- CFrame 95 modes:N
	CFrame.new(-2130.674316, -109.038483, -5691.516602, 0.652771, 0.000000, 0.757555, 0.000000, 1.000000, -0.000000, -0.757555, 0.000000, 0.652771), -- CFrame 96 modes:NF
	CFrame.new(-2158.924805, -109.036713, -5838.735840, 0.999708, -0.000000, 0.024151, 0.000000, 1.000000, -0.000000, -0.024151, 0.000000, 0.999708), -- CFrame 97 modes:NFS
	CFrame.new(-2157.822754, -109.039032, -5890.735840, 0.537583, -0.000000, 0.843211, 0.000000, 1.000000, 0.000000, -0.843211, 0.000000, 0.537583), -- CFrame 98 modes:NF
	CFrame.new(-2043.721924, -109.039032, -5899.330078, 0.999073, 0.000000, -0.043046, -0.000000, 1.000000, -0.000000, 0.043046, 0.000000, 0.999073), -- CFrame 99 modes:N
	CFrame.new(-2046.213379, -108.921761, -5949.420410, -0.794346, -0.000000, -0.607466, -0.000000, 1.000000, -0.000000, 0.607466, -0.000000, -0.794346), -- CFrame 100 modes:N
	CFrame.new(-2046.191895, -76.067596, -6078.995605, -0.142012, -0.000000, -0.989865, 0.000000, 1.000000, -0.000000, 0.989865, -0.000000, -0.142012), -- CFrame 101 modes:N
	CFrame.new(-2045.687134, -76.060432, -6114.630371, -0.343429, 0.000000, 0.939179, 0.000000, 1.000000, -0.000000, -0.939179, 0.000000, -0.343429), -- CFrame 102 modes:N
	CFrame.new(-2171.921875, -55.940319, -6079.653320, -0.999532, -0.000000, -0.030590, -0.000000, 1.000000, 0.000000, 0.030590, 0.000000, -0.999532), -- CFrame 103 modes:F
	CFrame.new(-2223.168945, -43.089211, -6124.910645, -0.591045, 0.000000, 0.806638, -0.000000, 1.000000, -0.000000, -0.806638, -0.000000, -0.591045), -- CFrame 104 modes:N
	CFrame.new(-2266.797119, -43.085396, -6123.513672, 0.382354, -0.000000, 0.924016, 0.000000, 1.000000, 0.000000, -0.924016, 0.000000, 0.382354), -- CFrame 105 modes:N
	CFrame.new(-2266.984619, -43.085396, -6080.699219, 0.548471, -0.000000, 0.836170, -0.000000, 1.000000, 0.000000, -0.836170, -0.000000, 0.548471), -- CFrame 106 modes:N
	CFrame.new(-2267.391113, -10.287116, -5949.721191, -0.365208, 0.000000, -0.930926, 0.000000, 1.000000, 0.000000, 0.930926, -0.000000, -0.365208), -- CFrame 107 modes:N
	CFrame.new(-2268.511963, -10.129237, -5911.355469, -0.998559, -0.000000, 0.053661, -0.000000, 1.000000, -0.000000, -0.053661, -0.000000, -0.998559), -- CFrame 108 modes:N
	CFrame.new(-2223.602783, -10.129237, -5911.150879, -0.172702, -0.000000, -0.984974, 0.000000, 1.000000, -0.000000, 0.984974, -0.000000, -0.172702), -- CFrame 109 modes:N
	CFrame.new(-2162.547852, 5.101793, -5948.480957, 0.702743, 0.000000, -0.711444, 0.000000, 1.000000, 0.000000, 0.711444, -0.000000, 0.702743), -- CFrame 110 modes:F
	CFrame.new(-2091.559326, 22.845793, -5907.810547, -0.647408, -0.000000, -0.762143, -0.000000, 1.000000, -0.000000, 0.762143, -0.000000, -0.647408), -- CFrame 111 modes:N
	CFrame.new(-2049.938965, 22.845793, -5908.574707, -0.075823, -0.000000, -0.997121, -0.000000, 1.000000, -0.000000, 0.997121, 0.000000, -0.075823), -- CFrame 112 modes:N
	CFrame.new(-2049.121338, 22.845793, -5946.925781, 0.991554, -0.000000, -0.129696, 0.000000, 1.000000, -0.000000, 0.129696, 0.000000, 0.991554), -- CFrame 113 modes:N
	CFrame.new(-2047.412476, 55.801739, -6079.977051, 0.361305, -0.000000, 0.932448, -0.000000, 1.000000, 0.000000, -0.932448, -0.000000, 0.361305), -- CFrame 114 modes:N
	CFrame.new(-2047.680298, 55.801739, -6112.555176, 0.979468, -0.000000, 0.201602, 0.000000, 1.000000, 0.000000, -0.201602, -0.000000, 0.979468), -- CFrame 115 modes:N
	CFrame.new(-2092.197510, 55.818737, -6112.405273, -0.316484, -0.000000, 0.948598, -0.000000, 1.000000, -0.000000, -0.948598, -0.000000, -0.316484), -- CFrame 116 modes:N
	CFrame.new(-2142.987061, 68.541687, -6079.058594, -0.927693, -0.000000, 0.373343, -0.000000, 1.000000, 0.000000, -0.373343, 0.000000, -0.927693), -- CFrame 117 modes:F
	CFrame.new(-2222.015381, 88.617874, -6123.796387, -0.071223, -0.000000, 0.997460, -0.000000, 1.000000, 0.000000, -0.997460, -0.000000, -0.071223), -- CFrame 118 modes:N
	CFrame.new(-2258.933594, 88.776756, -6124.555664, 0.026878, -0.000000, 0.999639, -0.000000, 1.000000, 0.000000, -0.999639, -0.000000, 0.026878), -- CFrame 119 modes:N
	CFrame.new(-2261.036865, 88.787743, -6079.577637, -0.999042, -0.000000, -0.043771, -0.000000, 1.000000, 0.000000, 0.043771, 0.000000, -0.999042), -- CFrame 120 modes:N
	CFrame.new(-2260.954834, 121.732918, -5948.331543, -0.864683, -0.000000, 0.502318, -0.000000, 1.000000, -0.000000, -0.502318, -0.000000, -0.864683), -- CFrame 121 modes:N
	CFrame.new(-2261.293701, 121.732918, -5912.591309, -0.998810, -0.000000, -0.048762, -0.000000, 1.000000, 0.000000, 0.048762, 0.000000, -0.998810), -- CFrame 122 modes:N
	CFrame.new(-2222.482178, 121.809174, -5911.831543, -0.023209, -0.000000, -0.999731, -0.000000, 1.000000, -0.000000, 0.999731, 0.000000, -0.023209), -- CFrame 123 modes:N
	CFrame.new(-2150.757080, 139.955276, -5948.726562, 0.410006, 0.000000, -0.912083, -0.000000, 1.000000, 0.000000, 0.912083, -0.000000, 0.410006), -- CFrame 124 modes:F
	CFrame.new(-2091.486328, 154.707962, -5905.091797, -0.989906, -0.000000, -0.141724, -0.000000, 1.000000, 0.000000, 0.141724, 0.000000, -0.989906), -- CFrame 125 modes:N
	CFrame.new(-2050.897217, 154.707962, -5905.969727, -0.167784, -0.000000, -0.985824, 0.000000, 1.000000, -0.000000, 0.985824, -0.000000, -0.167784), -- CFrame 126 modes:N
	CFrame.new(-2051.775391, 154.707962, -6117.379395, 0.999643, -0.000000, -0.026712, 0.000000, 1.000000, 0.000000, 0.026712, -0.000000, 0.999643), -- CFrame 127 modes:N
	CFrame.new(-2157.757324, 154.705612, -6124.634766, -0.465964, 0.000000, 0.884804, -0.000000, 1.000000, -0.000000, -0.884804, -0.000000, -0.465964), -- CFrame 128 modes:N
	CFrame.new(-2159.168457, 154.906082, -6079.477051, -0.906686, -0.000000, -0.421806, -0.000000, 1.000000, 0.000000, 0.421806, 0.000000, -0.906686), -- CFrame 129 modes:F
	CFrame.new(-2157.790527, 154.458725, -6169.575195, 0.999800, 0.000000, -0.019995, -0.000000, 1.000000, 0.000000, 0.019995, -0.000000, 0.999800) -- CFrame 130 modes:NFS
}

S.routeModes = {
	[1] = { normal = true, fast = true, super = true }, -- CF 1
	[2] = { normal = true, fast = false, super = false }, -- CF 2
	[3] = { normal = true, fast = true, super = true }, -- CF 3
	[4] = { normal = true, fast = false, super = false }, -- CF 4
	[5] = { normal = true, fast = true, super = false }, -- CF 5
	[6] = { normal = true, fast = true, super = true }, -- CF 6
	[7] = { normal = true, fast = true, super = true }, -- CF 7
	[8] = { normal = true, fast = true, super = true }, -- CF 8
	[9] = { normal = true, fast = true, super = true }, -- CF 9
	[10] = { normal = false, fast = false, super = true }, -- CF 10
	[11] = { normal = true, fast = false, super = false }, -- CF 11
	[12] = { normal = true, fast = true, super = false }, -- CF 12
	[13] = { normal = true, fast = true, super = true }, -- CF 13
	[14] = { normal = true, fast = true, super = true }, -- CF 14
	[15] = { normal = true, fast = true, super = true }, -- CF 15
	[16] = { normal = true, fast = true, super = true }, -- CF 16
	[17] = { normal = true, fast = true, super = true }, -- CF 17
	[18] = { normal = true, fast = true, super = true }, -- CF 18
	[19] = { normal = true, fast = false, super = false }, -- CF 19
	[20] = { normal = false, fast = true, super = false }, -- CF 20
	[21] = { normal = true, fast = false, super = false }, -- CF 21
	[22] = { normal = false, fast = true, super = false }, -- CF 22
	[23] = { normal = true, fast = false, super = false }, -- CF 23
	[24] = { normal = true, fast = false, super = false }, -- CF 24
	[25] = { normal = false, fast = true, super = false }, -- CF 25
	[26] = { normal = true, fast = false, super = false }, -- CF 26
	[27] = { normal = true, fast = false, super = false }, -- CF 27
	[28] = { normal = false, fast = true, super = false }, -- CF 28
	[29] = { normal = false, fast = true, super = false }, -- CF 29
	[30] = { normal = true, fast = false, super = false }, -- CF 30
	[31] = { normal = true, fast = false, super = false }, -- CF 31
	[32] = { normal = true, fast = false, super = false }, -- CF 32
	[33] = { normal = true, fast = false, super = false }, -- CF 33
	[34] = { normal = false, fast = true, super = false }, -- CF 34
	[35] = { normal = true, fast = true, super = true }, -- CF 35
	[36] = { normal = true, fast = false, super = false }, -- CF 36
	[37] = { normal = false, fast = true, super = true }, -- CF 37
	[38] = { normal = true, fast = false, super = false }, -- CF 38
	[39] = { normal = true, fast = true, super = false }, -- CF 39
	[40] = { normal = true, fast = false, super = false }, -- CF 40
	[41] = { normal = true, fast = false, super = false }, -- CF 41
	[42] = { normal = true, fast = true, super = false }, -- CF 42
	[43] = { normal = true, fast = true, super = false }, -- CF 43
	[44] = { normal = true, fast = false, super = false }, -- CF 44
	[45] = { normal = true, fast = false, super = false }, -- CF 45
	[46] = { normal = true, fast = true, super = false }, -- CF 46
	[47] = { normal = true, fast = true, super = false }, -- CF 47
	[48] = { normal = true, fast = false, super = false }, -- CF 48
	[49] = { normal = true, fast = true, super = true }, -- CF 49
	[50] = { normal = true, fast = false, super = false }, -- CF 50
	[51] = { normal = true, fast = true, super = false }, -- CF 51
	[52] = { normal = true, fast = true, super = false }, -- CF 52
	[53] = { normal = true, fast = false, super = false }, -- CF 53
	[54] = { normal = true, fast = true, super = true }, -- CF 54
	[55] = { normal = true, fast = false, super = false }, -- CF 55
	[56] = { normal = true, fast = true, super = false }, -- CF 56
	[57] = { normal = true, fast = false, super = false }, -- CF 57
	[58] = { normal = true, fast = true, super = true }, -- CF 58
	[59] = { normal = true, fast = false, super = false }, -- CF 59
	[60] = { normal = true, fast = false, super = false }, -- CF 60
	[61] = { normal = true, fast = true, super = false }, -- CF 61
	[62] = { normal = true, fast = true, super = false }, -- CF 62
	[63] = { normal = true, fast = false, super = false }, -- CF 63
	[64] = { normal = true, fast = false, super = false }, -- CF 64
	[65] = { normal = true, fast = true, super = false }, -- CF 65
	[66] = { normal = true, fast = false, super = false }, -- CF 66
	[67] = { normal = true, fast = false, super = false }, -- CF 67
	[68] = { normal = true, fast = true, super = false }, -- CF 68
	[69] = { normal = true, fast = false, super = false }, -- CF 69
	[70] = { normal = true, fast = false, super = false }, -- CF 70
	[71] = { normal = true, fast = true, super = false }, -- CF 71
	[72] = { normal = true, fast = false, super = false }, -- CF 72
	[73] = { normal = true, fast = false, super = false }, -- CF 73
	[74] = { normal = true, fast = true, super = false }, -- CF 74
	[75] = { normal = true, fast = true, super = false }, -- CF 75
	[76] = { normal = true, fast = false, super = false }, -- CF 76
	[77] = { normal = true, fast = true, super = true }, -- CF 77
	[78] = { normal = true, fast = true, super = true }, -- CF 78
	[79] = { normal = true, fast = true, super = true }, -- CF 79
	[80] = { normal = true, fast = false, super = false }, -- CF 80
	[81] = { normal = true, fast = true, super = false }, -- CF 81
	[82] = { normal = true, fast = false, super = false }, -- CF 82
	[83] = { normal = true, fast = true, super = false }, -- CF 83
	[84] = { normal = true, fast = false, super = false }, -- CF 84
	[85] = { normal = true, fast = true, super = false }, -- CF 85
	[86] = { normal = true, fast = false, super = false }, -- CF 86
	[87] = { normal = true, fast = true, super = false }, -- CF 87
	[88] = { normal = true, fast = true, super = true }, -- CF 88
	[89] = { normal = true, fast = false, super = false }, -- CF 89
	[90] = { normal = true, fast = false, super = false }, -- CF 90
	[91] = { normal = true, fast = false, super = false }, -- CF 91
	[92] = { normal = true, fast = true, super = false }, -- CF 92
	[93] = { normal = true, fast = false, super = false }, -- CF 93
	[94] = { normal = true, fast = false, super = false }, -- CF 94
	[95] = { normal = true, fast = false, super = false }, -- CF 95
	[96] = { normal = true, fast = true, super = false }, -- CF 96
	[97] = { normal = true, fast = true, super = true }, -- CF 97
	[98] = { normal = true, fast = true, super = false }, -- CF 98
	[99] = { normal = true, fast = false, super = false }, -- CF 99
	[100] = { normal = true, fast = false, super = false }, -- CF 100
	[101] = { normal = true, fast = false, super = false }, -- CF 101
	[102] = { normal = true, fast = false, super = false }, -- CF 102
	[103] = { normal = false, fast = true, super = false }, -- CF 103
	[104] = { normal = true, fast = false, super = false }, -- CF 104
	[105] = { normal = true, fast = false, super = false }, -- CF 105
	[106] = { normal = true, fast = false, super = false }, -- CF 106
	[107] = { normal = true, fast = false, super = false }, -- CF 107
	[108] = { normal = true, fast = false, super = false }, -- CF 108
	[109] = { normal = true, fast = false, super = false }, -- CF 109
	[110] = { normal = false, fast = true, super = false }, -- CF 110
	[111] = { normal = true, fast = false, super = false }, -- CF 111
	[112] = { normal = true, fast = false, super = false }, -- CF 112
	[113] = { normal = true, fast = false, super = false }, -- CF 113
	[114] = { normal = true, fast = false, super = false }, -- CF 114
	[115] = { normal = true, fast = false, super = false }, -- CF 115
	[116] = { normal = true, fast = false, super = false }, -- CF 116
	[117] = { normal = false, fast = true, super = false }, -- CF 117
	[118] = { normal = true, fast = false, super = false }, -- CF 118
	[119] = { normal = true, fast = false, super = false }, -- CF 119
	[120] = { normal = true, fast = false, super = false }, -- CF 120
	[121] = { normal = true, fast = false, super = false }, -- CF 121
	[122] = { normal = true, fast = false, super = false }, -- CF 122
	[123] = { normal = true, fast = false, super = false }, -- CF 123
	[124] = { normal = false, fast = true, super = false }, -- CF 124
	[125] = { normal = true, fast = false, super = false }, -- CF 125
	[126] = { normal = true, fast = false, super = false }, -- CF 126
	[127] = { normal = true, fast = false, super = false }, -- CF 127
	[128] = { normal = true, fast = false, super = false }, -- CF 128
	[129] = { normal = false, fast = true, super = false }, -- CF 129
	[130] = { normal = true, fast = true, super = true } -- CF 130
}

S.orderedWinBlocks = {
	{real = "WinBlock1", display = "+1 Wins", order = 1},
	{real = "WinBlock2", display = "+3 Wins", order = 2},
	{real = "WinBlock3", display = "+10 Wins", order = 3},
	{real = "WinBlock4", display = "+20 Wins", order = 4},
	{real = "WinBlock5", display = "+50 Wins", order = 5},
	{real = "WinBlock6", display = "+100 Wins", order = 6},
	{real = "WinBlock7", display = "+150 Wins", order = 7},
	{real = "WinBlock8", display = "+300 Wins", order = 8},
	{real = "WinBlock9", display = "+500 Wins", order = 9},
	{real = "WinBlock10", display = "+1K Wins", order = 10},
	{real = "WinBlock11", display = "+2.5K Wins", order = 11},
	{real = "WinBlock12", display = "+12K Wins", order = 12},
	{real = "WinBlock13", display = "+25K Wins", order = 13},
	{real = "WinBlock14", display = "+50K Wins", order = 14},
	{real = "WinBlock15", display = "+150K Wins", order = 15}
}

-- ---------- Helpers (pocas locals cada uno) ----------
function S.waitAliveHrp(returnCf)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp and hum and hum.Health > 0 then
		return hrp
	end
	char = player.CharacterAdded:Wait()
	hrp = char:WaitForChild("HumanoidRootPart", 8)
	local newHum = char:WaitForChild("Humanoid", 8)
	task.wait(0.35)
	if hrp and returnCf then
		hrp.CFrame = returnCf
		hrp.AssemblyLinearVelocity = Vector3.zero
	end
	if newHum and newHum.Health <= 0 then
		return S.waitAliveHrp(returnCf)
	end
	return hrp
end

function S.runExactCleanup()
	local list = S.targetNamesToDestroy
	if not list then
		return
	end
	for _, obj in pairs(Workspace:GetDescendants()) do
		local name = obj.Name
		for i = 1, #list do
			if name == list[i] then
				pcall(function()
					obj:Destroy()
				end)
			end
		end
	end
end

function S.getRouteIndicesForMode(mode)
	local key = "normal"
	if mode == "fast" then
		key = "fast"
	elseif mode == "ultra" or mode == "super" then
		key = "super"
	end
	local frames = S.routeCFrames
	local modes = S.routeModes
	local idxs = {}
	for i = 1, #frames do
		local m = modes[i]
		if not m or m[key] then
			idxs[#idxs + 1] = i
		end
	end
	if #idxs == 0 then
		for i = 1, #frames do
			idxs[i] = i
		end
	end
	return idxs
end

function S.getRouteCFramesForMode(mode)
	local idxs = S.getRouteIndicesForMode(mode)
	local frames = S.routeCFrames
	local list = {}
	for i = 1, #idxs do
		list[i] = frames[idxs[i]]
	end
	return list, idxs
end

-- ---------- Loading UI (solo init; se destruye al 100%) ----------
local function createLoadingUi()
	local old = playerGui:FindFirstChild("DeltaHubLoadingGui")
	if old then
		old:Destroy()
	end
	local gui = Instance.new("ScreenGui")
	gui.Name = "DeltaHubLoadingGui"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 200000
	gui.Parent = playerGui

	local screen = Instance.new("Frame")
	screen.Name = "LoadingScreen"
	screen.Parent = gui
	screen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	screen.Size = UDim2.fromScale(1, 1)
	screen.BorderSizePixel = 0
	screen.Active = true

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Parent = screen
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0.1, 0, 0.36, 0)
	title.Size = UDim2.new(0.8, 0, 0, 28)
	title.Font = Enum.Font.GothamBold
	title.Text = "Hallowen world cargando..."
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20

	local sub = Instance.new("TextLabel")
	sub.Name = "Sub"
	sub.Parent = screen
	sub.BackgroundTransparency = 1
	sub.Position = UDim2.new(0.1, 0, 0.42, 0)
	sub.Size = UDim2.new(0.8, 0, 0, 22)
	sub.Font = Enum.Font.Gotham
	sub.Text = "Preparando datos..."
	sub.TextColor3 = Color3.fromRGB(180, 180, 190)
	sub.TextSize = 14

	local barBg = Instance.new("Frame")
	barBg.Name = "BarBg"
	barBg.Parent = screen
	barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	barBg.Position = UDim2.new(0.15, 0, 0.50, 0)
	barBg.Size = UDim2.new(0.7, 0, 0, 16)
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 8)

	local barFill = Instance.new("Frame")
	barFill.Name = "BarFill"
	barFill.Parent = barBg
	barFill.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
	barFill.Size = UDim2.new(0, 0, 1, 0)
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 8)

	local pct = Instance.new("TextLabel")
	pct.Name = "Pct"
	pct.Parent = screen
	pct.BackgroundTransparency = 1
	pct.Position = UDim2.new(0.15, 0, 0.54, 0)
	pct.Size = UDim2.new(0.7, 0, 0, 20)
	pct.Font = Enum.Font.GothamBold
	pct.Text = "0.0%"
	pct.TextColor3 = Color3.fromRGB(220, 220, 230)
	pct.TextSize = 14

	local choice = Instance.new("Frame")
	choice.Name = "CleanChoice"
	choice.Parent = screen
	choice.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
	choice.Position = UDim2.new(0.15, 0, 0.60, 0)
	choice.Size = UDim2.new(0.7, 0, 0, 120)
	choice.Visible = false
	Instance.new("UICorner", choice).CornerRadius = UDim.new(0, 10)

	local choiceTitle = Instance.new("TextLabel")
	choiceTitle.Parent = choice
	choiceTitle.BackgroundTransparency = 1
	choiceTitle.Size = UDim2.new(1, 0, 0, 28)
	choiceTitle.Font = Enum.Font.GothamBold
	choiceTitle.Text = "Tipo de limpieza inicial"
	choiceTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	choiceTitle.TextSize = 14

	local function makeBtn(text, order, color)
		local b = Instance.new("TextButton")
		b.Parent = choice
		b.BackgroundColor3 = color
		b.Position = UDim2.new(0.05, 0, 0, 28 + (order - 1) * 30)
		b.Size = UDim2.new(0.9, 0, 0, 26)
		b.Font = Enum.Font.GothamBold
		b.Text = text
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.TextSize = 12
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		return b
	end

	local btnN = makeBtn("Limpieza Normal (ruta Normal)", 1, Color3.fromRGB(40, 100, 55))
	local btnF = makeBtn("Limpieza Rapida (ruta Fast)", 2, Color3.fromRGB(40, 80, 140))
	local btnS = makeBtn("Limpieza Super rapida (ruta Super)", 3, Color3.fromRGB(120, 60, 140))

	S.UI.LoadingGui = gui
	S.UI.LoadingScreen = screen
	S.UI.LoadingTitle = title
	S.UI.LoadingSub = sub
	S.UI.BarFill = barFill
	S.UI.PctLabel = pct
	S.UI.CleanChoice = choice
	S.UI.BtnCleanNormal = btnN
	S.UI.BtnCleanFast = btnF
	S.UI.BtnCleanSuper = btnS
	return gui
end

function S.setProgress(p, title, sub)
	p = math.clamp(tonumber(p) or 0, 0, 100)
	S.loadProgress = p
	local ui = S.UI
	if ui.BarFill then
		ui.BarFill.Size = UDim2.new(p / 100, 0, 1, 0)
	end
	if ui.PctLabel then
		ui.PctLabel.Text = string.format("%.1f%%", p)
	end
	if title and ui.LoadingTitle then
		ui.LoadingTitle.Text = title
	end
	if sub and ui.LoadingSub then
		ui.LoadingSub.Text = sub
	end
end

-- Al 100%: fade 1s (transparencia 0 -> 1) y destruye loading (libera RAM)
function S.fadeAndDestroyLoading()
	S.setProgress(100, "Listo", "Abriendo Delta Hub...")
	local screen = S.UI and S.UI.LoadingScreen
	local gui = S.UI and S.UI.LoadingGui
	if not screen then
		S.scriptReady = true
		return
	end
	local t0 = tick()
	while tick() - t0 < 1 do
		local a = (tick() - t0) / 1
		screen.BackgroundTransparency = a
		for _, d in ipairs(screen:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") then
				d.TextTransparency = a
				if d:IsA("TextButton") then
					d.BackgroundTransparency = math.min(1, a + 0.3)
				end
			elseif d:IsA("Frame") then
				d.BackgroundTransparency = math.clamp(a + (d.BackgroundTransparency or 0) * 0.2, 0, 1)
			end
		end
		RunService.Heartbeat:Wait()
	end
	if gui then
		gui:Destroy()
	end
	if S.UI then
		S.UI.LoadingGui = nil
		S.UI.LoadingScreen = nil
		S.UI.LoadingTitle = nil
		S.UI.LoadingSub = nil
		S.UI.BarFill = nil
		S.UI.PctLabel = nil
		S.UI.CleanChoice = nil
		S.UI.BtnCleanNormal = nil
		S.UI.BtnCleanFast = nil
		S.UI.BtnCleanSuper = nil
	end
	S.scriptReady = true
end

local function askCleanMode()
	local ui = S.UI
	local choice = ui.CleanChoice
	if not choice then
		return "normal"
	end
	choice.Visible = true
	S.setProgress(S.loadProgress, "Limpieza inicial", "Elige el tipo de limpieza")
	local selected = nil
	local c1 = ui.BtnCleanNormal.MouseButton1Click:Connect(function()
		selected = "normal"
	end)
	local c2 = ui.BtnCleanFast.MouseButton1Click:Connect(function()
		selected = "fast"
	end)
	local c3 = ui.BtnCleanSuper.MouseButton1Click:Connect(function()
		selected = "super"
	end)
	local t0 = tick()
	while not selected and tick() - t0 < 90 do
		task.wait(0.1)
	end
	c1:Disconnect()
	c2:Disconnect()
	c3:Disconnect()
	choice.Visible = false
	return selected or "normal"
end

local function moveToCFrame(hrp, cf)
	if not hrp or not cf then
		return
	end
	hrp.CFrame = cf
	hrp.AssemblyLinearVelocity = Vector3.zero
end

local function travelAlongCleanup(mode)
	local list = select(1, S.getRouteCFramesForMode(mode))
	if not list or #list == 0 then
		list = S.routeCFrames
	end
	local n = #list
	if n == 0 then
		S.runExactCleanup()
		return
	end
	local hrp = S.waitAliveHrp(list[1])
	if not hrp then
		return
	end
	moveToCFrame(hrp, list[1])
	S.runExactCleanup()
	S.setProgress(5, "Limpieza (" .. mode .. ")", "1/" .. n)

	local lastClean = tick()
	for i = 2, n do
		hrp = S.waitAliveHrp(list[i])
		if not hrp then
			break
		end
		local from = hrp.Position
		local target = list[i].Position
		local dist = (target - from).Magnitude
		if dist < 200 then
			moveToCFrame(hrp, list[i])
			S.runExactCleanup()
			lastClean = tick()
		else
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
			bv.Velocity = Vector3.zero
			bv.Parent = hrp
			while hrp and hrp.Parent and (hrp.Position - target).Magnitude > 4 do
				local d = target - hrp.Position
				if d.Magnitude > 0.1 then
					bv.Velocity = d.Unit * 250
				else
					bv.Velocity = Vector3.zero
				end
				if tick() - lastClean >= 1 then
					S.runExactCleanup()
					lastClean = tick()
				end
				RunService.Heartbeat:Wait()
			end
			if bv then
				bv:Destroy()
			end
			moveToCFrame(hrp, list[i])
			S.runExactCleanup()
			lastClean = tick()
		end
		-- progreso 5% -> 50% durante la ruta
		local p = 5 + (i / n) * 45
		S.setProgress(p, "Limpieza (" .. mode .. ")", i .. "/" .. n)
		task.wait()
	end
	S.runExactCleanup()
	S.setProgress(50, "Limpieza lista", "Cargando pestaña Farm...")
end

local function loadNext(url)
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(body) ~= "string" or #body < 20 then
		S.setProgress(S.loadProgress, "Error de descarga", tostring(body):sub(1, 60))
		warn("[Delta Hub] No se pudo bajar", url, body)
		return false
	end
	if body:sub(1, 9) == "<!DOCTYPE" or body:sub(1, 6) == "<html>" then
		S.setProgress(S.loadProgress, "Archivo no encontrado", url)
		warn("[Delta Hub] GitHub HTML:", url)
		return false
	end
	local fn, err = loadstring(body)
	if not fn then
		S.setProgress(S.loadProgress, "Error loadstring", tostring(err):sub(1, 60))
		warn("[Delta Hub] loadstring", err)
		return false
	end
	local okRun, runErr = pcall(fn)
	if not okRun then
		S.setProgress(S.loadProgress, "Error al ejecutar", tostring(runErr):sub(1, 60))
		warn("[Delta Hub] run", runErr)
		return false
	end
	return true
end

-- ---------- Main init sequence ----------
createLoadingUi()
S.setProgress(1, "Hallowen world", "Cargando datos...")
task.wait(0.05)
S.setProgress(3, "Hallowen world", "Rutas y WinBlocks listos")
task.wait(0.05)

local mode = askCleanMode()
S.cleanMode = mode
travelAlongCleanup(mode)

-- Encadenar pestaña Farm (50% -> 62.5% lo hace tab_farm)
S.setProgress(50, "Cargando Farm", "Descargando tab_farm.lua...")
loadNext(NEXT_URL)
