local Frame
local ply = LocalPlayer()

concommand.Add("nebulafinance_config", function()
	if !(ply:IsSuperAdmin()) then
		notification.AddLegacy("You do not have access to the configuration menu.", NOTIFY_ERROR, 10)
		return
	end

	if IsValid(Frame) then Frame:Remove() end

	local dataModifiers = {}

	Frame = vgui.Create("DFrame")
	Frame:SetSize(ScrW() * 0.30, ScrH() * 0.5)
	Frame:Center()
	Frame:MakePopup()
	Frame:SetTitle("")
	Frame:SetDraggable(false)
	Frame:ShowCloseButton(false)
	Frame.headerHeight = 40
	Frame:DockPadding(0, Frame.headerHeight, 0, 0)

	Frame.Paint = function(self, w, h)
		ax, ay = self:LocalToScreen()

        BSHADOWS.BeginShadow()
			draw.RoundedBox(5, ax, ay, w, h, NebulaFinance:GetTheme("frame"))			
			draw.RoundedBoxEx(5, ax, ay, w, Frame.headerHeight, NebulaFinance:GetTheme("header"), true, true, false, false)
			draw.DrawText("NebulaFinance - Configuration", "NebulaFinance:Fonts:Regular", ax + 10, ay + 1, NebulaShelves:GetTheme("text1"), 0, TEXT_ALIGN_CENTER)
		BSHADOWS.EndShadow(1, 1, 1)
	end

    local size = 40

	local closeButton = vgui.Create("DButton", Frame)
	closeButton:SetSize( size, size )
	closeButton:SetPos(Frame:GetWide() - size - ((Frame.headerHeight - size)), (Frame.headerHeight) - (size))
	closeButton:SetTextColor(color_white)
    closeButton:SetFont("NebulaFinance:Fonts:Small")
	closeButton:SetText("✕")
	closeButton.Color = ColorAlpha(color_black, 0)

	closeButton.Paint = function(self, w, h)
		local nextColor = ColorAlpha(color_black, 0)
		if self.Hovered then
			nextColor = NebulaFinance:GetTheme("red")
		end

		self.Color = NebulaFinance:LerpColor(FrameTime() * 4, self.Color, nextColor)

		draw.RoundedBoxEx(5, 0, 0, w, h, self.Color, false, true, false, false)
	end

	closeButton.DoClick = function()
		NebulaFinance:Derma_Query("Would you like to save the changes made?", "NebulaFinance - Save Configuration","Save Changes",function(  )

			local config = {}

			for k, v in pairs(dataModifiers) do
				if NebulaFinance.Configuration.ConfigOptions[v.interactElement.ID].Type == NebulaFinance_CONFIG_INT then
					config[v.interactElement.ID] = tonumber(v.interactElement:GetValue())
				else
					config[v.interactElement.ID] = v.interactElement:GetValue()
				end
			end

			net.Start("NebulaFinance:SaveConfiguration")
				net.WriteTable(config)
			net.SendToServer()

			Frame:Remove()

		end, "Disregard Changes",function()
			Frame:Remove()
			chat.AddText(Color(231, 128, 9),"[NebulaFinance] ", Color(255, 255, 255, 255), "No changes were saved.")
		end, "Cancel")

	end

	local configPanel = vgui.Create("DPanel", Frame)
	configPanel:SetSize(Frame:GetWide(), Frame:GetTall() * 0.908)
	configPanel:Dock(TOP)
	configPanel:DockMargin(5, 5, 5, 5)

	configPanel.Paint = function(self, w, h) 
		draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox")) 
	end

	local configPanelScroll = vgui.Create("NebulaFinance:Scroll", configPanel)
	configPanelScroll:Dock(FILL)
	configPanelScroll:DockMargin(5, 5, 5, 5)

	local optionHeight = configPanel:GetTall() * 0.25
	local optionMargins = configPanel:GetTall() * 0.05

	for k, v in SortedPairsByMemberValue(NebulaFinance.Configuration.ConfigOptions, "Order", false) do
		local configOption = vgui.Create("DPanel", configPanelScroll)
		configOption:SetSize(configPanel:GetWide(), optionHeight)
		configOption:DockMargin(0, 0, 0, optionMargins)
		configOption:Dock(TOP)

		configOption.Paint = nil

		local title = vgui.Create("DLabel", configOption)
		title:SetFont("NebulaFinance:Fonts:Regular")
		title:SetText(v.Title)
		title:SetTextColor(color_white)
		title:SizeToContents()

		local description = vgui.Create("DLabel", configOption)
		description:SetFont("NebulaFinance:Fonts:Small")
		description:SetText(v.Description)
		description:SetTextColor(NebulaFinance:GetTheme("text1"))
		description:SizeToContents()
		description:SetPos(0,configOption:GetTall() * 0.29)
		description:SetWrap(true)
		description:SetSize(configOption:GetWide() * 0.75, description:GetTall() * 2)

		local dataModifier = vgui.Create("NebulaFinance:ConfigController", configOption)
		dataModifier:SetSize(configOption:GetWide() * 0.55, configOption:GetTall() * 0.27)
		dataModifier:SetPos(0, configOption:GetTall() * 0.73)
		dataModifier:SetID(k)
		table.insert(dataModifiers, dataModifier)
	end
end)

net.Receive("NebulaFinance:ConfigurationSaved",function()
	chat.AddText(NebulaFinance:GetTheme("navigationbtn"),"[NebulaFinance] ", color_white, "changes were saved successfully.")
end)