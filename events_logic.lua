if not S._eventsLoopsStarted then
	S._eventsLoopsStarted = true
	E.searchInterval = 1
	E.returnPos = nil
	E.busy = false

	local function anyEventOn()
		return E.chocolate or E.candy or E.coin or E.xp
	end

	task.spawn(function()
		while true do
			local interval = E.searchInterval or 1
			task.wait(interval)
			if not anyEventOn() then
				E.searchInterval = 1
				E.queue = {}
				E.seen = {}
				E.busy = false
				continue
			end
			local farm = S.Farm
			if farm and farm.routeRunning then continue end
			if E.busy then continue end

			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			E.seen = {}
			E.queue = {}
			for _, obj in ipairs(Workspace:GetDescendants()) do
				rememberEvent(obj)
			end

			if #E.queue == 0 then
				E.searchInterval = 1
				continue
			end

			local order = {}
			for pi, name in ipairs(E.priority or { "chocolate", "battlecoin", "xp", "candy", "specialkeys" }) do
				order[name] = pi
			end
			local function kindKey(k)
				if k == "coin" then return "battlecoin" end
				return k
			end
			table.sort(E.queue, function(a, b)
				return (order[kindKey(a.kind)] or 99) < (order[kindKey(b.kind)] or 99)
			end)

			E.busy = true
			E.searchInterval = 0.3
			E.returnPos = hrp.Position

			while #E.queue > 0 and anyEventOn() and not (farm and farm.routeRunning) do
				local item = table.remove(E.queue, 1)
				if not item or not item.pos then continue end
				if item.obj and not item.obj.Parent then continue end
				local pos = objectPosition(item.obj) or item.pos
				goToPos(hrp, pos)
				task.wait(0.35)

				-- caja ~100 studs (radio 50)
				for _, obj in ipairs(Workspace:GetDescendants()) do
					local p = objectPosition(obj)
					if p and (p - pos).Magnitude <= 50 then
						rememberEvent(obj)
					end
				end
				table.sort(E.queue, function(a, b)
					return (order[kindKey(a.kind)] or 99) < (order[kindKey(b.kind)] or 99)
				end)

				local tWait = tick()
				while tick() - tWait < 1 and anyEventOn() do
					task.wait(0.3)
					for _, obj in ipairs(Workspace:GetDescendants()) do
						rememberEvent(obj)
					end
				end
				hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if not hrp then break end
			end

			if hrp and E.returnPos then
				if E.collectMode == "Tp" then
					hrp.CFrame = CFrame.new(E.returnPos + Vector3.new(0, 3, 0))
				else
					local sg = S.UI.ScreenGui
					if sg then
						local answered = nil
						local fr = Instance.new("Frame")
						fr.Parent = sg
						fr.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
						fr.Position = UDim2.new(0.5, -140, 0.35, 0)
						fr.Size = UDim2.new(0, 280, 0, 110)
						fr.ZIndex = 50
						Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)
						local lab = Instance.new("TextLabel")
						lab.Parent = fr
						lab.BackgroundTransparency = 1
						lab.Size = UDim2.new(1, -12, 0, 36)
						lab.Position = UDim2.new(0, 6, 0, 8)
						lab.Font = Enum.Font.GothamBold
						lab.Text = "Regresar a tu lugar?"
						lab.TextColor3 = Color3.fromRGB(255, 255, 255)
						lab.TextSize = 13
						lab.ZIndex = 51
						local y = Instance.new("TextButton")
						y.Parent = fr
						y.Size = UDim2.new(0.4, 0, 0, 30)
						y.Position = UDim2.new(0.05, 0, 0, 55)
						y.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
						y.Text = "Si"
						y.TextColor3 = Color3.fromRGB(255, 255, 255)
						y.Font = Enum.Font.GothamBold
						y.ZIndex = 51
						Instance.new("UICorner", y).CornerRadius = UDim.new(0, 6)
						local n = Instance.new("TextButton")
						n.Parent = fr
						n.Size = UDim2.new(0.4, 0, 0, 30)
						n.Position = UDim2.new(0.55, 0, 0, 55)
						n.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
						n.Text = "No"
						n.TextColor3 = Color3.fromRGB(255, 255, 255)
						n.Font = Enum.Font.GothamBold
						n.ZIndex = 51
						Instance.new("UICorner", n).CornerRadius = UDim.new(0, 6)
						y.MouseButton1Click:Connect(function() answered = true end)
						n.MouseButton1Click:Connect(function() answered = false end)
						local t0 = tick()
						while answered == nil and tick() - t0 < 10 do task.wait(0.1) end
						fr:Destroy()
						if answered then goToPos(hrp, E.returnPos) end
					end
				end
			end

			E.busy = false
			E.searchInterval = 1
		end
	end)

	task.spawn(function()
		while true do
			task.wait(2)
			local farm = S.Farm
			local routeRunning = farm and farm.routeRunning
			if E.autoSpecialKeys and not routeRunning then
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, obj in pairs(Workspace:GetDescendants()) do
						if obj.Name:find("SpecialKey") then
							if obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart) then
								processSpecialKey(obj, hrp)
								break
							end
						end
					end
				end
			end
		end
	end)
end

setProgress(87, "Events", "Events lista")
task.spawn(function()
	local ok, body = pcall(function() return game:HttpGet(NEXT_URL) end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] no tab_extras")
		setProgress(87.5, "Error", "Falta tab_extras")
		return
	end
	local fn, err = loadstring(body)
	if not fn then warn("[Delta Hub] tab_extras load", err) return end
	setProgress(87.5, "Events", "Entrando a Extras...")
	local okRun, runErr = pcall(fn)
	if not okRun then warn("[Delta Hub] tab_extras run", runErr) end
end)

print("[Delta Hub] Events listo")
