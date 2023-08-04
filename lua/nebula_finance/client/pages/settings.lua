local PANEL = {}

local ply = LocalPlayer()

local SettingsEnums_BOOL = 1
local SettingsEnums_TABLE = 2

local settings = {
    {name = NebulaFinance:GetPhrase("notifications"), desc = NebulaFinance:GetPhrase("notificationsdesc"), settingType = SettingsEnums_BOOL},
    {name = NebulaFinance:GetPhrase("receivemoney"), desc = NebulaFinance:GetPhrase("receivemoneydesc"), settingType = SettingsEnums_BOOL},
    {name = NebulaFinance:GetPhrase("paymentaccount"), desc = NebulaFinance:GetPhrase("paymentaccountdesc"), settingType = SettingsEnums_TABLE},
    {name = NebulaFinance:GetPhrase("receiveaccount"), desc = NebulaFinance:GetPhrase("receiveaccountdesc"), settingType = SettingsEnums_TABLE},
    {name = NebulaFinance:GetPhrase("cryptoaccount"), desc = NebulaFinance:GetPhrase("cryptoaccountdesc"), settingType = SettingsEnums_TABLE}
}

if !CH_CryptoCurrencies then table.remove(settings, 5) end

function PANEL:Init()
    self:FillPanel()
end

function PANEL:FillPanel()
    for k, v in ipairs(settings) do
        v.Setting = vgui.Create("DPanel", self)
        v.Setting:Dock(TOP)
        v.Setting:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), 0)
        v.Setting:SetTall(NebulaFinance:Scale(85))

        v.Setting.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("inframe"))
        end

        v.Setting.Info = vgui.Create("DPanel", v.Setting)
        v.Setting.Info:Dock(LEFT)
        v.Setting.Info:SetWide(NebulaFinance:Scale(450))

        v.Setting.Info.Paint = function(self, w, h)
            local desc = DarkRP.textWrap(v.desc, "NebulaFinance:Fonts:Medium", w*.9)

            draw.DrawText(v.name, "NebulaFinance:Fonts:RegularBold", NebulaFinance:Scale(8), 0, color_white)
            draw.DrawText(desc, "NebulaFinance:Fonts:Medium", NebulaFinance:Scale(8), NebulaFinance:Scale(30), color_white)
        end

        v.actionPanel = vgui.Create("DPanel", v.Setting)
        v.actionPanel:Dock(FILL)

        v.actionPanel.Paint = nil 

        if v.settingType == SettingsEnums_BOOL then
            v.actionButton = vgui.Create("NebulaFinance:Checkbox", v.actionPanel)
            v.actionButton:Dock(FILL)
            v.actionButton:DockMargin(NebulaFinance:Scale(45), NebulaFinance:Scale(30), NebulaFinance:Scale(45), NebulaFinance:Scale(30))
            if k == 1 then
                v.actionButton:SetValue(NebulaFinance:GetSettings(ply).notifications)
            elseif k == 2 then
                v.actionButton:SetValue(NebulaFinance:GetSettings(ply).receiveMoney)
            end
        else
            v.actionButton = vgui.Create("NebulaFinance:DcomboBox_v2", v.actionPanel)
            v.actionButton:Dock(FILL)
            v.actionButton:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(25), NebulaFinance:Scale(10), NebulaFinance:Scale(25))
            v.actionButton:SetFont("NebulaFinance:Fonts:MediumBold")

            v.actionButton.Paint = function(self, w, h)
                draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
            end

            if k == 5 then
                v.data = NebulaFinance:GetSettings(ply).cryptoChoice
                v.actionButton:SetValue(CH_CryptoCurrencies.CryptosCL[NebulaFinance:GetSettings(ply).cryptoChoice].Name)
        
                for index, crypto in ipairs(CH_CryptoCurrencies.CryptosCL) do
                    v.actionButton:AddChoice(crypto.Name, index)
                end
            elseif k == 3 then
                v.data = NebulaFinance:GetSettings(ply).paymentAccount
                v.actionButton:SetValue(NebulaFinance:GetAccounts(ply)[NebulaFinance:GetSettings(ply).paymentAccount].name)
        
                for index, account in ipairs(NebulaFinance:GetAccounts(ply)) do
                    v.actionButton:AddChoice(account.name, index)
                end

            elseif k == 4 then
                v.data = NebulaFinance:GetSettings(ply).receiveAccount
                v.actionButton:SetValue(NebulaFinance:GetAccounts(ply)[NebulaFinance:GetSettings(ply).receiveAccount].name)
        
                for index, account in ipairs(NebulaFinance:GetAccounts(ply)) do
                    v.actionButton:AddChoice(account.name, index)
                end
            end

            v.actionButton.OnSelect = function(self2, index, value, data)
                v.data = data
            end
        end
    
    end

    self.SaveChanges = vgui.Create("DButton", self)
    self.SaveChanges:Dock(BOTTOM)
    self.SaveChanges:SetTall(NebulaFinance:Scale(50))
    self.SaveChanges:DockMargin(NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5), NebulaFinance:Scale(5))
    self.SaveChanges:SetText("")
    self.SaveChanges.buttonColor = ColorAlpha(NebulaFinance:GetTheme("inframe"), 100)
    self.SaveChanges.textColor = ColorAlpha(color_white, 100)
    
    self.SaveChanges.OnCursorEntered = function(pnl)
        pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("green"), 25))
        pnl:LerpColor("textColor", NebulaFinance:GetTheme("green"))
    end

    self.SaveChanges.OnCursorExited = function(pnl)    
        pnl:LerpColor("buttonColor", ColorAlpha(NebulaFinance:GetTheme("inframe"), 100))
        pnl:LerpColor("textColor", ColorAlpha(color_white, 100))
    end

    self.SaveChanges.Paint = function(self, w, h)
        draw.RoundedBox(5, 0, 0, w, h, self.buttonColor)
        draw.DrawText(NebulaFinance:GetPhrase("savechanges"), "NebulaFinance:Fonts:RegularBold", w*.5, h*.12, self.textColor, TEXT_ALIGN_CENTER)
    end

    self.SaveChanges.DoClick = function()
        net.Start("NebulaFinance:UpdateSettings")
            net.WriteBool(settings[1].actionButton:GetValue())
            net.WriteBool(settings[2].actionButton:GetValue())
            net.WriteUInt(settings[3].data, 3)
            net.WriteUInt(settings[4].data, 3)

            if CH_CryptoCurrencies then
                net.WriteUInt(settings[5].data, 6)
            end
        net.SendToServer()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(5, 0, 0, w, h, NebulaFinance:GetTheme("insidebox"))
end

vgui.Register("nebulafinance_tabs_settings", PANEL, "DPanel")