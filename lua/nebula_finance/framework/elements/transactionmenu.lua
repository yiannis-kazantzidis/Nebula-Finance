local PANEL = {}

function PANEL:Init()
	self.BackgroundAlpha = 0
	self.Opened = true

	self.SubMenu = vgui.Create("DPanel", self)
end

function PANEL:Open(transactionAccount)
	local w, h = self:GetSize()

    self.SubMenu:SetPos(w, 0)
	self.SubMenu:SetSize(w*.7, h)
	self.SubMenu:MoveTo(w*.3, 0, 0.25, 0, 1)

	self.SubMenu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, NebulaFinance:GetTheme("frame"))
    end

    self.SubMenuHeader = vgui.Create("DPanel", self.SubMenu)
    self.SubMenuHeader:Dock(TOP)
    self.SubMenuHeader:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.SubMenuHeader:SetTall(NebulaFinance:Scale(40))

    self.SubMenuHeader.Paint = nil

    self.DeleteTransactions = vgui.Create("DButton", self.SubMenuHeader)
    self.DeleteTransactions:Dock(RIGHT)
    self.DeleteTransactions:SetWide(NebulaFinance:Scale(180))
    self.DeleteTransactions:SetFont("NebulaFinance:Fonts:Medium")
    self.DeleteTransactions:SetTextColor(color_white)
    self.DeleteTransactions:SetText(NebulaFinance:GetPhrase("deletehistory"))
    self.DeleteTransactions.Color = NebulaFinance:GetTheme("insidebox")

    self.DeleteTransactions.Paint = function(self, w, h)
        local nextColor = NebulaFinance:GetTheme("inframe")
        if self:IsHovered() then
            nextColor = ColorAlpha(NebulaFinance:GetTheme("red"))
        end

        self.Color = NebulaFinance:LerpColor(FrameTime() * 3, self.Color, nextColor)

        draw.RoundedBox(5, 0, 0, w, h, self.Color)
    end

    self.DeleteTransactions.DoClick = function()
        net.Start("NebulaFinance:RemoveAllTransactions")
        net.SendToServer()
    end

    self.SearchPanel = vgui.Create("DPanel", self.SubMenuHeader)
    self.SearchPanel:Dock(FILL)
    self.SearchPanel:DockMargin(0, 0, NebulaFinance:Scale(5), 0)
    self.SearchPanel.buttonColor = NebulaFinance:GetTheme("insidebox")

    self.SearchPanel.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
    end

    self.Search = vgui.Create("DTextEntry", self.SearchPanel)
    self.Search:Dock(FILL)
    self.Search:DockMargin(NebulaFinance:Scale(2), NebulaFinance:Scale(2), NebulaFinance:Scale(2), NebulaFinance:Scale(2))
    self.Search:SetFont("NebulaFinance:Fonts:Regular")

    self.Search.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))

        if self:GetValue() == "" then
            draw.DrawText(NebulaFinance:GetPhrase("search"), "NebulaFinance:Fonts:RegularBold", w*.5, -2, ColorAlpha(color_white, 100), TEXT_ALIGN_CENTER)
        end

        self:DrawTextEntryText(color_white, NebulaFinance:GetTheme("blue"), NebulaFinance:GetTheme("text2"))
    end

    self.Search.OnGetFocus = function()
        self.SearchPanel:LerpColor("buttonColor", NebulaFinance:GetTheme("blue"))
    end

    self.Search.OnLoseFocus = function()
        self.SearchPanel:LerpColor("buttonColor", NebulaFinance:GetTheme("insidebox"))
    end

    self.TransactionsPanel = vgui.Create("DPanel", self.SubMenu)
    self.TransactionsPanel:Dock(FILL)
    self.TransactionsPanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(2), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
  
    self.TransactionsPanel.Paint = nil 

    self.TransactionsScroll = vgui.Create("NebulaFinance:Scroll", self.TransactionsPanel)
    self.TransactionsScroll:Dock(FILL)

    function self.Container()
        self.TransactionsScroll:Clear()

        for k, v in pairs(table.Reverse(NebulaFinance:GetTransactions())) do
            if transactionAccount.id != (v.from or v.to) then continue end
            if ((self.Search:GetValue() != "" and not string.find(string.lower(v.transactionType), string.lower(self.Search:GetValue())))) then
                continue
            end

            v.transaction = vgui.Create("DPanel", self.TransactionsScroll)
            v.transaction:Dock(TOP)
            v.transaction:DockMargin(0, NebulaFinance:Scale(2), 0, NebulaFinance:Scale(5))
            v.transaction:SetTall(NebulaFinance:Scale(85))

            v.transaction.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))

                draw.DrawText(v.transactionType, "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(10), NebulaFinance:Scale(5), color_white)
                draw.DrawText(v.receiving and NebulaFinance:GetPhrase("from") or NebulaFinance:GetPhrase("to"), "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(420), NebulaFinance:Scale(5), color_white, TEXT_ALIGN_RIGHT)

                if v.transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) then
                    draw.DrawText(v.receiver, "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(420), NebulaFinance:Scale(45), color_white, TEXT_ALIGN_RIGHT)
                elseif v.transactionType != string.upper(NebulaFinance:GetPhrase("transfer")) then
                    draw.DrawText(NebulaFinance:GetAccounts(ply)[v.to].name, "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(420), NebulaFinance:Scale(45), color_white, TEXT_ALIGN_RIGHT)
                end
                
                draw.DrawText(DarkRP.formatMoney(v.amount), "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(10), NebulaFinance:Scale(45), (v.transactionType == "TRANSFER" and !v.receiving) and NebulaFinance:GetTheme("red") or NebulaFinance:GetTheme("green"))
            end
        end
    end

    hook.Add("NebulaFinance:OnTransactionsRemoved", "NebulaFinance:UpdateTransactions", function()
        if !IsValid(self.SubMenu) then return end

        self.Container()
    end)

    self.Search.OnChange = function()
        self.Container()
    end

    self.Container()
end

function PANEL:Close()
	local w = self:GetWide()
	self.Opened = false

	self.SubMenu:MoveTo(w, 0, 0.25, 0, 1, function()
		self:Remove()
	end)
end

function PANEL:OnMouseReleased()
	self:Close()
end

function PANEL:Paint(w, h)	
	self.BackgroundAlpha = math.Approach(self.BackgroundAlpha, self.Opened and 200 or 0, FrameTime() * 1200)
    NebulaFinance:DrawBlurPanel(self, 6, 6, self.BackgroundAlpha)
end

vgui.Register("NebulaFinance:TransactionMenu", PANEL)