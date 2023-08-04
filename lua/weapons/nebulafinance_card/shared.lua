if SERVER then
    AddCSLuaFile("shared.lua")
end

if CLIENT then
    SWEP.PrintName = "Nebula Finance Card"
    SWEP.Slot = 2
    SWEP.SlotPos = 4
    SWEP.DrawAmmo = false
end

SWEP.Author         = "tenwriter"
SWEP.Instructions   = "Left click on card reader to insert, right click to open finance menu"
SWEP.Category 		= "tenwriter scripts"

SWEP.ViewModelFOV   = 75
SWEP.ViewModelFlip  = false
SWEP.UseHands		= true
SWEP.AnimPrefix  	= "pistol"

SWEP.Spawnable      	= true
SWEP.AdminSpawnable     = true

SWEP.ViewModel = "models/credit_card/card_swep.mdl"
SWEP.WorldModel = "models/credit_card/card_world.mdl"

SWEP.Primary.ClipSize     	= -1
SWEP.Primary.DefaultClip   	= 0
SWEP.Primary.Automatic    	= false
SWEP.Primary.Ammo 			= ""

SWEP.Secondary.ClipSize  	= -1
SWEP.Secondary.DefaultClip  = 0
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = ""

if SERVER then return end

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

function SWEP:Deploy()
    self:SetHoldType("pistol")
end

local function InsertCard(ent)
    net.Start("NebulaFinance:InsertCard")
        net.WriteEntity(ent)
    net.SendToServer()
end

function SWEP:PrimaryAttack()
    if !IsFirstTimePredicted() then return end

    local ply = self:GetOwner()

    local tr = ply:GetEyeTraceNoCursor()
    if not tr.Hit then return end

    InsertCard(tr.Entity)
end

function SWEP:SecondaryAttack()
    if !IsFirstTimePredicted() then return end

    if NebulaFinance.Configuration.GetConvar("openfinancemenu") != ("All of them" or "Nebula Finance Card") then return end

    RunConsoleCommand("openfinanceframe")
end
