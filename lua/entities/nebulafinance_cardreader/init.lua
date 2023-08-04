
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("NebulaFinance:InsertCard")
util.AddNetworkString("NebulaFinance:SetupTerminal")
util.AddNetworkString("NebulaFinance:ChangeScreen")
util.AddNetworkString("NebulaFinance:CancelPayment")
util.AddNetworkString("NebulaFinance:NebulaPay")

function NebulaFinance:CardDistanceChecks(ply, ent)
    return ent:GetPos():DistToSqr(ply:GetPos()) <= 4500
end

function ENT:Initialize()
    self:SetModel("models/credit_card/card_reader.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetModelScale(self:GetModelScale() * 1.25, .01)
    self:PhysWake()
end

net.Receive("NebulaFinance:CancelPayment", function(len, ply)
    local ent = net.ReadEntity()

    if ent.CardInside then return end
    if !NebulaFinance:CardDistanceChecks(ply, ent) then return end

    ent:SetScreenID(1)
end)

net.Receive("NebulaFinance:ChangeScreen", function(len, ply)
    local ent = net.ReadEntity()

    if !ent:IsMerchant(ply) then return end
    if !NebulaFinance:CardDistanceChecks(ply, ent) then return end

    ent:SetScreenID(net.ReadUInt(3))
end)

net.Receive("NebulaFinance:SetupTerminal", function(len, ply)
    local ent = net.ReadEntity()

    if ent.CardInside then return end
    if !NebulaFinance:CardDistanceChecks(ply, ent) then return end

    if !ent:IsMerchant(ply) then return end

    ent:SetTransactionAmount(net.ReadUInt(32))
    ent:SetScreenID(2)
end)

function ENT:ResetReader(ply, card)
    self:SetScreenID(1)
    self:SetTransactionAmount(0)

    if card then
        self:RemoveCard(ply)
    else
        self.NebulaPayUsing = false
    end
end

function ENT:SetMerchant(ply)
    return self:CPPISetOwner(ply)
end

function ENT:OnCardInserted() end

function ENT:InsertCard(ply)
    self.CardInside = true 
    self:OnCardInserted()
    ply:StripWeapon("nebulafinance_card")

    self:SetBodygroup(1, 1)
    self:SetSequence(2)
    self:EmitSound("NebulaFinance:CardInsert")
end

function ENT:RemoveCard(ply)
    self:SetSequence(1)
    timer.Simple(.1, function()
        self:SetBodygroup(1, 0)
        self.CardInside = false

        if IsValid(ply) then
            ply:Give("nebulafinance_card", false)
        end
    end)
end

function ENT:ProcessPayment(ply, card)
    if !NebulaFinance:CardDistanceChecks(ply, self) then return end

    local merchant = self:GetMerchant()
    local fromAccount = NebulaFinance:GetSettings(ply).paymentAccount
    local toAccount = NebulaFinance:GetSettings(merchant).receiveAccount
    local amount = self:GetTransactionAmount()
    local result = false

    timer.Simple(1, function()
        if !IsValid(self or merchant or ply) then 
            if IsValid(self) then
                self:ResetReader(ply, card)
            end
        return end

        self:SetScreenID(3)

        timer.Simple(math.random(2, 5), function()
            if !IsValid(self or merchant or ply) then 
                if IsValid(self) then
                    self:ResetReader(ply, card)
                end
            return end

            local toPayAmount = amount
            
            if !NebulaFinance:IsPremiumUser(ply) then
                local toPayamount = (NebulaFinance:AddPercent(NebulaFinance.Configuration.GetConvar("transactionfeeamount"), amount))
            end

            if NebulaFinance:CanAfford(ply, fromAccount, toPayAmount) then
                NebulaFinance:GetIntegrationTbl(fromAccount):REMOVEBALANCE(ply, toPayAmount)
                NebulaFinance:GetIntegrationTbl(toAccount):ADDBALANCE(merchant, amount)
                result = true
            elseif !NebulaFinance:CanAfford(ply, fromAccount, amount) and NebulaFinance:IsPremiumUser(ply) then
                for i = 1, 4 do -- smart pay feature (scan through all accounts and use one that has enough amount)
                    if !NebulaFinance:GetAccounts(ply)[i] then continue end
    
                    if NebulaFinance:CanAfford(ply, i, toPayAmount) then
                        NebulaFinance:GetIntegrationTbl(i):REMOVEBALANCE(ply, toPayAmount)
                        NebulaFinance:GetIntegrationTbl(toAccount):ADDBALANCE(merchant, amount)
                        result = true
                        break
                    end
                end
            end

            if result then
                NebulaFinance:RegisterTransaction(ply, {
                    transactionType = string.upper(NebulaFinance:GetPhrase("transfer")), 
                    amount = amount, 
                    from = fromAccount, 
                    to = toAccount, 
                    receiver = merchant:GetName(),
                    receiving = false
                })
            
                NebulaFinance:RegisterTransaction(merchant, {
                    transactionType = string.upper(NebulaFinance:GetPhrase("transfer")), 
                    amount = amount, 
                    from = NebulaFinance:GetSettings(merchant).receiveAccount, 
                    to = toAccount, 
                    receiver = ply:GetName(),
                    receiving = true
                })
            end

            if !card then
                net.Start("NebulaFinance:NebulaPayFinished")
                    net.WriteBool(result)
                net.Send(ply)
            end

            self:SetScreenID(result and 5 or 4)
            self:EmitSound(result and "NebulaFinance:Success" or "NebulaFinance:Error")

            if result then
                timer.Simple(6, function()
                    if IsValid(ply) then  
                        NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("yousent"), merchant:GetName(), DarkRP.formatMoney(amount), NebulaFinance:GetAccounts(ply)[fromAccount].name))
                    end
    
                    if NebulaFinance:IsPremiumUser(ply) then
                        timer.Simple(5, function()
                            if IsValid(ply) then 
                                local cashbackAmount = NebulaFinance:GetPercentOf(NebulaFinance.Configuration.GetConvar("cashbackamount"), amount)
                                NebulaFinance:GetIntegrationTbl(NebulaFinance:GetSettings(ply).paymentAccount):ADDBALANCE(ply, cashbackAmount)
                                NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("gotcashback"), NebulaFinance.Configuration.GetConvar("cashbackamount"), "%"))
                            end
                        end)
                    end
                
                    if IsValid(merchant) then
                        NebulaFinance:Notify(merchant, string.format(NebulaFinance:GetPhrase("youreceived"), DarkRP.formatMoney(amount), ply:GetName()))
                    end
                end)
            end

            timer.Simple(3, function()
                if IsValid(self) then 
                    self:ResetReader(ply, card)
                end
            end)
        end)
    end)
end

net.Receive("NebulaFinance:InsertCard", function(len, ply)
    local ent = net.ReadEntity()

    if !NebulaFinance:CardDistanceChecks(ply, ent) then return end
    if ent.CardInside or ent.NebulaPayUsing then return end
    if ent:GetScreenID() != 2 then return end

    ent:InsertCard(ply)

    ent:ProcessPayment(ply, true)
end)

net.Receive("NebulaFinance:NebulaPay", function(len, ply)
    local ent = net.ReadEntity()

    if !NebulaFinance:CardDistanceChecks(ply, ent) then return end
    if ent.CardInside or ent.NebulaPayUsing then return end

    ent:ProcessPayment(ply, false)

    net.Start("NebulaFinance:NebulaPayStarted")
    net.Send(ply)

    ent.NebulaPayUsing = true
end)
