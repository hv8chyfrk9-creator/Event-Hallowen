-- DELTA HUB tab_events (self-contained)
local Players = game:GetService("Players")
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
E.searchInterval = 1
E.busy = false
E.priority = E.priority or { "chocolate", "battlecoin", "xp", "candy", "specialkeys" }

local BASE = S.BASE_URL or "https://raw.githubusercontent.com/hv8chyfrk9-creator/Event-Hallowen/main/"
local NEXT_URL = BASE .. "tab_extras.lua"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
local function notify(t)
	if S.notify then S.notify(t) else warn("[Delta Hub]", t) end
end
local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = p
	return c
end

setProgress(76, "Events", "Creando Events...")

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
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, -8, 0, 30)
	row.LayoutOrder = order or 1
	local lab = Instance.new("TextLabel")
	lab.Parent = row
	lab.BackgroundTransparency = 1
	lab.Size = UDim2.new(1, -54, 1, 0)
	lab.Font = Enum.Font.Gotham
	lab.Text = text
	lab.TextColor3 = Color3.fromRGB(240, 240, 245)
	lab.TextSize = 12
	lab.TextXAlignment = Enum.TextXAlignment.Left
	local hit = Instance.new("TextButton")
	hit.Parent = row
	hit.Size = UDim2.new(0, 48, 0, 24)
	hit.Position = UDim2.new(1, -48, 0.5, -12)
	hit.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	hit.Text = "OFF"
	hit.TextColor3 = Color3.fromRGB(255, 120, 120)
	hit.Font = Enum.Font.GothamBold
	hit.TextSize = 11
	corner(hit, 6)
	local function paint(on)
		hit.Text = on and "ON" or "OFF"
		hit.TextColor3 = on and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 120, 120)
		hit.BackgroundColor3 = on and Color3.fromRGB(40, 90, 50) or Color3.fromRGB(60, 60, 70)
	end
	return row, paint, hit
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
tabEvents.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	eventsPage.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Events" end
end)

setProgress(78, "Events", "Toggles...")
local adminBody = section(eventsPage, "Admin abuse", 1)
local _, pChoco, hChoco = makeSwitch(adminBody, "Auto Chocolate Hunt", 1)
local _, pCoin, hCoin = makeSwitch(adminBody, "Auto Battle Coin", 2)
local _, pXp, hXp = makeSwitch(adminBody, "Auto XP Event Key", 3)
hChoco.MouseButton1Click:Connect(function() E.chocolate = not E.chocolate; pChoco(E.chocolate) end)
hCoin.MouseButton1Click:Connect(function() E.coin = not E.coin; pCoin(E.coin) end)
hXp.MouseButton1Click:Connect(function() E.xp = not E.xp; pXp(E.xp) end)
pChoco(E.chocolate); pCoin(E.coin); pXp(E.xp)

local limitedBody = section(eventsPage, "Limited Time", 2)
local _, pCandy, hCandy = makeSwitch(limitedBody, "Auto Candy Corn", 1)
hCandy.MouseButton1Click:Connect(function() E.candy = not E.candy; pCandy(E.candy) end)
pCandy(E.candy)

local dailyBody = section(eventsPage, "Daily", 3)
local _, pSK, hSK = makeSwitch(dailyBody, "Auto Special Keys", 1)
hSK.MouseButton1Click:Connect(function() E.autoSpecialKeys = not E.autoSpecialKeys; pSK(E.autoSpecialKeys) end)
pSK(E.autoSpecialKeys)

local modeBtn = Instance.new("TextButton")
modeBtn.Parent = dailyBody
modeBtn.Size = UDim2.new(1, -8, 0, 28)
modeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
modeBtn.Text = "Modo: " .. E.collectMode
modeBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 12
modeBtn.LayoutOrder = 2
corner(modeBtn, 6)
modeBtn.MouseButton1Click:Connect(function()
	E.collectMode = (E.collectMode == "Tween") and "Tp" or "Tween"
	modeBtn.Text = "Modo: " .. E.collectMode
end)

-- Helpers
local function objectPosition(obj)
	if not obj then return nil end
	if obj:IsA("BasePart") then return obj.Position end
	local ok, piv = pcall(function() return obj:GetPivot() end)
	if ok and piv then return piv.Position end
	local p = obj:FindFirstChildWhichIsA("BasePart", true)
	return p and p.Position
end

local function eventKind(name)
	if not name then return nil end
	local n = name:lower()
	if n:find("chocolate") and n:find("hunt") then return "chocolate" end
	if n:find("chocolatehunt") then return "chocolate" end
	if n:find("eventcoin") then return "candy" end
	if n:find("coinbattlecoin") or n:find("battlecoin") then return "coin" end
	if n:find("electrifiedkeycap") then return "xp" end
	return nil
