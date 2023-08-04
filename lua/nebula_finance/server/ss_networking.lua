net.Receive("NebulaFinance:InitializeNetworking", function(len, ply)
    if ply.NebulaFinance_InitializedNetwork then return end

    hook.Run("NebulaFinance:OnPlayerFullyLoaded", ply)
    ply.NebulaFinance_InitializedNetwork = true
end)

-- if player is on the nebulapay app, called when player open & closes app
net.Receive("NebulaFinance:UpdateNebulaPayStatus", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    if !aphone then return end
    if ply:GetActiveWeapon():GetClass() != "aphone" then return end
    
    ply.nebulapay_status = !ply.nebulapay_status
end)

net.Receive("NebulaFinance:UpgradeTier", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    local paymentAccount = NebulaFinance:GetSettings(ply).paymentAccount

    if !NebulaFinance:IsValidAccount(paymentAccount) then return end

    if !NebulaFinance:CanAfford(ply, paymentAccount, NebulaFinance.Configuration.GetConvar("premiumprice")) then
        NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("notaffordupgrade"))
    return end

    NebulaFinance:GetIntegrationTbl(paymentAccount):REMOVEBALANCE(ply, NebulaFinance.Configuration.GetConvar("premiumprice"))

    NebulaFinance:GetAccount(ply).Tier = string.lower(NebulaFinance:GetPhrase("premium"))

    NebulaFinance:SaveAccount(ply)

    net.Start("NebulaFinance:UpgradeTier")
    net.Send(ply)

    NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("subscriptionpaid"))
end)

net.Receive("NebulaFinance:DowngradeTier", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    local paymentAccount = NebulaFinance:GetSettings(ply).paymentAccount

    if !NebulaFinance:IsValidAccount(paymentAccount) then return end

    NebulaFinance:GetAccount(ply).Tier = string.lower(NebulaFinance:GetPhrase("regular"))

    NebulaFinance:SaveAccount(ply)

    net.Start("NebulaFinance:DowngradeTier")
    net.Send(ply)

    NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("downgradedtier"))
end)

hook.Add("playerGetSalary", "NebulaFinance:TakeSubscriptionAmount", function(ply, amount)
    if !NebulaFinance:IsPremiumUser(ply) then return end

    local canAfford = false

    if NebulaFinance:CanAfford(ply, NebulaFinance:GetSettings(ply).paymentAccount, NebulaFinance.Configuration.GetConvar("premiumprice")) then
        NebulaFinance:GetIntegrationTbl(NebulaFinance:GetSettings(ply).paymentAccount):REMOVEBALANCE(ply, NebulaFinance.Configuration.GetConvar("premiumprice"))
        canAfford = true
    else
        for i = 1, 4 do -- smart pay feature (scan through all accounts and use one that has enough amount)
            if !NebulaFinance:GetAccounts(ply)[i] then continue end

            if NebulaFinance:CanAfford(ply, i, amountToPay) then
                NebulaFinance:GetIntegrationTbl(i):REMOVEBALANCE(ply, amountToPay)
                canAfford = true
                break
            end
        end
    end

    if canAfford then
        NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("subscriptionpaid"))
    else
        NebulaFinance:GetAccount(ply).Tier = string.lower(NebulaFinance:GetPhrase("regular"))

        NebulaFinance:SaveAccount(ply)

        net.Start("NebulaFinance:DowngradeTier")
        net.Send(ply)

        NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("failedpaid"))
    end
end)

hook.Add("PlayerSay", "NebulaFinance:ChatCommand", function(ply, text)
    if string.lower(text) == NebulaFinance.Configuration.GetConvar("chatcommand") then 
        if NebulaFinance.Configuration.GetConvar("openfinancemenu") != ("All of them" or "Chat Command") then return end

        net.Start("NebulaFinance:OpenMenu")
        net.Send(ply)

        return ""
    elseif string.lower(text) == NebulaFinance.Configuration.GetConvar("introchatcommand") then
        net.Start("NebulaFinance:IntroMenu")
        net.Send(ply)

        return ""
    end
end)

net.Receive("NebulaFinance:UpdateSettings", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    local notifications = net.ReadBool()
    local receiveMoney = net.ReadBool()
    local paymentAccount = net.ReadUInt(3)
    local receiveAccount = net.ReadUInt(3)

    if !NebulaFinance:IsValidAccount(paymentAccount) then return end
    if !NebulaFinance:IsValidAccount(receiveAccount) then return end

    local cryptoChoice

    if CH_CryptoCurrencies then -- if server has CHCryptos
        cryptoChoice = net.ReadUInt(6)
    end

    NebulaFinance:GetAccount(ply).Settings.notifications = notifications
    NebulaFinance:GetAccount(ply).Settings.receiveMoney = receiveMoney
    NebulaFinance:GetAccount(ply).Settings.paymentAccount = paymentAccount
    NebulaFinance:GetAccount(ply).Settings.receiveAccount = receiveAccount
    if CH_CryptoCurrencies then
        NebulaFinance:GetAccount(ply).Settings.cryptoChoice = cryptoChoice
    end

    NebulaFinance:SaveAccount(ply)

    local account = NebulaFinance:GetAccount(ply)

    -- send the updated data to the player
    net.Start("NebulaFinance:UpdateSettings")
        net.WriteBool(notifications)
        net.WriteBool(receiveMoney)
        net.WriteUInt(paymentAccount, 3)
        net.WriteUInt(receiveAccount, 3)
        if (CH_CryptoCurrencies) then
            net.WriteUInt(cryptoChoice, 6)
        end
    net.Send(ply)

    NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("savedchanges"))
