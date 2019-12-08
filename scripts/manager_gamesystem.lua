--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = true },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	["attack"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["grapple"] = { sIcon = "action_attack", sTargeting = "each", bUseModStack = true },
	["damage"] = { sIcon = "action_damage", sTargeting = "each", bUseModStack = true },
	["heal"] = { sIcon = "action_heal", sTargeting = "all", bUseModStack = true },
	["cast"] = { sTargeting = "each" },
	["castclc"] = { sTargeting = "each" },
	["castsave"] = { sTargeting = "each" },
	["clc"] = { sTargeting = "each", bUseModStack = true },
	["spellsave"] = { sTargeting = "each" },
	["spdamage"] = { sIcon = "action_damage", sTargeting = "all", bUseModStack = true },
	["skill"] = { bUseModStack = true },
	["init"] = { bUseModStack = true },
	["save"] = { bUseModStack = true },
	["ability"] = { bUseModStack = true },
	-- PF SPECIFIC
	["concentration"] = { bUseModStack = true },
	-- TRIGGERED
	["critconfirm"] = { sIcon = "action_attack" },
	["misschance"] = { },
	["stabilization"] = { },
};

targetactions = {
	"attack",
	"critconfirm",
	"grapple",
	"damage",
	"spdamage",
	"heal",
	"effect",
	"cast",
	"clc",
	"spellsave"
};

currencies = { "Credits", "UPB" };
currencyDefault = "Credits";

languages = {
	};

function onInit()
	-- Languages
	languages = {
		[Interface.getString("language_value_akitonian")] = "Celestial",
		[Interface.getString("language_value_aklo")] = "Dwarven",
		[Interface.getString("language_value_brethedan")] = "Celestial",
		[Interface.getString("language_value_castrovelian")] = "Dwarven",
		[Interface.getString("language_value_eoxian")] = "Celestial",
		[Interface.getString("language_value_kasatha")] = "Draconic",
		[Interface.getString("language_value_shirren")] = "Elven",
		[Interface.getString("language_value_trixian")] = "Dwarven",
		[Interface.getString("language_value_vercite")] = "Elven",
		[Interface.getString("language_value_vesk")] = "Draconic",
		[Interface.getString("language_value_ysoki")] = "Elven",

		[Interface.getString("language_value_abyssal")] = "Abyssal",
		[Interface.getString("language_value_aquan")] = "Celestial",
		[Interface.getString("language_value_arkanen")] = "Elven",
		[Interface.getString("language_value_auran")] = "Abyssal",
		[Interface.getString("language_value_azlanti")] = "Celestial",
		[Interface.getString("language_value_celestial")] = "Celestial",
		[Interface.getString("language_value_common")] = "",
		[Interface.getString("language_value_draconic")] = "Draconic",
		[Interface.getString("language_value_drow")] = "Elven",
		[Interface.getString("language_value_dwarven")] = "Dwarven",
		[Interface.getString("language_value_elven")] = "Elven",
		[Interface.getString("language_value_gnome")] = "Abyssal",
		[Interface.getString("language_value_goblin")] = "Abyssal",
		[Interface.getString("language_value_halfling")] = "Dwarven",
		[Interface.getString("language_value_ignan")] = "Dwarven",
		[Interface.getString("language_value_infernal")] = "Infernal",
		[Interface.getString("language_value_kalo")] = "Infernal",
		[Interface.getString("language_value_nchaki")] = "Elven",
		[Interface.getString("language_value_orc")] = "Abyssal",
		[Interface.getString("language_value_sarcesian")] = "Elven",
		[Interface.getString("language_value_shobhad")] = "Infernal",
		[Interface.getString("language_value_terran")] = "",

	-- Original Lang setup
	--	[Interface.getString("language_value_akitonian")] = "Akitonian",
	--	[Interface.getString("language_value_aklo")] = "Aklo",
	--	[Interface.getString("language_value_brethedan")] = "Brethedan",
	--	[Interface.getString("language_value_castrovelian")] = "Castrovelian",
	--	[Interface.getString("language_value_eoxian")] = "Eoxian",
	--	[Interface.getString("language_value_kasatha")] = "Kasatha",
	--	[Interface.getString("language_value_shirren")] = "Shirren",
	--	[Interface.getString("language_value_trixian")] = "Triaxian",
	--	[Interface.getString("language_value_vercite")] = "Vercite",
	--	[Interface.getString("language_value_vesk")] = "Vesk",
	--	[Interface.getString("language_value_ysoki")] = "Ysoki",

	--	[Interface.getString("language_value_abyssal")] = "Abyssal",
	--	[Interface.getString("language_value_aquan")] = "Aquan",
	--	[Interface.getString("language_value_arkanen")] = "Arkanen",
	--	[Interface.getString("language_value_auran")] = "Auran",
	--	[Interface.getString("language_value_azlanti")] = "Azlanti",
	--	[Interface.getString("language_value_celestial")] = "Celestial",
	--	[Interface.getString("language_value_common")] = "",
	--	[Interface.getString("language_value_draconic")] = "Draconic",
	--	[Interface.getString("language_value_drow")] = "Drow",
	--	[Interface.getString("language_value_dwarven")] = "Dwarven",
	--	[Interface.getString("language_value_elven")] = "Elven",
	--	[Interface.getString("language_value_gnome")] = "Gnome",
	--	[Interface.getString("language_value_goblin")] = "Goblin",
	--	[Interface.getString("language_value_halfling")] = "Halfling",
	--	[Interface.getString("language_value_ignan")] = "Ignan",
	--	[Interface.getString("language_value_infernal")] = "Infernal",
	--	[Interface.getString("language_value_kalo")] = "Kalo",
	--	[Interface.getString("language_value_nchaki")] = "Nchaki",
	--	[Interface.getString("language_value_orc")] = "Orc",
	--	[Interface.getString("language_value_sarcesian")] = "Sarcesian",
	--	[Interface.getString("language_value_shobhad")] = "Shobhad",
	--	[Interface.getString("language_value_terran")] = "Terran",
	}
	languagefonts = {
		[Interface.getString("language_value_celestial")] = "Celestial",
		[Interface.getString("language_value_draconic")] = "Draconic",
		[Interface.getString("language_value_dwarven")] = "Dwarven",
		[Interface.getString("language_value_elven")] = "Elven",
		[Interface.getString("language_value_infernal")] = "Infernal",
	}

