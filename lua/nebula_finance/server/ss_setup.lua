util.AddNetworkString("NebulaFinance:NetworkAccountToPlayer")
util.AddNetworkString("NebulaFinance:InitializeNetworking")
util.AddNetworkString("NebulaFinance:UpdatePlayerBalance")
util.AddNetworkString("NebulaFinance:TransactionCompleted")
util.AddNetworkString("NebulaFinance:RemoveAllTransactions")
util.AddNetworkString("NebulaFinance:SendTransaction")
util.AddNetworkString("NebulaFinance:UpdateSettings")
util.AddNetworkString("NebulaFinance:UpgradeTier")
util.AddNetworkString("NebulaFinance:DowngradeTier")
util.AddNetworkString("NebulaFinance:Notify")
util.AddNetworkString("NebulaFinance:Withdraw")
util.AddNetworkString("NebulaFinance:Transfer")
util.AddNetworkString("NebulaFinance:Deposit")
util.AddNetworkString("NebulaFinance:UpdateNebulaPayStatus")
util.AddNetworkString("NebulaFinance:NebulaPayFinished")
util.AddNetworkString("NebulaFinance:NebulaPayStarted")
util.AddNetworkString("NebulaFinance:OpenMenu")
util.AddNetworkString("NebulaFinance:IntroMenu")

hook.Add("NebulaFinance:OnPlayerFullyLoaded", "NebulaFinance:InitializeAccountSV", function(ply)
     NebulaFinance:LoadAccount(ply)

     timer.Simple(1, function()
          if !IsValid(ply) then return end

          NebulaFinance:NetworkAccountToPlayer(ply)

          if NebulaFinance:GetAccount(ply).hasOpened then return end

          net.Start("NebulaFinance:IntroMenu")
          net.Send(ply)
     
          NebulaFinance:GetAccount(ply).hasOpened = true 
     end)
end)

hook.Add("PlayerDisconnected", "NebulaFinance:PlayerDisconnected", function(ply)
     NebulaFinance:SaveAccount(ply)
end)
