local PANEL = {}

local ply = LocalPlayer()

local actionButtons = {
    {name = NebulaFinance:GetPhrase("withdraw"), playerSelection = false, imgurID = "JnUwCKd", OnConfirm = function(amount, destinationTbl) 
        net.Start("NebulaFinance:Withdraw")
            net.WriteDouble(amount)
            net.WriteUInt(destinationTbl.from.id, 3)
            net.WriteUInt(destinationTbl.to.id, 3)
        net.SendToServer()
    end},
    {name = NebulaFinance:GetPhrase("transfer"), playerSelection = true, imgurID = "JnUwCKd", OnConfirm = function(amount, destinationTbl, receiver) 
        net.Start("NebulaFinance:Transfer")
            net.WriteDouble(amount)
            net.WriteUInt(destinationTbl.from.id, 3)
            net.WriteEntity(receiver)
        net.SendToServer()
    end},
    {name = NebulaFinance:GetPhrase("deposit"), playerSelection = false, imgurID = "JnUwCKd", OnConfirm = function(amount,  destinationTbl)
        net.Start("NebulaFinance:Deposit")
            net.WriteDouble(amount)
            net.WriteUInt(destinationTbl.from.id, 3)
            net.WriteUInt(destinationTbl.to.id, 3)
        net.SendToServer()
    end}
}

function PANEL:Init()
    self.pnl = vgui.Create("DPanel", self)
    self.pnl:Dock(FILL)

    self.pnl.Paint = nil
    self:FillPanel()
end

function PANEL:FillPanel()
    self.WelcomePanel = vgui.Create("DPanel", self.pnl)
    self.WelcomePanel:Dock(TOP)
    self.WelcomePanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.WelcomePanel:SetTall(NebulaFinance:Scale(265))
    local balance = 0

    self.WelcomePanel.Paint = function(self, w, h)
        balance = Lerp(0.025, balance, NebulaFinance:GetBalance() or 0)
        draw.DrawText(string.format(NebulaFinance:GetPhrase("welcome"), ply:GetName()), "NebulaFinance:Fonts:Large", w*.5, 0, ColorAlpha(color_white, 125), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        NebulaFinance:DrawImgur(w*.42, NebulaFinance:Scale(65), NebulaFinance:Scale(102), NebulaFinance:Scale(102), "67DQsrH", color_white)
        draw.DrawText(DarkRP.formatMoney(math.Round(balance)), "NebulaFinance:Fonts:Large", w*.5, NebulaFinance:Scale(175), NebulaFinance:GetBalance() > 0 and NebulaFinance:GetTheme("green") or NebulaFinance:GetTheme("red"), TEXT_ALIGN_CENTER)
        draw.DrawText(NebulaFinance:GetPhrase("available"), "NebulaFinance:Fonts:Medium", w*.5, NebulaFinance:Scale(235), ColorAlpha(color_white, 100), TEXT_ALIGN_CENTER)
    end

    self.buttonsPanel = vgui.Create("DPanel", self.pnl)
    self.buttonsPanel:Dock(TOP)
    self.buttonsPanel:DockMargin(NebulaFinance:Scale(50), NebulaFinance:Scale(0), NebulaFinance:Scale(50), NebulaFinance:Scale(0))
    self.buttonsPanel:SetTall(NebulaFinance:Scale(60))

    self.buttonsPanel.Paint = nil

    for k, v in pairs(actionButtons) do
        v.actionButton = vgui.Create("DButton", self.buttonsPanel)
        v.actionButton:Dock(RIGHT)
        v.actionButton:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
        v.actionButton:SetWide(NebulaFinance:Scale(170))
        v.actionButton:SetText("")
        v.actionButton.buttonColor = ColorAlpha(NebulaFinance:GetTheme("inframe"), 100)
        v.actionButton.textColor = ColorAlpha(color_white, 100)
        
        v.actionButton.OnCursorEntered = function(pnl)
            pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("navigationbtn"), 25))
            pnl:LerpColor("textColor", NebulaFinance:GetTheme("navigationbtn"))
        end

        v.actionButton.OnCursorExited = function(pnl)    
            pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("inframe"), 100))
            pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
        end

        v.actionButton.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
            draw.DrawText(v.name, "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(7), self.textColor, TEXT_ALIGN_CENTER)
        end

        v.actionButton.DoClick = function()
            NebulaFinance:AmountEntryBox(v.name, v.playerSelection, self, function(amountRequested, destinationTbl, playerRequested)
                v.OnConfirm(amountRequested, destinationTbl, playerRequested)
            end)
        end
    end

    self.line = vgui.Create("DPanel", self.pnl)
    self.line:Dock(TOP)
    self.line:DockMargin(NebulaFinance:Scale(15), NebulaFinance:Scale(10), NebulaFinance:Scale(15), NebulaFinance:Scale(10))
    self.line:SetTall(2)

    self.line.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("navigationbtn"))
    end

    self.accountsPanel = vgui.Create("DPanel", self.pnl)
    self.accountsPanel:Dock(FILL)
    self.accountsPanel:DockMargin(NebulaFinance:Scale(10), NebulaFinance:Scale(10), NebulaFinance:Scale(0), NebulaFinance:Scale(5))

    self.accountsPanel.Paint = nil 

    self.accountsScroll = vgui.Create("NebulaFinance:Scroll", self.accountsPanel)
    self.accountsScroll:Dock(FILL)

    self.accountsLayout = vgui.Create("DIconLayout", self.accountsScroll)
    self.accountsLayout:Dock(FILL)
    self.accountsLayout:SetSpaceY(5)
    self.accountsLayout:SetSpaceX(5)

    for k, v in pairs(NebulaFinance:GetLinkedAccounts()) do
        if !NebulaFinance:GetLinkedAccounts()[k] then continue end

        v.account = vgui.Create("DButton", self.accountsLayout)
        v.account:SetText("")
        v.account:SetSize(NebulaFinance:Scale(151.7), NebulaFinance:Scale(128))
        v.account.buttonColor = v.color
        
        v.account.OnCursorEntered = function(pnl)
            pnl:LerpColor("buttonColor", ColorAlpha(v.color, 150))
        end

        v.account.OnCursorExited = function(pnl)    
            pnl:LerpColor("buttonColor", v.color)
        end

        v.account.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
            NebulaFinance:DrawImgur(NebulaFinance:Scale(10), NebulaFinance:Scale(15), NebulaFinance:Scale(26), NebulaFinance:Scale(26), "AiTkLvQ", color_white)
            draw.DrawText(v.name, "NebulaFinance:Fonts:Medium", NebulaFinance:Scale(5), NebulaFinance:Scale(52), color_white)
            draw.DrawText(NebulaFinance:FormatValue(NebulaFinance:GetIntegrationTbl(v.id):GETBALANCE(ply)), "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(5), NebulaFinance:Scale(80), color_white)
        end

        v.account.DoClick = function()
            v.transactionPnl = vgui.Create("NebulaFinance:TransactionMenu", self)
            v.transactionPnl:SetSize(self:GetWide(), self:GetTall())
            v.transactionPnl:Open(v)
        end
    end

end

function PANEL:Paint(w, h)
    draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("nebulafinance_tabs_home", PANEL, "DPanel")