end

local function findCandyPlane(obj)
	if not obj then return nil end
	local plane = obj:FindFirstChild("Plane", true)
	if plane then return plane end
	return obj
end

local function rememberEvent(obj)
	local kind = eventKind(obj.Name)
	if not kind then return false end
	if kind == "chocolate" and not E.chocolate then return false end
	if kind == "candy" and not E.candy then return false end
	if kind == "coin" and not E.coin then return false end
	if kind == "xp" and not E.xp then return false end
	local target, pos = obj, objectPosition(obj)
	if kind == "candy" then
		local plane = findCandyPlane(obj)
		if not plane then return false end
		target, pos = plane, objectPosition(plane)
	end
	if not pos then return false end
	local id = tostring(target:GetFullName())
	if E.seen[id] then return false end
	E.seen[id] = true
	table.insert(E.queue, { obj = target, pos = pos, kind = kind })
	return true
end

local function goToPos(hrp, dest)
	if not hrp or not dest then return end
	if typeof(dest) == "Vector3" then
		if E.collectMode == "Tp" then
			hrp.CFrame = CFrame.new(dest + Vector3.new(0, 3, 0))
		else
			local bv = hrp:FindFirstChildOfClass("BodyVelocity")
			if not bv then
				bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
				bv.Parent = hrp
			end
			local t0 = tick()
			while hrp.Parent and (hrp.Position - dest).Magnitude > 3 and tick() - t0 < 12 do
				bv.Velocity = (dest - hrp.Position).Unit * 80
				task.wait()
			end
			bv.Velocity = Vector3.zero
		end
	end
end

local function processSpecialKey(obj, hrp)
	local pos = objectPosition(obj)
	if not pos then return end
	goToPos(hrp, pos)
	E.specialKeyCount = (E.specialKeyCount or 0) + 1
end
S.Events.processSpecialKey = processSpecialKey

setProgress(85, "Events", "Bucles...")

if not S._eventsLoopsStarted then
	S._eventsLoopsStarted = true
	local function anyOn()
		return E.chocolate or E.candy or E.coin or E.xp
	end
	task.spawn(function()
		while true do
			task.wait(E.searchInterval or 1)
			if not anyOn() then E.searchInterval = 1; E.queue = {}; E.seen = {}; E.busy = false; continue end
			local farm = S.Farm
			if farm and farm.routeRunning then continue end
			if E.busy then continue end
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end
			E.seen = {}; E.queue = {}
			for _, obj in ipairs(Workspace:GetDescendants()) do rememberEvent(obj) end
			if #E.queue == 0 then E.searchInterval = 1; continue end
			local order = {}
			for i, n in ipairs(E.priority) do order[n] = i end
			local function kk(k) return k == "coin" and "battlecoin" or k end
			table.sort(E.queue, function(a, b) return (order[kk(a.kind)] or 99) < (order[kk(b.kind)] or 99) end)
			E.busy = true
			E.searchInterval = 0.3
			E.returnPos = hrp.Position
			while #E.queue > 0 and anyOn() and not (farm and farm.routeRunning) do
				local item = table.remove(E.queue, 1)
				if not item or not item.pos then continue end
				if item.obj and not item.obj.Parent then continue end
				local pos = objectPosition(item.obj) or item.pos
				goToPos(hrp, pos)
				task.wait(0.35)
				for _, obj in ipairs(Workspace:GetDescendants()) do
					local p = objectPosition(obj)
					if p and (p - pos).Magnitude <= 50 then rememberEvent(obj) end
				end
				local tW = tick()
				while tick() - tW < 1 and anyOn() do
					task.wait(0.3)
					for _, obj in ipairs(Workspace:GetDescendants()) do rememberEvent(obj) end
				end
				hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if not hrp then break end
			end
			if hrp and E.returnPos then
				if E.collectMode == "Tp" then
					hrp.CFrame = CFrame.new(E.returnPos + Vector3.new(0, 3, 0))
				else
					goToPos(hrp, E.returnPos)
				end
			end
			E.busy = false
			E.searchInterval = 1
		end
	end)
	task.spawn(function()
		while true do
			task.wait(2)
			if E.autoSpecialKeys and not (S.Farm and S.Farm.routeRunning) then
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					for _, obj in pairs(Workspace:GetDescendants()) do
						if obj.Name:find("SpecialKey") and (obj:IsA("BasePart") or obj:IsA("Model")) then
							processSpecialKey(obj, hrp)
							break
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
