local ply = LocalPlayer()

local blur = Material("pp/blurscreen")
function NebulaFinance:DrawBlurPanel(panel, layers, density, alpha)
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(blur)

    for i = 1, 3 do
        blur:SetFloat("$blur", (i / layers) * density)
        blur:Recompute()

        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end
end

function NebulaFinance:AmountEntryBox(name, playerselection, parent, func)
    local popupButton = vgui.Create("DButton", parent)
	popupButton:Dock(FILL)
	popupButton:SetText("")
	popupButton:SetCursor("arrow")
	popupButton:SetAlpha(0)
	popupButton:AlphaTo(255, 0.2)
			  
	popupButton.Paint = function(self, w, h)
        NebulaFinance:DrawBlurPanel(self, 6, 6, 255)
		draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(color_black, 150))
	end
  
	popupButton.DoClick = function()
      if popupButton.ContactingServers then return end

	  popupButton:AlphaTo(0, 0.2, 0, function()
			if( IsValid(popupButton) ) then
			  popupButton:Remove()
			end
		end)
	end
  
	local popup = vgui.Create("DPanel", popupButton)
    popup:SetSize(0, 0)
    popup.IsAnimating = true
    popup:AnimateSize(NebulaFinance:Scale(360), NebulaFinance:Scale(255), .7, function()
        popup.IsAnimating = true
    end)

    popup.Think = function(self)
        if self.IsAnimating then popup:Center() end
    end

	local nameText = name
	popup.Paint = function(self, w, h)
		ax, ay = self:LocalToScreen()

		BSHADOWS.BeginShadow()
			draw.RoundedBox(5, ax, ay, w, h, NebulaFinance:GetTheme("inframe"))
		BSHADOWS.EndShadow(1, 1, 1)

        draw.DrawText(nameText, "NebulaFinance:Fonts:Large", w*.5, NebulaFinance:Scale(5), color_white, TEXT_ALIGN_CENTER)
	end

    local entryPanel = vgui.Create("DPanel", popup)
    entryPanel:Dock(TOP)
    entryPanel:DockMargin(NebulaFinance:Scale(20), NebulaFinance:Scale(playerselection and 75 or 100), NebulaFinance:Scale(20), NebulaFinance:Scale(5))
    entryPanel:SetTall(NebulaFinance:Scale(42))
    entryPanel.buttonColor = NebulaFinance:GetTheme("insidebox")

    entryPanel.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, entryPanel.buttonColor)
    end

    local amountEntry = vgui.Create("DTextEntry", entryPanel)
    amountEntry:Dock(FILL)
    amountEntry:DockMargin(NebulaFinance:Scale(2), NebulaFinance:Scale(2), NebulaFinance:Scale(2), NebulaFinance:Scale(2))
    amountEntry:SetFont("NebulaFinance:Fonts:Regular")
    amountEntry:SetNumeric(true)

    amountEntry.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))

        if self:GetValue() == "" then
            draw.DrawText(string.format(NebulaFinance:GetPhrase("pocketbalance"), DarkRP.formatMoney(NebulaFinance:GetBalance(ply))), "NebulaFinance:Fonts:MediumBold", w*.5, NebulaFinance:Scale(6), ColorAlpha(color_white, 100), TEXT_ALIGN_CENTER)
        end

        self:DrawTextEntryText(color_white, NebulaFinance:GetTheme("blue"), NebulaFinance:GetTheme("text2"))
    end

    amountEntry.OnGetFocus = function()
        entryPanel:LerpColor("buttonColor", NebulaFinance:GetTheme("blue"))
    end

    amountEntry.OnLoseFocus = function()
        entryPanel:LerpColor("buttonColor", NebulaFinance:GetTheme("insidebox"))
    end

    local playerRequested

    if playerselection then
        local playerSelection = vgui.Create("NebulaFinance:DcomboBox_v2", popup)
        playerSelection:Dock(TOP)
        playerSelection:DockMargin(NebulaFinance:Scale(20), NebulaFinance:Scale(5), NebulaFinance:Scale(20), NebulaFinance:Scale(5))
        playerSelection:SetTall(NebulaFinance:Scale(42))
        playerSelection:SetFont("NebulaFinance:Fonts:RegularBold")
        playerSelection:SetText(NebulaFinance:GetPhrase("selectplayer"))

        for k, v in pairs(player.GetHumans()) do
            if v == ply then continue end
            playerSelection:AddChoice(v:GetName(), v)
        end

        playerSelection.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
        end

        playerSelection.OnSelect = function(self2, index, value, data)
            playerRequested = data
        end
    end

    local nextPanel = vgui.Create("DButton", popup)
    nextPanel:Dock(BOTTOM)
    nextPanel:DockMargin(NebulaFinance:Scale(100), NebulaFinance:Scale(5), NebulaFinance:Scale(100), NebulaFinance:Scale(18))
    nextPanel:SetTall(NebulaFinance:Scale(45))
    nextPanel:SetText("")
    nextPanel.buttonColor = ColorAlpha(NebulaFinance:GetTheme("insidebox"), 50)
    nextPanel.textColor = ColorAlpha(color_white, 100)

    nextPanel.OnCursorEntered = function(pnl)
        pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("blue"), 25))
        pnl:LerpColor("textColor", NebulaFinance:GetTheme("blue"))
    end

    nextPanel.OnCursorExited = function(pnl)    
        pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("insidebox"), 50))
        pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
    end

    nextPanel.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, nextPanel.buttonColor)
        draw.DrawText(NebulaFinance:GetPhrase("next"), "NebulaFinance:Fonts:Regular", w*.1, h*.07, self.textColor)
        NebulaFinance:DrawImgur(NebulaFinance:Scale(120), NebulaFinance:Scale(11), NebulaFinance:Scale(24), NebulaFinance:Scale(24), "Db2x88B", self.textColor)
    end

    nextPanel.DoClick = function()
        local amountRequested = tonumber(amountEntry:GetValue())
        if !amountRequested or amountRequested == 0 then return end
        if playerselection then 
            if !playerRequested then return end
        end

        nameText = ""

        popup:Clear()

        popup:SetAlpha(0)
        popup:AlphaTo(255, .3, 0)

        local accountsPanel = vgui.Create("DPanel", popup)
        accountsPanel:Dock(TOP)
        accountsPanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
        accountsPanel:SetTall(NebulaFinance:Scale(180))

        accountsPanel.Paint = nil 

        local accountsScroll = vgui.Create("NebulaFinance:Scroll", accountsPanel)
        accountsScroll:Dock(FILL)

        local accountsLayout = vgui.Create("DIconLayout", accountsScroll)
        accountsLayout:Dock(FILL)
        accountsLayout:SetSpaceY(5)
        accountsLayout:SetSpaceX(5)

        local toAccount
        local fromAccount

        for k, v in pairs(NebulaFinance:GetLinkedAccounts()) do
            v.account = vgui.Create("DButton", accountsLayout)
            v.account:SetText("")
            v.account:SetSize(NebulaFinance:Scale(172), NebulaFinance:Scale(86))
            v.account.buttonColor = ColorAlpha(NebulaFinance:GetTheme("insidebox"), 100)
            v.account.textColor = color_white
            
            v.account.OnCursorEntered = function(pnl)
                pnl:LerpColor("buttonColor", ColorAlpha(v.color, 25))
                pnl:LerpColor("textColor", ColorAlpha(v.color, 150))
            end
    
            v.account.OnCursorExited = function(pnl)    
                pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("insidebox"), 100))
                pnl:LerpColor("textColor", color_white)
            end
    
            v.account.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
                draw.DrawText(v.name, "NebulaFinance:Fonts:Medium", w*.5, NebulaFinance:Scale(5), ((toAccount == v) or (fromAccount == v)) and NebulaFinance:GetTheme("green") or self.textColor, TEXT_ALIGN_CENTER)
                draw.DrawText(DarkRP.formatMoney(NebulaFinance:GetIntegrationTbl(v.id):GETBALANCE(ply)), "NebulaFinance:Fonts:MediumBold", w*.5, NebulaFinance:Scale(32), self.textColor, TEXT_ALIGN_CENTER)


                if playerselection then
                    if fromAccount == v then
                        draw.DrawText(NebulaFinance:GetPhrase("from"), "NebulaFinance:Fonts:Small", w*.5, NebulaFinance:Scale(60), self.textColor, TEXT_ALIGN_CENTER)
                    else
                        draw.DrawText("N/A", "NebulaFinance:Fonts:Small", w*.5, NebulaFinance:Scale(60), self.textColor, TEXT_ALIGN_CENTER)
                    end
                else
                    if toAccount == v then
                        draw.DrawText(NebulaFinance:GetPhrase("to"), "NebulaFinance:Fonts:Small", w*.5, NebulaFinance:Scale(60), self.textColor, TEXT_ALIGN_CENTER)
                    elseif fromAccount == v then
                        draw.DrawText(NebulaFinance:GetPhrase("from"), "NebulaFinance:Fonts:Small", w*.5, NebulaFinance:Scale(60), self.textColor, TEXT_ALIGN_CENTER)
                    else
                        draw.DrawText("N/A", "NebulaFinance:Fonts:Small", w*.5, NebulaFinance:Scale(60), self.textColor, TEXT_ALIGN_CENTER)
                    end
                end
            end

            v.account.DoClick = function()
                -- handling the buttons functions (it does multiple)
                local shouldKeep = true

                if playerselection then
                    if fromAccount == v then
                        shouldKeep = false 
                        fromAccount = nil 
                    end
    
                    if !shouldKeep then return end

                    if !fromAccount then
                        fromAccount = v
                    end
                else
                    if toAccount == v then 
                        shouldKeep = false
                        toAccount = nil 
                    end
                    
                    if fromAccount == v then
                        shouldKeep = false 
                        fromAccount = nil 
                    end
    
                    if !shouldKeep then return end
                    
                    if !fromAccount then
                        fromAccount = v
                    else
                        toAccount = v
                    end
                end
            end
        end

        local nextPanel = vgui.Create("DButton", popup)
        nextPanel:Dock(BOTTOM)
        nextPanel:DockMargin(NebulaFinance:Scale(100), NebulaFinance:Scale(5), NebulaFinance:Scale(100), NebulaFinance:Scale(18))
        nextPanel:SetTall(NebulaFinance:Scale(42))
        nextPanel:SetText("")
        nextPanel.buttonColor = ColorAlpha(NebulaFinance:GetTheme("insidebox"), 50)
        nextPanel.textColor = ColorAlpha(color_white, 100)
    
        nextPanel.OnCursorEntered = function(pnl)
            pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("blue"), 25))
            pnl:LerpColor("textColor", NebulaFinance:GetTheme("blue"))
        end
    
        nextPanel.OnCursorExited = function(pnl)    
            pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("insidebox"), 50))
            pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
        end

        nextPanel.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
            draw.DrawText(NebulaFinance:GetPhrase("next"), "NebulaFinance:Fonts:Regular", w*.1, h*.07, self.textColor)
            NebulaFinance:DrawImgur(NebulaFinance:Scale(120), NebulaFinance:Scale(11), NebulaFinance:Scale(24), NebulaFinance:Scale(24), "Db2x88B", self.textColor)
        end

        nextPanel.DoClick = function()
            if playerselection then
                if !fromAccount then return end
            else
                if !fromAccount or !toAccount then return end  
            end

            nameText = ""
    
            popup:Clear()

            popup:SetAlpha(0)
            popup:AlphaTo(255, .3, 0)

            local overviewPanel = vgui.Create("DPanel", popup)
            overviewPanel:Dock(TOP)
            overviewPanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(0))
            overviewPanel:SetTall(NebulaFinance:Scale(190))

            overviewPanel.Paint = function(self, w, h)
                draw.DrawText(NebulaFinance:GetPhrase("amount"), "NebulaFinance:Fonts:RegularBold", w*.5, 0, color_white, TEXT_ALIGN_CENTER)
                
                draw.DrawText(DarkRP.formatMoney(amountRequested), "NebulaFinance:Fonts:RegularBold", w*.5, NebulaFinance:Scale(35), ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER)

                if !NebulaFinance:IsPremiumUser(ply) then
                    draw.DrawText(string.format(NebulaFinance:GetPhrase("feeincluded"), NebulaFinance.Configuration.GetConvar("transactionfeeamount"), "%"), "NebulaFinance:Fonts:Medium", w*.5, NebulaFinance:Scale(70), ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER)
                end
                
                draw.DrawText(NebulaFinance:GetPhrase("fromandto"), "NebulaFinance:Fonts:RegularBold", w*.5, NebulaFinance:Scale(100), color_white, TEXT_ALIGN_CENTER)

                if playerselection then
                    draw.DrawText(fromAccount.name.." / "..playerRequested:GetName(), "NebulaFinance:Fonts:Medium", w*.5, NebulaFinance:Scale(135), ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER)
                else       
                    draw.DrawText(fromAccount.name.." / "..toAccount.name, "NebulaFinance:Fonts:Medium", w*.5, NebulaFinance:Scale(135), ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER)
                end
            end

            local confirmPanel = vgui.Create("DButton", popup)
            confirmPanel:Dock(BOTTOM)
            confirmPanel:DockMargin(NebulaFinance:Scale(100), NebulaFinance:Scale(5), NebulaFinance:Scale(100), NebulaFinance:Scale(18))
            confirmPanel:SetTall(NebulaFinance:Scale(42))
            confirmPanel:SetText("")
            confirmPanel.buttonColor = ColorAlpha(NebulaFinance:GetTheme("insidebox"), 50)
            confirmPanel.textColor = ColorAlpha(color_white, 100)
        
            confirmPanel.OnCursorEntered = function(pnl)
                pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("green"), 25))
                pnl:LerpColor("textColor", NebulaFinance:GetTheme("green"))
            end
        
            confirmPanel.OnCursorExited = function(pnl)    
                pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("insidebox"), 50))
                pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
            end

            confirmPanel.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
                draw.DrawText(NebulaFinance:GetPhrase("confirm"), "NebulaFinance:Fonts:Regular", w*.05, h*.07, self.textColor)
                NebulaFinance:DrawImgur(NebulaFinance:Scale(122), NebulaFinance:Scale(11), NebulaFinance:Scale(24), NebulaFinance:Scale(24), "O53WPQY", self.textColor)
            end

            confirmPanel.DoClick = function()
                popup:Clear()

                if func then
                    if playerselection then
                        func(amountRequested, {from = fromAccount},  playerRequested)
                    else
                        func(amountRequested, {to = toAccount, from = fromAccount})
                    end
                end

                local panel = vgui.Create("DPanel", popup)
                panel:SetSize(0, 0)
                panel.IsAnimating = true
                panel.frameColor = NebulaFinance:GetTheme("blue")
                popupButton.ContactingServers = true
                panel.ContactingServers = true
                panel.isSuccess = true
                panel.transactionID = 0
                panel:AnimateSize(popup:GetWide(), popup:GetTall(), .7, function()
                    panel.IsAnimating = true
                end)
            
                panel.Think = function(self)
                    if self.IsAnimating then panel:Center() end
                end

                panel.Paint = function(self, w, h)
                    draw.RoundedBox(5, 0, 0, w, h, self.frameColor)

                    if self.ContactingServers then
                        NebulaFinance:DrawProgressWheel(NebulaFinance:Scale(150), NebulaFinance:Scale(65), NebulaFinance:Scale(64), NebulaFinance:Scale(64), color_white)
                        draw.DrawText(NebulaFinance:GetPhrase("contactingservers"), "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(155), color_white, TEXT_ALIGN_CENTER)
                    else 
                        if self.isSuccess then
                            NebulaFinance:DrawImgur(NebulaFinance:Scale(150), NebulaFinance:Scale(65), NebulaFinance:Scale(64), NebulaFinance:Scale(64), "QzdSeYc", color_white)
                            draw.DrawText(NebulaFinance:GetPhrase("transapproved"), "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(155), color_white, TEXT_ALIGN_CENTER)
                        else
                            NebulaFinance:DrawImgur(NebulaFinance:Scale(150), NebulaFinance:Scale(65), NebulaFinance:Scale(64), NebulaFinance:Scale(64), "AhpuFNT", color_white)
                            draw.DrawText(NebulaFinance:GetPhrase("transfailed"), "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(155), color_white, TEXT_ALIGN_CENTER)
                        end
                    end
                end

                hook.Add("NebulaFinance:OnTransactionCompleted", "NebulaFinance:NotifyTransactionComplete", function(transactionTbl)
                    if !IsValid(popupButton) then return end

                    panel.isSuccess = transactionTbl.result

                    if transactionTbl.result then
                        panel:LerpColor("frameColor", ColorAlpha(NebulaFinance:GetTheme("green"), 150))
                        ply:EmitSound("NebulaFinance:Success")
                    else
                        panel:LerpColor("frameColor", ColorAlpha(NebulaFinance:GetTheme("red"), 150))
                        ply:EmitSound("NebulaFinance:Error")
                    end

                    panel.ContactingServers = false


                    timer.Simple(3, function()
                        if !IsValid(popupButton) then return end
                        popupButton.ContactingServers = false

                        popupButton.DoClick()
                    end)
                end)
            end
        end
    end
end

function NebulaFinance:GetAccount()
    return NebulaFinance.MyAccount or {}
end


function NebulaFinance:GetAccountBalance(id)
    if id == 1 then
        return NebulaFinance.MyAccount.Balance
    elseif id == 2 then
        return ply:getDarkRPVar("money")
    elseif id == 3 then
        if GlorifiedBanking then
            GlorifiedBanking.GetPlayerBalance(ply)
        elseif CH_ATM then
            CH_ATM.GetMoneyBankAccount(ply)
        end
    end
end

function NebulaFinance:GetTier()
    return NebulaFinance.MyAccount.Tier
end

function NebulaFinance:IsPremiumUser()
    return NebulaFinance.MyAccount.Tier == "premium"
end

function NebulaFinance:GetLinkedAccounts()
    return NebulaFinance.MyAccount.LinkedAccounts
end

function NebulaFinance:GetTransactions()
    return NebulaFinance.MyAccount.Transactions
end

function NebulaFinance:IntroductionMenu()
    local frame = vgui.Create("EditablePanel")
    frame:MakePopup(true)
    frame:SetSize(0, 0)
    frame.IsAnimating = true

    frame:AnimateSize(NebulaFinance:Scale(550), NebulaFinance:Scale(400), .7, function()
        frame.IsAnimating = true
    end)

    frame.Close = function(self)
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)

        self:AnimateSize(1, 1, .7, function()
            self:Remove()
        end)
    end

    frame.Think = function(self)
        if self.IsAnimating then self:Center() end
    end

    frame.Paint = function(self, w, h)
        ax, ay = self:LocalToScreen()

        BSHADOWS.BeginShadow()
            draw.RoundedBox(5, ax, ay, w, h, NebulaFinance:GetTheme("frame"))
        BSHADOWS.EndShadow(1, 1, 1)
    end

    frame.Navbar = vgui.Create("NebulaFinance:Navbar", frame)
	frame.Navbar:Dock(BOTTOM)
	frame.Navbar:DockMargin(NebulaFinance:Scale(5), 0, NebulaFinance:Scale(5), NebulaFinance:Scale(5))
	frame.Navbar:SetTall(NebulaFinance:Scale(75))
	frame.Navbar.padding = NebulaFinance:Scale(40)
	frame.Navbar:SetBody(frame)
    frame.Navbar:AddTab(NebulaFinance:GetPhrase("introduction"), "V64fZ31", "nebulafinance_tabs_intro")
    frame.Navbar:AddTab(NebulaFinance:GetPhrase("howtouse"), "DTEhyrN", "nebulafinance_tabs_howtouse")
    frame.Navbar:SetActive(NebulaFinance:GetPhrase("introduction"))
    frame.Navbar.Think = function()
        if input.IsKeyDown(KEY_TAB) then  
            frame:Close()
        end
    end
    
    frame.Navbar:AddExit(NebulaFinance:GetPhrase("exit"), "rsPOK1b", function()
        frame:Close()
    end)
end

function NebulaFinance:MainMenu()
    if frame then return end

    local frame = vgui.Create("EditablePanel")
    frame:MakePopup(true)
    frame:SetSize(0, 0)
    frame.IsAnimating = true
    frame:AnimateSize(NebulaFinance:Scale(650), NebulaFinance:Scale(600), .7, function()
        frame.IsAnimating = true
    end)

    frame.Close = function(self)
        self:SetMouseInputEnabled(false)
        self:SetKeyboardInputEnabled(false)

        self:AnimateSize(1, 1, .7, function()
            self:Remove()
        end)
    end

    frame.Think = function(self)
        if self.IsAnimating then self:Center() end
    end

    frame.Paint = function(self, w, h)
        ax, ay = self:LocalToScreen()

        BSHADOWS.BeginShadow()
            draw.RoundedBox(5, ax, ay, w, h, NebulaFinance:GetTheme("frame"))
        BSHADOWS.EndShadow(1, 1, 1)
    end

    frame.Navbar = vgui.Create("NebulaFinance:Navbar", frame)
	frame.Navbar:Dock(BOTTOM)
	frame.Navbar:DockMargin(NebulaFinance:Scale(5), 0, NebulaFinance:Scale(5), NebulaFinance:Scale(5))
	frame.Navbar:SetTall(NebulaFinance:Scale(75))
	frame.Navbar.padding = NebulaFinance:Scale(40)
	frame.Navbar:SetBody(frame)
    frame.Navbar:AddTab(NebulaFinance:GetPhrase("home"), "XCVsFmc", "nebulafinance_tabs_home")
    frame.Navbar:AddTab(NebulaFinance:GetPhrase("accounts"), "3WnvIXM", "nebulafinance_tabs_accounts")
    frame.Navbar:AddTab(NebulaFinance:GetPhrase("settings"), "qC5LHWs", "nebulafinance_tabs_settings")
    frame.Navbar:AddTab(NebulaFinance:GetPhrase("tiers"), "tR48rnV", "nebulafinance_tabs_tiers")
    frame.Navbar:SetActive(NebulaFinance:GetPhrase("home"))
    frame.Navbar.Think = function()
        if input.IsKeyDown(KEY_TAB) then  
            frame:Close()
        end
    end
    
    frame.Navbar:AddExit(NebulaFinance:GetPhrase("exit"), "rsPOK1b", function()
        frame:Close()
    end)
end

function NebulaFinance:Notify(msg)
	if (IsValid(NebulaFinance.CurNotify)) then
		NebulaFinance.CurNotify:Close()
	end
    
    ply:EmitSound("NebulaFinance:Popup")

	local w, h = ScrW(), ScrH()
	local popup = vgui.Create("DButton")
	popup:MoveToFront()
	popup:SetText(msg)
	popup:SetFont("NebulaFinance:Fonts:RegularBold")
	popup:SetTextColor(color_white)
	popup:SetSize(w, NebulaFinance:Scale(55))
	popup:AlignTop(h)

	popup.Paint = function(me, w, h)
		surface.SetDrawColor(NebulaFinance:GetTheme("navigationbtn"))
		surface.DrawRect(0, 0, w, h)
	end

	popup.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:Stop()

		me:MoveTo(0, h, 0.4, 0, -1, function()
			me:Remove()
		end)
	end
	popup.DoClick = popup.Close
	NebulaFinance.CurNotify = popup

	popup:MoveTo(0, h - popup:GetTall(), 0.4, 0, -1, function()
		popup:MoveTo(0, h, 0.4, 3, -1, function()
			popup:Remove()
		end)
	end)
end

concommand.Add("openfinanceintro", function()
    NebulaFinance:IntroductionMenu()
end)

concommand.Add("openfinanceframe", function()
    NebulaFinance:MainMenu()
end)