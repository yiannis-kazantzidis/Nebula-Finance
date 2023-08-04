local PANEL = {}

local ply = LocalPlayer()

local regularFeatures = {
    {title = NebulaFinance:GetPhrase("sendreceivep"), onfeature = true},
    {title = NebulaFinance:GetPhrase("nebulapay"), onfeature = true},
    {title = NebulaFinance:GetPhrase("nofees"), onfeature = false},
    {title = NebulaFinance:GetPhrase("free"), onfeature = true},
    {title = string.format(NebulaFinance:GetPhrase("cashback"), NebulaFinance.Configuration.GetConvar("cashbackamount"), "%"), onfeature = false},
    {title = NebulaFinance:GetPhrase("smartpay"), onfeature = false}
}

local premiumFeatures = {
    {title = NebulaFinance:GetPhrase("sendreceivep"), onfeature = true},
    {title = NebulaFinance:GetPhrase("nebulapay"), onfeature = true},
    {title = NebulaFinance:GetPhrase("nofees"), onfeature = true},
    {title = NebulaFinance:GetPhrase("free"), onfeature = false},
    {title = string.format(NebulaFinance:GetPhrase("cashback"), NebulaFinance.Configuration.GetConvar("cashbackamount"), "%"), onfeature = true},
    {title = NebulaFinance:GetPhrase("smartpay"), onfeature = true}
}

function PANEL:Init()
    self:FillPanel()

end