end

function getCharSelectDetailHost(nodeChar)
	local sValue = "";
	local nLevel = DB.getValue(nodeChar, "level", 0);
	if nLevel > 0 then
		sValue = "Level " .. math.floor(nLevel*100)*0.01;
	end
	return sValue;
end

function requestCharSelectDetailClient()
	return "name,#level";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails[1], "Level " .. math.floor(vDetails[2]*100)*0.01;
end

function getCharSelectDetailLocal(nodeLocal)
	local vDetails = {};
	table.insert(vDetails, DB.getValue(nodeLocal, "name", ""));
	table.insert(vDetails, DB.getValue(nodeLocal, "level", 0));
	return receiveCharSelectDetailClient(vDetails);
end

function getDistanceUnitsPerGrid()
	return 5;
end

function getDeathThreshold(rActor)
	return 10;
end

function getStabilizationRoll(rActor)
	local rRoll = { sType = "stabilization", sDesc = "[STABILIZATION]" };

	rRoll.aDice = { "d20" };
	rRoll.nMod = ActorManager2.getAbilityBonus(rActor, "constitution");

	local sType, nodeActor = ActorManager.getTypeAndNode(rActor);
	local nHP = 0;
	local nWounds = 0;
	if sType == "pc" then
		nHP = DB.getValue(nodeActor, "hp.total", 0);
		nWounds = DB.getValue(nodeActor, "hp.wounds", 0);
	else
		nHP = DB.getValue(nodeActor, "hp", 0);
		nWounds = DB.getValue(nodeActor, "wounds", 0);
	end

	if nHP > 0 and nWounds > nHP then
		rRoll.sDesc = string.format("%s [at %+d]", rRoll.sDesc, (nHP - nWounds));
		rRoll.nMod = rRoll.nMod + (nHP - nWounds);
	end

	return rRoll;
end

function modStabilization(rSource, rTarget, rRoll)
	ActionAbility.modRoll(rSource, rTarget, rRoll);
end

function getStabilizationResult(rRoll)
	local bSuccess = false;

	local nTotal = ActionsManager.total(rRoll);
	local nFirstDie = 0;
	if #(rRoll.aDice) > 0 then
		nFirstDie = rRoll.aDice[1].result or 0;
	end
	if nFirstDie >= 20 or nTotal >= 10 then
		bSuccess = true;
	end

	return bSuccess;
end

function performConcentrationCheck(draginfo, rActor, nodeSpellClass)
	local rRoll = { sType = "concentration", sDesc = "[CONCENTRATION]", aDice = { "d20" } };

	local sAbility = DB.getValue(nodeSpellClass, "dc.ability", "");
	local sAbilityEffect = DataCommon.ability_ltos[sAbility];
	if sAbilityEffect then
		rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
	end

	local nCL = DB.getValue(nodeSpellClass, "cl", 0);
	rRoll.nMod = nCL + ActorManager2.getAbilityBonus(rActor, sAbility);

	local nCCMisc = DB.getValue(nodeSpellClass, "cc.misc", 0);
	if nCCMisc ~= 0 then
		rRoll.nMod = rRoll.nMod + nCCMisc;
		rRoll.sDesc = string.format("%s (Spell Class %+d)", rRoll.sDesc, nCCMisc);
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end
