NebulaFinance.RegisteredThemes = {}

function NebulaFinance:RegisterTheme(tbl)
	NebulaFinance.RegisteredThemes[tbl.Name] = tbl
	return NebulaFinance.RegisteredThemes[tbl.Name]
end

function NebulaFinance:AddTheme(tbl, phraseID, phrase)
	if phrase == nil then return end
	NebulaFinance.RegisteredThemes[tbl.Name][phraseID] = phrase
end

function NebulaFinance:GetTheme(phraseID)
	local curTheme = NebulaFinance.Configuration.GetConvar("Theme")

	if !NebulaFinance.RegisteredThemes[curTheme][phraseID] then
		curTheme = "Dark"
	end

	return NebulaFinance.RegisteredThemes[curTheme][phraseID]
end

local installedLanguages = file.Find("nebula_finance/themes/*","LUA")

for k,v in pairs(installedLanguages) do
	AddCSLuaFile("nebula_finance/themes/" .. v)
	include("nebula_finance/themes/" .. v)
end