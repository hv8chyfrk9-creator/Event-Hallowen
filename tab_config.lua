-- ==========================================
-- DELTA HUB - Event Hallowen - tab_config.lua
-- Perfiles locales · Auto Load/Save · Import/Export
-- ==========================================

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then
	warn("[Delta Hub] tab_config: falta hub")
	return
end

if S._configTabBuilt then return end
S._configTabBuilt = true

S.Config = S.Config or {}
local C = S.Config
C.autoSave = C.autoSave ~= false -- default ON
C.autoLoad = C.autoLoad ~= false -- default ON
C.activeName = C.activeName or "Default"
C.startupName = C.startupName or "Default"
C.profiles = C.profiles or {}
C._suppressSave = false

local FILE = "DeltaHub_HW_Configs.json"
local PREFIX = "DHCFG1|"

local function setProgress(p, t, s)
	if S.setProgress then S.setProgress(p, t, s) end
end
local function notify(msg)
	if S.Farm and S.Farm.notify then S.Farm.notify(msg)
	elseif S.notify then S.notify(msg)
	else print("[Config]", msg) end
end
local function corner(o, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 6)
	c.Parent = o
	return c
end

local function jsonEncode(t)
	local ok, s = pcall(function() return HttpService:JSONEncode(t) end)
	if ok then return s end
	return nil
end
local function jsonDecode(s)
	local ok, t = pcall(function() return HttpService:JSONDecode(s) end)
	if ok then return t end
	return nil
end

local function readFile()
	if not isfile or not readfile then return nil end
	if not isfile(FILE) then return nil end
	local ok, body = pcall(readfile, FILE)
	if ok and type(body) == "string" and #body > 2 then return body end
	return nil
end
local function writeFile(body)
	if not writefile then return false end
	local ok = pcall(writefile, FILE, body)
	return ok and true or false
end

local function ensureDefault()
	if not C.profiles["Default"] then
		C.profiles["Default"] = {}
	end
end

local function listNames()
	ensureDefault()
	local names = {}
	for k in pairs(C.profiles) do table.insert(names, k) end
	table.sort(names)
	return names
end

-- Captura TODO el estado del hub
function C.capture()
	local F = S.Farm or {}
	local P = S.Player or {}
	local E = S.Events or {}
	local X = S.Extras or {}
	local brain = S.Brain or {}
	return {
		farm = {
			routeMode = F.routeMode or "normal",
			routeSpeed = F.routeSpeed or 250,
			infinite = F.infinite and true or false,
			selectedRealName = F.selectedRealName or "WinBlock1",
			selectedDisplayName = F.selectedDisplayName or "+1 Wins",
			autoRebirth = F.autoRebirth and true or false,
			autoTreadmill = F.autoTreadmill and true or false,
			routeWasRunning = (brain.routeRunning or F.routeRunning) and true or false,
		},
		player = {
			speedEnabled = P.speedEnabled and true or false,
			jumpEnabled = P.jumpEnabled and true or false,
			noclipEnabled = P.noclipEnabled and true or false,
			infJumpEnabled = P.infJumpEnabled and true or false,
			customSpeed = P.customSpeed or 16,
			customJump = P.customJump or 50,
		},
		events = {
			chocolate = E.chocolate and true or false,
			candy = E.candy and true or false,
			coin = E.coin and true or false,
			xp = E.xp and true or false,
			autoSpecialKeys = E.autoSpecialKeys and true or false,
			collectMode = E.collectMode or "Tween",
		},
		extras = {
			renderOn = X.renderOn and true or false,
			renderWhite = X.renderWhite ~= false,
			statsOn = X.statsOn and true or false,
			antiLagOn = X.antiLagOn and true or false,
			antiOpts = {
				decorations = not (X.antiOpts and X.antiOpts.decorations == false),
				halloween = not (X.antiOpts and X.antiOpts.halloween == false),
				keycaps = not (X.antiOpts and X.antiOpts.keycaps == false),
			},
		},
		meta = {
			savedAt = os.time and os.time() or 0,
			world = "hallowen",
		},
	}
end

