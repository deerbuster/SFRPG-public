--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local rsname = "SFRPG";
local rsmajorversion = 17;

function onInit()
	if User.isHost() or User.isLocal() then
		updateCampaign();
	end

	DB.onAuxCharLoad = onCharImport;
	DB.onImport = onImport;
	Module.onModuleLoad = onModuleLoad;
	upDatePCAbilities();
end

function onCharImport(nodePC)
	local _, _, aMajor, _ = DB.getImportRulesetVersion();
	updateChar(nodePC, aMajor[rsname]);
end

function onImport(node)
	upDatePCAbilities();
	local aPath = StringManager.split(node.getNodeName(), ".");
	if #aPath == 2 and aPath[1] == "charsheet" then
		local _, _, aMajor, _ = DB.getImportRulesetVersion();
		updateChar(node, aMajor[rsname]);
	end
end

function onModuleLoad(sModule)
	local _, _, aMajor, _ = DB.getRulesetVersion(sModule);
	local bUpdate = false;
	if sModule == "Starfinder Core Rulebook" then
		bUpdate = true;
	elseif sModule == "Starfinder Core Rulebook (Players)" then
		bUpdate = true;
	elseif sModule == "SFRPG Character Operation Manual Playtest" then
		bUpdate = true;
	else
		bUpdate = false;
	end
	if bUpdate then
		local nodeRoot = DB.getRoot();
		local aClasses = DB.getChildrenGlobal(nodeRoot, "reference.class");
		local sCallSource = "manager";
		ClassManager.upDateAllClasses(aClasses, sCallSource);
	end
	updateModule(sModule, aMajor[rsname]);
end


function updateChar(nodePC, nVersion)
	if not nVersion then
		nVersion = 0;
	end

	if nVersion < rsmajorversion then
	-- No version updates currently; assume SFRPG database ruleset versions start at 17
	end
end

function updateCampaign()
	local _, _, aMajor, aMinor = DB.getRulesetVersion();
	local major = aMajor[rsname];
	if not major then
		return;
	end

	if major > 0 and major < rsmajorversion then
		print("Migrating campaign database to latest data version.");
		DB.backup();
	-- No version updates currently; assume SFRPG database ruleset versions start at 17
	end
end

function updateModule(sModule, nVersion)
	if not nVersion then
		nVersion = 0;
	end

	if nVersion < rsmajorversion then
	-- No version updates currently; assume SFRPG database ruleset versions start at 17
	end
end

function upDatePCAbilities()
	local nodeRoot = DB.getRoot();
	local aCharacters = DB.getChildren(nodeRoot, "charsheet");

	for _,PC in pairs (aCharacters) do
		local aClasses = DB.getChildren(PC, "classes");
		local aSpecialabilitylist = DB.getChildren(PC, "specialabilitylist");
		for _,Class in pairs (aClasses) do
			local sClass, sRecord = DB.getValue(Class, "shortcut", "", "");
			aRecordStrip = StringManager.split(sRecord, "@");
			aClassName = StringManager.split(aRecordStrip[1], ".");
			if aClassName[3] == "mechanic_exocortex_" then
				sRecordNew = sRecord:gsub("mechanic_exocortex_", "mechanic");
				DB.setValue(Class, "shortcut", "windowreference", sClass, sRecordNew);
				DB.setValue(Class, "name", "string", "Mechanic" )
				--local aSpecialabilitylist = DB.getChildren(PC, "specialabilitylist");
				for _,Ability in pairs (aSpecialabilitylist) do
					DB.setValue(Ability, "source", "string", "");
					DB.setValue(Ability, "class", "string", "Mechanic");
				end
			end
			if aClassName[3] == "mechanic_drone_" then
				sRecordNew = sRecord:gsub("mechanic_drone_", "mechanic");
				DB.setValue(Class, "shortcut", "windowreference", sClass, sRecordNew);
				DB.setValue(Class, "name", "string", "Mechanic" )
				--local aSpecialabilitylist = DB.getChildren(PC, "specialabilitylist");
				for _,Ability in pairs (aSpecialabilitylist) do
					DB.setValue(Ability, "source", "string", "Mechanic");
					DB.setValue(Ability, "class", "string", "Mechanic");
				end
			end
		end
	end
end
