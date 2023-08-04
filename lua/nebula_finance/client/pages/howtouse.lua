local PANEL = {}

local ply = LocalPlayer()

function PANEL:Init()
    self:FillPanel()

end

function PANEL:FillPanel()
    self.UsePanel = vgui.Create("DPanel", self)
    self.UsePanel:Dock(FILL)
    self.UsePanel:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))

    self.UsePanel.Paint = nil 

    self.UseScroll = vgui.Create("NebulaFinance:Scroll", self.UsePanel)
    self.UseScroll:Dock(FILL)

    self.UseInfo = vgui.Create("DPanel", self.UseScroll)
    self.UseInfo:Dock(TOP)
    self.UseInfo:SetTall(select(2, surface.GetTextSize(NebulaFinance:GetPhrase("howtousedesc"))) * 5.4)

    self.UseInfo.Paint = function(self, w, h)
        local msg = DarkRP.textWrap(string.format(NebulaFinance:GetPhrase("howtousedesc"), NebulaFinance.Configuration.GetConvar("chatcommand")), "NebulaFinance:Fonts:Regular", w*.98)

        draw.DrawText(msg, "NebulaFinance:Fonts:Regular", w*.5, NebulaFinance:Scale(5), color_white, TEXT_ALIGN_CENTER)
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("nebulafinance_tabs_howtouse", PANEL, "DPanel")