function C.apply(data, opts)
	opts = opts or {}
	if type(data) ~= "table" then return false end
	C._suppressSave = true

	local F = S.Farm or {}
	local P = S.Player or {}
	local E = S.Events or {}
	local X = S.Extras or {}

	if data.farm then
		local f = data.farm
		F.routeMode = f.routeMode or F.routeMode
		F.routeSpeed = tonumber(f.routeSpeed) or F.routeSpeed
		F.infinite = f.infinite and true or false
		F.selectedRealName = f.selectedRealName or F.selectedRealName
		F.selectedDisplayName = f.selectedDisplayName or F.selectedDisplayName
		F.autoRebirth = f.autoRebirth and true or false
		F.autoTreadmill = f.autoTreadmill and true or false
	end
	if data.player then
		local p = data.player
		P.speedEnabled = p.speedEnabled and true or false
		P.jumpEnabled = p.jumpEnabled and true or false
		P.noclipEnabled = p.noclipEnabled and true or false
		P.infJumpEnabled = p.infJumpEnabled and true or false
		P.customSpeed = tonumber(p.customSpeed) or P.customSpeed
		P.customJump = tonumber(p.customJump) or P.customJump
	end
	if data.events then
		local e = data.events
		E.chocolate = e.chocolate and true or false
		E.candy = e.candy and true or false
		E.coin = e.coin and true or false
		E.xp = e.xp and true or false
		E.autoSpecialKeys = e.autoSpecialKeys and true or false
		E.collectMode = e.collectMode or E.collectMode
	end
	if data.extras then
		local x = data.extras
		X.renderOn = x.renderOn and true or false
		X.renderWhite = x.renderWhite ~= false
		X.statsOn = x.statsOn and true or false
		X.antiLagOn = x.antiLagOn and true or false
		if type(x.antiOpts) == "table" then
			X.antiOpts = X.antiOpts or {}
			for k, v in pairs(x.antiOpts) do X.antiOpts[k] = v and true or false end
		end
	end

	if type(C.onApplied) == "function" then
		pcall(C.onApplied, data)
	end

	C._suppressSave = false

	-- Si tenía recorrido corriendo + infinito → arrancar cuando todo listo
	if opts.startRoute and data.farm and data.farm.routeWasRunning and data.farm.infinite then
		task.spawn(function()
			local t0 = tick()
			while tick() - t0 < 12 do
				if S.scriptReady and S.Brain and S.Brain.startRoute and not S.Brain.routeRunning then
					S.Brain.startRoute()
					notify("Config: reiniciando recorrido infinito")
					break
				end
				task.wait(0.25)
			end
		end)
	end
	return true
end

function C.persistAll()
	ensureDefault()
	local payload = {
		activeName = C.activeName,
		startupName = C.startupName,
		autoSave = C.autoSave and true or false,
		autoLoad = C.autoLoad and true or false,
		profiles = C.profiles,
	}
	local s = jsonEncode(payload)
	if not s then return false end
	return writeFile(s)
end

function C.loadFromDisk()
	local body = readFile()
	if not body then
		ensureDefault()
		return false
	end
	local data = jsonDecode(body)
	if type(data) ~= "table" then ensureDefault() return false end
	C.profiles = type(data.profiles) == "table" and data.profiles or {}
	ensureDefault()
	C.activeName = data.activeName or "Default"
	C.startupName = data.startupName or C.activeName or "Default"
	if data.autoSave ~= nil then C.autoSave = data.autoSave and true or false end
	if data.autoLoad ~= nil then C.autoLoad = data.autoLoad and true or false end
	return true
end

function C.saveActive()
	if C._suppressSave then return end
	ensureDefault()
	C.profiles[C.activeName or "Default"] = C.capture()
	C.persistAll()
end

function C.markDirty()
	if C._suppressSave or not C.autoSave then return end
	C._dirty = true
end

-- Auto-save loop (cada cambio marcado + debounce)
task.spawn(function()
	while true do
		task.wait(0.6)
		if C._dirty and C.autoSave and not C._suppressSave then
			C._dirty = false
			C.saveActive()
		end
	end
end)

-- Snapshot periódico si autoSave (por si algún toggle no llama markDirty)
task.spawn(function()
	local last = ""
	while true do
		task.wait(2.5)
		if C.autoSave and not C._suppressSave and S.scriptReady then
			local cap = C.capture()
			local s = jsonEncode(cap) or ""
			if s ~= last then
				last = s
				C.profiles[C.activeName or "Default"] = cap
				C.persistAll()
			end
		end
	end
end)

S.Config.markDirty = C.markDirty
S.Config.saveActive = C.saveActive

