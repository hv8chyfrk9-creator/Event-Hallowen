-- tab_farm_auto.lua - Auto funciones for Event Hallowen
local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.Farm or not S.UI or not S.UI.FarmPage then
	warn("[Delta Hub] tab_farm_auto: falta Farm")
	return
end
local F = S.Farm
local farmPage = S.UI.FarmPage
local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local function notify(t)
	if S.notify then S.notify(t) else warn("[Delta Hub]", t) end
end
local function corner(parent, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = parent
	return c
end
local function section(parent, title, order)
	local wrap = Instance.new("Frame")
	wrap.Parent = parent
	wrap.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	wrap.BackgroundTransparency = 0.25
	wrap.Size = UDim2.new(1, -8, 0, 0)
	wrap.AutomaticSize = Enum.AutomaticSize.Y
	wrap.LayoutOrder = order or 1
	corner(wrap, 8)
	local lay = Instance.new("UIListLayout")
	lay.Parent = wrap
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 6)
	local pad = Instance.new("UIPadding")
	pad.Parent = wrap
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 6)
	pad.PaddingRight = UDim.new(0, 6)
	local head = Instance.new("TextLabel")
	head.Parent = wrap
	head.BackgroundTransparency = 1
	head.Size = UDim2.new(1, 0, 0, 20)
	head.Font = Enum.Font.GothamBold
	head.Text = title
	head.TextColor3 = Color3.fromRGB(255, 255, 255)
	head.TextSize = 13
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.LayoutOrder = 0
	return wrap
end

-- ---------- Auto funciones ----------
local autoBody = section(farmPage, "Auto funciones", 2)

F.autoRebirth = F.autoRebirth or false
F.autoTreadmill = F.autoTreadmill or false
F.treadmillInWins = F.treadmillInWins or false
F.bestTreadmill = F.bestTreadmill or "Normal"

local function makeSwitch(parent, text, order)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	row.Size = UDim2.new(1, -4, 0, 36)
	row.LayoutOrder = order or 1
	corner(row, 6)
	local label = Instance.new("TextLabel")
	label.Parent = row
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -58, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = Color3.fromRGB(240, 240, 245)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	local hit = Instance.new("TextButton")
	hit.Parent = row
	hit.BackgroundColor3 = Color3.fromRGB(70, 70, 78)
	hit.Position = UDim2.new(1, -46, 0.5, -11)
	hit.Size = UDim2.new(0, 36, 0, 22)
	hit.Text = ""
	corner(hit, 99)
	local knob = Instance.new("Frame")
	knob.Parent = hit
	knob.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
	knob.Position = UDim2.new(0, 2, 0, 2)
	knob.Size = UDim2.new(0, 18, 0, 18)
	corner(knob, 99)
	local function paint(on)
		hit.BackgroundColor3 = on and Color3.fromRGB(70, 190, 90) or Color3.fromRGB(70, 70, 78)
		knob.Position = on and UDim2.new(1, -20, 0, 2) or UDim2.new(0, 2, 0, 2)
	end
	return row, paint, hit
end

local bestLabel = Instance.new("TextLabel")
bestLabel.Parent = autoBody
bestLabel.BackgroundTransparency = 1
bestLabel.Size = UDim2.new(1, -4, 0, 20)
bestLabel.Font = Enum.Font.Gotham
bestLabel.Text = "Best treadmill: " .. tostring(F.bestTreadmill)
bestLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
bestLabel.TextSize = 12
bestLabel.TextXAlignment = Enum.TextXAlignment.Left
bestLabel.LayoutOrder = 1

local _, paintRebirth, hitRebirth = makeSwitch(autoBody, "Auto Rebirth", 2)
hitRebirth.MouseButton1Click:Connect(function()
	F.autoRebirth = not F.autoRebirth
	paintRebirth(F.autoRebirth)
end)
paintRebirth(F.autoRebirth)

local function visiblePurchase()
	local gui = player:FindFirstChild("PlayerGui")
	if not gui then return false end
	for _, d in ipairs(gui:GetDescendants()) do
		if d:IsA("GuiObject") and d.Visible then
			local n = string.lower(d.Name)
			if n:find("robux") or n:find("purchase") or n:find("prompt") or n:find("shopmodal") or n:find("buy") then
				if d:IsA("Frame") or d:IsA("ImageLabel") or d:IsA("TextButton") then
					return true
				end
			end
		end
	end
	return false
end

local function closeTreadmillShop()
	pcall(function()
		local gui = player:FindFirstChild("PlayerGui")
		if not gui then return end
		for _, d in ipairs(gui:GetDescendants()) do
			local n = string.lower(d.Name or "")
			if n:find("robuxshop") or n:find("purchase") or n:find("prompt") then
				if d:IsA("GuiObject") then d.Visible = false end
			end
		end
	end)
