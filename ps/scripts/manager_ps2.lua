-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local aFieldMap = {};

function onInit()
	if User.isHost() then	
		DB.addHandler("charsheet.*.classes", "onChildUpdate", linkPCClasses);
		DB.addHandler("charsheet.*.skilllist", "onChildUpdate", linkPCSkills);		
		DB.addHandler("charsheet.*.languagelist", "onChildUpdate", linkPCLanguages);
	end
	
	
end

function linkPCClasses(nodeClass)
	local nodePS = PartyManager.mapChartoPS(nodeClass.getParent());
	if not nodePS then
		return;
	end

	DB.setValue(nodePS, "class", "string", CharManager.getClassLevelSummary(nodeClass.getParent()));
end

function linkPCLanguages(nodeLanguages)
	if not nodeLanguages then
		return;
	end
	local nodePS = PartyManager.mapChartoPS(nodeLanguages.getParent());
	if not nodePS then
		return;
	end
	
	local aLanguages = {};
	
	for _,v in pairs(nodeLanguages.getChildren()) do
		local sName = DB.getValue(v, "name", "");
		if sName ~= "" then
			table.insert(aLanguages, sName);
		end
	end
	table.sort(aLanguages);
	
	local sLanguages = table.concat(aLanguages, ", ");
	DB.setValue(nodePS, "languages", "string", sLanguages);
end

function linkPCSkill(nodeSkill, nodePS, sPSField)
	PartyManager.linkRecordField(nodeSkill, nodePS, "total", "number", sPSField);
end
function linkPCSkillranks(nodeSkill, nodePS, sPSField)
	PartyManager.linkRecordField(nodeSkill, nodePS, "ranks", "number", sPSField);
end

function linkPCSkills(nodeSkills)
	if not nodeSkills then
		return;
	end
	local nodePS = PartyManager.mapChartoPS(nodeSkills.getParent());
	if not nodePS then
		return;
	end
	
	for _,v in pairs(nodeSkills.getChildren()) do
		local sLabel = DB.getValue(v, "label", ""):lower();
		
		if sLabel == "spot" then
			linkPCSkill(v, nodePS, "spot");
			linkPCSkillranks(v, nodePS, "spotranks");
		elseif sLabel == "listen" then
			linkPCSkill(v, nodePS, "listen");
			linkPCSkillranks(v, nodePS, "listenranks");
		elseif sLabel == "search" then
			linkPCSkill(v, nodePS, "search");
			linkPCSkillranks(v, nodePS, "searchranks");
		elseif sLabel == "perception" then
			linkPCSkill(v, nodePS, "perception");
			linkPCSkillranks(v, nodePS, "perceptionranks");
		elseif sLabel == "sense motive" then
			linkPCSkill(v, nodePS, "sensemotive");
			linkPCSkillranks(v, nodePS, "sensemotiveranks");
		
		elseif sLabel == "engineering" then
			linkPCSkill(v, nodePS, "engineering");
			linkPCSkillranks(v, nodePS, "engineeringranks");
		elseif sLabel == "computers" then
			linkPCSkill(v, nodePS, "computers");
			linkPCSkillranks(v, nodePS, "computersranks");
		elseif sLabel == "piloting" then
			linkPCSkill(v, nodePS, "piloting");
			linkPCSkillranks(v, nodePS, "pilotingranks");
		elseif sLabel == "life science" then
			linkPCSkill(v, nodePS, "lifescience");
			linkPCSkillranks(v, nodePS, "lifescienceranks");
		elseif sLabel == "physical science" then
			linkPCSkill(v, nodePS, "physicalscience");
			linkPCSkillranks(v, nodePS, "physicalscienceranks");
		elseif sLabel == "mysticism" then
			linkPCSkill(v, nodePS, "mysticism");
			linkPCSkillranks(v, nodePS, "mysticismranks");
		
		
		elseif sLabel == "bluff" then
			linkPCSkill(v, nodePS, "bluff");
			linkPCSkillranks(v, nodePS, "bluffranks");
		elseif sLabel == "diplomacy" then
			linkPCSkill(v, nodePS, "diplomacy");
			linkPCSkillranks(v, nodePS, "diplomacyranks");
		elseif sLabel == "culture" then
			linkPCSkill(v, nodePS, "culture");
			linkPCSkillranks(v, nodePS, "cultureranks");
		elseif sLabel == "intimidate" then
			linkPCSkill(v, nodePS, "intimidate");
			linkPCSkillranks(v, nodePS, "intimidateranks");
		
		elseif sLabel == "acrobatics" then
			linkPCSkill(v, nodePS, "acrobatics");
			linkPCSkillranks(v, nodePS, "acrobaticsranks");
		elseif sLabel == "athletics" then
			linkPCSkill(v, nodePS, "athletics");
			linkPCSkillranks(v, nodePS, "athleticsranks");
		elseif sLabel == "engineering" then
			linkPCSkill(v, nodePS, "engineering");
			linkPCSkillranks(v, nodePS, "engineeringranks");
		elseif sLabel == "medicine" then
			linkPCSkill(v, nodePS, "medicine");
			linkPCSkillranks(v, nodePS, "medicineranks");
		elseif sLabel == "jump" then
			linkPCSkill(v, nodePS, "jump");
			linkPCSkillranks(v, nodePS, "jumpranks");
		elseif sLabel == "survival" then
			linkPCSkill(v, nodePS, "survival");
			linkPCSkillranks(v, nodePS, "survivalranks");
		
		elseif sLabel == "disguise" then
			linkPCSkill(v, nodePS, "disguise");
			linkPCSkillranks(v, nodePS, "disguiseranks");
		elseif sLabel == "sleight of hand" then
			linkPCSkill(v, nodePS, "sleightofhand");
			linkPCSkillranks(v, nodePS, "sleightofhandranks");
		elseif sLabel == "stealth" then
			linkPCSkill(v, nodePS, "stealth");
			linkPCSkillranks(v, nodePS, "stealthranks");
		
		elseif sLabel == "knowledge" then
			local sSubLabel = DB.getValue(v, "sublabel", ""):lower();	
		end
	end
