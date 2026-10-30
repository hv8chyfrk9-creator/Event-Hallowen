-- ==========================================
-- DELTA HUB - Event Hallowen - tab_events.lua
-- Solo pestaña Events | 75% -> 87.5%
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_events: falta hub")
	return
end

S.Events = S.Events or {}
local E = S.Events
E.chocolate = E.chocolate or false
E.candy = E.candy or false
E.coin = E.coin or false
E.xp = E.xp or false
E.collectMode = E.collectMode or "Tween"
E.queue = E.queue or {}
E.seen = E.seen or {}
E.autoSpecialKeys = E.autoSpecialKeys or false
E.specialKeyCount = E.specialKeyCount or 0
E.specialKeyWins = E.specialKeyWins or 0
E.specialKeysQueue = E.specialKeysQueue or {}

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local NEXT_URL = BASE .. "tab_extras.lua"

local function setProgress(p, title, sub)
	if S.setProgress then S.setProgress(p, title, sub) end
end

local function notify(text)
	if S.notify then
		S.notify(text)
		return
	end
	warn("[Delta Hub]", text)
end

setProgress(76, "Events", "Creando pestaña Events...")

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

local function makeButton(parent, text, order)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
	b.Size = UDim2.new(1, -4, 0, 32)
	b.Font = Enum.Font.GothamBold
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.TextSize = 12
	b.LayoutOrder = order or 1
	corner(b, 6)
	return b
end

local function createScrollingPage(parent)
	local sc = Instance.new("ScrollingFrame")
	sc.Parent = parent
	sc.BackgroundTransparency = 1
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.ScrollBarThickness = 4
	sc.Visible = false
	local lay = Instance.new("UIListLayout")
	lay.Parent = sc
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 8)
	return sc
end

local eventsPage = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Events = eventsPage
S.UI.EventsPage = eventsPage

local tabEvents = Instance.new("TextButton")
tabEvents.Parent = S.UI.Sidebar
tabEvents.Size = UDim2.new(0, 92, 0, 42)
tabEvents.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
tabEvents.Font = Enum.Font.GothamBold
tabEvents.Text = "Events"
tabEvents.TextColor3 = Color3.fromRGB(255, 255, 255)
tabEvents.TextSize = 14
tabEvents.LayoutOrder = 3
corner(tabEvents, 6)
S.UI.TabEvents = tabEvents
tabEvents.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	eventsPage.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Events" end
end)

setProgress(78, "Events", "Admin abuse / daily...")

local adminBody = section(eventsPage, "Admin abuse", 1)
local _, paintChoco, hitChoco = makeSwitch(adminBody, "Auto Chocolate Hunt", 1)
local _, paintCandy, hitCandy = makeSwitch(adminBody, "Auto Candy Corn", 2)
local _, paintCoin, hitCoin = makeSwitch(adminBody, "Auto Battle Coin", 3)
local _, paintXp, hitXp = makeSwitch(adminBody, "Auto XP Event Key", 4)

hitChoco.MouseButton1Click:Connect(function()
	E.chocolate = not E.chocolate
	paintChoco(E.chocolate)
end)
hitCandy.MouseButton1Click:Connect(function()
	E.candy = not E.candy
	paintCandy(E.candy)
end)
hitCoin.MouseButton1Click:Connect(function()
	E.coin = not E.coin
	paintCoin(E.coin)
end)
hitXp.MouseButton1Click:Connect(function()
	E.xp = not E.xp
	paintXp(E.xp)
end)
paintChoco(E.chocolate)
paintCandy(E.candy)
paintCoin(E.coin)
paintXp(E.xp)

local dailyBody = section(eventsPage, "Daily", 2)
local _, paintSK, hitSK = makeSwitch(dailyBody, "Auto Special Keys", 1)
hitSK.MouseButton1Click:Connect(function()
	E.autoSpecialKeys = not E.autoSpecialKeys
	paintSK(E.autoSpecialKeys)
end)
paintSK(E.autoSpecialKeys)

