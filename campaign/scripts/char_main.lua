--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", onLevelChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "abilitiesedit"), "onChildUpdate", onStatChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "abilities"), "onChildUpdate", onBonusChanged);

	onLevelChanged();
	onHealthChanged();
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "classes"), "onChildUpdate", onLevelChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "abilitiesedit"), "onChildUpdate", onStatChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities"), "onChildUpdate", onBonusChanged);
end

function onLevelChanged()
	CharManager.calcLevel(getDatabaseNode());
	onHealthChanged();
end

function onHealthChanged()
	-- Set HP Current Display. System still uses the wounds for Calulations.
	local nodeChar = getDatabaseNode();
	local nHpMax = DB.getValue(nodeChar, "hp.total", 0);
	local nWounds = DB.getValue(nodeChar, "hp.wounds", 0);
	local nHpCurrent = nHpMax - nWounds;
	if nHpCurrent < 0 then
		nHpCurrent = 0;
	end
	DB.setValue(nodeChar, "hp.current", "number", nHpCurrent);
	local sColorWounds = ActorManager2.getWoundColor("pc", getDatabaseNode());

	-- Set SP Current Display. System uses the fatique for Calulations.
	local nSpMax = DB.getValue(nodeChar, "sp.total", 0);
	local nFatique = DB.getValue(nodeChar, "sp.fatique", 0);
	local nSpCurrent = nSpMax - nFatique;
	if nSpCurrent < 0 then
		nSpCurrent = 0;
	end
	DB.setValue(nodeChar, "sp.current", "number", nSpCurrent);
	local sColorFatique = ActorManager2.getFatiqueColor("pc", getDatabaseNode());

	wounds.setColor(sColorWounds);
	fatique.setColor(sColorFatique);
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		if StringManager.contains({"class", "race", "theme"}, sClass) then
			CharManager.addInfoDB(getDatabaseNode(), sClass, sRecord);
			return true;
		end
	end
end
--SFRPG ADD Ability Score Editor
function onStatChanged() --Adjust Skills after Int change
local nodeChar = getDatabaseNode();
	local nBase = 10;
	local nMod = 0;
	local nEnc = 0;
	local nDmg = 0;
	local nScore = 0;
	local nSta = 0;

	local nLevel = DB.getValue(nodeChar,"level", 0);	
	local nConBonus = DB.getValue(nodeChar, "abilities.constitution.bonus", 0);

	for kAbility, vAbility in pairs(DataCommon.abilities) do
		nBase = DB.getValue(nodeChar, "abilitiesedit." .. vAbility .. ".base", 10);
		nMod = DB.getValue(nodeChar, "abilitiesedit." .. vAbility .. ".mod", 0);
		nEnc = DB.getValue(nodeChar, "abilitiesedit." .. vAbility .. ".encumbrance", 0);
		nDmg = DB.getValue(nodeChar, "abilities." .. vAbility .. ".damage", 0);
		nScore = (nBase + nMod) + nEnc;
		DB.setValue(nodeChar, "abilities." .. vAbility .. ".score", "number", nScore);

		if vAbility == "intelligence" then
			local sClassList = DB.getChildren(nodeChar,"classes","");
			for _,sClass in pairs(sClassList) do
				local nodeClassEdit = sClass;
				local nLevel = DB.getValue(sClass,"level",0);
				local nAbilitySkillPoints = DB.getValue(nodeChar, "abilities.intelligence.bonus", 0);
				local nBonusSkillPoints = 0;
				local nSkillRanks = DB.getValue(sClass,"skillranks",0);
				local nClassSkillRanks = DB.getValue(sClass,"classskillranks",0);
				if CharManager.hasTrait(nodeChar, "Skilled") then
					nBonusSkillPoints = 1;
				end
				nNewSkillRanks = ((nClassSkillRanks + nAbilitySkillPoints + nBonusSkillPoints) * nLevel);

				nSkillRanksAdj = nNewSkillRanks - nSkillRanks;
				DB.setValue(nodeClassEdit, "skillranks", "number", nNewSkillRanks);
			end
		end
		local sKeyAbility = DB.getValue(nodeChar, "abilities.keyability", "");
		if vAbility == sKeyAbility then
			nMod= DB.getValue(nodeChar, "abilities." .. vAbility .. ".bonus",0);
			DB.setValue(nodeChar,"abilities.keyabilitymod", "number", nMod);
			DB.setValue(nodeChar,"abilities.key","number",1);
		end
	end

	CharManager.updateSkillPoints(nodeChar);
	CharManager.addClassSpellLevelHelper(nodeChar, nodeSpellClass);	
	return;
end

function onBonusChanged()
	local nodeChar = getDatabaseNode();
	local nClassStamina = 0;
	local nStaminaTotal = 0;
	local nConBonus = DB.getValue(nodeChar, "abilities.constitution.bonus", 0);
	local nSpMod = DB.getValue(nodeChar, "sp.mod", 0);
	local nLevel = 0;
	for _,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		local sClassLookup = DB.getValue(vClass,"name",""):lower();
		nLevel = DB.getValue(vClass,"level",0);
		if DataCommon.classdata[sClassLookup] then
			nClassStaminaLookup = DataCommon.classdata[sClassLookup].classstamina;
		end
		if nClassStaminaLookup == nil or nClassStaminaLookup == 0 then
			nClassStaminaLookup = DB.getValue(vClass,"classstamina", 0);
		end
		nClassStamina = math.floor(nClassStamina + ((nClassStaminaLookup + nConBonus) * nLevel) + nSpMod);
	end

	local nStaMaxStart = DB.getValue(nodeChar, "sp.total", 0);
	local nStaCurrStart = DB.getValue(nodeChar, "sp.current", 0);
	local nFatique = DB.getValue(nodeChar, "sp.fatique", 0);
	DB.setValue(nodeChar,"sp.total", "number", nClassStamina);
	DB.setValue(nodeChar,"sp.current", "number", (nClassStamina - nFatique));
	nStaminaChange = nClassStamina - nStaMaxStart;

	if nStaminaChange ~= 0 and nLevel > 0 then
		local sCharName = DB.getValue(nodeChar,"name", "Name Missing")
		ChatManager.SystemMessage( "Max Stamina adjusted to " .. sCharName .. ".(" .. nStaminaChange .. ")");
		LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, "Max Stamina Points", nStaminaChange);
	end
	CharManager.updateSkillPoints(nodeChar);
end
