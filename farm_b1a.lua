local function findWinBlockPos(wbName)
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == wbName then
			if obj:IsA("BasePart") then return obj.Position, obj end
			local okp, piv = pcall(function() return obj:GetPivot() end)
			if okp and piv then return piv.Position, obj end
			local part = obj:FindFirstChildWhichIsA("BasePart", true)
			if part then return part.Position, obj end
		end
	end
	return nil, nil
end

local function runOneLap()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	local hum = char:WaitForChild("Humanoid", 5)
	if not hrp or not hum or hum.Health <= 0 then return false end
	if S.Signals.SetNoclip then S.Signals.SetNoclip(true) end

	local activeRoute = select(1, S.getRouteCFramesForMode(F.routeMode))
	if not activeRoute or #activeRoute == 0 then activeRoute = S.routeCFrames end
	if not activeRoute or #activeRoute == 0 then
		notify("Sin CFrames")
		return false
	end

	local bv = hrp:FindFirstChildOfClass("BodyVelocity")
	if not bv then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1250
		bv.Parent = hrp
	end

	hrp.CFrame = activeRoute[1]
	task.wait(0.15)

	local wbName = F.selectedRealName or "WinBlock1"
	local targetRouteIndex = #activeRoute
	local winPos = nil
	local lastWbSearch = 0

	local function searchWinAndPickNearestCF()
		local pos = select(1, findWinBlockPos(wbName))
		if not pos then return end
		winPos = pos
		local bestI, bestD = 1, math.huge
		for ri = 1, #activeRoute do
			local d = (activeRoute[ri].Position - pos).Magnitude
			if d < bestD then bestD, bestI = d, ri end
		end
		if bestI >= 1 then targetRouteIndex = bestI end
	end

	searchWinAndPickNearestCF()

	for i = 2, #activeRoute do
		if not F.routeRunning then break end
		if i > targetRouteIndex then break end

		if hum.Health <= 0 then
			if S.waitAliveHrp then
				hrp = S.waitAliveHrp(activeRoute[math.max(1, i - 1)])
				hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if hrp then
					bv = hrp:FindFirstChildOfClass("BodyVelocity")
					if not bv then
						bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
						bv.Parent = hrp
					end
				else
					return false
				end
			else
				return false
			end
		end

		if tick() - lastWbSearch >= 1 then
			lastWbSearch = tick()
			searchWinAndPickNearestCF()
			if i > targetRouteIndex then break end
		end

		local target = activeRoute[i]
		local targetPos = target.Position
		local guard = 0
		while hrp and hrp.Parent and (hrp.Position - targetPos).Magnitude > 2.5 and F.routeRunning and hum and hum.Health > 0 and guard < 600 do
			guard = guard + 1
			if tick() - lastWbSearch >= 1 then
				lastWbSearch = tick()
				searchWinAndPickNearestCF()
				if i > targetRouteIndex then break end
			end
			local dist = (hrp.Position - targetPos).Magnitude
			local nextD = activeRoute[i + 1] and (activeRoute[i + 1].Position - targetPos).Magnitude
			local spd = approachSpeed(dist, nextD)
			if S.tsunamiDangerSpeed then spd = select(1, S.tsunamiDangerSpeed(hrp, spd)) end
			if F._tsunamiSkipNext then
				F._tsunamiSkipNext = false
				break
			end
			if dist > 0.05 then
				bv.Velocity = (targetPos - hrp.Position).Unit * spd
			else
				bv.Velocity = Vector3.zero
			end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
	end

	if not winPos then winPos = select(1, findWinBlockPos(wbName)) end
	if winPos and hrp and F.routeRunning then
		F._winsBeforeClaim = (function()
			local ls = player:FindFirstChild("leaderstats")
			local w = ls and ls:FindFirstChild("Wins")
			return w and tonumber(w.Value) or 0
		end)()
		local t0 = tick()
		while hrp and hrp.Parent and (hrp.Position - winPos).Magnitude > 2 and tick() - t0 < 30 and F.routeRunning do
			if bv then bv.Velocity = (winPos - hrp.Position).Unit * 20 end
			RunService.Heartbeat:Wait()
		end
		if bv then bv.Velocity = Vector3.zero end
		F._lastWinPos = winPos
		notify("WinBlock tocado")
		local waitStart = tick()
		while tick() - waitStart < 2 and F.routeRunning do
			if hrp and hrp.Parent then
				local p = hrp.Position
				local inBox = math.abs(p.X - winPos.X) <= 5 and math.abs(p.Y - winPos.Y) <= 5 and math.abs(p.Z - winPos.Z) <= 5
				if not inBox and bv then
					bv.Velocity = (winPos - hrp.Position).Unit * 20
				elseif bv then
					bv.Velocity = Vector3.zero
				end
			end
			task.wait(0.1)
		end
		if bv then bv.Velocity = Vector3.zero end
	end

		-- Verificar si subieron las Wins
		local function readWins()
			local ls = player:FindFirstChild("leaderstats")
			local w = ls and ls:FindFirstChild("Wins")
			if w then return tonumber(w.Value) or 0 end
			for _, d in ipairs(player:GetDescendants()) do