end)

net.Receive("NebulaFinance:Withdraw", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    local amount = net.ReadDouble()
    local fromAccount = net.ReadUInt(3) -- the account that the player is using to pay with
    local toAccount = net.ReadUInt(3) -- the player will be receiving to
    if !NebulaFinance:IsValidAccount(fromAccount) then return end
    if !NebulaFinance:IsValidAccount(toAccount) then return end
    local result = NebulaFinance:CanAfford(ply, fromAccount, amount) -- if initally the player can afford it
    local transactionType = string.upper(NebulaFinance:GetPhrase("withdraw"))

    NebulaFinance:CompleteTransaction(ply, {
        ply = ply, 
        result = result, 
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount,
        to = toAccount
    })

    if !result then return end

    NebulaFinance:RegisterTransaction(ply, {
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount, 
        to = toAccount
    })

    timer.Simple(6, function()
        if !IsValid(ply) then return end
        

        NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("withdrew"), DarkRP.formatMoney(amount), NebulaFinance:GetAccounts(ply)[fromAccount].name))
    end)
end)

net.Receive("NebulaFinance:RemoveAllTransactions", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    -- clear all transactions
    NebulaFinance:GetAccount(ply).Transactions = {}

    NebulaFinance:SaveAccount(ply)

    NebulaFinance:Notify(ply, NebulaFinance:GetPhrase("actionsuc"))

    net.Start("NebulaFinance:RemoveAllTransactions")
    net.Send(ply)
end)

net.Receive("NebulaFinance:Transfer", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    local amount = net.ReadDouble()
    local fromAccount = net.ReadUInt(3) -- the account that the player is using to pay with
    local receiver = net.ReadEntity()
    local toAccount = NebulaFinance:GetSettings(receiver).receiveAccount -- the receiver will be receiving to
    if !NebulaFinance:IsValidAccount(fromAccount) then return end
    if !NebulaFinance:IsValidAccount(toAccount) then return end
    local result = NebulaFinance:CanAfford(ply, fromAccount, amount) -- if initally the player can afford it
    local transactionType = string.upper(NebulaFinance:GetPhrase("transfer"))
    if !IsValid(receiver) or receiver == ply then return end

    NebulaFinance:CompleteTransaction(ply, {
        result = result, 
        transactionType = transactionType, 
        receiver = receiver,
        amount = amount, 
        from = fromAccount,
        to = toAccount
    })

    if !result then return end

    NebulaFinance:RegisterTransaction(ply, {
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount, 
        to = toAccount, 
        receiver = receiver:GetName(),
        receiving = false
    })

    NebulaFinance:RegisterTransaction(receiver, {
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount, 
        to = toAccount, 
        receiver = ply:GetName(),
        receiving = true
    })

    timer.Simple(6, function()
        if IsValid(ply) then  
            NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("yousent"), receiver:GetName(), DarkRP.formatMoney(amount), NebulaFinance:GetAccounts(ply)[fromAccount].name))
        end

        if IsValid(receiver) then
            NebulaFinance:Notify(receiver, string.format(NebulaFinance:GetPhrase("youreceived"), DarkRP.formatMoney(amount), receiver:GetName()))
        end
    end)
end)

net.Receive("NebulaFinance:Deposit", function(len, ply)
    if (ply.NebulaFinance_NetworkDelay or CurTime()) > CurTime() then return end
	ply.NebulaFinance_NetworkDelay = CurTime() + 1

    local amount = net.ReadDouble()
    local fromAccount = net.ReadUInt(3) -- the account that the player is using to pay with
    local toAccount = net.ReadUInt(3) -- the player will be receiving to
    if !NebulaFinance:IsValidAccount(fromAccount) then return end
    if !NebulaFinance:IsValidAccount(toAccount) then return end
    local result = NebulaFinance:CanAfford(ply, fromAccount, amount) -- if initally the player can afford it
    local transactionType = string.upper(NebulaFinance:GetPhrase("deposit"))

    NebulaFinance:CompleteTransaction(ply, {
        ply = ply, 
        result = result, 
        transactionID = transactionID, 
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount,
        to = toAccount
    })

    if !result then return end

    NebulaFinance:RegisterTransaction(ply, {
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount, 
        to = toAccount
    })

    timer.Simple(6, function()
        if !IsValid(ply) then return end

        NebulaFinance:Notify(ply, string.format(NebulaFinance:GetPhrase("deposited"), DarkRP.formatMoney(amount), NebulaFinance:GetAccounts(ply)[fromAccount].name))
    end)
end)