NebulaFinance.Configuration.CreateConvar("Language", {
	Title = "Language",
	Description = "What language should be used for NebulaFinance interface.",
	Type = NebulaFinance_CONFIG_TABLE,
	Default = "English",
	AllowedValues = table.GetKeys(NebulaFinance.RegisteredLanguages),
	SortItems = true,
} )

NebulaFinance.Configuration.CreateConvar("Theme", {
	Title = "Theme",
	Description = "What theme should be used for NebulaFinance interface.",
	Type = NebulaFinance_CONFIG_TABLE,
	Default = "Dark",
	AllowedValues = table.GetKeys(NebulaFinance.RegisteredThemes),
	SortItems = true,
} )

NebulaFinance.Configuration.CreateConvar("openfinancemenu", {
	Title = "Ways to open finance menu",
	Description = "What should the ways to open the finance menu be.",
	Type = NebulaFinance_CONFIG_TABLE,
	Default = "All of them",
	AllowedValues = {"NPC", "Chat Command", "Nebula Finance Card", "All of them"},
	SortItems = true,
} )

NebulaFinance.Configuration.CreateConvar("f4menupurchases", {
	Title = "F4 Menu Purchases",
	Description = "Should F4 Menu purchases be integrated with players Nebula Finance account.",
	Type = NebulaFinance_CONFIG_BOOL,
	Default = true,
} )

NebulaFinance.Configuration.CreateConvar("chatcommand", {
	Title = "Menu Chat Command",
	Description = "The chat command to open the menu.",
	Type = NebulaFinance_CONFIG_STRING,
	Default = "!finance",
	maxLength = 100,
} )

NebulaFinance.Configuration.CreateConvar("introchatcommand", {
	Title = "Introduction Chat Command",
	Description = "The chat command to open the introduction menu.",
	Type = NebulaFinance_CONFIG_STRING,
	Default = "!financehelp",
	maxLength = 100,
} )

NebulaFinance.Configuration.CreateConvar("premiumprice", {
	Title = "Premium Account Subscription Price",
	Description = "What should the subscription price of upgrading to Nebula Finance Premium be.",
	Type = NebulaFinance_CONFIG_INT,
	Default = 1000,
} )

NebulaFinance.Configuration.CreateConvar("transactionfeeamount", {
	Title = "Transaction Fee Amount",
	Description = "What should the percentage fee of purchases be on non premium accounts.",
	Type = NebulaFinance_CONFIG_INT,
	Default = 20,
} )

NebulaFinance.Configuration.CreateConvar("cashbackamount", {
	Title = "Cashback Amount",
	Description = "What should the percantage of cashback be when a premium completes a card purchase.",
	Type = NebulaFinance_CONFIG_INT,
	Default = 10,
} )