end

function linkPCFields(nodePS)
	local sClass, sRecord = DB.getValue(nodePS, "link", "", "");
	if sRecord == "" then
		return;
	end
	local nodeChar = DB.findNode(sRecord);
	if not nodeChar then
		return;
	end
	
	PartyManager.linkRecordField(nodeChar, nodePS, "name", "string");
	PartyManager.linkRecordField(nodeChar, nodePS, "token", "token", "token");

	PartyManager.linkRecordField(nodeChar, nodePS, "race", "string");
	PartyManager.linkRecordField(nodeChar, nodePS, "level", "number");
	PartyManager.linkRecordField(nodeChar, nodePS, "exp", "number");
	PartyManager.linkRecordField(nodeChar, nodePS, "expneeded", "number");

	PartyManager.linkRecordField(nodeChar, nodePS, "senses", "string");
	
	PartyManager.linkRecordField(nodeChar, nodePS, "hp.total", "number", "hptotal");
	PartyManager.linkRecordField(nodeChar, nodePS, "hp.temporary", "number", "hptemp");
	PartyManager.linkRecordField(nodeChar, nodePS, "hp.wounds", "number", "wounds");
	PartyManager.linkRecordField(nodeChar, nodePS, "hp.nonlethal", "number", "nonlethal");
	PartyManager.linkRecordField(nodeChar, nodePS, "sp.fatique", "number", "fatique");
	PartyManager.linkRecordField(nodeChar, nodePS, "sp.total", "number", "sptotal");
	
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.strength.score", "number", "strength");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.constitution.score", "number", "constitution");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.dexterity.score", "number", "dexterity");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.intelligence.score", "number", "intelligence");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.wisdom.score", "number", "wisdom");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.charisma.score", "number", "charisma");

	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.strength.bonus", "number", "strcheck");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.constitution.bonus", "number", "concheck");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.dexterity.bonus", "number", "dexcheck");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.intelligence.bonus", "number", "intcheck");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.wisdom.bonus", "number", "wischeck");
	PartyManager.linkRecordField(nodeChar, nodePS, "abilities.charisma.bonus", "number", "chacheck");

	PartyManager.linkRecordField(nodeChar, nodePS, "ac.totals.kac", "number", "kac");	
	PartyManager.linkRecordField(nodeChar, nodePS, "ac.totals.eac", "number", "eac");
	PartyManager.linkRecordField(nodeChar, nodePS, "ac.totals.cmd", "number", "cmd");
	PartyManager.linkRecordField(nodeChar, nodePS, "ac.totals.flatfooted", "number", "flatfooted");
	
	PartyManager.linkRecordField(nodeChar, nodePS, "saves.fortitude.total", "number", "fortitude");
	PartyManager.linkRecordField(nodeChar, nodePS, "saves.reflex.total", "number", "reflex");
	PartyManager.linkRecordField(nodeChar, nodePS, "saves.will.total", "number", "will");
	
	PartyManager.linkRecordField(nodeChar, nodePS, "defenses.damagereduction", "string", "dr");
	PartyManager.linkRecordField(nodeChar, nodePS, "defenses.sr.total", "number", "sr");

	linkPCClasses(nodeChar.getChild("classes"));
	linkPCSkills(nodeChar.getChild("skilllist"));
	linkPCLanguages(nodeChar.getChild("languagelist"));
