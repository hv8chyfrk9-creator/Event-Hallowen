-- tab_config_ui.lua v2
-- Boton derecha · selectores · apartados · nombres unicos
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local S = getgenv().DeltaHub
if type(S) ~= "table" or not S.UI or not S.UI.ContentArea then return end
if S._configTabBuilt then return end
S._configTabBuilt = true

S.Config = S.Config or {}
local C = S.Config
C.autoSave = C.autoSave ~= false
C.autoLoad = C.autoLoad ~= false
C.activeName = C.activeName or "Default"
C.startupName = C.startupName or "Default"
C.profiles = C.profiles or {}
C._suppressSave = false
C.selStartup = C.startupName
C.selLoad = C.activeName
C.selSave = C.activeName
C.selDelete = C.activeName

local FILE = "DeltaHub_HW_Configs.json"
local PREFIX = "DHCFG1|"

local function setProgress(p,t,s) if S.setProgress then S.setProgress(p,t,s) end end
local function notify(msg)
	if S.Farm and S.Farm.notify then S.Farm.notify(msg)
	elseif S.notify then S.notify(msg) else print("[Config]", msg) end
end
local function corner(o,r)
	local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 6) c.Parent=o return c
end
local function jenc(t) local ok,s=pcall(function() return HttpService:JSONEncode(t) end) return ok and s end
local function jdec(s) local ok,t=pcall(function() return HttpService:JSONDecode(s) end) return ok and t end
local function readFile()
	if not (isfile and readfile and isfile(FILE)) then return end
	local ok,b=pcall(readfile,FILE)
	return (ok and type(b)=="string" and #b>2) and b or nil
end
local function writeFile(b)
	if not writefile then return false end
	return pcall(writefile,FILE,b) and true or false
end
local function ensureDefault()
	if not C.profiles["Default"] then C.profiles["Default"]={} end
end
local function listNames()
	ensureDefault()
	local n={}
	for k in pairs(C.profiles) do table.insert(n,k) end
	table.sort(n) return n
end
local function uniqueName(base)
	base=string.gsub(base or "","^%s*(.-)%s*$","%1")
	if base=="" then base="Config" end
	if not C.profiles[base] then return base end
	local i=2 while C.profiles[base..i] do i=i+1 end
	return base..i
end

function C.capture()
	local F,P,E,X=S.Farm or {},S.Player or {},S.Events or {},S.Extras or {}
	local brain=S.Brain or {}
	return {
		farm={routeMode=F.routeMode or "normal",routeSpeed=F.routeSpeed or 250,infinite=F.infinite and true or false,
			selectedRealName=F.selectedRealName or "WinBlock1",selectedDisplayName=F.selectedDisplayName or "+1 Wins",
			autoRebirth=F.autoRebirth and true or false,autoTreadmill=F.autoTreadmill and true or false,
			routeWasRunning=(brain.routeRunning or F.routeRunning) and true or false},
		player={speedEnabled=P.speedEnabled and true or false,jumpEnabled=P.jumpEnabled and true or false,
			noclipEnabled=P.noclipEnabled and true or false,infJumpEnabled=P.infJumpEnabled and true or false,
			customSpeed=P.customSpeed or 16,customJump=P.customJump or 50},
		events={chocolate=E.chocolate and true or false,candy=E.candy and true or false,coin=E.coin and true or false,
			xp=E.xp and true or false,autoSpecialKeys=E.autoSpecialKeys and true or false,collectMode=E.collectMode or "Tween"},
		extras={renderOn=X.renderOn and true or false,renderWhite=X.renderWhite~=false,statsOn=X.statsOn and true or false,
			antiLagOn=X.antiLagOn and true or false,antiOpts=type(X.antiOpts)=="table" and X.antiOpts or {}},
		meta={savedAt=os.time and os.time() or 0,world="hallowen"},
	}
end

function C.apply(data,opts)
	opts=opts or {}
	if type(data)~="table" then return false end
	C._suppressSave=true
	local F,P,E,X=S.Farm or {},S.Player or {},S.Events or {},S.Extras or {}
	if data.farm then local f=data.farm
		F.routeMode=f.routeMode or F.routeMode F.routeSpeed=tonumber(f.routeSpeed) or F.routeSpeed
		F.infinite=f.infinite and true or false
		F.selectedRealName=f.selectedRealName or F.selectedRealName
		F.selectedDisplayName=f.selectedDisplayName or F.selectedDisplayName
		F.autoRebirth=f.autoRebirth and true or false F.autoTreadmill=f.autoTreadmill and true or false
	end
	if data.player then local p=data.player
		P.speedEnabled=p.speedEnabled and true or false P.jumpEnabled=p.jumpEnabled and true or false
		P.noclipEnabled=p.noclipEnabled and true or false P.infJumpEnabled=p.infJumpEnabled and true or false
		P.customSpeed=tonumber(p.customSpeed) or P.customSpeed P.customJump=tonumber(p.customJump) or P.customJump
	end
	if data.events then local e=data.events
		E.chocolate=e.chocolate and true or false E.candy=e.candy and true or false
		E.coin=e.coin and true or false E.xp=e.xp and true or false
		E.autoSpecialKeys=e.autoSpecialKeys and true or false E.collectMode=e.collectMode or E.collectMode
	end
	if data.extras then local x=data.extras
		X.renderOn=x.renderOn and true or false X.renderWhite=x.renderWhite~=false
		X.statsOn=x.statsOn and true or false X.antiLagOn=x.antiLagOn and true or false
		if type(x.antiOpts)=="table" then X.antiOpts=X.antiOpts or {} for k,v in pairs(x.antiOpts) do X.antiOpts[k]=v and true or false end end
	end
	C._suppressSave=false
	if opts.startRoute and data.farm and data.farm.routeWasRunning and data.farm.infinite then
		task.spawn(function()
			local t0=tick()
			while tick()-t0<12 do
				if S.scriptReady and S.Brain and S.Brain.startRoute and not S.Brain.routeRunning then
					S.Brain.startRoute() notify("Config: reiniciando recorrido infinito") break
				end
				task.wait(0.25)
			end
		end)
	end
	return true
end

function C.persistAll()
	ensureDefault()
	local s=jenc({activeName=C.activeName,startupName=C.startupName,autoSave=C.autoSave and true or false,autoLoad=C.autoLoad and true or false,profiles=C.profiles})
	return s and writeFile(s) or false
end
function C.loadFromDisk()
	local body=readFile()
	if not body then ensureDefault() return false end
	local data=jdec(body)
	if type(data)~="table" then ensureDefault() return false end
	C.profiles=type(data.profiles)=="table" and data.profiles or {}
	ensureDefault()
	C.activeName=data.activeName or "Default"
	C.startupName=data.startupName or C.activeName or "Default"
	if data.autoSave~=nil then C.autoSave=data.autoSave and true or false end
	if data.autoLoad~=nil then C.autoLoad=data.autoLoad and true or false end
	C.selStartup,C.selLoad,C.selSave,C.selDelete=C.startupName,C.activeName,C.activeName,C.activeName
	return true
end
function C.saveActive()
	if C._suppressSave then return end
	ensureDefault() C.profiles[C.activeName or "Default"]=C.capture() C.persistAll()
end
function C.markDirty()
	if C._suppressSave or not C.autoSave then return end
	C._dirty=true
end
task.spawn(function() while true do task.wait(0.6) if C._dirty and C.autoSave and not C._suppressSave then C._dirty=false C.saveActive() end end end)
task.spawn(function()
	local last=""
	while true do task.wait(2.5)
		if C.autoSave and not C._suppressSave and S.scriptReady then
			local cap=C.capture() local s=jenc(cap) or ""
			if s~=last then last=s C.profiles[C.activeName or "Default"]=cap C.persistAll() end
		end
	end
end)
S.Config.markDirty=C.markDirty S.Config.saveActive=C.saveActive
C.loadFromDisk()

local function section(parent,title,order)
	local wrap=Instance.new("Frame") wrap.Parent=parent wrap.BackgroundColor3=Color3.fromRGB(22,22,28)
	wrap.BackgroundTransparency=0.25 wrap.Size=UDim2.new(1,-8,0,0) wrap.AutomaticSize=Enum.AutomaticSize.Y
	wrap.LayoutOrder=order or 1 corner(wrap,8)
	local lay=Instance.new("UIListLayout") lay.Parent=wrap lay.SortOrder=Enum.SortOrder.LayoutOrder lay.Padding=UDim.new(0,8)
	local pad=Instance.new("UIPadding") pad.Parent=wrap pad.PaddingTop=UDim.new(0,10) pad.PaddingBottom=UDim.new(0,10)
	pad.PaddingLeft=UDim.new(0,8) pad.PaddingRight=UDim.new(0,8)
	local head=Instance.new("TextLabel") head.Parent=wrap head.BackgroundTransparency=1 head.Size=UDim2.new(1,0,0,18)
	head.Font=Enum.Font.GothamBold head.Text=title head.TextColor3=Color3.fromRGB(255,255,255) head.TextSize=13
	head.TextXAlignment=Enum.TextXAlignment.Left head.LayoutOrder=0
	return wrap
end
local function makeBtn(parent,text,order,color)
	local b=Instance.new("TextButton") b.Parent=parent b.Size=UDim2.new(1,-4,0,32)
	b.BackgroundColor3=color or Color3.fromRGB(36,36,44) b.Text=text b.TextColor3=Color3.fromRGB(240,240,245)
	b.Font=Enum.Font.Gotham b.TextSize=12 b.LayoutOrder=order or 1 corner(b,6) return b
end
local function makeSwitch(parent,text,order,get,set)
	local row=Instance.new("Frame") row.Parent=parent row.BackgroundColor3=Color3.fromRGB(32,32,36)
	row.Size=UDim2.new(1,-4,0,36) row.LayoutOrder=order or 1 corner(row,6)
	local label=Instance.new("TextLabel") label.Parent=row label.BackgroundTransparency=1
	label.Size=UDim2.new(1,-58,1,0) label.Position=UDim2.new(0,8,0,0) label.Font=Enum.Font.GothamBold
	label.Text=text label.TextColor3=Color3.fromRGB(240,240,245) label.TextSize=12 label.TextXAlignment=Enum.TextXAlignment.Left
	local hit=Instance.new("TextButton") hit.Parent=row hit.BackgroundColor3=Color3.fromRGB(70,70,78)
	hit.Position=UDim2.new(1,-46,0.5,-11) hit.Size=UDim2.new(0,36,0,22) hit.Text="" corner(hit,99)
	local knob=Instance.new("Frame") knob.Parent=hit knob.BackgroundColor3=Color3.fromRGB(230,230,235)
	knob.Position=UDim2.new(0,2,0,2) knob.Size=UDim2.new(0,18,0,18) corner(knob,99)
	local function paint(on)
		hit.BackgroundColor3=on and Color3.fromRGB(70,190,90) or Color3.fromRGB(70,70,78)
		knob.Position=on and UDim2.new(1,-20,0,2) or UDim2.new(0,2,0,2)
	end
	paint(get())
	hit.MouseButton1Click:Connect(function() set(not get()) paint(get()) C.markDirty() end)
end
local function makeSelector(parent,labelText,order,getName,setName)
	local wrap=Instance.new("Frame") wrap.Parent=parent wrap.BackgroundTransparency=1
	wrap.Size=UDim2.new(1,-4,0,0) wrap.AutomaticSize=Enum.AutomaticSize.Y wrap.LayoutOrder=order or 1
	local lay=Instance.new("UIListLayout") lay.Parent=wrap lay.Padding=UDim.new(0,4)
	local lab=Instance.new("TextLabel") lab.Parent=wrap lab.BackgroundTransparency=1 lab.Size=UDim2.new(1,0,0,16)
	lab.Font=Enum.Font.Gotham lab.Text=labelText lab.TextColor3=Color3.fromRGB(170,170,180) lab.TextSize=11
	lab.TextXAlignment=Enum.TextXAlignment.Left lab.LayoutOrder=0
	local head=Instance.new("TextButton") head.Parent=wrap head.Size=UDim2.new(1,0,0,30)
	head.BackgroundColor3=Color3.fromRGB(36,36,44) head.Font=Enum.Font.Gotham head.TextSize=12
	head.TextColor3=Color3.fromRGB(240,240,245) head.TextXAlignment=Enum.TextXAlignment.Left head.LayoutOrder=1 corner(head,6)
	local list=Instance.new("Frame") list.Parent=wrap list.BackgroundTransparency=1 list.Size=UDim2.new(1,0,0,0)
	list.AutomaticSize=Enum.AutomaticSize.Y list.Visible=false list.LayoutOrder=2
	Instance.new("UIListLayout",list).Padding=UDim.new(0,3)
	local open=false
	local function refreshHead() head.Text="  "..(open and "v  " or ">  ")..(getName() or "?") list.Visible=open end
	local function rebuild()
		for _,ch in ipairs(list:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
		for i,name in ipairs(listNames()) do
			local b=Instance.new("TextButton") b.Parent=list b.Size=UDim2.new(1,0,0,28)
			b.BackgroundColor3=name==getName() and Color3.fromRGB(40,90,50) or Color3.fromRGB(30,30,36)
			b.Text="  "..name b.TextColor3=Color3.fromRGB(240,240,245) b.Font=Enum.Font.Gotham b.TextSize=12
			b.TextXAlignment=Enum.TextXAlignment.Left b.LayoutOrder=i corner(b,5)
			b.MouseButton1Click:Connect(function() setName(name) open=false refreshHead() rebuild() end)
		end
		refreshHead()
	end
	head.MouseButton1Click:Connect(function() open=not open refreshHead() end)
	rebuild()
	return {rebuild=rebuild}
end

local page=Instance.new("ScrollingFrame")
page.Parent=S.UI.ContentArea page.BackgroundTransparency=1 page.Size=UDim2.new(1,0,1,0)
page.CanvasSize=UDim2.new(0,0,0,0) page.AutomaticCanvasSize=Enum.AutomaticSize.Y page.ScrollBarThickness=4 page.Visible=false
local play=Instance.new("UIListLayout") play.Parent=page play.SortOrder=Enum.SortOrder.LayoutOrder play.Padding=UDim.new(0,14)
local ppad=Instance.new("UIPadding") ppad.Parent=page ppad.PaddingTop=UDim.new(0,4) ppad.PaddingBottom=UDim.new(0,12)
S.UI.Pages=S.UI.Pages or {} S.UI.Pages.Config=page

local sg=S.UI.ScreenGui
local rightSide=Instance.new("Frame")
rightSide.Name="SidebarRight" rightSide.Parent=sg rightSide.BackgroundTransparency=1
rightSide.Size=UDim2.new(0,92,0,60) rightSide.Position=UDim2.new(0.5,210,0.5,-100)
S.UI.SidebarRight=rightSide
local tabBtn=Instance.new("TextButton") tabBtn.Parent=rightSide tabBtn.Size=UDim2.new(0,92,0,42)
tabBtn.BackgroundColor3=Color3.fromRGB(170,35,35) tabBtn.Font=Enum.Font.GothamBold tabBtn.Text="Config"
tabBtn.TextColor3=Color3.fromRGB(255,255,255) tabBtn.TextSize=13 corner(tabBtn,6)
tabBtn.MouseButton1Click:Connect(function()
	for _,p in pairs(S.UI.Pages) do if typeof(p)=="Instance" then p.Visible=false end end
	page.Visible=true if S.UI.SectionTitle then S.UI.SectionTitle.Text="Configuración" end
end)
task.spawn(function() while true do task.wait(0.4) if S.UI.MainFrame then rightSide.Visible=S.UI.MainFrame.Visible end end end)

local selectors={}
local gen=section(page,"General",1)
makeSwitch(gen,"Auto Save",1,function() return C.autoSave end,function(v) C.autoSave=v C.persistAll() end)
makeSwitch(gen,"Auto Load",2,function() return C.autoLoad end,function(v) C.autoLoad=v C.persistAll() end)

local startSec=section(page,"Al iniciar el script",2)
selectors.startup=makeSelector(startSec,"Con qué configuración empezamos",1,function() return C.selStartup end,function(n) C.selStartup=n end)
makeBtn(startSec,"Aplicar como inicio",2,Color3.fromRGB(40,70,110)).MouseButton1Click:Connect(function()
	C.startupName=C.selStartup or "Default" C.persistAll() notify("Inicio = "..C.startupName)
end)

local createSec=section(page,"Crear configuración",3)
local nameBox=Instance.new("TextBox") nameBox.Parent=createSec nameBox.Size=UDim2.new(1,-4,0,30)
nameBox.BackgroundColor3=Color3.fromRGB(28,28,34) nameBox.PlaceholderText="Nombre (si existe: 2,3...)" nameBox.Text=""
nameBox.TextColor3=Color3.fromRGB(255,255,255) nameBox.PlaceholderColor3=Color3.fromRGB(110,110,125)
nameBox.Font=Enum.Font.Gotham nameBox.TextSize=12 nameBox.LayoutOrder=1 corner(nameBox,6)
makeBtn(createSec,"Crear (copia estado actual)",2,Color3.fromRGB(40,90,50)).MouseButton1Click:Connect(function()
	local name=uniqueName(nameBox.Text)
	C.profiles[name]=C.capture() C.activeName=name
	C.selLoad,C.selSave,C.selDelete=name,name,name C.persistAll() nameBox.Text=""
	for _,s in pairs(selectors) do if s.rebuild then s.rebuild() end end
	notify("Creado: "..name)
end)

local manage=section(page,"Gestionar configuraciones",4)
selectors.save=makeSelector(manage,"Guardar en…",1,function() return C.selSave end,function(n) C.selSave=n end)
makeBtn(manage,"Save Configuración",2).MouseButton1Click:Connect(function()
	local name=C.selSave or "Default" C.profiles[name]=C.capture() C.activeName=name C.persistAll()
	notify("Guardado en: "..name)
end)
selectors.load=makeSelector(manage,"Cargar…",3,function() return C.selLoad end,function(n) C.selLoad=n end)
makeBtn(manage,"Load Config",4,Color3.fromRGB(40,70,110)).MouseButton1Click:Connect(function()
	local name=C.selLoad or "Default" local data=C.profiles[name]
	if type(data)~="table" then notify("No existe: "..tostring(name)) return end
	C.activeName=name C.apply(data,{startRoute=false}) C.persistAll() notify("Cargado: "..name)
end)
selectors.del=makeSelector(manage,"Borrar…",5,function() return C.selDelete end,function(n) C.selDelete=n end)
local confirmRow=Instance.new("Frame") confirmRow.Parent=manage confirmRow.BackgroundTransparency=1
confirmRow.Size=UDim2.new(1,-4,0,0) confirmRow.AutomaticSize=Enum.AutomaticSize.Y confirmRow.Visible=false confirmRow.LayoutOrder=6
Instance.new("UIListLayout",confirmRow).Padding=UDim.new(0,4)
local confLab=Instance.new("TextLabel") confLab.Parent=confirmRow confLab.BackgroundTransparency=1 confLab.Size=UDim2.new(1,0,0,32)
confLab.Font=Enum.Font.Gotham confLab.TextColor3=Color3.fromRGB(255,180,100) confLab.TextSize=11 confLab.TextWrapped=true confLab.Text=""
local confYes=makeBtn(confirmRow,"Sí, borrar",2,Color3.fromRGB(140,40,40))
local confNo=makeBtn(confirmRow,"Cancelar",3)
makeBtn(manage,"Borrar configuración",5,Color3.fromRGB(100,40,40)).MouseButton1Click:Connect(function()
	local name=C.selDelete or "Default"
	if name=="Default" then notify("No se puede borrar Default") return end
	confLab.Text="¿Seguro que quieres borrar \""..name.."\"? No se puede deshacer."
	confirmRow.Visible=true
end)
confYes.MouseButton1Click:Connect(function()
	local name=C.selDelete or "Default" if name=="Default" then confirmRow.Visible=false return end
	C.profiles[name]=nil
	if C.activeName==name then C.activeName="Default" end
	if C.startupName==name then C.startupName="Default" end
	C.selDelete,C.selLoad,C.selSave="Default",C.activeName,C.activeName C.selStartup=C.startupName
	C.persistAll() confirmRow.Visible=false
	for _,s in pairs(selectors) do if s.rebuild then s.rebuild() end end
	notify("Borrado: "..name)
end)
confNo.MouseButton1Click:Connect(function() confirmRow.Visible=false end)

local ie=section(page,"Import / Export",5)
makeBtn(ie,"Exportar (clipboard)",1).MouseButton1Click:Connect(function()
	local s=jenc(C.capture()) if not s then notify("Error export") return end
	local payload=PREFIX..s local ok=false
	if setclipboard then ok=pcall(setclipboard,payload) end
	if not ok and toclipboard then ok=pcall(toclipboard,payload) end
	notify(ok and "Copiado" or "Sin setclipboard")
end)
local importBox=Instance.new("TextBox") importBox.Parent=ie importBox.Size=UDim2.new(1,-4,0,52)
importBox.BackgroundColor3=Color3.fromRGB(28,28,34) importBox.PlaceholderText="Pega export aquí" importBox.Text=""
importBox.TextColor3=Color3.fromRGB(255,255,255) importBox.PlaceholderColor3=Color3.fromRGB(110,110,125)
importBox.Font=Enum.Font.Code importBox.TextSize=11 importBox.TextWrapped=true importBox.MultiLine=true importBox.LayoutOrder=2 corner(importBox,6)
makeBtn(ie,"Importar",3,Color3.fromRGB(40,90,50)).MouseButton1Click:Connect(function()
	local raw=string.gsub(importBox.Text or "","^%s+","")
	if string.sub(raw,1,#PREFIX)==PREFIX then raw=string.sub(raw,#PREFIX+1) end
	local data=jdec(raw) if type(data)~="table" then notify("Import inválido") return end
	C.apply(data,{startRoute=false}) C.profiles[C.activeName or "Default"]=C.capture() C.persistAll()
	importBox.Text="" notify("Importado OK")
end)

task.spawn(function()
	local t0=tick() while not S.scriptReady and tick()-t0<30 do task.wait(0.2) end task.wait(0.35)
	if C.autoLoad then
		local name=C.startupName or "Default" local data=C.profiles[name]
		if type(data)=="table" and next(data) then
			C.activeName=name C.apply(data,{startRoute=true})
			for _,s in pairs(selectors) do if s.rebuild then s.rebuild() end end
			notify("Auto Load: "..name)
		end
	end
end)

setProgress(99,"Config","Finalizando...")
task.spawn(function()
	if S.fadeAndDestroyLoading then S.fadeAndDestroyLoading() end
	if S.UI.MainFrame then S.UI.MainFrame.Visible=true end
	if S.UI.Sidebar then S.UI.Sidebar.Visible=true end
	if rightSide then rightSide.Visible=true end
	if S.UI.SectionTitle then S.UI.SectionTitle.Text="Farm" end
	S.scriptReady=true notify("Hallowen world listo") setProgress(100,"Listo","Delta Hub activo")
end)
print("[Delta Hub] tab_config UI v2 listo")