setProgress(97, "Config", "Pestaña Configuración...")

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
	head.Size = UDim2.new(1, 0, 0, 18)
	head.Font = Enum.Font.GothamBold
	head.Text = title
	head.TextColor3 = Color3.fromRGB(255, 255, 255)
	head.TextSize = 13
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.LayoutOrder = 0
	return wrap
end

local function makeBtn(parent, text, order)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1, -4, 0, 30)
	b.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 240, 245)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.LayoutOrder = order or 1
	corner(b, 6)
	return b
end

local function makeSwitch(parent, text, order, get, set)
	local row = Instance.new("Frame")
	row.Parent = parent
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	row.Size = UDim2.new(1, -4, 0, 34)
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
	paint(get())
	hit.MouseButton1Click:Connect(function()
		set(not get())
		paint(get())
		C.markDirty()
	end)
	return paint
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

local page = createScrollingPage(S.UI.ContentArea)
S.UI.Pages = S.UI.Pages or {}
S.UI.Pages.Config = page

local tabBtn = Instance.new("TextButton")
tabBtn.Parent = S.UI.Sidebar
tabBtn.Size = UDim2.new(0, 92, 0, 42)
tabBtn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
tabBtn.Font = Enum.Font.GothamBold
tabBtn.Text = "Config"
tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tabBtn.TextSize = 13
tabBtn.LayoutOrder = 5
corner(tabBtn, 6)
tabBtn.MouseButton1Click:Connect(function()
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	page.Visible = true
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Configuración" end
end)

-- UI state refs
local activeLabel, startupLabel, profileListFrame
local function refreshLabels()
	if activeLabel then activeLabel.Text = "Activo: " .. (C.activeName or "Default") end
	if startupLabel then startupLabel.Text = "Startup: " .. (C.startupName or "Default") end
end

local function rebuildProfileList()
	if not profileListFrame then return end
	for _, ch in ipairs(profileListFrame:GetChildren()) do
		if ch:IsA("TextButton") then ch:Destroy() end
	end
	for i, name in ipairs(listNames()) do
		local b = makeBtn(profileListFrame, name, i)
		if name == C.activeName then b.BackgroundColor3 = Color3.fromRGB(40, 90, 50) end
		b.MouseButton1Click:Connect(function()
			C.activeName = name
			local data = C.profiles[name]
			if data then C.apply(data, { startRoute = false }) end
			C.persistAll()
			refreshLabels()
			rebuildProfileList()
			notify("Cargado: " .. name)
		end)
	end
end

C.loadFromDisk()

local genBody = section(page, "General", 1)
makeSwitch(genBody, "Auto Save", 1, function() return C.autoSave end, function(v)
	C.autoSave = v
	C.persistAll()
end)
makeSwitch(genBody, "Auto Load", 2, function() return C.autoLoad end, function(v)
	C.autoLoad = v
	C.persistAll()
end)
activeLabel = Instance.new("TextLabel")
activeLabel.Parent = genBody
activeLabel.BackgroundTransparency = 1
activeLabel.Size = UDim2.new(1, -4, 0, 18)
activeLabel.Font = Enum.Font.Gotham
activeLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
activeLabel.TextSize = 12
activeLabel.TextXAlignment = Enum.TextXAlignment.Left
activeLabel.LayoutOrder = 3
startupLabel = Instance.new("TextLabel")
startupLabel.Parent = genBody
startupLabel.BackgroundTransparency = 1
startupLabel.Size = UDim2.new(1, -4, 0, 18)
startupLabel.Font = Enum.Font.Gotham
startupLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
startupLabel.TextSize = 12
startupLabel.TextXAlignment = Enum.TextXAlignment.Left
startupLabel.LayoutOrder = 4
refreshLabels()

local profBody = section(page, "Perfiles", 2)
local nameBox = Instance.new("TextBox")
nameBox.Parent = profBody
nameBox.Size = UDim2.new(1, -4, 0, 28)
nameBox.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
nameBox.PlaceholderText = "Nombre del perfil nuevo"
nameBox.Text = ""
nameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
nameBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 12
nameBox.LayoutOrder = 1
corner(nameBox, 6)

makeBtn(profBody, "Crear perfil (copia actual)", 2).MouseButton1Click:Connect(function()
	local name = string.gsub(nameBox.Text or "", "^%s*(.-)%s*$", "%1")
	if name == "" then notify("Pon un nombre") return end
	C.profiles[name] = C.capture()
	C.activeName = name
	C.startupName = name -- el nuevo pasa a auto-load actual
	C.persistAll()
	nameBox.Text = ""
	refreshLabels()
	rebuildProfileList()
	notify("Perfil creado: " .. name)
end)