local modePick = makeButton(dailyBody, "  >  Modo eventos: " .. E.collectMode, 2)
local modeList = Instance.new("Frame")
modeList.Parent = dailyBody
modeList.BackgroundTransparency = 1
modeList.Size = UDim2.new(1, -4, 0, 0)
modeList.AutomaticSize = Enum.AutomaticSize.Y
modeList.Visible = false
modeList.LayoutOrder = 3
local modeLay = Instance.new("UIListLayout")
modeLay.Parent = modeList
modeLay.Padding = UDim.new(0, 4)

for i, modeName in ipairs({ "Tween", "Tp" }) do
	local opt = Instance.new("TextButton")
	opt.Parent = modeList
	opt.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
	opt.Size = UDim2.new(1, 0, 0, 26)
	opt.Font = Enum.Font.Gotham
	opt.Text = modeName
	opt.TextColor3 = Color3.fromRGB(240, 240, 245)
	opt.TextSize = 12
	opt.LayoutOrder = i
	corner(opt, 5)
	opt.MouseButton1Click:Connect(function()
		E.collectMode = modeName
		modePick.Text = "  >  Modo eventos: " .. modeName
		modeList.Visible = false
		notify("Modo eventos: " .. modeName)
	end)
end
modePick.MouseButton1Click:Connect(function()
	modeList.Visible = not modeList.Visible
	modePick.Text = (modeList.Visible and "  v  " or "  >  ") .. "Modo eventos: " .. E.collectMode
end)

setProgress(82, "Events", "Logica de coleccionables...")

