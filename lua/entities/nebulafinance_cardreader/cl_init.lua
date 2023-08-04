
include("shared.lua")

surface.CreateFont("NebulaFinance:ScreenFonts:Key", {font = "Montserrat Medium", size = 100, weight = 500})
surface.CreateFont("NebulaFinance:ScreenFonts:TextBold", {font = "Montserrat SemiBold", size = 100, weight = 500})
surface.CreateFont("NebulaFinance:ScreenFonts:TextRegular", {font = "Montserrat Medium", size = 100, weight = 500})
surface.CreateFont("NebulaFinance:ScreenFonts:TextSmall", {font = "Montserrat Medium", size = 80, weight = 500})

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local scrw, scrh = 575, 1195

function ENT:ChangeScreen(screenid)
    net.Start("NebulaFinance:ChangeScreen")
        net.WriteEntity(self)
        net.WriteUInt(screenid, 7)
    net.SendToServer()
end

function ENT:Think()
    if not self.LocalPlayer then self.LocalPlayer = LocalPlayer() end
    self.IsMerchant = self.LocalPlayer == self:GetMerchant()
end

ENT.TransactionColor = Color(0, 0, 0, 0)

ENT.Screens[1].drawFunction = function(self) -- Amount entry screen
    draw.RoundedBox(0, 0, 0, scrw, 150, NebulaFinance:GetTheme("navigationbtn"))
    draw.DrawText("Current Sale", "NebulaFinance:ScreenFonts:TextBold", scrw*.5, 20, color_white, TEXT_ALIGN_CENTER)

    draw.RoundedBox(0, 0, 270, scrw, 150, NebulaFinance:GetTheme("blue"))
    draw.DrawText(DarkRP.formatMoney(self:GetKeypadContent()), "NebulaFinance:ScreenFonts:TextRegular", scrw*.5, 290, color_white, TEXT_ALIGN_CENTER)


    self:DrawKeypad()
end

ENT.Screens[1].onEnterPressed = function(self) -- Amount entry screen
    net.Start("NebulaFinance:SetupTerminal")
        net.WriteEntity(self)
        net.WriteUInt(self:GetKeypadContent(), 32)
    net.SendToServer()

    self.KeyPadBuffer = ""
end

ENT.Screens[2].drawFunction = function(self) -- confirmation screen
    draw.RoundedBox(0, 0, 0, scrw, 200, NebulaFinance:GetTheme("navigationbtn")) 
    draw.DrawText("Purchase To ", "NebulaFinance:ScreenFonts:TextBold", scrw*.5, 10, color_white, TEXT_ALIGN_CENTER)
    draw.DrawText(self:GetMerchant():GetName(), "NebulaFinance:ScreenFonts:TextBold", scrw*.5, 80, color_white, TEXT_ALIGN_CENTER)

    draw.RoundedBox(0, 0, 220, scrw, 150, NebulaFinance:GetTheme("blue"))
    draw.DrawText(DarkRP.formatMoney(self:GetTransactionAmount()), "NebulaFinance:ScreenFonts:TextRegular", scrw*.5, 240, color_white, TEXT_ALIGN_CENTER)

    NebulaFinance:DrawImgur(30, 440, 512, 512, "RKLYfTn", NebulaFinance:GetTheme("navigationbtn"))
    draw.DrawText("Please Insert Card", "NebulaFinance:ScreenFonts:TextSmall", scrw*.5, 930, color_white, TEXT_ALIGN_CENTER)

    if imgui.IsHovering(0, 1080, scrw, 100) then
        draw.RoundedBox(5, 0, 1080, scrw, 100, ColorAlpha(NebulaFinance:GetTheme("red"), 125))

        if imgui.IsPressed() then
            self:ChangeScreen(1)
            self:EmitSound("NebulaFinance:KeyPress")
        end
    else
        draw.RoundedBox(5, 0, 1080, scrw, 100, NebulaFinance:GetTheme("red"))
    end
    
    draw.DrawText("Cancel Payment", "NebulaFinance:ScreenFonts:TextSmall", scrw*.5, 1082, color_white, TEXT_ALIGN_CENTER)
end

ENT.Screens[3].drawFunction = function(self) -- waiting screen
    self.TransactionColor = NebulaFinance:LerpColor(FrameTime() * 3, self.TransactionColor, NebulaFinance:GetTheme("blue"))
    draw.RoundedBox(0, 0, 0, scrw, scrh, self.TransactionColor) 

    NebulaFinance:DrawProgressWheel(150, 370, 264, 264, color_white)
    draw.DrawText("Please Wait", "NebulaFinance:ScreenFonts:TextRegular", scrw*.5, 670, color_white, TEXT_ALIGN_CENTER)
end

