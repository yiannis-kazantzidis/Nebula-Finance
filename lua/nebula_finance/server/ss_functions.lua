local accountSaveDir = "nebulafinance/accounts"

function NebulaFinance:SaveAccount(ply) -- save an individual portfolio
    if !file.Exists(accountSaveDir, "DATA") then
        file.CreateDir(accountSaveDir)
    end

    -- convert it to lua table and initialize
    file.Write(accountSaveDir.."/"..ply:SteamID64()..".json", util.TableToJSON(ply.NebulaFinance_accountdata, true))
end

function NebulaFinance:LoadAccount(ply) -- load up an individual portfolio
    local data = file.Read(accountSaveDir.."/"..ply:SteamID64()..".json", "DATA")
    if !data then  
        ply.NebulaFinance_accountdata = NebulaFinance:ProvideFreshAccount()
        NebulaFinance:SaveAccount(ply)
    return end
    
    ply.NebulaFinance_accountdata = util.JSONToTable(data)

    -- check for supported accounts
    if NebulaFinance:GetAccounts(ply) then
        if !(GlorifiedBanking or CH_ATM) and ply.NebulaFinance_accountdata.LinkedAccounts[3] then
            ply.NebulaFinance_accountdata.LinkedAccounts[3] = nil
        elseif (GlorifiedBanking or CH_ATM) and !ply.NebulaFinance_accountdata.LinkedAccounts[3] then
            table.insert(ply.NebulaFinance_accountdata.LinkedAccounts, 3, {name = "Bank Account", id = 3, color = NebulaFinance:GetTheme("bankaccountcol")})
        end

        if !(CH_CryptoCurrencies) and ply.NebulaFinance_accountdata.LinkedAccounts[4] then
            table.remove(ply.NebulaFinance_accountdata.LinkedAccounts, 4)
        elseif (CH_CryptoCurrencies) and !ply.NebulaFinance_accountdata.LinkedAccounts[4] then
            table.insert(ply.NebulaFinance_accountdata.LinkedAccounts, 4, {name = "Crypto Account", id = 4, color = NebulaFinance:GetTheme("cryptoaccountcol")})
        end

        NebulaFinance:SaveAccount(ply)
    end
end

function NebulaFinance:UpdatePlayerBalance(ply)
    net.Start("NebulaFinance:UpdatePlayerBalance")
        net.WriteDouble(NebulaFinance:GetAccount(ply).Balance)
    net.Send(ply)
end

function NebulaFinance:SendTransaction(ply, transactionTbl)
    net.Start("NebulaFinance:SendTransaction")
        net.WriteString(transactionTbl.transactionType)
        net.WriteDouble(transactionTbl.amount)
        net.WriteUInt(transactionTbl.from, 3)
        net.WriteUInt(transactionTbl.to, 3)
        net.WriteBool(transactionTbl.receiving)
        if transactionTbl.transactionType == (string.upper(NebulaFinance:GetPhrase("transfer"))) then
            net.WriteString(transactionTbl.receiver)
        end
    net.Send(ply)
end

function NebulaFinance:RegisterTransaction(ply, transactionTbl)
    table.insert(NebulaFinance:GetTransactions(ply), transactionTbl)
    NebulaFinance:SendTransaction(ply, transactionTbl)
end

function NebulaFinance:ProvideFreshAccount()
    local freshAccount = {
        Balance = 0,
        Tier = string.lower(NebulaFinance:GetPhrase("regular")),
        hasOpened = false,
        LinkedAccounts = {{name = "Primary Pocket", id = 1, color = NebulaFinance:GetTheme("primarypocketcol")}, {name = "DarkRP Wallet", id = 2, color = NebulaFinance:GetTheme("darkrpwalletcol")}}, -- setup default accounts
        Transactions = {},
        Settings = {
            notifications = true,
            receiveMoney = true,
            paymentAccount = 1,
            receiveAccount = 1,
            cryptoChoice = 1
        }
    }

    -- check for supported accounts
    if GlorifiedBanking or CH_ATM then
        table.insert(freshAccount.LinkedAccounts, 3, {name = "Bank Account", id = 3, color = NebulaFinance:GetTheme("bankaccountcol")})
    end

    if (CH_CryptoCurrencies) then
        table.insert(freshAccount.LinkedAccounts, 4, {name = "Crypto Account", id = 4, color = NebulaFinance:GetTheme("cryptoaccountcol")})
    end

    return freshAccount
end

function NebulaFinance:Notify(ply, msg)
    if !NebulaFinance:GetSettings(ply).notifications then return end

    net.Start("NebulaFinance:Notify")
        net.WriteString(msg)
    net.Send(ply)
end

function NebulaFinance:RunSmartPay(ply, amount, func)
    for i = 1, 4 do -- smart pay feature (scan through all accounts and use one that has enough amount)
        if !NebulaFinance:GetAccounts(ply)[i] then continue end

        if NebulaFinance:CanAfford(ply, i, amount) then
            NebulaFinance:GetIntegrationTbl(i):REMOVEBALANCE(ply, transactionTbl.amount)
            func(true)
            break
        end
    end
end