local function objectPosition(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj.Position end
	local ok, pivot = pcall(function() return obj:GetPivot() end)
	if ok and pivot then return pivot.Position end
	local ok2, wp = pcall(function() return obj.WorldPivot end)
	if ok2 and wp then return wp.Position end
	if obj.PrimaryPart then return obj.PrimaryPart.Position end
	local part = obj:FindFirstChildWhichIsA("BasePart", true)
	if part then return part.Position end
	return nil
end

local function restoreKeycap(obj)
	local function fix(p)
		if p:IsA("BasePart") then
			p.Transparency = 0
			p.CanCollide = true
			p.CanTouch = true
			p.CanQuery = true
		end
	end
	if obj:IsA("BasePart") then fix(obj) end
	for _, d in ipairs(obj:GetDescendants()) do fix(d) end
end

local function findCandyPlane(eventCoinObj)
	if not eventCoinObj then return nil end
	local plaine = eventCoinObj:FindFirstChild("Plane", true)
	if not plaine then
		for _, d in ipairs(eventCoinObj:GetDescendants()) do
			if string.lower(d.Name) == "plane" then
				plaine = d
				break
			end
		end
	end
	return plaine
end

local function eventKind(name)
	local n = string.lower(name or "")
	if E.chocolate and (string.find(n, "chocolatehuntcollectible", 1, true)
		or (string.find(n, "chocolate", 1, true) and string.find(n, "collect", 1, true))) then
		return "chocolate"
	end
	if E.candy and string.find(n, "eventcoin", 1, true) then
		return "candy"
	end
	if E.coin and string.find(n, "coinbattlecoin", 1, true) then
		return "coin"
	end
	if E.xp and string.find(n, "electrifiedkeycap", 1, true) then
		return "xp"
	end
	return nil
end

local function rememberEvent(obj)
	if not obj or E.seen[obj] then return nil end
	local kind = eventKind(obj.Name)
	if not kind then return nil end
	local targetObj = obj
	local pos = nil
	if kind == "candy" then
		local plane = findCandyPlane(obj)
		if not plane then return nil end
		targetObj = plane
		pos = objectPosition(plane)
		if not pos then return nil end
		E.seen[obj] = true
		E.seen[plane] = true
	else
		pos = objectPosition(obj)
		if not pos then return nil end
		E.seen[obj] = true
	end
	if kind == "xp" then restoreKeycap(obj) end
	table.insert(E.queue, { obj = targetObj, pos = pos, kind = kind })
	return pos
end

local function goToPos(hrp, dest)
	if not hrp or not dest then return end
	if E.collectMode == "Tp" then
		hrp.CFrame = CFrame.new(dest + Vector3.new(0, 3, 0))
		hrp.AssemblyLinearVelocity = Vector3.zero
		return
	end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Parent = hrp
	local t0 = tick()
	while hrp and hrp.Parent and (hrp.Position - dest).Magnitude > 3 and tick() - t0 < 8 do
		local d = dest - hrp.Position
		if d.Magnitude > 0.05 then
			bv.Velocity = d.Unit * math.clamp(d.Magnitude * 8, 40, 250)
		else
			bv.Velocity = Vector3.zero
		end
		RunService.Heartbeat:Wait()
	end
	if bv then bv:Destroy() end
	hrp.CFrame = CFrame.new(dest + Vector3.new(0, 3, 0))
	hrp.AssemblyLinearVelocity = Vector3.zero
end

local function readExactWins()
	local ls = player:FindFirstChild("leaderstats")
	local w = ls and ls:FindFirstChild("Wins")
	return w and tonumber(w.Value) or 0
end

local function processSpecialKey(obj, hrp)
	if not obj or not hrp then return end
	local before = readExactWins()
	local itemPos = objectPosition(obj)
	if not itemPos then return end
	local original = hrp.CFrame
	goToPos(hrp, itemPos)
	local tStart = tick()
	while obj and obj.Parent and E.autoSpecialKeys and (tick() - tStart < 8) do
		pcall(function()
			local fwd = hrp.CFrame.LookVector
			hrp.CFrame = hrp.CFrame + (fwd * 3)
			task.wait(0.15)
			hrp.CFrame = hrp.CFrame - (fwd * 3)
			task.wait(0.15)
		end)
	end
	E.specialKeyCount = (E.specialKeyCount or 0) + 1
	E.specialKeyWins = (E.specialKeyWins or 0) + math.max(0, readExactWins() - before)
	if hrp then hrp.CFrame = original end
end
S.Events.processSpecialKey = processSpecialKey

setProgress(85, "Events", "Bucles de busqueda...")

if not S._eventsLoopsStarted then
	S._eventsLoopsStarted = true
	task.spawn(function()
		local anchored = false
		local lastWide, lastNear = 0, 0
		while true do
			task.wait(0.1)
			local anyOn = E.chocolate or E.candy or E.coin or E.xp
			if not anyOn then
				anchored = false
				E.queue = {}
				E.seen = {}
			else
				local now = tick()
				local char = player.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					if not anchored and now - lastWide >= 1 then
						lastWide = now
						for _, obj in ipairs(Workspace:GetDescendants()) do
							if rememberEvent(obj) then break end
						end
						if #E.queue > 0 then
							local first = table.remove(E.queue, 1)
							goToPos(hrp, first.pos)
							anchored = true
						end
					elseif anchored and now - lastNear >= 0.3 then
						lastNear = now
						for _, obj in ipairs(Workspace:GetDescendants()) do
							local pos = objectPosition(obj)
							if pos and (pos - hrp.Position).Magnitude <= 100 then
								rememberEvent(obj)
							end
						end
						if #E.queue > 0 then
							local nextItem = E.queue[1]
							local pos = objectPosition(nextItem.obj) or nextItem.pos
							if (hrp.Position - pos).Magnitude <= 4 then
								table.remove(E.queue, 1)
							else
								goToPos(hrp, pos)
								table.remove(E.queue, 1)
							end
						else
							anchored = false
						end
					end
				end
			end
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

local function loadNext(url)
	local ok, body = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok or type(body) ~= "string" or #body < 20 then
		warn("[Delta Hub] tab_events: no se pudo bajar", url)
		setProgress(87.5, "Error", "Falta tab_extras.lua")
		return
	end
	if body:sub(1, 9) == "<!DOCTYPE" or body:sub(1, 6) == "<html>" then
		warn("[Delta Hub] tab_events: HTML", url)
		setProgress(87.5, "Error", "Sube tab_extras.lua")
		return
	end
	local fn, err = loadstring(body)
	if not fn then
		warn("[Delta Hub] tab_events loadstring", err)
		return
	end
	local okRun, runErr = pcall(fn)
	if not okRun then
		warn("[Delta Hub] tab_extras run", runErr)
	end
end

setProgress(87.5, "Events", "Cargando Extras...")
loadNext(NEXT_URL)