ENT.Screens[4].drawFunction = function(self) -- failedscreen
    self.TransactionColor = NebulaFinance:LerpColor(FrameTime() * 3, self.TransactionColor, NebulaFinance:GetTheme("red"))
    draw.RoundedBox(0, 0, 0, scrw, scrh, self.TransactionColor) 
    NebulaFinance:DrawImgur(150, 370, 264, 264, "AhpuFNT", color_white)
    draw.DrawText("Failed", "NebulaFinance:ScreenFonts:TextRegular", scrw*.5, 670, color_white, TEXT_ALIGN_CENTER)
end

ENT.Screens[5].drawFunction = function(self) -- success screen
    self.TransactionColor = NebulaFinance:LerpColor(FrameTime() * 3, self.TransactionColor, NebulaFinance:GetTheme("green"))
    draw.RoundedBox(0, 0, 0, scrw, scrh, self.TransactionColor) 

    NebulaFinance:DrawImgur(150, 370, 264, 264, "QzdSeYc", color_white)
    draw.DrawText("Approved", "NebulaFinance:ScreenFonts:TextRegular", scrw*.5, 670, color_white, TEXT_ALIGN_CENTER)
end

ENT.KeyPadBuffer = ""
function ENT:PressKey(key)
    if not self.IsMerchant then return end

    self:EmitSound("NebulaFinance:KeyPress")

    if key == "#" then
        self.KeyPadBuffer = ""
        return
    end

    local curScreen = self.Screens[self:GetScreenID()]

    if key == "*" then
        if not curScreen.onEnterPressed then return end
        curScreen.onEnterPressed(self, self:GetKeypadContent())
        return
    end

    if #self.KeyPadBuffer > 8 then return end

    self.KeyPadBuffer = self.KeyPadBuffer .. key
end

--Keypad content getter
function ENT:GetKeypadContent()
    return #self.KeyPadBuffer > 0 and tonumber(self.KeyPadBuffer) or 0
end

local keyx, keyy = 60, 515
local keyw, keyh = 140, 140
local keyspacing = 20
function ENT:DrawKeypad()
    local hovering = false

    for i = 0, 2 do
        for j = 0, 3 do
            local x, y = keyx + (keyw + keyspacing) * i, keyy + (keyh + keyspacing) * j
            local keyNo = j * 3 + i + 1
            local key = (keyNo == 10 and "#") or (keyNo == 11 and "0") or (keyNo == 12 and "*") or tostring(keyNo)

            local keyHovered = imgui.IsHovering(x, y, keyw, keyh)
            hovering = keyHovered or hovering

            if keyHovered and imgui.IsPressed() then
                self:PressKey(key)
            end

            if keyNo < 10 or keyNo == 11 then
                draw.RoundedBox(8, x, y, keyw, keyh, keyHovered and NebulaFinance:GetTheme("blue") or Color(97,97,97))
                draw.RoundedBox(8, x+8, y +8, keyw *.9, keyh *.9, NebulaFinance:GetTheme("insidebox"))
                draw.DrawText(key, "NebulaFinance:ScreenFonts:Key", x + keyw / 2, y + keyh * .12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                continue
            end

            local iconsize = keyw * .5
            local iconoff = (keyw - iconsize) / 2

            if keyNo == 10 then
                draw.RoundedBox(8, x, y, keyw, keyh, keyHovered and NebulaFinance:GetTheme("red") or Color(97,97,97))
                draw.RoundedBox(8, x+8, y +8, keyw *.9, keyh *.9, NebulaFinance:GetTheme("insidebox"))
                NebulaFinance:DrawImgur(x + iconoff, y + iconoff, iconsize, iconsize, "p2mL8md", color_white)
                continue
            end

            draw.RoundedBox(8, x, y, keyw, keyh, keyHovered and NebulaFinance:GetTheme("green") or Color(97,97,97))
            draw.RoundedBox(8, x+8, y +8, keyw *.9, keyh *.9, NebulaFinance:GetTheme("insidebox"))
            NebulaFinance:DrawImgur(x + iconoff, y + iconoff, iconsize, iconsize, "d9rbPHR", color_white)

        end
    end

    return hovering
end

function ENT:DrawScreenBackground()
    draw.RoundedBox(5, 0, 0, scrw, scrh, NebulaFinance:GetTheme("insidebox"))
end

local screenpos = Vector(-3.5, 7.1, 6.65)
local screenang = Angle(0, 0, 19.55)
function ENT:DrawScreen()
    if imgui.Entity3D2D(self, screenpos, screenang, 0.01215, 150, 120) then
        local screenID = self:GetScreenID()
        local currentScreen = self.Screens[screenID]

        self:DrawScreenBackground()
        currentScreen.drawFunction(self)

        imgui.End3D2D()
    end
end


function ENT:DrawTranslucent()
    self:DrawModel()
    self:DrawScreen()
end