end

local function detectBestTreadmill()
	local best = "Normal"
	local checks = {
		{ name = "Admin", remote = "PromptAdminTreadmill" },
		{ name = "Candy", remote = "PromptCandyTreadmill" },
		{ name = "Diamond", remote = "PromptDiamondTreadmill" },
		{ name = "Gold", remote = "PromptGoldTreadmill" },
	}
	local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	for _, info in ipairs(checks) do
		local remote = remotes and remotes:FindFirstChild(info.remote)
		if remote then
			closeTreadmillShop()
			local before = visiblePurchase()
			pcall(function() remote:FireServer() end)
			task.wait(0.45)
			local opened = visiblePurchase() and not before
			closeTreadmillShop()
			if not opened then
				best = info.name
				break
			end
		end
	end
	closeTreadmillShop()
	F.bestTreadmill = best
	return best
end

local function findConveyor(bestName)
	local map = {
		Admin = "TreadmillAdmin",
		Candy = "TreadmillCandy",
		Diamond = "TreadmillDiamond",
		Gold = "TreadmillGold",
		Normal = "Treadmill",
	}
	local want = map[bestName] or "Treadmill"
	local goldRef = Workspace:FindFirstChild("TreadmillGold", true)
	local bestConv, bestDist = nil, math.huge
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local origin = hrp and hrp.Position or Vector3.zero
	if goldRef then origin = goldRef:GetPivot().Position end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name == "Conveyor" or string.lower(obj.Name) == "conveyor" then
			local parent = obj.Parent
			local pname = parent and parent.Name or ""
			local ok = false
			if bestName == "Normal" then
				if pname == "Treadmill" or (string.find(pname, "Treadmill") and not string.find(pname, "Admin") and not string.find(pname, "Candy") and not string.find(pname, "Diamond") and not string.find(pname, "Gold")) then
					ok = true
				end
			else
				if string.find(pname, want) or pname == want then
					ok = true
				end
			end
			if ok then
				local pos = obj:IsA("BasePart") and obj.Position or (obj:IsA("Model") and obj:GetPivot().Position)
				if pos then
					local d = (pos - origin).Magnitude
					if d < bestDist then
						bestDist = d
						bestConv = obj
					end
				end
			end
		end
	end
	return bestConv
end

local function goToBestConveyor()
	local best = F.bestTreadmill or detectBestTreadmill()
	local conv = findConveyor(best)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp or not conv then
		notify("No se encontro Conveyor (" .. tostring(best) .. ")")
		return
	end
	local pos = conv:IsA("BasePart") and conv.Position or conv:GetPivot().Position
	hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
	hrp.AssemblyLinearVelocity = Vector3.zero
	notify("Treadmill: " .. tostring(best))
end

local _, paintTread, hitTread = makeSwitch(autoBody, "Auto Treadmill", 3)
hitTread.MouseButton1Click:Connect(function()
	F.autoTreadmill = not F.autoTreadmill
	paintTread(F.autoTreadmill)
	if F.autoTreadmill then
		task.spawn(function()
			F.bestTreadmill = detectBestTreadmill()
			bestLabel.Text = "Best treadmill: " .. tostring(F.bestTreadmill)
			goToBestConveyor()
		end)
	end
end)
paintTread(F.autoTreadmill)

local _, paintTIW, hitTIW = makeSwitch(autoBody, "Treadmill in wins", 4)
hitTIW.MouseButton1Click:Connect(function()
	F.treadmillInWins = not F.treadmillInWins
	paintTIW(F.treadmillInWins)
end)
paintTIW(F.treadmillInWins)

if not S._farmAutoLoops then
	S._farmAutoLoops = true
	task.spawn(function()
		while true do
			task.wait(1.5)
			if F.autoRebirth then
				pcall(function()
					local ev = game:GetService("ReplicatedStorage").Remotes.Rebirth
					ev:FireServer()
				end)
			end
		end
	end)
	task.spawn(function()
		local lockedConv, origCF = nil, nil
		while true do
			task.wait(0.2)
			if F.treadmillInWins and F.routeRunning then
				local conv = findConveyor(F.bestTreadmill or "Normal")
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if conv and hrp and conv:IsA("BasePart") then
					if lockedConv ~= conv then
						if lockedConv and origCF then
							pcall(function() lockedConv.CFrame = origCF end)
						end
						lockedConv = conv
						origCF = conv.CFrame
					end
					pcall(function()
						conv.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3, 0))
					end)
				end
			else
				if lockedConv and origCF then
					pcall(function() lockedConv.CFrame = origCF end)
					lockedConv, origCF = nil, nil
				end
			end
		end
	end)
end
