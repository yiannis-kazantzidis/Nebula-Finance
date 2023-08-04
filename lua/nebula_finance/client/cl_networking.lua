NebulaFinance.MyAccount = NebulaFinance.MyAccount or {Balance = 0, Tier = "", LinkedAccounts = {}, Transactions = {}, Settings = {notifications = true, receiveMoney = true, paymentAccount = 1, receiveAccount = 1}}
NebulaFinance.Notifications = NebulaFinance.Notifications or {}

net.Start("NebulaFinance:InitializeNetworking")
net.SendToServer()

net.Receive("NebulaFinance:IntroMenu", function()
    RunConsoleCommand("openfinanceintro")
end)

net.Receive("NebulaFinance:OpenMenu", function()
    RunConsoleCommand("openfinanceframe")
end)

net.Receive("NebulaFinance:UpgradeTier", function()
    NebulaFinance.MyAccount.Tier = string.lower(NebulaFinance:GetPhrase("premium"))
end)

net.Receive("NebulaFinance:DowngradeTier", function()
    NebulaFinance.MyAccount.Tier = string.lower(NebulaFinance:GetPhrase("regular"))
end)

net.Receive("NebulaFinance:UpdateSettings", function()
    local account = NebulaFinance.MyAccount
    
    account.Settings.notifications = net.ReadBool()
    account.Settings.receiveMoney = net.ReadBool()
    account.Settings.paymentAccount = net.ReadUInt(3)
    account.Settings.receiveAccount = net.ReadUInt(3)
    if (CH_CryptoCurrencies) then
        account.Settings.cryptoChoice = net.ReadUInt(6)
    end
end)

net.Receive("NebulaFinance:NetworkAccountToPlayer", function()
    local account = NebulaFinance.MyAccount

    account.Balance = net.ReadDouble()
    account.Tier = net.ReadString()

    for i = 1, net.ReadUInt(3) do
        table.insert(account.LinkedAccounts, {name = net.ReadString(), id = net.ReadUInt(3), color = net.ReadColor()})
    end

    for i = 1, net.ReadUInt(5) do
        local transactionType = net.ReadString()

        if transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) then
            table.insert(NebulaFinance:GetTransactions(), {transactionType = transactionType, amount = net.ReadDouble(), from = net.ReadUInt(3), to = net.ReadUInt(3), receiving = net.ReadBool(), receiver = net.ReadString()})
        else
            table.insert(NebulaFinance:GetTransactions(), {transactionType = transactionType, amount = net.ReadDouble(), from = net.ReadUInt(3), to = net.ReadUInt(3)})
        end
    end

    account.Settings.notifications = net.ReadBool()
    account.Settings.receiveMoney = net.ReadBool()
    account.Settings.paymentAccount = net.ReadUInt(3)
    account.Settings.receiveAccount = net.ReadUInt(3)
    if (CH_CryptoCurrencies) then
        account.Settings.cryptoChoice = net.ReadUInt(6)
    end
end)

net.Receive("NebulaFinance:RemoveAllTransactions", function()
    NebulaFinance.MyAccount.Transactions = {}

    hook.Run("NebulaFinance:OnTransactionsRemoved")
end)

net.Receive("NebulaFinance:SendTransaction", function()
    local transactionType = net.ReadString()

    if transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) then
        table.insert(NebulaFinance:GetTransactions(), {transactionType = transactionType, amount = net.ReadDouble(), from = net.ReadUInt(3), to = net.ReadUInt(3), receiving = net.ReadBool(), receiver = net.ReadString()})
    else
        table.insert(NebulaFinance:GetTransactions(), {transactionType = transactionType, amount = net.ReadDouble(), from = net.ReadUInt(3), to = net.ReadUInt(3)})
    end
end)

net.Receive("NebulaFinance:TransactionCompleted", function()
    local transactionType = net.ReadString()
    local result = net.ReadBool()
    local amount = net.ReadDouble()
    local fromAccount = net.ReadUInt(3)
    local toAccount = net.ReadUInt(3)
    if transactionType == string.upper(NebulaFinance:GetPhrase("transfer")) then
        local receiver = net.ReadString()
    end

    local receiver = receiver or ""

    local transactionTbl = {        
        result = result, 
        transactionType = transactionType, 
        amount = amount, 
        from = fromAccount,
        to = toAccount,
        receiver = receiver
    }

    hook.Run("NebulaFinance:OnTransactionCompleted", transactionTbl)
end)

net.Receive("NebulaFinance:Notify", function()
    local msg = net.ReadString()

    NebulaFinance:Notify(msg)

    hook.Run("NebulaFinance:OnNewNotification")
end)

net.Receive("NebulaFinance:UpdatePlayerBalance", function()
    NebulaFinance.MyAccount.Balance = net.ReadDouble()
end)

