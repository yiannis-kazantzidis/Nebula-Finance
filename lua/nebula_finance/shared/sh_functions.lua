
function NebulaFinance:GetAccount(ply)
    if CLIENT then
        return (NebulaFinance.MyAccount or {})
    else
        return (ply.NebulaFinance_accountdata or {})
    end
end

function NebulaFinance:GetSettings(ply)
    return NebulaFinance:GetAccount(ply).Settings
end

function NebulaFinance:GetTransactions(ply)
    return NebulaFinance:GetAccount(ply).Transactions
end

function NebulaFinance:GetTier(ply)
    return NebulaFinance:GetAccount(ply).Tier
end

function NebulaFinance:IsPremiumUser(ply)
    return NebulaFinance:GetTier(ply) == (string.upper(NebulaFinance:GetPhrase("premium")) or "premium")
end

function NebulaFinance:GetAccounts(ply)
    return NebulaFinance:GetAccount(ply).LinkedAccounts
end

function NebulaFinance:GetBalance(ply)
    return NebulaFinance:GetAccount(ply).Balance
end

function NebulaFinance:IsValidAccount(accountID)
    if accountID < 1 or accountID > 4 then return false end
    if accountID == 3 and !(GlorifiedBanking or CH_ATM) then return false end
    if accountID == 4 and !(CH_CryptoCurrencies) then return false end
    
    return true
end
function NebulaFinance:GetIntegrationTbl(accountID)
    if accountID == 1 then 
        return NebulaFinance.NblaFnance
    elseif accountID == 2 then
        return NebulaFinance.DRP
    elseif accountID == 3 then
        if GlorifiedBanking then
            return NebulaFinance.GlrfiedBnking
        elseif CH_ATM then
            return NebulaFinance.CHATM
        end
    elseif accountID == 4 then
        return NebulaFinance.CHCryptos
    end
end

function NebulaFinance:CanAfford(ply, fromAccount, amount)
    if fromAccount == 4 then
        return NebulaFinance:GetIntegrationTbl(fromAccount):CANAFFORD(ply, amount)
    end

    return (amount <= NebulaFinance:GetIntegrationTbl(fromAccount):GETBALANCE(ply)) 
end

function NebulaFinance:GetPercent(value, totalValue)
    return math.Round(totalValue - ((value * totalValue) / 100), 2)
end

function NebulaFinance:GetPercentOf(value, totalValue)
    return math.Round(((value * totalValue) / 100), 2)
end

function NebulaFinance:AddPercent(value, totalValue)
    return math.Round(totalValue + ((value * totalValue) / 100), 2)
end

function NebulaFinance:AddBalance(ply, amount)
    NebulaFinance:GetAccount(ply).Balance = NebulaFinance:GetAccount(ply).Balance + amount
    NebulaFinance:SaveAccount(ply)
end

function NebulaFinance:CardDistanceChecks(ply, ent)
    return ent:GetPos():DistToSqr(ply:GetPos()) <= 4500
end