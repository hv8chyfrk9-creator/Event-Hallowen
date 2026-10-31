				if d.Name == "Wins" and (d:IsA("NumberValue") or d:IsA("IntValue") or d:IsA("StringValue")) then
					return tonumber(d.Value) or 0
				end
			end
			return 0
		end
		local winsBefore = F._winsBeforeClaim or readWins()
		local winsAfter = readWins()
		if winsAfter <= winsBefore then
			local sg = S.UI.ScreenGui or player:FindFirstChild("PlayerGui")
			if sg then
				local prompt = Instance.new("Frame")
				prompt.Name = "WinsClaimPrompt"
				prompt.Parent = sg
				prompt.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
				prompt.Position = UDim2.new(0.5, -140, 0.4, 0)
				prompt.Size = UDim2.new(0, 280, 0, 120)
				prompt.ZIndex = 50
				Instance.new("UICorner", prompt).CornerRadius = UDim.new(0, 8)
				local lab = Instance.new("TextLabel")
				lab.Parent = prompt
				lab.BackgroundTransparency = 1
				lab.Size = UDim2.new(1, -16, 0, 40)
				lab.Position = UDim2.new(0, 8, 0, 8)
				lab.Font = Enum.Font.GothamBold
				lab.Text = "Recibiste las wins?"
				lab.TextColor3 = Color3.fromRGB(255, 255, 255)
				lab.TextSize = 14
				lab.ZIndex = 51
				local answered = nil
				local yes = Instance.new("TextButton")
				yes.Parent = prompt
				yes.Size = UDim2.new(0.4, 0, 0, 32)
				yes.Position = UDim2.new(0.05, 0, 0, 60)
				yes.BackgroundColor3 = Color3.fromRGB(40, 120, 50)
				yes.Text = "Si"
				yes.TextColor3 = Color3.fromRGB(255, 255, 255)
				yes.Font = Enum.Font.GothamBold
				yes.ZIndex = 51
				Instance.new("UICorner", yes).CornerRadius = UDim.new(0, 6)
				local no = Instance.new("TextButton")
				no.Parent = prompt
				no.Size = UDim2.new(0.4, 0, 0, 32)
				no.Position = UDim2.new(0.55, 0, 0, 60)
				no.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
				no.Text = "No"
				no.TextColor3 = Color3.fromRGB(255, 255, 255)
				no.Font = Enum.Font.GothamBold
				no.ZIndex = 51
				Instance.new("UICorner", no).CornerRadius = UDim.new(0, 6)
				yes.MouseButton1Click:Connect(function() answered = "yes" end)
				no.MouseButton1Click:Connect(function() answered = "no" end)
				local t0 = tick()
				while answered == nil and tick() - t0 < 12 do task.wait(0.1) end
				prompt:Destroy()
				if answered == "no" then
					local why = Instance.new("Frame")
					why.Parent = sg
					why.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
					why.Position = UDim2.new(0.5, -140, 0.4, 0)
					why.Size = UDim2.new(0, 280, 0, 130)
					why.ZIndex = 50
					Instance.new("UICorner", why).CornerRadius = UDim.new(0, 8)
					local wl = Instance.new("TextLabel")
					wl.Parent = why
					wl.BackgroundTransparency = 1
					wl.Size = UDim2.new(1, -16, 0, 30)
					wl.Position = UDim2.new(0, 8, 0, 8)
					wl.Font = Enum.Font.GothamBold
					wl.Text = "Por que?"
					wl.TextColor3 = Color3.fromRGB(255, 255, 255)
					wl.TextSize = 14
					wl.ZIndex = 51
					local reason = nil
					local b1 = Instance.new("TextButton")
					b1.Parent = why
					b1.Size = UDim2.new(0.9, 0, 0, 28)
					b1.Position = UDim2.new(0.05, 0, 0, 44)
					b1.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
					b1.Text = "Falta de nivel"
					b1.TextColor3 = Color3.fromRGB(255, 255, 255)
					b1.Font = Enum.Font.Gotham
					b1.ZIndex = 51
					Instance.new("UICorner", b1).CornerRadius = UDim.new(0, 6)
					local b2 = Instance.new("TextButton")
					b2.Parent = why
					b2.Size = UDim2.new(0.9, 0, 0, 28)
					b2.Position = UDim2.new(0.05, 0, 0, 80)
					b2.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
					b2.Text = "Otro"
					b2.TextColor3 = Color3.fromRGB(255, 255, 255)
					b2.Font = Enum.Font.Gotham
					b2.ZIndex = 51
					Instance.new("UICorner", b2).CornerRadius = UDim.new(0, 6)
					b1.MouseButton1Click:Connect(function() reason = "level" end)
					b2.MouseButton1Click:Connect(function() reason = "other" end)
					local t1 = tick()
					while reason == nil and tick() - t1 < 12 do task.wait(0.1) end
					why:Destroy()
					if reason == "level" then
						F._levelBlocked = true
						notify("Posible falta de nivel")
					end
				end
			end
		else
			F._levelBlocked = false
		end

	if bv then bv:Destroy() end
	return true
end

startBtn.MouseButton1Click:Connect(function()
	if F.routeRunning then
		stopRoute()
		notify("Recorrido detenido")
		return
	end
	F.routeRunning = true
	startBtn.Text = "Detener Recorrido"
	startBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
	task.spawn(function()
		repeat
			local ok = runOneLap()
			if not F.routeRunning then break end
			if F.delayTime and F.delayTime > 0 then task.wait(F.delayTime) end
		until not F.infinite or not F.routeRunning
		stopRoute()
	end)
end)
