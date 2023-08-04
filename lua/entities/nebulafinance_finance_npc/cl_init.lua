include("shared.lua")

surface.CreateFont("NebulaFinance:Fonts:NPCHeader", {font = "Montserrat SemiBold", size = 160, weight = 500})

local range = 400

function ENT:Initialize()
    hook.Add("PreDrawEffects", self, function(self)
        local ply = LocalPlayer()
        local distance = self:GetPos():Distance(ply:GetPos())
        if distance > range then return end
    
        local ang = Angle( 0, (ply:GetPos() - self:GetPos()):Angle()["yaw"], (ply:GetPos() - self:GetPos()):Angle()["pitch"]) + Angle(0, 90, 90)
    
        local animprog = CurTime() * 3.5

        cam.Start3D2D(self:GetPos() + Vector(0, 0, 80), ang, 0.05)
            draw.DrawText(NebulaFinance:GetPhrase("nebulafinance"), "NebulaFinance:Fonts:NPCHeader", 0, math.sin(animprog + 1) * 15, color_white, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end)
end

function ENT:Draw()
    self:DrawModel()
end