end

--
-- DROP HANDLING
--

function addEncounter(nodeEnc)
	if not nodeEnc then
		return;
	end
	
	local nodePSEnc = DB.createChild("partysheet.encounters");
	DB.copyNode(nodeEnc, nodePSEnc);
end

function addQuest(nodeQuest)
	if not nodeQuest then
		return;
	end
	
	local nodePSQuest = DB.createChild("partysheet.quests");
	DB.copyNode(nodeQuest, nodePSQuest);
end

--
-- XP DISTRIBUTION
--

function awardQuestsToParty(nodeEntry)
	local nXP = 0;
	if nodeEntry then
		if DB.getValue(nodeEntry, "xpawarded", 0) == 0 then
			nXP = DB.getValue(nodeEntry, "xp", 0);
			DB.setValue(nodeEntry, "xpawarded", "number", 1);
		end
	else
		for _,v in pairs(DB.getChildren("partysheet.quests")) do
			if DB.getValue(v, "xpawarded", 0) == 0 then
				nXP = nXP + DB.getValue(v, "xp", 0);
				DB.setValue(v, "xpawarded", "number", 1);
			end
		end
	end
	if nXP ~= 0 then
		awardXP(nXP);
	end
end

function awardEncountersToParty(nodeEntry)
	local nXP = 0;
	if nodeEntry then
		if DB.getValue(nodeEntry, "xpawarded", 0) == 0 then
			nXP = DB.getValue(nodeEntry, "exp", 0);
			DB.setValue(nodeEntry, "xpawarded", "number", 1);
		end
	else
		for _,v in pairs(DB.getChildren("partysheet.encounters")) do
			if DB.getValue(v, "xpawarded", 0) == 0 then
				nXP = nXP + DB.getValue(v, "exp", 0);
				DB.setValue(v, "xpawarded", "number", 1);
			end
		end
	end
	if nXP ~= 0 then
		awardXP(nXP);
	end
end

function awardXP(nXP) 
	-- Determine members of party
	local aParty = {};
	for _,v in pairs(DB.getChildren("partysheet.partyinformation")) do
		local sClass, sRecord = DB.getValue(v, "link");
		if sClass == "charsheet" and sRecord then
			local nodePC = DB.findNode(sRecord);
			if nodePC then
				local sName = DB.getValue(v, "name", "");
				table.insert(aParty, { name = sName, node = nodePC } );
			end
		end
	end

	-- Determine split
	local nAverageSplit;
	if nXP >= #aParty then
		nAverageSplit = math.floor((nXP / #aParty) + 0.5);
	else
		nAverageSplit = 0;
	end
	local nFinalSplit = math.max((nXP - ((#aParty - 1) * nAverageSplit)), 0);
	
	-- Award XP
	for _,v in ipairs(aParty) do
		local nAmount;
		if k == #aParty then
			nAmount = nFinalSplit;
		else
			nAmount = nAverageSplit;
		end
		
		if nAmount > 0 then
			local nNewAmount = DB.getValue(v.node, "exp", 0) + nAmount;
			DB.setValue(v.node, "exp", "number", nNewAmount);
		end

		v.given = nAmount;
	end
	
	-- Output results
	local msg = {font = "msgfont"};
	msg.icon = "xp";
	for _,v in ipairs(aParty) do
		msg.text = "[" .. v.given .. " XP] -> " .. v.name;
		Comm.deliverChatMessage(msg);
	end

	msg.icon = "portrait_gm_token";
	msg.text = Interface.getString("ps_message_xpaward") .. " (" .. nXP .. ")";
	Comm.deliverChatMessage(msg);
end

function awardXPtoPC(nXP, nodePC)
	local nCharXP = DB.getValue(nodePC, "exp", 0);
	nCharXP = nCharXP + nXP;
	DB.setValue(nodePC, "exp", "number", nCharXP);
							
	local msg = {font = "msgfont"};
	msg.icon = "xp";
	msg.text = "[" .. nXP .. " XP] -> " .. DB.getValue(nodePC, "name");
	Comm.deliverChatMessage(msg, "");

	local sOwner = nodePC.getOwner();
	if (sOwner or "") ~= "" then
		Comm.deliverChatMessage(msg, sOwner);
	end
end
