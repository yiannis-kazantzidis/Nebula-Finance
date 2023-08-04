local PANEL = {}

local noCol = Color(0, 0, 0, 0)

function PANEL:Init(  )
	self:SetSize(175, 75)
end

function PANEL:SetID(id)
	if NebulaFinance.Configuration.ConfigOptions[id].Type == NebulaFinance_CONFIG_BOOL then
		self.interactElement = vgui.Create("NebulaFinance:Checkbox", self)
		self.interactElement:SetSize(self:GetWide()*.2, self:GetTall())
		self.interactElement:SetText("")
		self.interactElement.value = NebulaFinance.Configuration.GetConvar(id)
		self.interactElement:SetValue(self.interactElement.value, self.interactElement.value)

	elseif NebulaFinance.Configuration.ConfigOptions[id].Type == NebulaFinance_CONFIG_STRING then
		self.interactElement = vgui.Create("DTextEntry", self)
		self.interactElement:SetSize(self:GetWide(), self:GetTall())
		self.interactElement:SetFont("NebulaFinance:Fonts:Small")
		self.interactElement:SetText(NebulaFinance.Configuration.GetConvar(id))

		self.interactElement.AllowInput = function(...)
			if #self.interactElement:GetValue() >= NebulaFinance.Configuration.ConfigOptions[id].maxLength then
				return true
			end
		end

		self.interactElement.Paint = function(self, w, h)
			draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))

			self:DrawTextEntryText(NebulaFinance:GetTheme("text1"), NebulaFinance:GetTheme("blue"), NebulaFinance:GetTheme("text2"))
		end

	elseif NebulaFinance.Configuration.ConfigOptions[id].Type == NebulaFinance_CONFIG_INT then
		self.interactElement = vgui.Create("DTextEntry", self)
		self.interactElement:SetSize(self:GetWide(), self:GetTall())
		self.interactElement:SetFont("NebulaFinance:Fonts:Small")
		self.interactElement:SetText(tostring(NebulaFinance.Configuration.GetConvar(id)))

		self.interactElement.Paint = function(self, w, h)
			draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))

			self:DrawTextEntryText(NebulaFinance:GetTheme("text1"), NebulaFinance:GetTheme("blue"), NebulaFinance:GetTheme("text2"))
		end

	elseif NebulaFinance.Configuration.ConfigOptions[id].Type == NebulaFinance_CONFIG_TABLE then
		self.interactElement = vgui.Create("NebulaFinance:DcomboBox_v2", self)
		self.interactElement:SetSize(self:GetWide()*.5, self:GetTall())
		self.interactElement:SetFont("NebulaFinance:Fonts:Small")
		self.interactElement:SetTextColor(NebulaFinance:GetTheme("text2"))
		self.interactElement:SetText(NebulaFinance.Configuration.GetConvar(id))
		self.interactElement:SetSortItems(NebulaFinance.Configuration.ConfigOptions[id].SortItems)

		for k,v in pairs(NebulaFinance.Configuration.ConfigOptions[id].AllowedValues) do
			self.interactElement:AddChoice(v, v)
		end
	end
	self.interactElement.ID = id
end

vgui.Register("NebulaFinance:ConfigController", PANEL, "Panel")