function NebulaFinance:CompleteTransaction(ply, transactionTbl)
    timer.Simple(math.random(2, 5), function()
        if !IsValid(ply) then return end
        if !NebulaFinance:IsValidAccount(transactionTbl.from) then return end
        if !NebulaFinance:IsValidAccount(transactionTbl.to) then return end

        if transactionTbl.transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) and !IsValid(transactionTbl.receiver) then return end

        local amountToGive = transactionTbl.amount


        if !NebulaFinance:IsPremiumUser(ply) then -- not a premium user so needs to pay transaction fee on top of amount
            amountToGive = (NebulaFinance:GetPercent(NebulaFinance.Configuration.GetConvar("transactionfeeamount"), transactionTbl.amount))
        end

        if transactionTbl.result and NebulaFinance:CanAfford(ply, transactionTbl.from, transactionTbl.amount) then
            if transactionTbl.transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) and NebulaFinance:GetSettings(transactionTbl.receiver).receiveMoney then
                NebulaFinance:GetIntegrationTbl(transactionTbl.from):REMOVEBALANCE(ply, transactionTbl.amount)
                NebulaFinance:GetIntegrationTbl(transactionTbl.to):ADDBALANCE(transactionTbl.receiver, amountToGive)
            elseif transactionTbl.transactionType != string.upper(NebulaFinance:GetPhrase("transfer")) then
                NebulaFinance:GetIntegrationTbl(transactionTbl.from):REMOVEBALANCE(ply, transactionTbl.amount)
                NebulaFinance:GetIntegrationTbl(transactionTbl.to):ADDBALANCE(ply, amountToGive)
            else
                transactionTbl.result = false
            end
        elseif transactionTbl.transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) and !NebulaFinance:CanAfford(ply, transactionTbl.from, transactionTbl.amount) and NebulaFinance:IsPremiumUser(ply) then
            NebulaFinance:RunSmartPay(ply, amount, function(result)
                transactionTbl.result = (result or false)
                NebulaFinance:GetIntegrationTbl(transactionTbl.to):ADDBALANCE(transactionTbl.receiver, amountToGive)
            end)
        else
            transactionTbl.result = false
        end

        -- send to notify the screen that the transaction has completed
        net.Start("NebulaFinance:TransactionCompleted")
            net.WriteString(transactionTbl.transactionType)
            net.WriteBool(transactionTbl.result) -- send the result to display if the transaction has failed or gone through
            net.WriteDouble(transactionTbl.amount, 32)
            net.WriteUInt(transactionTbl.from, 3)
            net.WriteUInt(transactionTbl.to, 3)
            if transactionTbl.transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) then
                net.WriteString(transactionTbl.receiver:GetName())
            end
        net.Send(ply)
    end)

    hook.Run("NebulaFinance:OnTransactionCompleted", transactionTbl) -- for devlopers
    NebulaFinance:SaveAccount(ply)
    if transactionTbl.receiver then NebulaFinance:SaveAccount(transactionTbl.receiver) end
end

-- send the account data to connected players
function NebulaFinance:NetworkAccountToPlayer(ply)
    local account = NebulaFinance:GetAccount(ply)
    
    net.Start("NebulaFinance:NetworkAccountToPlayer")
        net.WriteDouble(account.Balance)
        net.WriteString(account.Tier)

        net.WriteUInt(#account.LinkedAccounts, 3)
        
        for k, v in pairs(account.LinkedAccounts) do 
            net.WriteString(v.name)
            net.WriteUInt(v.id, 3)
            net.WriteColor(Color(v.color.r, v.color.g, v.color.b))
        end

        net.WriteUInt(#account.Transactions, 5)

        for k, v in pairs(account.Transactions) do
            net.WriteString(v.transactionType)
            net.WriteDouble(v.amount)
            net.WriteUInt(v.from, 3)
            net.WriteUInt(v.to, 3)
            if v.transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) then
                net.WriteBool(v.receiving)
                net.WriteString(v.receiver)
            end
        end

        net.WriteBool(account.Settings.notifications)
        net.WriteBool(account.Settings.receiveMoney)
        net.WriteUInt(account.Settings.paymentAccount, 3)
        net.WriteUInt(account.Settings.receiveAccount, 3)
        if (CH_CryptoCurrencies) then -- if server has CHCryptos
            net.WriteUInt(account.Settings.cryptoChoice, 6)
        end
    net.Send(ply)
end

local hooks = {
	"canBuyCustomEntity",
	"canBuyShipment",
	"canBuyAmmo",
	"canBuyPistol"
}

-- integrating for darkrp purchases
for i = 1, 4 do
	hook.Add(hooks[i],"NebulaFinance:BuyWithFinance", function(ply, item)
        if !NebulaFinance.Configuration.GetConvar("f4menupurchases") then return end
        
        local result = false
        local paymentAccount = NebulaFinance:GetSettings(ply).paymentAccount

        if NebulaFinance:CanAfford(ply, paymentAccount, item.price) then
            NebulaFinance:GetIntegrationTbl(paymentAccount):REMOVEBALANCE(ply, item.price)
            result = true
        elseif !NebulaFinance:CanAfford(ply, paymentAccount, item.price) and NebulaFinance:IsPremiumUser(ply) then
            for i = 1, 4 do -- smart pay feature (scan through all accounts and use one that has enough amount)
                if !NebulaFinance:GetAccounts(ply)[i] then continue end

                if NebulaFinance:CanAfford(ply, i, item.price) then
                    NebulaFinance:GetIntegrationTbl(i):REMOVEBALANCE(ply, item.price)
                    result = true
                    break
                end
            end
        end

        if result then
            NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("itembought"), item.name, DarkRP.formatMoney(item.price)))
            return true, true, nil, 0
        else
            NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("itemboughtfailed"), item.name))
            return false, true
        end
	end)
end

