local PANEL = {}

AccessorFunc(PANEL, "m_pMenu", "Menu")
AccessorFunc(PANEL, "m_bChecked", "Checked")
AccessorFunc(PANEL, "m_bCheckable", "IsCheckable")
local lighten = Color(255, 255, 255, 3)

function PANEL:Init(  )
	self:SetContentAlignment(4)
	self:SetChecked(false)
	self.Color = Color(0, 0, 0, 0)
end

function PANEL:SetSubMenu(menu)
	self.SubMenu = menu

	if (!IsValid( self.SubMenuArrow)) then
		self.SubMenuArrow = vgui.Create("DPanel", self)
		self.SubMenuArrow.Paint = function(panel, w, h) derma.SkinHook("Paint", "MenuRightArrow", panel, w, h) end
	end
end

function PANEL:AddSubMenu(  )
	local SubMenu = DermaMenu(self)
	SubMenu:SetVisible(false)
	SubMenu:SetParent(self)

	self:SetSubMenu(SubMenu)

	return SubMenu
end

function PANEL:OnCursorEntered(  )
	if IsValid(self.ParentMenu) then

		self.ParentMenu:OpenSubMenu(self, self.SubMenu)
		return

	end

	self:GetParent():OpenSubMenu(self, self.SubMenu)
end

function PANEL:OnCursorExited(  ) end

function PANEL:Paint(w, h)
    local nextColor = Color(0, 0, 0, 0)
    if self.Hovered then
        nextColor = lighten
    end

    self.Color = NebulaFinance:LerpColor(FrameTime() * 10, self.Color, nextColor)

	draw.RoundedBoxEx(0, 0, 0, w, h, self.Color, false, false, false, false )
	draw.DrawText(self.label, "NebulaFinance:Fonts:Small", w/2, h/4, NebulaFinance:GetTheme("text1"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return false
end

function PANEL:OnMousePressed(mousecode)
	self.m_MenuClicking = true

	DButton.OnMousePressed(self, mousecode)
end

function PANEL:OnMouseReleased(mousecode)
	DButton.OnMouseReleased(self, mousecode)

	if self.m_MenuClicking && mousecode == MOUSE_LEFT then
		self.m_MenuClicking = false
		CloseDermaMenus()
	end
end

function PANEL:DoRightClick(  )
	if (self:GetIsCheckable()) then
		self:ToggleCheck()
	end
end

function PANEL:DoClickInternal(  )
	if (self:GetIsCheckable()) then
		self:ToggleCheck()
	end

	if (self.m_pMenu) then
		self.m_pMenu:OptionSelectedInternal(self)
	end
end

function PANEL:ToggleCheck(  )
	self:SetChecked(!self:GetChecked())
	self:OnChecked(self:GetChecked())
end

function PANEL:OnChecked(b) end

function PANEL:PerformLayout(  )

	self:SizeToContents()
	self:SetWide(self:GetWide() + 30)

	local w = math.max(self:GetParent():GetWide(), self:GetWide())

	self:SetSize(w, 40)

	if (IsValid(self.SubMenuArrow)) then

		self.SubMenuArrow:SetSize(15, 15)
		self.SubMenuArrow:CenterVertical()
		self.SubMenuArrow:AlignRight(4)

	end

	DButton.PerformLayout(self)
end

function PANEL:GenerateExample(  ) end

derma.DefineControl("NebulaFinance:Dmenuoption", "Menu Option Line", PANEL, "DButton")