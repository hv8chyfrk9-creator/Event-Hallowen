-- tab_farm_tsunami.lua v6
-- Predicción: velocidad tsunami, ETA a CFrames, hold atrás si colisión, seguir detrás cuando pasa
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm

-- Estado tsunami
F._tsunamiHoldUntil = 0
F._tsunamiPos = nil
F._tsunamiVel = Vector3.zero
F._tsunamiSpeed = 0
F._tsunamiDir = Vector3.zero
F._tsunamiApproaching = false
F._tsunamiMovingAway = false
F._tsunamiDist = nil
F._lastTsunamiPos = nil
F._lastTsunamiTick = nil
F._tsunamiPathMin = nil -- extremo del path (más cerca del origen de ruta)
F._tsunamiPathMax = nil
F._tsunamiSeenCycle = false
F._safeHoldPos = nil -- CFrame/pos donde nos quedamos esperando
F._waitPassTarget = nil -- posición del CF que esperamos que el tsunami cruce
F._trailMode = false -- ir despacio detrás del tsunami

local SAFE_SIDE = 18 -- studs laterales = pasa al lado sin tocarnos
local HOLD_MARGIN = 12 -- margen extra detrás del CF peligroso
local PASS_CLEAR = 22 -- tsunami ya pasó el CF por esta distancia
local TRAIL_DIST = 35 -- seguir detrás a esta distancia

local function findTsunami()
	-- Preferir hijo/desc dentro de TsunamiStage4 llamado tsunami
	local stage = Workspace:FindFirstChild("TsunamiStage4", true)
	if stage then
		for _, d in ipairs(stage:GetDescendants()) do
			local n = string.lower(d.Name)
			if n == "tsunami" or (string.find(n, "tsunami", 1, true) and (d:IsA("BasePart") or d:IsA("Model"))) then
				return d
			end
		end
		-- fallback: el propio stage si es part/model
		if stage:IsA("BasePart") or stage:IsA("Model") then return stage end
	end
	local folder = Workspace:FindFirstChild("NPC & Piege") or Workspace:FindFirstChild("NPC & Piege", true)
	if folder then
		for _, d in ipairs(folder:GetDescendants()) do
			local n = string.lower(d.Name)
			if string.find(n, "tsunami", 1, true) then return d end
		end
	end
	for _, d in ipairs(Workspace:GetDescendants()) do
		local n = string.lower(d.Name)
		if n == "tsunami" or string.find(n, "tsunami", 1, true) then return d end
	end
	return nil
end

local function tsunamiWorldPos(t)
	if not t then return nil end
	if t:IsA("BasePart") then return t.Position end
	local ok, piv = pcall(function() return t:GetPivot() end)
	if ok and piv then return piv.Position end
	local p = t:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

-- Distancia punto a línea (trayectoria del tsunami)
local function distPointToRay(point, origin, dir)
	if dir.Magnitude < 0.05 then return (point - origin).Magnitude end
	local u = dir.Unit
	local w = point - origin
	local proj = w:Dot(u)
	local closest = origin + u * proj
	return (point - closest).Magnitude, proj
end

-- ETA tsunami a un punto (segundos). nil si no va hacia allá o speed~0
local function etaTsunamiToPoint(point)
	local pos = F._tsunamiPos
	local vel = F._tsunamiVel
	if not pos or not point then return nil end
	local speed = F._tsunamiSpeed or 0
	if speed < 1 then return nil end
	local to = point - pos
	local dir = F._tsunamiDir
	if dir.Magnitude < 0.05 then return nil end
	local along = to:Dot(dir.Unit)
	if along < 0 then return nil end -- se aleja del punto
	local lateral = (to - dir.Unit * along).Magnitude
	if lateral > SAFE_SIDE * 1.5 then return nil end -- no pasa cerca del punto
	return along / speed
end

-- ETA jugador a un CFrame (aprox con routeSpeed)
local function etaPlayerTo(hrp, targetPos)
	if not hrp or not targetPos then return nil end
	local dist = (hrp.Position - targetPos).Magnitude
	local spd = tonumber(F.routeSpeed) or 250
	if spd < 1 then spd = 50 end
	return dist / spd
end

-- Loop de tracking
task.spawn(function()
	while true do
		task.wait(0.08)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local t = findTsunami()
		local tPos = tsunamiWorldPos(t)
		local now = tick()

		if tPos then
			if F._lastTsunamiPos and F._lastTsunamiTick then
				local dt = now - F._lastTsunamiTick
				if dt > 0.02 and dt < 1 then
					local delta = tPos - F._lastTsunamiPos
					local instVel = delta / dt
					-- suavizado
					F._tsunamiVel = F._tsunamiVel:Lerp(instVel, 0.35)
					F._tsunamiSpeed = F._tsunamiVel.Magnitude
					if F._tsunamiSpeed > 0.5 then
						F._tsunamiDir = F._tsunamiVel.Unit
					end
				end
			end
			F._lastTsunamiPos = tPos
			F._lastTsunamiTick = now
			F._tsunamiPos = tPos

			if hrp then
				local d = (hrp.Position - tPos).Magnitude
				F._tsunamiDist = d
				if F._tsunamiDir.Magnitude > 0.1 then
					local towardPlayer = (hrp.Position - tPos).Unit
					local align = F._tsunamiDir:Dot(towardPlayer)
					F._tsunamiApproaching = align > 0.35 and d < 120
					F._tsunamiMovingAway = align < -0.25
				else
					F._tsunamiApproaching = false
					F._tsunamiMovingAway = false
				end
			end

			-- extremos del path (ciclo)
			if not F._tsunamiPathMin or tPos.X < F._tsunamiPathMin.X then F._tsunamiPathMin = tPos end
			if not F._tsunamiPathMax or tPos.X > F._tsunamiPathMax.X then F._tsunamiPathMax = tPos end
			-- también por magnitud desde un ref si se resetea
		else
			F._tsunamiPos = nil
			F._tsunamiDist = nil
			F._tsunamiApproaching = false
			F._tsunamiMovingAway = false
			-- si desapareció, limpiar hold
			if F._trailMode or F._waitPassTarget then
				F._trailMode = false
				F._waitPassTarget = nil
				F._safeHoldPos = nil
			end
		end
	end
end)

