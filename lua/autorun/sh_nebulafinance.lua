NebulaFinance = NebulaFinance or {}

local folder = "nebula_finance"

for k, v in ipairs(file.Find(folder .. "/shared/*.lua", "LUA")) do
	AddCSLuaFile(folder .. "/shared/" .. v)
end

for k, v in ipairs(file.Find(folder .. "/client/*.lua", "LUA")) do
	AddCSLuaFile(folder .. "/client/" .. v)
end

for k, v in ipairs(file.Find(folder .. "/client/pages/*.lua", "LUA")) do
	AddCSLuaFile(folder .. "/client/pages/" .. v)
end

for k, v in ipairs(file.Find(folder .. "/server/*.lua", "LUA")) do
	include(folder .. "/server/" .. v)
end

local function loadAddon()
	if SERVER then
		for k, v in ipairs(file.Find(folder .. "/server/*.lua", "LUA")) do
			include(folder .. "/server/" .. v)
		end
	else
		if (DarkRP) then
			include(folder .. "/shared/sh_languages.lua")
			include(folder .. "/shared/sh_themes.lua")
			include(folder .. "/shared/sh_configuration.lua")
			include(folder .. "/shared/sh_functions.lua")
			include(folder .. "/shared/sh_supportedfuncs.lua")

			if table.Count(NebulaFinance.Configuration.Config) != 0 then
				file.CreateDir("nebula_finance")

				for k, v in ipairs(file.Find(folder .. "/client/*.lua", "LUA")) do
					include(folder .. "/client/" .. v)
				end

				for k, v in ipairs(file.Find(folder .. "/client/pages/*.lua", "LUA")) do
					include(folder .. "/client/pages/" .. v)
				end

				hook.Add("DarkRPFinishedLoading","NebulaFinance:ReloadOnDarkRPReload", function()
					include("autorun/sh_nebulafinance.lua")
				end)
			end
		end
	end
end

if not CLIENT then
	resource.AddWorkshop("2811442227")
	include(folder .. "/shared/sh_languages.lua")
	include(folder .. "/shared/sh_themes.lua")
	include(folder .. "/shared/sh_configuration.lua")
	include(folder .. "/shared/sh_functions.lua")
	include(folder .. "/shared/sh_supportedfuncs.lua")

	for k, v in ipairs(file.Find(folder .. "/framework/functions/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/framework/functions/" .. v)
	end	

	for k, v in ipairs(file.Find(folder .. "/framework/elements/*.lua", "LUA")) do
		AddCSLuaFile(folder .. "/framework/elements/" .. v)
	end
else
	for k, v in ipairs(file.Find(folder .. "/framework/functions/*.lua", "LUA")) do
		include(folder .. "/framework/functions/" .. v)
	end

	for k, v in ipairs(file.Find(folder .. "/framework/elements/*.lua", "LUA")) do
		include(folder .. "/framework/elements/" .. v)
	end
end

hook.Add(CLIENT and "InitPostEntity" or "OnGamemodeLoaded", "NebulaFinance:LoadAddon", function()
	timer.Simple(1, loadAddon)
	print("[ NEBULA FINANCE ] INITIALIZED ")
end)

if GAMEMODE then loadAddon() end

sound.Add({
    name = "NebulaFinance:Success",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 100,
    pitch = 100,
    sound = "tenw_finance/nebulapay_purchase.ogg"
})

sound.Add({
    name = "NebulaFinance:Error",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 100,
    pitch = 100,
    sound = "tenw_finance/nebulafinance_error.ogg"
})

sound.Add({
    name = "NebulaFinance:Popup",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 100,
    pitch = 100,
    sound = "tenw_finance/nebulapay_finance.ogg"
})

sound.Add({
    name = "NebulaFinance:CardInsert",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 100,
    pitch = 100,
    sound = "tenw_finance/nebulapay_insert.mp3"
})

sound.Add({
    name = "NebulaFinance:KeyPress",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 100,
    pitch = 100,
    sound = "tenw_finance/key_press.mp3"
})