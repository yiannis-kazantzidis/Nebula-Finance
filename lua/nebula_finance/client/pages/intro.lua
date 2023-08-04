local PANEL = {}

local ply = LocalPlayer()

function PANEL:Init()
    self:FillPanel()

end

function PANEL:FillPanel()
    self.IntroPanel = vgui.Create("DPanel", self)
    self.IntroPanel:Dock(FILL)
    self.IntroPanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))

    self.IntroPanel.Paint = nil 

    self.IntroScroll = vgui.Create("NebulaFinance:Scroll", self.IntroPanel)
    self.IntroScroll:Dock(FILL)

    self.IntroInfo = vgui.Create("DPanel", self.IntroScroll)
    self.IntroInfo:Dock(TOP)
    self.IntroInfo:SetTall(select(2, surface.GetTextSize(NebulaFinance:GetPhrase("introductiondesc"))) * 5.2)

    self.IntroInfo.Paint = function(self, w, h)
        local msg = DarkRP.textWrap(NebulaFinance:GetPhrase("introductiondesc"), "NebulaFinance:Fonts:Regular", w*.95)

        draw.DrawText(msg, "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(5), color_white, TEXT_ALIGN_CENTER)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("nebulafinance_tabs_intro", PANEL, "DPanel")