makeBtn(profBody, "Guardar en perfil activo", 3).MouseButton1Click:Connect(function()
	C.saveActive()
	notify("Guardado: " .. (C.activeName or "Default"))
end)

makeBtn(profBody, "Poner activo como Startup", 4).MouseButton1Click:Connect(function()
	C.startupName = C.activeName or "Default"
	C.persistAll()
	refreshLabels()
	notify("Startup = " .. C.startupName)
end)

makeBtn(profBody, "Borrar perfil activo", 5).MouseButton1Click:Connect(function()
	local name = C.activeName or "Default"
	if name == "Default" then notify("No se puede borrar Default") return end
	C.profiles[name] = nil
	C.activeName = "Default"
	if C.startupName == name then C.startupName = "Default" end
	C.persistAll()
	local data = C.profiles["Default"]
	if data then C.apply(data) end
	refreshLabels()
	rebuildProfileList()
	notify("Borrado: " .. name)
end)

profileListFrame = Instance.new("Frame")
profileListFrame.Parent = profBody
profileListFrame.BackgroundTransparency = 1
profileListFrame.Size = UDim2.new(1, -4, 0, 0)
profileListFrame.AutomaticSize = Enum.AutomaticSize.Y
profileListFrame.LayoutOrder = 10
local pl = Instance.new("UIListLayout")
pl.Parent = profileListFrame
pl.Padding = UDim.new(0, 4)
rebuildProfileList()

local ieBody = section(page, "Import / Export", 3)
makeBtn(ieBody, "Exportar (clipboard)", 1).MouseButton1Click:Connect(function()
	local data = C.capture()
	local s = jsonEncode(data)
	if not s then notify("Error al exportar") return end
	local payload = PREFIX .. s
	local ok = false
	if setclipboard then ok = pcall(setclipboard, payload) end
	if not ok and toclipboard then ok = pcall(toclipboard, payload) end
	if ok then notify("Copiado al portapapeles") else notify("Sin setclipboard") end
end)

local importBox = Instance.new("TextBox")
importBox.Parent = ieBody
importBox.Size = UDim2.new(1, -4, 0, 56)
importBox.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
importBox.PlaceholderText = "Pega aquí el export y pulsa Importar"
importBox.Text = ""
importBox.TextColor3 = Color3.fromRGB(255, 255, 255)
importBox.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
importBox.Font = Enum.Font.Code
importBox.TextSize = 11
importBox.TextWrapped = true
importBox.MultiLine = true
importBox.ClearTextOnFocus = false
importBox.LayoutOrder = 2
corner(importBox, 6)

makeBtn(ieBody, "Importar (pegar arriba)", 3).MouseButton1Click:Connect(function()
	local raw = importBox.Text or ""
	raw = string.gsub(raw, "^%s+", "")
	if string.sub(raw, 1, #PREFIX) == PREFIX then
		raw = string.sub(raw, #PREFIX + 1)
	end
	local data = jsonDecode(raw)
	if type(data) ~= "table" then notify("Import inválido") return end
	C.apply(data, { startRoute = false })
	C.profiles[C.activeName or "Default"] = C.capture()
	C.persistAll()
	importBox.Text = ""
	notify("Importado OK")
end)

-- Auto Load al final de carga completa
task.spawn(function()
	local t0 = tick()
	while not S.scriptReady and tick() - t0 < 30 do task.wait(0.2) end
	task.wait(0.35)
	if C.autoLoad then
		local name = C.startupName or "Default"
		local data = C.profiles[name]
		if type(data) == "table" and next(data) then
			C.activeName = name
			C.apply(data, { startRoute = true })
			refreshLabels()
			rebuildProfileList()
			notify("Auto Load: " .. name)
		end
	end
end)

setProgress(99, "Config", "Finalizando...")
task.spawn(function()
	if S.fadeAndDestroyLoading then S.fadeAndDestroyLoading() end
	if S.UI.MainFrame then S.UI.MainFrame.Visible = true end
	if S.UI.Sidebar then S.UI.Sidebar.Visible = true end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text = "Farm" end
	S.scriptReady = true
	notify("Hallowen world listo")
	setProgress(100, "Listo", "Delta Hub activo")
end)

print("[Delta Hub] tab_config listo")
