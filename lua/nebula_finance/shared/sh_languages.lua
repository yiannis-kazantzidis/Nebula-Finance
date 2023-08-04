NebulaFinance.RegisteredLanguages = {}

function NebulaFinance:RegisterLanguage(tbl)
	if !tbl or !tbl.Name then return end

	NebulaFinance.RegisteredLanguages[tbl.Name] = tbl
	return NebulaFinance.RegisteredLanguages[tbl.Name]
end

function NebulaFinance:AddPhrase(tbl, phraseID, phrase)
	if phrase == nil then return end

	if !tbl or !phraseID then
		ErrorNoHalt("Failed to add phrase. Missing argument(s).\nRequired Arguments:\n	1: Language table from language registration.\n	2: An phraseID.\n	3: The phrase itself.")
		return
	end

	NebulaFinance.RegisteredLanguages[tbl.Name][phraseID] = phrase
end

function NebulaFinance:GetPhrase(phraseID)
	local curLang = NebulaFinance.Configuration.GetConvar("Language")

	if !NebulaFinance.RegisteredLanguages[curLang][phraseID] then
		curLang = "English"
	end

	return NebulaFinance.RegisteredLanguages[curLang][phraseID] or "Missing Phrase"
end

local installedLanguages = file.Find("nebula_finance/languages/*","LUA")

for k,v in pairs(installedLanguages) do
	AddCSLuaFile("nebula_finance/languages/" .. v)
	include("nebula_finance/languages/" .. v)
end