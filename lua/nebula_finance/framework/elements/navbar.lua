local PANEL = {}

function PANEL:Init()
	self.buttons = {}
	self.panels = {}
	self.buttonsNum = {}

	self.padding = 60
	self.minSize = 80
end

function PANEL:AddExit(name, icon, func)
	self.Exit = vgui.Create("DButton", self)
	self.Exit:Dock(RIGHT)
	self.Exit:DockMargin(0, 0, -0, 0)
	self.Exit:SetText("")
	self.Exit:SetFont("NebulaFinance:Fonts:Regular")
	self.Exit.textColor = Color(120, 120, 120)
	self.Exit.Paint = function(pnl, w, h)
		NebulaFinance:DrawImgur(w*.38, h*.15, NebulaFinance:Scale(26), NebulaFinance:Scale(26), icon, pnl.textColor)
		draw.DrawText(name, "NebulaFinance:Fonts:Regular", w*.5, h*.45, pnl.textColor, TEXT_ALIGN_CENTER)
	end

	self.Exit.DoClick = function(pnl)
		func()
	end

	self.Exit.OnCursorEntered = function(pnl)
		pnl:LerpColor("textColor", NebulaFinance:GetTheme("red"))
	end

	self.Exit.OnCursorExited = function(pnl)
		if (self.active == name) then return end

		pnl:LerpColor("textColor", Color(120, 120, 120))
	end
	
	surface.SetFont("NebulaFinance:Fonts:Regular")
	local tw, th = surface.GetTextSize(name)
	self.Exit:SetWide(math.max(self.minSize, tw + self.padding))
end

function PANEL:AddTab(name, icon, panel, tbl)
	self.buttonsNum[#self.buttonsNum + 1] = name

	self.buttons[name] = vgui.Create("DButton", self)
	if (!tbl or (tbl and !tbl.dontDock)) then
		self.buttons[name]:Dock(LEFT)
		self.buttons[name]:DockMargin(0, 0, -0, 0)
	end

	self.buttons[name]:SetText("")
	self.buttons[name]:SetFont("NebulaFinance:Fonts:Regular")
	self.buttons[name].textColor = Color(120, 120, 120)
	local boxW, boxWMin = 0, 20
	self.buttons[name].Paint = function(pnl, w, h)
		if self.active == name then
			boxW = math.Clamp(boxW+2, boxWMin, w)
		else
			boxW = math.Clamp(boxW-2, boxWMin, w)
		end

		if(boxW > boxWMin) then
			draw.RoundedBox(0, (w/2)-(boxW/2), h*.95, boxW, h*.05, NebulaFinance:GetTheme("navigationbtn"))
		end

		NebulaFinance:DrawImgur(w*.4, h*.15, NebulaFinance:Scale(26), NebulaFinance:Scale(26), icon, pnl.textColor)
		draw.DrawText(name, "NebulaFinance:Fonts:Regular", w*.5, h*.45, pnl.textColor, TEXT_ALIGN_CENTER)
	end

	self.buttons[name].DoClick = function(pnl)
		self:SetActive(name)
	end

	self.buttons[name].OnCursorEntered = function(pnl)
		pnl:LerpColor("textColor", NebulaFinance:GetTheme("navigationbtn"))
	end
	
	self.buttons[name].OnCursorExited = function(pnl)
		if (self.active == name) then return end

		pnl:LerpColor("textColor", Color(120, 120, 120))
	end

	surface.SetFont("NebulaFinance:Fonts:Regular")

	local tw, th = surface.GetTextSize(name)
	self.buttons[name]:SetWide(math.max(self.minSize, tw + self.padding))

	if (!panel) then panel = "DPanel"end

	self.panels[name] = vgui.Create(panel, self.body)
	self.panels[name]:Dock(FILL)
	self.panels[name]:SetVisible(false)
	self.panels[name].Data = tbl

	if self.panels[name].SetData then
		self.panels[name]:SetData(tbl)
	end

	if (tbl and tbl.PostInit) then
		tbl.PostInit(self.panels[name])
	end

	return self.panels[name]
end

function PANEL:FindIndex(name)
	for i, v in pairs(self.buttonsNum) do
		if (v != name) then continue end

		return i
	end
end

function PANEL:SetActive(name)
	if (self.active == name) then return end

	local instant = !IsValid(self.buttons[self.active])

	if self.buttons[self.active] then
		self.buttons[self.active]:LerpColor("textColor", Color(120, 120, 120))
	end

	if self.panels[self.active] then
		local pnl = self.panels[self.active]

		pnl.DrawAlpha = pnl.DrawAlpha or 0

		pnl.PaintOver = function(pnl, w, h)
			draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(NebulaFinance:GetTheme("insidebox"), pnl.DrawAlpha))
		end

		pnl:Lerp("DrawAlpha", 255, 0.2, function()
			pnl.PaintOver = nil
			pnl:SetVisible(false)
		end)

		if self.panels[name].OnSwitchedFrom then
			self.panels[name]:OnSwitchedFrom()
		end
	end

	self.active = name

	if self.buttons[name] then
		if instant then
			self.buttons[name].textColor = NebulaFinance:GetTheme("navigationbtn")
			local id = self:FindIndex(name)
			local x = 0

			surface.SetFont("NebulaFinance:Fonts:Regular")

			local width = self.buttons[name]:GetWide()
		else
			self.buttons[name]:LerpColor("textColor", NebulaFinance:GetTheme("navigationbtn"))
			local id = self:FindIndex(name)
			local x = 0
		end
	end

	if self.panels[name] then
		if instant then
			local pnl = self.panels[name]
			pnl:SetVisible(true)
		else
			timer.Simple(0.15, function()
				if (!IsValid(self)) then return end

				local pnl = self.panels[name]
				pnl.DrawAlpha = pnl.DrawAlpha or 255
				pnl:SetVisible(true)

				pnl.PaintOver = function(pnl, w, h)
					draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(NebulaFinance:GetTheme("insidebox"), pnl.DrawAlpha))
				end

				pnl:Lerp("DrawAlpha", 0, 0.2, function()
					pnl.PaintOver = nil
				end)
			end)
		end

		if self.panels[name].OnSwitchedTo then
			self.panels[name]:OnSwitchedTo(name)
		end
	end

	self:SwitchedTab(name)
end

function PANEL:SwitchedTab(name) end

function PANEL:GetActive()
	return self.panels[self.active]
end

function PANEL:SetBody(pnl)
	self.body = vgui.Create("DPanel", pnl)
	self.body:Dock(FILL)
	self.body:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))

	self.body.Paint = nil
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("NebulaFinance:Navbar", PANEL)