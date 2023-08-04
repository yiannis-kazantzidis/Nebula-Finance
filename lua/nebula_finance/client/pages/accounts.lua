local PANEL = {}

local ply = LocalPlayer()

function PANEL:Init()
    self.pnl = vgui.Create("NebulaFinance:Scroll", self)
    self.pnl:Dock(FILL)

    self.pnl.Paint = nil
    self:FillPanel()
end

function PANEL:FillPanel()
    function self.Container()
        for k, v in pairs(NebulaFinance:GetAccounts()) do
            if !NebulaFinance:GetLinkedAccounts()[k] then continue end
            
            v.account = vgui.Create("DButton", self.pnl)
            v.account:Dock(TOP)
            v.account:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
            v.account:SetTall(NebulaFinance:Scale(100))
            v.account:SetText("")
            v.account.buttonColor = ColorAlpha(NebulaFinance:GetTheme("inframe"), 80)
        
            v.account.OnCursorEntered = function(pnl)
                pnl:LerpColor("buttonColor", ColorAlpha(v.color, 50))
            end
    
            v.account.OnCursorExited = function(pnl)    
                pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("inframe"), 80))
            end

            v.account.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
                
                NebulaFinance:DrawImgur(NebulaFinance:Scale(560), NebulaFinance:Scale(20), NebulaFinance:Scale(62), NebulaFinance:Scale(62), "1Utw3EE", color_white)

                NebulaFinance:DrawImgur(NebulaFinance:Scale(10), NebulaFinance:Scale(10), NebulaFinance:Scale(32), NebulaFinance:Scale(32), "AiTkLvQ", v.color)
                draw.DrawText(v.name, "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(55), NebulaFinance:Scale(6), color_white)
                NebulaFinance:DrawImgur(NebulaFinance:Scale(10), NebulaFinance:Scale(60), NebulaFinance:Scale(32), NebulaFinance:Scale(32), "zyyeBq4", color_white)

                draw.DrawText(DarkRP.formatMoney(NebulaFinance:GetIntegrationTbl(v.id):GETBALANCE(ply)), "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(55), NebulaFinance:Scale(59), NebulaFinance:GetTheme("green"))
            end

            v.account.DoClick = function()
                v.transactionPnl = vgui.Create("NebulaFinance:TransactionMenu", self)
                v.transactionPnl:SetSize(self:GetWide(), self:GetTall())
                v.transactionPnl:Open(v)
            end
        end
    end

    self.Container()
end

function PANEL:Paint(w, h)
    draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("nebulafinance_tabs_accounts", PANEL, "DPanel")