function PANEL:FillPanel()
    self.RegularPanel = vgui.Create("DPanel", self)
    self.RegularPanel:Dock(LEFT)
    self.RegularPanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.RegularPanel:SetWide(NebulaFinance:Scale(312))

    self.RegularPanel.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))
    end

    self.RegularPanelInfo = vgui.Create("DPanel", self.RegularPanel)
    self.RegularPanelInfo:Dock(TOP)
    self.RegularPanelInfo:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.RegularPanelInfo:SetTall(NebulaFinance:Scale(375))

    self.RegularPanelInfo.Paint = function(self, w, h)
        draw.DrawText(NebulaFinance:GetPhrase("nebulafinance"), "NebulaFinance:Fonts:RegularBold", w*.5, 0, color_white, TEXT_ALIGN_CENTER)

        draw.DrawText(NebulaFinance:GetPhrase("regular"), "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(30), color_white, TEXT_ALIGN_CENTER)
    end

    self.FeaturePanel = vgui.Create("DPanel", self.RegularPanelInfo)
    self.FeaturePanel:Dock(FILL)
    self.FeaturePanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(75), NebulaFinance:Scale(5), NebulaFinance:Scale(5))

    self.FeaturePanel.Paint = nil 

    self.RegularPurchase = vgui.Create("DButton", self.RegularPanel)
    self.RegularPurchase:Dock(BOTTOM)
    self.RegularPurchase:SetTall(NebulaFinance:Scale(95))
    self.RegularPurchase:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.RegularPurchase:SetText("")
    self.RegularPurchase:SetCursor("arrow")
    self.RegularPurchase.buttonColor = NebulaFinance:GetTheme("insidebox")
    self.RegularPurchase.textColor = ColorAlpha(color_white, 100)
        
    self.RegularPurchase.OnCursorEntered = function(pnl)
        pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("red"), 150))
        pnl:LerpColor("textColor", NebulaFinance:GetTheme("red"))
    end

    self.RegularPurchase.OnCursorExited = function(pnl)    
        pnl:LerpColor("buttonColor", NebulaFinance:GetTheme("insidebox"))
        pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
    end

    self.RegularPurchase.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
        draw.DrawText(NebulaFinance:GetPhrase("alreadyowned"), "NebulaFinance:Fonts:RegularBold", w*.5, NebulaFinance:Scale(30), self.textColor, TEXT_ALIGN_CENTER)
    end

    for k, v in pairs(regularFeatures) do
        self.RegularPanelFeatures = vgui.Create("DLabel", self.FeaturePanel)
        self.RegularPanelFeatures:Dock(TOP)
        self.RegularPanelFeatures:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
        self.RegularPanelFeatures:SetTall(select( 2, surface.GetTextSize(v.title) ))
        self.RegularPanelFeatures:SetWrap(true)
        self.RegularPanelFeatures:SetFont("NebulaFinance:Fonts:Medium")
        self.RegularPanelFeatures:SetTextColor(v.onfeature and NebulaFinance:GetTheme("green") or NebulaFinance:GetTheme("red"))
        self.RegularPanelFeatures:SetText(v.title)
    end
    
    self.PremiumPanel = vgui.Create("DPanel", self)
    self.PremiumPanel:Dock(RIGHT)
    self.PremiumPanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.PremiumPanel:SetWide(NebulaFinance:Scale(312))

    self.PremiumPanel.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))
    end

    self.PremiumPanelInfo = vgui.Create("DPanel", self.PremiumPanel)
    self.PremiumPanelInfo:Dock(TOP)
    self.PremiumPanelInfo:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.PremiumPanelInfo:SetTall(NebulaFinance:Scale(375))

    self.PremiumPanelInfo.Paint = function(self, w, h)
        draw.DrawText(NebulaFinance:GetPhrase("nebulafinance"), "NebulaFinance:Fonts:RegularBold", w*.5, 0, color_white, TEXT_ALIGN_CENTER)

        draw.DrawText(NebulaFinance:GetPhrase("premium"), "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(30), color_white, TEXT_ALIGN_CENTER)
    end

    self.PremiumFeaturePanel = vgui.Create("DPanel", self.PremiumPanelInfo)
    self.PremiumFeaturePanel:Dock(FILL)
    self.PremiumFeaturePanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(75), NebulaFinance:Scale(5), NebulaFinance:Scale(5))

    self.PremiumFeaturePanel.Paint = nil 

    for k, v in pairs(premiumFeatures) do
        self.PremiumPanelFeatures = vgui.Create("DLabel", self.PremiumFeaturePanel)
        self.PremiumPanelFeatures:Dock(TOP)
        self.PremiumPanelFeatures:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
        self.PremiumPanelFeatures:SetTall(select( 2, surface.GetTextSize(v.title) ))
        self.PremiumPanelFeatures:SetWrap(true)
        self.PremiumPanelFeatures:SetFont("NebulaFinance:Fonts:Medium")
        self.PremiumPanelFeatures:SetTextColor(v.onfeature and NebulaFinance:GetTheme("green") or NebulaFinance:GetTheme("red"))
        self.PremiumPanelFeatures:SetText(v.title)
    end

    self.PremiumPurchase = vgui.Create("DButton", self.PremiumPanel)
    self.PremiumPurchase:Dock(BOTTOM)
    self.PremiumPurchase:SetTall(NebulaFinance:Scale(95))
    self.PremiumPurchase:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.PremiumPurchase:SetText("")
    self.PremiumPurchase.buttonColor = NebulaFinance:GetTheme("insidebox")
    self.PremiumPurchase.hoverColor = NebulaFinance:IsPremiumUser(ply) and NebulaFinance:GetTheme("red") or NebulaFinance:GetTheme("green")
    self.PremiumPurchase.textColor = ColorAlpha(color_white, 100)

    self.PremiumPurchase.OnCursorEntered = function(pnl)
        pnl:LerpColor("buttonColor", ColorAlpha(pnl.hoverColor, 150))
        pnl:LerpColor("textColor", pnl.hoverColor)
    end

    self.PremiumPurchase.OnCursorExited = function(pnl)    
        pnl:LerpColor("buttonColor", NebulaFinance:GetTheme("insidebox"))
        pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
    end

    self.PremiumPurchase.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
        if NebulaFinance:IsPremiumUser(ply) then
            draw.DrawText(NebulaFinance:GetPhrase("canelsubscribtion"), "NebulaFinance:Fonts:RegularBold", w*.5, NebulaFinance:Scale(30), self.textColor, TEXT_ALIGN_CENTER)
        else
            draw.DrawText(NebulaFinance:GetPhrase("subscribe"), "NebulaFinance:Fonts:RegularBold", w*.5, NebulaFinance:Scale(10), self.textColor, TEXT_ALIGN_CENTER)
            draw.DrawText(DarkRP.formatMoney(NebulaFinance.Configuration.GetConvar("premiumprice")).."/hr", "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(50), self.textColor, TEXT_ALIGN_CENTER)
        end
    end

    self.PremiumPurchase.DoClick = function(self, w, h)
        if NebulaFinance:IsPremiumUser(ply) then
            net.Start("NebulaFinance:DowngradeTier")
            net.SendToServer()
        else
            net.Start("NebulaFinance:UpgradeTier")
            net.SendToServer()
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("nebulafinance_tabs_tiers", PANEL, "DPanel")