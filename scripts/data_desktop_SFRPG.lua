--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	for k,v in pairs(aDataModuleSet) do
		for _,v2 in ipairs(v) do
			Desktop.addDataModuleSet(k, v2);
		end
	end
	CharacterListManager.onShortcutDrop = onShortcutDropOverride;
	CharacterListManager.registerDropHandler("shortcut", onShortcutDropOverride);
end

function onShortcutDropOverride(sIdentity, draginfo)
	local sClass, sRecord = draginfo.getShortcutData();
	local nodeSource = draginfo.getDatabaseNode();	
	if sClass == "companionsheet" then		
		ChatManager.SystemMessage("[Sharing of Companions done by dropping on PC Sheets (Companion)]");
		return;
	end	
	if User.isHost() then
		local bProcessed = false;
		if Input.isAltPressed() then
			bProcessed = CharacterListManager.processClassDrop(sClass, sIdentity, draginfo);
		end
		if not bProcessed then
			local w = Interface.openWindow(draginfo.getShortcutData());
			if w then
				w.share(User.getIdentityOwner(sIdentity));
			end
		end
		return true;
	else
		CharacterListManager.processClassDrop(sClass, sIdentity, draginfo);
	end
end

aDataModuleSet =
	{
		["local"] =
		{
			{
				name = "SFRPG - Core Rules",
				modules =
				{
					{ name = "Starfinder Core Rulebook", storeid = "PZOSMWPZO7101FG" },
					{ name = "Starfinder Alien Archive (Players)", storeid = "PZOSMWPZO7105FG" },
				},
			},
		},
		["client"] =
		{
			{
				name = "SFRPG - Core Rules",
				modules =
				{
					{ name = "Starfinder Core Rulebook (Players)", storeid = "PZOSMWPZO7101FG" },
					{ name = "Starfinder Alien Archive (Players)", storeid = "PZOSMWPZO7105FG" },
					{ name = "Starfinder Alien Archive 2 (Players)", storeid = "PZOSMWPZO7109FG" },
					{ name = "Starfinder Pact Worlds (Players)", storeid = "PZOSMWPZO7107FG" },
					{ name = "Starfinder Armory", storeid = "PZOSMWPZO7108FG" },
				},
			},
		},
		["host"] =
		{
			{
				name = "SFRPG - Core Rules GM",
				modules =
				{
					{ name = "Starfinder Core Rulebook", storeid = "PZOSMWPZO7101FG" },
					{ name = "Starfinder Alien Archive", storeid = "PZOSMWPZO7105FG" },
					{ name = "Starfinder Alien Archive 2", storeid = "PZOSMWPZO7109FG" },
					{ name = "Starfinder Pact Worlds", storeid = "PZOSMWPZO7107FG" },
					{ name = "Starfinder Armory", storeid = "PZOSMWPZO7108FG" },
				},
			},
			{
				name = "SFRPG - Core Rules Players",
				modules =
				{
					{ name = "Starfinder Core Rulebook (Players)", storeid = "PZOSMWPZO7101FG" },
					{ name = "Starfinder Alien Archive (Players)", storeid = "PZOSMWPZO7105FG" },
					{ name = "Starfinder Alien Archive 2 (Players)", storeid = "PZOSMWPZO7109FG" },
					{ name = "Starfinder Pact Worlds (Players)", storeid = "PZOSMWPZO7107FG" },
					{ name = "Starfinder Armory", storeid = "PZOSMWPZO7108FG" },
				},
			},
		},
	};
