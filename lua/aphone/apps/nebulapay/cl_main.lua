local APP = {}
APP.name = "Pay"
APP.color = Color(237, 76, 103)
APP.icon = "materials/nebulafinance_mats/nebulapaylogo.png"

local lua_grad = Material("akulla/aphone/lua_grad1.png")
local noCol = Color(0, 0, 0, 0)

function APP:Open(main, main_x, main_y)
    local ply = LocalPlayer()
    local bgColor = NebulaFinance:GetTheme("navigationbtn")

    net.Start("NebulaFinance:UpdateNebulaPayStatus")
    net.SendToServer()

    ply.nebulapay_status = true

    local logo = vgui.Create("DPanel", main)
    logo:Dock(TOP)
    logo:SetTall(main_x / 1.75)
    logo:DockMargin(0, main_y * 0.08, 0, main_y * 0.04)
    local curIcon
    local curText = NebulaFinance:GetPhrase("holdreader")

    timer.Create("APhone:ScanNebulaPay", 2, 0, function()
        if !ply.nebulapay_status then return end

        local tr = ply:GetEyeTraceNoCursor()
        if not tr.Hit then return end
        local ent = tr.Entity
        if ent:GetClass() != "nebulafinance_cardreader" then return end
        if ent:GetScreenID() != 2 then return end

        net.Start("NebulaFinance:NebulaPay")
            net.WriteEntity(ent)
        net.SendToServer()
    end)

    local result

    net.Receive("NebulaFinance:NebulaPayStarted", function()
        curText = NebulaFinance:GetPhrase("processing")
    end)

    net.Receive("NebulaFinance:NebulaPayFinished", function()
        if !IsValid(main) then return end

        result = net.ReadBool()

        curIcon = result and "QzdSeYc" or "AhpuFNT"
        curText = result and NebulaFinance:GetPhrase("transapproved") or NebulaFinance:GetPhrase("transfailed")

        timer.Simple(3, function()
            curIcon = nil
            curText = NebulaFinance:GetPhrase("holdreader")
        end)
    end)

    function logo:Paint(w, h)
        NebulaFinance:DrawImgur(w *.2, 0, w*.6, h, "zz1m4vx", color_white)
    end

    local info = vgui.Create("DPanel", main)
    info:Dock(TOP)
    info:SetTall(main_x / 1.75)
    info:DockMargin(0, main_y * 0.06, 0, main_y * 0.04)

    function info:Paint(w, h)
        if !curIcon then
            bgColor = NebulaFinance:LerpColor(FrameTime() * 3, bgColor, NebulaFinance:GetTheme("navigationbtn"))
            NebulaFinance:DrawProgressWheel(w *.19, h*.1, w*.6, h*.6, color_white)
        else
            bgColor = NebulaFinance:LerpColor(FrameTime() * 3, bgColor, result and NebulaFinance:GetTheme("green") or NebulaFinance:GetTheme("red"))
            NebulaFinance:DrawImgur(w *.32, h*.1, w*.33, h*.6, curIcon, color_white)
        end

        draw.DrawText(curText, "NebulaFinance:Fonts:RegularBold", w*.5, h*.8, color_white, TEXT_ALIGN_CENTER)
    end

    function main:Paint(w, h)
        surface.SetDrawColor(bgColor)
        surface.DrawRect(0, 0, w, h)

        draw.DrawText(NebulaFinance:GetPhrase("poweredby"), "NebulaFinance:Fonts:Medium", w*.5, h*.92, color_white, TEXT_ALIGN_CENTER)
    end

    main:aphone_RemoveCursor()
end

function APP:OnClose()
    local ply = LocalPlayer()

    net.Start("NebulaFinance:UpdateNebulaPayStatus")
    net.SendToServer()

    ply.nebulapay_status = false
end
 
aphone.RegisterApp(APP)