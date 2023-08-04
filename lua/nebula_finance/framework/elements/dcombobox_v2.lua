local PANEL = {}

Derma_Install_Convar_Functions(PANEL)

AccessorFunc(PANEL, "m_bDoSort", "SortItems", FORCE_BOOL)

function PANEL:Init(  )
	self:SetTall(40)
	self:Clear()

	self:SetIsMenu(true)
	self:SetSortItems(true)
	self:SetText("")
end

function PANEL:SetBackColor(color)
    self.backColor = color
end

function PANEL:SetHighlightColor(color)
    self.highlightColor = color
end

function PANEL:Clear(  )
	self.Choices = {}
	self.Data = {}
	self.ChoiceIcons = {}
	self.selected = nil

	if (self.Menu) then
		self.Menu:Remove()
		self.Menu = nil
	end
end

function PANEL:GetOptionText(id)
	return self.Choices[id]
end

function PANEL:GetOptionData(id)
	return self.Data[id]
end

function PANEL:GetOptionTextByData(data)
	for id, dat in pairs(self.Data) do
		if (dat == data) then
			return self:GetOptionText(id)
		end
	end

	for id, dat in pairs(self.Data) do
		if (dat == tonumber(data)) then
			return self:GetOptionText(id)
		end
	end

	-- In case we fail
	return data
end

function PANEL:PerformLayout(  ) end

function PANEL:ChooseOption(value, index)
	if (self.Menu) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self:SetText(value)
	self.selected = index

	self:OnSelect(index, value, self.Data[index])
end

function PANEL:ChooseOptionID(index)
	local value = self:GetOptionText(index)
	self:ChooseOption(value, index)
end

function PANEL:GetSelectedID(  )
	return self.selected
end

function PANEL:GetSelected(  )
	if (!self.selected) then return end

	return self:GetOptionText(self.selected), self:GetOptionData(self.selected)
end

function PANEL:OnSelect(index, value, data) end

function PANEL:AddChoice(value, data, select, icon)
	local i = table.insert(self.Choices, value)

	if (data) then
		self.Data[i] = data
	end
	
	if (icon) then
		self.ChoiceIcons[i] = icon
	end

	if (select) then
		self:ChooseOption(value, i)
	end

	return i
end

function PANEL:IsMenuOpen(  )
	return IsValid(self.Menu) && self.Menu:IsVisible()
end

function PANEL:OpenMenu(pControlOpener)
	if (pControlOpener && pControlOpener == self.TextEntry) then
		return
	end

	if #self.Choices == 0 then return end

	if IsValid(self.Menu) then
		self.Menu:Remove()
		self.Menu = nil
	end

	self.Menu = vgui.Create("NebulaFinance:Dmenu")

	if self:GetSortItems() then

		local sorted = {}

		for k, v in pairs(self.Choices) do
			local val = tostring(v)
			if (string.len(val) > 1 && !tonumber(val) && val:StartWith("#")) then val = language.GetPhrase(val:sub(2)) end
			table.insert(sorted, {id = k, data = v, label = val})
		end

		for k, v in SortedPairsByMemberValue(sorted, "label") do
			local option = self.Menu:AddOption(v.data, function() self:ChooseOption(v.data, v.id) end)
			if (self.ChoiceIcons[v.id]) then
				option:SetIcon(self.ChoiceIcons[v.id])
			end
		end

	else

		for k, v in pairs(self.Choices) do
			local option = self.Menu:AddOption(v, function() self:ChooseOption(v, k) end)
			if ( self.ChoiceIcons[k] ) then
				option:SetIcon(self.ChoiceIcons[k])
			end
		end

	end

	local x, y = self:LocalToScreen(0, self:GetTall())

	self.Menu:SetMaxHeight(ScrH()*0.2)
	self.Menu.dontRoundTop = true
	self.Menu:SetMinimumWidth(self:GetWide())
	self.Menu:Open(x, y, false, self)
end

function PANEL:CloseMenu(  )
	if (IsValid(self.Menu)) then
		self.Menu:Remove()
	end
end

function PANEL:CheckConVarChanges(  )
	if (!self.m_strConVar) then return end

	local strValue = GetConVarString(self.m_strConVar)
	if (self.m_strConVarValue == strValue) then return end

	self.m_strConVarValue = strValue

	self:SetValue(self:GetOptionTextByData(self.m_strConVarValue))
end

function PANEL:Think(  )
	self:CheckConVarChanges()
end

function PANEL:SetValue(strValue)
	self:SetText(strValue)
end

function PANEL:DoClick()
	if ( self:IsMenuOpen() ) then
		return self:CloseMenu()
	end

	self:OpenMenu()
end

function PANEL:SetRoundedBoxDimensions(roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH)
	self.roundedBoxX, self.roundedBoxY, self.roundedBoxW, self.roundedBoxH = roundedBoxX, roundedBoxY, roundedBoxW, roundedBoxH
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))
end

derma.DefineControl("NebulaFinance:DcomboBox_v2", "", PANEL, "DButton")