-- tab_farm_tsunami.lua v7
-- Regla simple: tsunami DELANTE → frenar | tsunami DETRÁS → seguir
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
S.Farm = S.Farm or {}
local F = S.Farm

F._tsunamiHoldUntil = 0
F._tsunamiPos = nil
F._tsunamiVel = Vector3.zero
F._tsunamiSpeed = 0
F._tsunamiDir = Vector3.zero
F._tsunamiDist = nil
F._lastTsunamiPos = nil
F._lastTsunamiTick = nil
F._tsunamiInFront = false
F._tsunamiBehind = false
F._tsunamiComingAtUs = false

local FRONT_RANGE = 70 -- studs: si está delante y dentro de esto, reaccionar
local STOP_RANGE = 35 -- delante y muy cerca → full stop
local SLOW_RANGE = 55 -- delante → ir lento

local function findTsunami()
	local stage = Workspace:FindFirstChild("TsunamiStage4", true)
	if stage then
		for _, d in ipairs(stage:GetDescendants()) do
			local n = string.lower(d.Name)
			if n == "tsunami" or (string.find(n, "tsunami", 1, true) and (d:IsA("BasePart") or d:IsA("Model"))) then
				return d
			end
		end
		if stage:IsA("BasePart") or stage:IsA("Model") then return stage end
	end
	local folder = Workspace:FindFirstChild("NPC & Piege") or Workspace:FindFirstChild("NPC & Piege", true)
	if folder then
		for _, d in ipairs(folder:GetDescendants()) do
			if string.find(string.lower(d.Name), "tsunami", 1, true) then return d end
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
					local instVel = (tPos - F._lastTsunamiPos) / dt
					F._tsunamiVel = F._tsunamiVel:Lerp(instVel, 0.4)
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

				-- Dirección de movimiento del jugador (hacia el siguiente CF si existe)
				local moveDir = nil
				if type(F._nextRoutePos) == "Vector3" then
					local toNext = F._nextRoutePos - hrp.Position
					if toNext.Magnitude > 0.5 then moveDir = toNext.Unit end
				end
				if not moveDir and hrp.AssemblyLinearVelocity.Magnitude > 2 then
					moveDir = hrp.AssemblyLinearVelocity.Unit
				end
				if not moveDir then
					moveDir = hrp.CFrame.LookVector
				end

				-- Vector al tsunami desde el jugador
				local toTsunami = tPos - hrp.Position
				local flatTo = Vector3.new(toTsunami.X, 0, toTsunami.Z)
				local flatMove = Vector3.new(moveDir.X, 0, moveDir.Z)
				if flatTo.Magnitude > 0.1 and flatMove.Magnitude > 0.1 then
					local align = flatMove.Unit:Dot(flatTo.Unit)
					-- >0.15 = más o menos delante en la dirección del recorrido
					F._tsunamiInFront = align > 0.15
					F._tsunamiBehind = align < -0.15
				else
					F._tsunamiInFront = false
					F._tsunamiBehind = false
				end

				-- ¿El tsunami se mueve hacia nosotros?
				if F._tsunamiDir.Magnitude > 0.1 then
					local towardUs = (hrp.Position - tPos)
					if towardUs.Magnitude > 0.1 then
						F._tsunamiComingAtUs = F._tsunamiDir:Dot(towardUs.Unit) > 0.3
					else
						F._tsunamiComingAtUs = false
					end
				else
					F._tsunamiComingAtUs = false
				end
			end
		else
			F._tsunamiPos = nil
			F._tsunamiDist = nil
			F._tsunamiInFront = false
			F._tsunamiBehind = false
			F._tsunamiComingAtUs = false
		end
	end
end)

function S.tsunamiDangerSpeed(hrp, baseSpeed, nextCfPos)
	if not hrp then return baseSpeed, false end

	-- WinBlocks ≤10: ignorar
	if F._ignoreTsunami then
		F._tsunamiSkipNext = false
		return baseSpeed, false
	end

	local now = tick()
	if now < (F._tsunamiHoldUntil or 0) then
		return 0, true
	end

	local d = F._tsunamiDist
	if not d or not F._tsunamiPos then
		return baseSpeed, false
	end

	-- ==========================================
	-- REGLA PRINCIPAL
	-- Delante → frenar / esperar
	-- Detrás → seguir (no frenar por él)
	-- ==========================================

	-- DETRÁS: ignorar y seguir el recorrido
	if F._tsunamiBehind and not F._tsunamiInFront then
		F._tsunamiSkipNext = false
		return baseSpeed, false
	end

	-- DELANTE
	if F._tsunamiInFront and d <= FRONT_RANGE then
		-- Muy cerca delante → parar
		if d <= STOP_RANGE then
			-- Si viene hacia nosotros: parar y esperar que cruce/pase
			if F._tsunamiComingAtUs then
				F._tsunamiHoldUntil = now + 0.25
				F._tsunamiSkipNext = false
				return 0, true
			end
			-- Está delante pero no viene hacia nosotros (lateral o quieto):
			-- frenar un poco, observar; si se aleja podemos seguir lento
			return 0, true
		end

		-- Delante a media distancia
		if d <= SLOW_RANGE then
			if F._tsunamiComingAtUs then
				-- Viene hacia nosotros: frenar fuerte y esperar
				return 0, true
			end
			-- Delante pero no viene a nosotros: ir muy lento / parar a observar
			return math.min(baseSpeed or 200, 8), true
		end

		-- Delante pero más lejos (SLOW_RANGE .. FRONT_RANGE)
		if F._tsunamiComingAtUs then
			return math.min(baseSpeed or 200, 20), true
		end
		return math.min(baseSpeed or 200, math.max(40, (baseSpeed or 200) * 0.35)), true
	end

	-- Ni claramente delante ni detrás (lado): cautela suave si está cerca
	if d <= 25 then
		return math.min(baseSpeed or 200, 15), true
	end

	F._tsunamiSkipNext = false
	return baseSpeed, false
end

print("[Delta Hub] Tsunami v7 (delante=frenar, detrás=seguir)")