--[[
  Lógica de predicción para el brain:
  - Si ETA jugador ≈ ETA tsunami al siguiente CF → HOLD en CF anterior seguro
  - Esperar a que tsunami pase completamente ese CF (PASS_CLEAR)
  - Luego trail detrás hasta que se aleje / desaparezca / reinicie ciclo
  - Después continuar normal
]]
function S.tsunamiDangerSpeed(hrp, baseSpeed, nextCfPos)
	if not hrp then return baseSpeed, false end

	if F._ignoreTsunami then
		F._tsunamiSkipNext = false
		F._trailMode = false
		F._waitPassTarget = nil
		return baseSpeed, false
	end

	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local tPos = F._tsunamiPos
	local d = F._tsunamiDist
	if not tPos or not d then
		F._trailMode = false
		return baseSpeed, false
	end

	-- Si estamos en modo espera: quedarnos quietos hasta que el tsunami pase el target
	if F._waitPassTarget then
		local target = F._waitPassTarget
		local tToTarget = (tPos - target).Magnitude
		local passed = false
		if F._tsunamiDir.Magnitude > 0.1 then
			local along = (tPos - target):Dot(F._tsunamiDir.Unit)
			-- si el tsunami ya está del otro lado del target en su dirección
			if along > PASS_CLEAR then passed = true end
		end
		if tToTarget > PASS_CLEAR + 10 and F._tsunamiMovingAway then passed = true end
		if not tPos then passed = true end

		if passed then
			F._waitPassTarget = nil
			F._safeHoldPos = nil
			F._trailMode = true -- seguir detrás un rato
			return math.min(baseSpeed or 200, 40), true
		end
		-- seguir en hold
		return 0, true
	end

	-- Modo trail: ir despacio detrás del tsunami
	if F._trailMode then
		if d > TRAIL_DIST + 25 or not F._tsunamiPos then
			F._trailMode = false
			return baseSpeed, false
		end
		if F._tsunamiMovingAway and d > 20 then
			return math.min(baseSpeed or 200, 55), true
		end
		if d < 18 then
			return 0, true -- demasiado cerca aún
		end
		return math.min(baseSpeed or 200, 45), true
	end

	-- Predicción de colisión en el siguiente CFrame
	local dangerPos = nextCfPos
	if not dangerPos and type(F._nextRoutePos) == "Vector3" then
		dangerPos = F._nextRoutePos
	end

	if dangerPos and F._tsunamiSpeed and F._tsunamiSpeed > 2 then
		local etaT = etaTsunamiToPoint(dangerPos)
		local etaP = etaPlayerTo(hrp, dangerPos)
		if etaT and etaP then
			-- Si llegamos en ventanas similares (±1.2s) → colisión probable
			local window = 1.2
			if math.abs(etaT - etaP) < window and etaP < 4.5 then
				-- Hold: no avanzar a ese CF; el brain debería frenar
				F._waitPassTarget = dangerPos
				F._safeHoldPos = hrp.Position
				F._tsunamiHoldUntil = now + 0.15
				F._tsunamiSkipNext = false
				return 0, true
			end
			-- Si el tsunami llega antes y estamos cerca de entrar → frenar suave
			if etaT < etaP and etaT < 2.5 and etaP < 5 then
				return math.min(baseSpeed or 200, 25), true
			end
		end

		-- Pasa al lado sin tocarnos?
		local lateral = select(1, distPointToRay(hrp.Position, tPos, F._tsunamiDir))
		if lateral and lateral > SAFE_SIDE and F._tsunamiApproaching and d < 50 then
			-- lateral seguro: seguir con algo de cautela
			return math.min(baseSpeed or 200, math.max(60, (baseSpeed or 200) * 0.7)), false
		end
	end

	-- Fallback distancia (seguridad)
	if d <= 15 then
		if F._tsunamiMovingAway then
			F._tsunamiSkipNext = true
			return math.max(baseSpeed or 200, 350), true
		end
		F._tsunamiHoldUntil = now + 0.35
		return 0, true
	end
	if d <= 28 and F._tsunamiApproaching then
		return math.min(baseSpeed or 200, 12), true
	end
	if d <= 55 and F._tsunamiApproaching then
		return math.min(baseSpeed or 200, math.max(30, (baseSpeed or 200) * 0.45)), true
	end

	F._tsunamiSkipNext = false
	return baseSpeed, false
end

-- El brain puede setear F._nextRoutePos = Vector3 del próximo CFrame cada frame
print("[Delta Hub] Tsunami v6 (predicción) loaded")
