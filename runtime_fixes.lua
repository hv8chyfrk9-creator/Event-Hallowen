-- runtime_fixes.lua: parches en caliente (paginas, keycaps)
local S = getgenv().DeltaHub
if type(S) ~= "table" then return end
local Workspace = game:GetService("Workspace")

function S.UI.showOnlyPage(page, title)
	S.UI.Pages = S.UI.Pages or {}
	for _, p in pairs(S.UI.Pages) do
		if typeof(p) == "Instance" then p.Visible = false end
	end
	if S.UI.ContentArea then
		for _, ch in ipairs(S.UI.ContentArea:GetChildren()) do
			if ch:IsA("ScrollingFrame") then ch.Visible = false end
		end
	end
	if page then page.Visible = true end
	if S.UI.SectionTitle and title then S.UI.SectionTitle.Text = title end
end

task.defer(function()
	local side = S.UI and S.UI.Sidebar
	if not side then return end
	for _, b in ipairs(side:GetChildren()) do
		if b:IsA("TextButton") then
			local name = b.Text
			b.MouseButton1Click:Connect(function()
				local pages = S.UI.Pages or {}
				local map = {
					Farm = pages.Farm or S.UI.FarmPage,
					Player = pages.Player or S.UI.PlayerPage,
					Events = pages.Events,
					Extras = pages.Extras,
				}
				local pg = map[name]
				if pg then S.UI.showOnlyPage(pg, name) end
			end)
		end
	end
end)

S.Extras = S.Extras or {}
local X = S.Extras
local function stripKeycaps()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local n = string.lower(obj.Name or "")
		local parentN = obj.Parent and string.lower(obj.Parent.Name or "") or ""
		local hit = string.find(n, "keycap", 1, true) or string.find(parentN, "keycap", 1, true)
		if hit and obj:IsA("BasePart") then
			pcall(function()
				obj.Transparency = 1
				obj.CanCollide = false
				obj.CanQuery = false
				obj.CanTouch = false
			end)
		end
	end
end
if not S._keycapFixLoop then
	S._keycapFixLoop = true
	task.spawn(function()
		while true do
			task.wait(0.5)
			if X.antiKey then stripKeycaps() end
		end
	end)
end

print("[Delta Hub] runtime_fixes loaded")
