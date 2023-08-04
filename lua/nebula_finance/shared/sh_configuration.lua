NebulaFinance.Configuration = {
	Config = {},
	ConfigOptions = {},
}

NebulaFinance_CONFIG_BOOL = 1
NebulaFinance_CONFIG_STRING = 2
NebulaFinance_CONFIG_INT = 3
NebulaFinance_CONFIG_TABLE = 4

if SERVER then
	util.AddNetworkString("NebulaFinance:UpdatePlayerConfig")
	util.AddNetworkString("NebulaFinance:SaveConfiguration")
	util.AddNetworkString("NebulaFinance:ConfigurationSaved")
	util.AddNetworkString("NebulaFinance:RequestConfig")

	function NebulaFinance.Configuration.SaveConfiguration(table)
		local JSON = util.TableToJSON(table, true)
		file.Write("nebulafinance/config.json", JSON)
	end

	function NebulaFinance.Configuration.LoadConfig(  )
		local configFile = util.JSONToTable(file.Read("nebulafinance/config.json","DATA"))

		local changesMade = false

		local function resetToDefault(id)
			configFile[id] = NebulaFinance.Configuration.ConfigOptions[id].Default
			changesMade = true
		end

		for k,v in pairs(NebulaFinance.Configuration.ConfigOptions) do
			if configFile[k] == nil then
				resetToDefault(k)
			elseif v.Type == NebulaFinance_CONFIG_BOOL then
				if !isbool(configFile[k]) then
					resetToDefault(k)
				end
			elseif v.Type == NebulaFinance_CONFIG_STRING then
				if !isstring(configFile[k]) or #configFile[k] > NebulaFinance.Configuration.ConfigOptions[k].maxLength then
					resetToDefault(k)
				end
			elseif v.Type == NebulaFinance_CONFIG_INT then
				if !isnumber(configFile[k]) then
					resetToDefault(k)
				end
			elseif v.Type == NebulaFinance_CONFIG_TABLE then
				if !isstring(configFile[k]) or !table.HasValue(NebulaFinance.Configuration.ConfigOptions[k].AllowedValues, configFile[k]) then
					resetToDefault(k)
				end
			end
		end

		for k,v in pairs(configFile) do
			if !NebulaFinance.Configuration.ConfigOptions[k] then
				configFile[k] = nil
				changesMade = true
			end
		end

		if changesMade == true then
			NebulaFinance.Configuration.SaveConfiguration(configFile)
		end

		NebulaFinance.Configuration.Config = configFile
	end

	function NebulaFinance.Configuration.UpdatePlayers(rf)
		net.Start("NebulaFinance:UpdatePlayerConfig")
			net.WriteTable(NebulaFinance.Configuration.Config)
		net.Send(rf)
	end

end

function NebulaFinance.Configuration.CreateConvar(ID, tbl)
	tbl.Order = table.Count(NebulaFinance.Configuration.ConfigOptions) + 1

	NebulaFinance.Configuration.ConfigOptions[ID] = tbl
end

function NebulaFinance.Configuration.GetConvar(ID)
	return NebulaFinance.Configuration.Config[ID]
end

include("nebula_finance/shared/sh_convars.lua")

if SERVER then
	if !file.Exists("nebulafinance","DATA") then
		file.CreateDir("nebulafinance")
	end

	if !file.Exists("nebulafinance/config.json", "DATA") then
		local toWriteTbl = {}

		for k,v in pairs(NebulaFinance.Configuration.ConfigOptions) do
			toWriteTbl[k] = v.Default
		end

		NebulaFinance.Configuration.SaveConfiguration(toWriteTbl)
	end

	NebulaFinance.Configuration.LoadConfig()

	timer.Simple(1, function()
		local rf = RecipientFilter()
		rf:AddAllPlayers()

		NebulaFinance.Configuration.UpdatePlayers(rf)
	end)

	net.Receive("NebulaFinance:RequestConfig", function(_, client)
		if client.NebulaFinanceConfig != nil then return end

		local rf = RecipientFilter()
		rf:AddPlayer(client)

		NebulaFinance.Configuration.UpdatePlayers(rf)

		client.NebulaFinanceConfig = true
	end)

	net.Receive("NebulaFinance:SaveConfiguration", function(_, client)
		if !client:IsSuperAdmin() then return end

		NebulaFinance.Configuration.SaveConfiguration(net.ReadTable())

		net.Start("NebulaFinance:ConfigurationSaved")
		net.Send(client)

		include("autorun/sh_nebulafinance.lua")
	end)

	hook.Add("PlayerSay", "NebulaFinance:ConfigCommand", function(client, text)
		if string.lower(text) == "!nebulafinance_config" then
			client:ConCommand("nebulafinance_config")

			return ""
		end
	end)

else
	NebulaFinance.Configuration.Config = hook.Run("NebulaFinance:Internal_GetConfig") or {}

	local config = {}

	if table.Count(NebulaFinance.Configuration.Config) > 0 then
		config = NebulaFinance.Configuration.Config
	else
		net.Start("NebulaFinance:RequestConfig")
		net.SendToServer()
	end

	hook.Add("NebulaFinance:Internal_GetConfig","NebulaFinance:Config", function()
		return config
	end)

	net.Receive("NebulaFinance:UpdatePlayerConfig", function()
		config = net.ReadTable()
		include("autorun/sh_nebulafinance.lua")
	end)
end