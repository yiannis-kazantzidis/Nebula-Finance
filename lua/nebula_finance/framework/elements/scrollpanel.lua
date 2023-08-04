local PANEL = {}

AccessorFunc(PANEL, "Padding", "Padding")
AccessorFunc(PANEL, "pnlCanvas", "Canvas")

function PANEL:Init(  )
	self.pnlCanvas = vgui.Create("Panel", self)

	self.pnlCanvas.OnMousePressed = function(self, code) self:GetParent():OnMousePressed(code) end

	self.pnlCanvas:SetMouseInputEnabled(true)

	self.pnlCanvas.PerformLayout = function(pnl)
		self:PerformLayoutInternal()
		self:InvalidateParent()
	end

	self.VBar = vgui.Create("DVScrollBar", self)
	self.VBar:Dock(RIGHT)
	self.VBar:SetWide(NebulaFinance:Scale(8))

    local sbar = self.VBar
    sbar.LerpTarget = 0

	sbar.btnUp.Paint = nil
	sbar.btnDown.Paint = nil

	sbar.Paint = function(self, w, h)
		draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))
	end

	sbar.btnGrip.Paint = function(self, w, h)
		draw.RoundedBox(5, w*.08, 0, w*.8, h, NebulaFinance:GetTheme("insidebox"))
	end

    function sbar:AddScroll(dlta)
       local OldScroll = self.LerpTarget or self:GetScroll()
       dlta = dlta * 50 
       self.LerpTarget = math.Clamp(self.LerpTarget + dlta, -self.btnGrip:GetTall(), self.CanvasSize + self.btnGrip:GetTall())

       return OldScroll ~= self:GetScroll()
    end

    sbar.Think = function(s)
		local frac = FrameTime() * 5

		if (math.abs(s.LerpTarget - s:GetScroll()) <= (s.CanvasSize / 10)) then
			frac = FrameTime() * 2 
		end

		local newpos = Lerp(frac, s:GetScroll(), s.LerpTarget)
		s:SetScroll(math.Clamp(newpos, 0, s.CanvasSize))

		if (s.LerpTarget < 0 and s:GetScroll() <= 0) then
			s.LerpTarget = 0
		elseif (s.LerpTarget > s.CanvasSize and s:GetScroll() >= s.CanvasSize) then
			s.LerpTarget = s.CanvasSize
		end
    end

	self:SetPadding(0)
	self:SetMouseInputEnabled(true)

	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)
	self:SetPaintBackground(false)
end

function PANEL:AddItem(pnl)
	pnl:SetParent(self:GetCanvas())
end

function PANEL:OnChildAdded(child)
	self:AddItem(child)
end

function PANEL:SizeToContents(  )
	self:SetSize(self.pnlCanvas:GetSize())
end

function PANEL:GetVBar(  )
	return self.VBar
end

function PANEL:GetCanvas(  )
	return self.pnlCanvas
end

function PANEL:InnerWidth(  )
	return self:GetCanvas():GetWide()
end

function PANEL:Rebuild(  )
	self:GetCanvas():SizeToChildren( false, true )

	if (self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall()) then
		self:GetCanvas():SetPos(0, (self:GetTall() - self:GetCanvas():GetTall()) * 0.5 )
	end
end

function PANEL:OnMouseWheeled(dlta)
	return self.VBar:OnMouseWheeled(dlta)
end

function PANEL:OnVScroll(iOffset)
	self.pnlCanvas:SetPos(0, iOffset)
end

function PANEL:ScrollToChild(panel)
	self:InvalidateLayout(true)

	local x, y = self.pnlCanvas:GetChildPosition(panel)
	local w, h = panel:GetSize()
	y = y + h * 0.5
	y = y - self:GetTall() * 0.5

	self.VBar:AnimateTo(y, 0.5, 0, 0.5)
end

function PANEL:PerformLayoutInternal(  )
	local Tall = self.pnlCanvas:GetTall()
	local Wide = self:GetWide()
	local YPos = 0

	self:Rebuild()

	self.VBar:SetUp(self:GetTall(), self.pnlCanvas:GetTall())
	YPos = self.VBar:GetOffset()

	if (self.VBar.Enabled) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos(0, YPos)
	self.pnlCanvas:SetWide(Wide)

	self:Rebuild()

	if Tall != self.pnlCanvas:GetTall() then
		self.VBar:SetScroll(self.VBar:GetScroll())
	end
end

function PANEL:PerformLayout(  )
	self:PerformLayoutInternal()
end

function PANEL:Clear(  )
	return self.pnlCanvas:Clear()
end

derma.DefineControl("NebulaFinance:Scroll", "", PANEL, "DPanel")