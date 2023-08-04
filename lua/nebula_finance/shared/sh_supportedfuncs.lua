-- (make the funcs universal)

NebulaFinance.NblaFnance = {}

function NebulaFinance.NblaFnance:GETBALANCE(ply)
    return NebulaFinance:GetBalance(ply)
end

function NebulaFinance.NblaFnance:ADDBALANCE(ply, amount)
    NebulaFinance:AddBalance(ply, amount)
    NebulaFinance:UpdatePlayerBalance(ply)
end

function NebulaFinance.NblaFnance:REMOVEBALANCE(ply, amount)     
    NebulaFinance:AddBalance(ply, -amount)
    NebulaFinance:UpdatePlayerBalance(ply)
end

function NebulaFinance.NblaFnance:CANAFFORD(ply, amount)
    return NebulaFinance:CanAfford(ply, amount)
end

function NebulaFinance.NblaFnance:TRANSFERAMOUNT(ply, receiver, amount)
    NebulaFinance:AddBalance(ply, -amount)
    NebulaFinance:AddBalance(receiver, amount)
    NebulaFinance:UpdatePlayerBalance(receiver)
    NebulaFinance:UpdatePlayerBalance(ply)
end

-- GLORIFIED BANKING SUPPORT

NebulaFinance.GlrfiedBnking = {}

function NebulaFinance.GlrfiedBnking:GETBALANCE(ply)
    if !GlorifiedBanking then return end
     
    return GlorifiedBanking.GetPlayerBalance(ply)
end

function NebulaFinance.GlrfiedBnking:ADDBALANCE(ply, amount)
    if !GlorifiedBanking then return end
     
    GlorifiedBanking.AddPlayerBalance(ply, amount)
end

function NebulaFinance.GlrfiedBnking:REMOVEBALANCE(ply, amount)
    if !GlorifiedBanking then return end
     
    GlorifiedBanking.RemovePlayerBalance(ply, amount)
end


function NebulaFinance.GlrfiedBnking:CANAFFORD(ply, amount)
    if !GlorifiedBanking then return end

    return GlorifiedBanking.CanPlayerAfford(ply, amount)
end

function NebulaFinance.GlrfiedBnking:TRANSFERAMOUNT(ply, receiver, amount)
    if !GlorifiedBanking then return end

    GlorifiedBanking.TransferAmount(ply, receiver, amount)
end

-- CRAP-HEAD ATM SUPPORT

NebulaFinance.CHATM = {}

function NebulaFinance.CHATM:GETBALANCE( ply )
    if !CH_ATM then return end

    return CH_ATM.Currencies[CH_ATM_GetCurrency()].GetMoney(ply)
end

function NebulaFinance.CHATM:ADDBALANCE(ply, amount)
    if !CH_ATM then return end

    CH_ATM.Currencies[CH_ATM_GetCurrency()].AddMoney(ply, amount)
end

function NebulaFinance.CHATM:REMOVEBALANCE(ply, amount)
    if !CH_ATM then return end

    CH_ATM.Currencies[CH_ATM_GetCurrency()].TakeMoney(ply, amount)
end

function NebulaFinance.CHATM:CANAFFORD(ply, amount)
    return CH_ATM.Currencies[CH_ATM_GetCurrency()].CanAfford(ply, amount)
end

function NebulaFinance.CHATM:TRANSFERAMOUNT(ply, receiver, amount)
    CH_ATM.Currencies[CH_ATM_GetCurrency()].TakeMoney(ply, amount)
    CH_ATM.Currencies[CH_ATM_GetCurrency()].AddMoney(ply, amount)
end

-- DarkRP

NebulaFinance.DRP = {}

function NebulaFinance.DRP:GETBALANCE(ply)
    return ply:getDarkRPVar("money")
end

function NebulaFinance.DRP:ADDBALANCE(ply, amount)
    ply:addMoney(amount)
end

function NebulaFinance.DRP:REMOVEBALANCE(ply, amount)
    ply:addMoney(-amount)
end

function NebulaFinance.DRP:CANAFFORD(ply, amount)
    return ply:canAfford(amount)
end

function NebulaFinance.DRP:TRANSFERAMOUNT(ply, receiver, amount)
    ply:addMoney(-amount)
    receiver:addMoney(amount)
end

NebulaFinance.CHCryptos = {}

function NebulaFinance.CHCryptos:CONVERTAMOUNT(index, amount)
    if !CH_CryptoCurrencies then return end

    return (amount * CH_CryptoCurrencies.Cryptos[index].Price)
end

function NebulaFinance.CHCryptos:AMOUNTCONVERT(index, amount)
    if !CH_CryptoCurrencies then return end
     
    return (amount / CH_CryptoCurrencies.Cryptos[index].Price)
end

function NebulaFinance.CHCryptos:GETBALANCE(ply)
    if !CH_CryptoCurrencies then return end
     
    local balance = 0

    for k, v in pairs(SERVER and CH_CryptoCurrencies.Cryptos or CH_CryptoCurrencies.CryptosCL) do
        if !(ply.CH_CryptoCurrencies_Wallet[v.Currency] or ply.CH_CryptoCurrencies_Wallet[v.Currency].Amount == 0) then continue end

        local player_owns = math.Round(ply.CH_CryptoCurrencies_Wallet[v.Currency].Amount, 7)
		local crypto_worth = math.Round(player_owns * v.Price)

        balance = balance + crypto_worth
    end

    return balance
end


function NebulaFinance.CHCryptos:ADDBALANCE(ply, amount)
    local cryptoTable = CH_CryptoCurrencies.Cryptos
    local prefix = cryptoTable[NebulaFinance:GetSettings(ply).cryptoChoice].Currency
    
    local amountToCrypto = NebulaFinance.CHCryptos:AMOUNTCONVERT(NebulaFinance:GetSettings(ply).cryptoChoice, amount)

    CH_CryptoCurrencies.GiveCrypto(ply, prefix, amountToCrypto)
end

function NebulaFinance.CHCryptos:REMOVEBALANCE(ply, amount)
    local cryptoTable = CH_CryptoCurrencies.Cryptos
    local prefix = cryptoTable[NebulaFinance:GetSettings(ply).cryptoChoice].Currency

    local amountToCrypto = NebulaFinance.CHCryptos:AMOUNTCONVERT(NebulaFinance:GetSettings(ply).cryptoChoice, amount)

    CH_CryptoCurrencies.TakeCrypto(ply, prefix, amountToCrypto)
end

function NebulaFinance.CHCryptos:CANAFFORD(ply, amount)
    local cryptoTable = CH_CryptoCurrencies.Cryptos
    local prefix = cryptoTable[NebulaFinance:GetSettings(ply).cryptoChoice].Currency

    return NebulaFinance.CHCryptos:AMOUNTCONVERT(NebulaFinance:GetSettings(ply).cryptoChoice, amount) <= ply.CH_CryptoCurrencies_Wallet[prefix].Amount
end









