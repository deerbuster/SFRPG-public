--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYATK = "applyatk";
OOB_MSGTYPE_APPLYHRFC = "applyhrfc";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYATK, handleApplyAttack);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYHRFC, handleApplyHRFC);

	ActionsManager.registerTargetingHandler("attack", onTargeting);
	ActionsManager.registerTargetingHandler("ab", onTargeting);

	ActionsManager.registerModHandler("attack", modAttack);
	ActionsManager.registerModHandler("cmb", modAttack);
	ActionsManager.registerModHandler("thrown", modAttack);
	ActionsManager.registerModHandler("ab", modAttack);

	ActionsManager.registerResultHandler("attack", onAttack);
	ActionsManager.registerResultHandler("ab", onAttack);
	ActionsManager.registerResultHandler("ability", onAttack);
	--ActionsManager.registerResultHandler("cmb", onGrapple);
	ActionsManager.registerResultHandler("cmb", onAttack);
	ActionsManager.registerResultHandler("thrown", onThrown);
	ActionsManager.registerResultHandler("misschance", onMissChance);
end

function handleApplyAttack(msgOOB)
	local rSource = ActorManager2.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rTarget = ActorManager2.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);

	local nTotal = tonumber(msgOOB.nTotal) or 0;
	applyAttack(rSource, rTarget, (tonumber(msgOOB.nSecret) == 1), msgOOB.sAttackType, msgOOB.sDesc, nTotal, msgOOB.sResults);
end

function notifyApplyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYATK;

	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sAttackType = sAttackType;
	msgOOB.nTotal = nTotal;
	msgOOB.sDesc = sDesc;
	msgOOB.sResults = sResults;

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;

	Comm.deliverOOBMessage(msgOOB, "");
end

function handleApplyHRFC(msgOOB)
	TableManager.processTableRoll("", msgOOB.sTable);
end

function notifyApplyHRFC(sTable)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYHRFC;

	msgOOB.sTable = sTable;

	Comm.deliverOOBMessage(msgOOB, "");
end

function onTargeting(rSource, aTargeting, rRolls)
	if OptionsManager.isOption("RMMT", "multi") then
		local aTargets = {};
		for _,vTargetGroup in ipairs(aTargeting) do
			for _,vTarget in ipairs(vTargetGroup) do
				table.insert(aTargets, vTarget);
			end
		end
		if #aTargets > 1 then
			for _,vRoll in ipairs(rRolls) do
				if not string.match(vRoll.sDesc, "%[FULL%]") then
					vRoll.bRemoveOnMiss = "true";
				end
			end
		end
	end
	return aTargeting;
end

function performPartySheetVsRoll(draginfo, rActor, rAction)
	local rRoll = getRoll(nil, rAction);

	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end

	ActionsManager.actionDirect(nil, "attack", { rRoll }, { { rActor } });
end

function performRoll(draginfo, rActor, rAction)
	--Debug.chat("Function performRoll")
	local rRoll = getRoll(rActor, rAction);

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
	--Debug.chat("Function getRoll", rAction)
	local rRoll = {};
	if rAction.cm then
		rRoll.sType = "cmb";
	elseif rAction.cr then
		rRoll.sType = "cr";
	elseif rAction.ab then
		rRoll.sType = "ab";
	else
		rRoll.sType = "attack";
	end
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.modifier or 0;

	if rAction.cm then
		rRoll.sDesc = "[CM";
		if rAction.order and rAction.order > 1 then
			rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
		end
		rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	elseif rAction.ab then
		rRoll.sDesc = "[ABILITY";
		if rAction.order and rAction.order > 1 then
			rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
		end
		if rAction.range then
			rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range .. ")";
		end
		if rAction.skill ~= "Skill" then
			local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
			local aSkillsSet = DB.getChildren(nodeActor, "skilllist");
			for _,nodeSkill in pairs (aSkillsSet) do
				local sSkillName = DB.getValue(nodeSkill, "label", "");
				local sSkillStat = DB.getValue(nodeSkill, "statname", "");
				if sSkillName == rAction.skill then
					rRoll.skill = rAction.skill;
					rRoll.skillstat = sSkillStat;
					break;
				end
			end
		end
		rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	else
		rRoll.sDesc = "[ATTACK";
		if rAction.order and rAction.order > 1 then
			rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
		end
		if rAction.range then
			rRoll.sDesc = rRoll.sDesc .. " (" .. rAction.range .. ")";
		end
		rRoll.rpreq = rAction.rp_req;
		rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;

	end
	rRoll.dcbase = rAction.dcbase;
	rRoll.dcmod = rAction.dcmod;
	rRoll.dctype = rAction.dctype;
	--rRoll.rpreq = rAction.rp_req;
	rRoll.skill = rAction.skill;
	rRoll.oppchk = rAction.opposed_chk;
	-- Add ability modifiers

	if rAction.stat ~= "" then
		--Debug.chat("STAT",rAction.stat)
		--if not rAction.ab then
		if (rAction.range == "M" and rAction.stat ~= "strength") or (rAction.range == "R" and rAction.stat ~= "dexterity") then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
		--end
	end

	-- Add other modifiers

	if rAction.touch then
		rRoll.sDesc = rRoll.sDesc .. " [vs. EAC]";
	elseif rAction.cm then
		rRoll.sDesc = rRoll.sDesc .. " [vs. CMD]";
	elseif rAction.ab then
		if rAction.dctype == "cr" then
			rRoll.sDesc = rRoll.sDesc .. " [vs. DC" .. rAction.dcbase .. " + CR]";
		elseif rAction.dctype == "cr15" then
			rRoll.sDesc = rRoll.sDesc .. " [vs. DC" .. rAction.dcbase .. " + CR*1.5]";
		elseif rAction.dctype == "kac" then
			rRoll.sDesc = rRoll.sDesc .. " [vs. DC" .. rAction.dcbase .. " + KAC]";
		elseif rAction.dctype == "eac" then
			rRoll.sDesc = rRoll.sDesc .. " [vs. DC" .. rAction.dcbase .. " + EAC]";
		elseif rAction.dcbase ~= 0 then
			rRoll.sDesc = rRoll.sDesc .. " [vs. DC" .. rAction.dcbase .. "]";
		else
			rRoll.sDesc = rRoll.sDesc;
		end
	else
		rRoll.sDesc = rRoll.sDesc .. " [vs. KAC]";
	end
	--Debug.chat(rAction)
	if rAction.crit and rAction.crit < 20 then
		rRoll.sDesc = rRoll.sDesc .. " [CRIT " .. rAction.crit .. "]";
	end
	--Debug.chat("Function getRoll(end)", rRoll)
	return rRoll;
end

function performCombatManRoll(draginfo, rActor, rAction)
	--Debug.chat("Function performCombatManRoll")
	local rRoll = getCombatManRoll(rActor, rAction);

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getCombatManRoll(rActor, rAction)
	--Debug.chat("Function getCombatManRoll")
	local rRoll = {};
	rRoll.sType = "cmb";
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.modifier or 0;
	rRoll.sDesc = "[Combat Maneuver]";

	if rAction.label and rAction.label ~= "" then
		rRoll.sDesc = rRoll.sDesc .. " " .. rAction.label;
	end

	-- Add ability modifiers
	if rAction.stat then
		if rAction.stat ~= "strength" then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end
	rRoll.sDesc = rRoll.sDesc .. " [vs. CMD]";
	return rRoll;
end

function performThrownRoll(draginfo, rActor, rAction)
	--Debug.chat("Function performThrownRoll")
	local rRoll = getThrownRoll(rActor, rAction);

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getThrownRoll(rActor, rAction)
	--Debug.chat("Function getThrownRoll")
	local rRoll = {};
	rRoll.sType = "thrown";
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.modifier or 0;

	rRoll.sDesc = "[THROWN]";
	if rAction.label and rAction.label ~= "" then
		rRoll.sDesc = rRoll.sDesc .. " " .. rAction.label;
	end

	-- Add ability modifiers
	if rAction.stat then
		if rAction.stat ~= "strength" then
			local sAbilityEffect = DataCommon.ability_ltos[rAction.stat];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end

	return rRoll;
end

function modAttack(rSource, rTarget, rRoll)
	--Debug.chat("Function modAttack",rRoll)
	clearCritState(rSource);

	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;

	-- Check for opportunity attack
	local bOpportunity = ModifierStack.getModifierKey("ATT_OPP") or Input.isShiftPressed();

	-- Check defense modifiers
	local bTouch = ModifierStack.getModifierKey("ATT_TCH");
	local bFlatFooted = ModifierStack.getModifierKey("ATT_FF"); -- Flat-footed Key on Modifier makes Attacker Flat-footed.
	local bCover = ModifierStack.getModifierKey("DEF_COVER");
	local bPartialCover = ModifierStack.getModifierKey("DEF_PCOVER");
	local bSuperiorCover = ModifierStack.getModifierKey("DEF_SCOVER");
	local bConceal = ModifierStack.getModifierKey("DEF_CONC");
	local bTotalConceal = ModifierStack.getModifierKey("DEF_TCONC");
	if bOpportunity then
		table.insert(aAddDesc, "[OPPORTUNITY]");
	end
	if bTouch then
		if not string.match(rRoll.sDesc, "%[TOUCH%]") then
			table.insert(aAddDesc, "[TOUCH]");
		end
	end
	if bFlatFooted then
		table.insert(aAddDesc, "[FF]");
	end
	if bSuperiorCover then
		table.insert(aAddDesc, "[COVER -8]");
	elseif bCover then
		table.insert(aAddDesc, "[COVER -4]");
	elseif bPartialCover then
		table.insert(aAddDesc, "[COVER -2]");
	end
	if bConceal then
		table.insert(aAddDesc, "[CONCEAL]");
	end
	if bTotalConceal then
		table.insert(aAddDesc, "[TOTAL CONC]");
	end

	if rSource then

		-- Determine attack type
		local sAttackType = nil;
		local bAbility = false;
		if rRoll.sType == "attack" then
			sAttackType = string.match(rRoll.sDesc, "%[ATTACK.*%((%w+)%)%]");
			if not sAttackType then
				sAttackType = "M";
			end
		elseif rRoll.sType == "cmb" then
			sAttackType = "M";
		elseif rRoll.sType == "ab" then
			sAttackType = "AB";
			bAbility = true;
		end

		-- Determine ability used
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end

		if not sActionStat then
			if sAttackType == "M" then
				sActionStat = "strength";
			elseif sAttackType == "R" then
				sActionStat = "dexterity";
			elseif bAbility then
				sActionStat = rRoll.skillstat;
			end
		end

		-- Build attack filter
		local aAttackFilter = {};
		if sAttackType == "M" then
			table.insert(aAttackFilter, "melee");
		elseif sAttackType == "R" then
			table.insert(aAttackFilter, "ranged");
		elseif bAbility then
			table.insert(aAttackFilter, "ability");
		end
		if bOpportunity then
			table.insert(aAttackFilter, "opportunity");
		end

		-- Get attack effect modifiers

		local bEffects = false;
		if rRoll.sType == "ab" then
			--local bEffects = false;
			local nEffectCount;
			aAddDice, nAddMod, nEffectCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"SKILL"}, false, aAttackFilter);

			if (nEffectCount > 0) then
				bEffects = true;
			end
		else
			--local bEffects = false;
			local nEffectCount;
			aAddDice, nAddMod, nEffectCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"ATK"}, false, aAttackFilter);
			if (nEffectCount > 0) then
				bEffects = true;
			end
		end

		if rRoll.sType == "cmb" then
			local aPFDice, nPFMod, nPFCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"CMB"}, false, aAttackFilter);

			if nPFCount > 0 then
				bEffects = true;
				for k, v in ipairs(aPFDice) do
					table.insert(aAddDice, v);
				end
				nAddMod = nAddMod + nPFMod;
			end
		end

		-- Get condition modifiers
		if EffectManagerSFRPG.hasEffect(rSource, "Blinded") then
			bEffects = true;
			table.insert(aAddDesc, "[BLINDED]");
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Dazzled") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Slowed") then
			bEffects = true;
			nAddMod = nAddMod - 1;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Entangled") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if rRoll.sType == "attack" and
			(EffectManagerSFRPG.hasEffectCondition(rSource, "Pinned") or
			EffectManagerSFRPG.hasEffectCondition(rSource, "Grappled")) then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Frightened") or
			EffectManagerSFRPG.hasEffectCondition(rSource, "Shaken") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Sickened") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		-- Get other effect modifiers
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Squeezing") then
			bEffects = true;
			nAddMod = nAddMod - 4;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Prone") then
			if sAttackType == "M" then
				bEffects = true;
				nAddMod = nAddMod - 4;
			end
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Off-kilter") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Off-target") then
			bEffects = true;
			nAddMod = nAddMod - 2;
		end

		-- Get ability modifiers
		local nBonusStat, nBonusEffects = ActorManager2.getAbilityEffectsBonus(rSource, sActionStat);

		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end

		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end

		-- If effects, then add them
		if bEffects then
			local sEffects = "";
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = "[" .. Interface.getString("effects_tag") .. " " .. sMod .. "]";
			else
				sEffects = "[" .. Interface.getString("effects_tag") .. "]";
			end
			table.insert(aAddDesc, sEffects);
		end
	end

	if bSuperiorCover then
		nAddMod = nAddMod - 8;
	elseif bCover then
		nAddMod = nAddMod - 4;
	elseif bPartialCover then
		nAddMod = nAddMod - 2;
	end

	if #aAddDesc > 0 then
		rRoll.sDesc = rRoll.sDesc .. " " .. table.concat(aAddDesc, " ");
	end
	for _,vDie in ipairs(aAddDice) do
		if vDie:sub(1,1) == "-" then
			table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
		else
			table.insert(rRoll.aDice, "p" .. vDie:sub(2));
		end
	end
	----Debug.chat(rRoll)
	rRoll.nMod = rRoll.nMod + nAddMod;
end

function onAttack(rSource, rTarget, rRoll)
	--Debug.chat("Function onAttack(rRoll)", rRoll,rSource, rSource.sType)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local bIsSourcePC = (rSource and rSource.sType == "pc");
	rRoll.dcbase = tonumber(rRoll.dcbase);
	rRoll.dcmod = tonumber(rRoll.dcmod);
	rRoll.oppchk = tonumber(rRoll.oppchk);

	if rRoll.sDesc:match("%[CMB") then
		rRoll.sType = "cmb";
	end

	local rAction = {};
	rAction.nTotal = ActionsManager.total(rRoll);
	rAction.aMessages = {};
	--Debug.chat("Roll Type",rRoll.sType)
	-- If we have a target, then calculate the defense we need to exceed
	local nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus, nMissChance;
	nDefenseVal, nAtkEffectsBonus, nDefEffectsBonus, nMissChance = ActorManager2.getDefenseValue(rSource, rTarget, rRoll);
	if nAtkEffectsBonus ~= 0 then
		rAction.nTotal = rAction.nTotal + nAtkEffectsBonus;
		local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]"
		table.insert(rAction.aMessages, string.format(sFormat, nAtkEffectsBonus));
	end
	if nDefEffectsBonus ~= 0 then
		nDefenseVal = nDefenseVal + nDefEffectsBonus;
		local sFormat = "[" .. Interface.getString("effects_def_tag") .. " %+d]"
		table.insert(rAction.aMessages, string.format(sFormat, nDefEffectsBonus));
	end
	if rTarget then
		local nDCbase = rRoll.dcbase
		if nDCbase == nil then
			nDCbase = 0;
		end
		local nDCmod = rRoll.dcmod
		if nDCmod == nil then
			nDCmod = 0;
		end

		local nodeTarget = ActorManager.getCreatureNode(rTarget);
		local nType = 0;
		if rRoll.sType == "ab" then
			if nodeTarget then
				if rRoll.dctype == "cr" then
					nType = DB.getValue(nodeTarget, "cr", 0);
					if nType < 1 or nType == nil then
						nType = 0;
					end
					nDefenseVal = rRoll.dcbase + rRoll.dcmod + nType;
				elseif rRoll.dctype == "cr15" then
					nType = DB.getValue(nodeTarget, "cr", 0);
					nType = nType + (math.floor(nType / 2));
					if nType < 1 then
						nType = 0;
					end
					nDefenseVal = nDCbase + nDCmod + nType;
				elseif rRoll.dctype == "kac" then
					nType = DB.getValue(nodeTarget, "kac", 0);
					nDefenseVal = nDCbase + nDCmod + nType;
				elseif rRoll.dctype == "eac" then
					nType = DB.getValue(nodeTarget, "eac", 0);
					nDefenseVal = nDCbase + nDCmod + nType;
				else
					nDefenseVal = nDCbase + nDCmod;
				end
			end
		elseif rRoll.sType == "cmb" then
			--Debug.chat("Yes CMB")
			nDefenseVal = nDefenseVal + nDCbase + nDCmod;
		elseif rRoll.sType == "attack" then
			nDefenseVal = nDefenseVal + nDCbase + nDCmod;
		--	nDefenseVal = rRoll.dcbase + rRoll.dcmod;
		end
	end
	-- Get the crit threshold
	rAction.nCrit = 20;
	local sAltCritRange = string.match(rRoll.sDesc, "%[CRIT (%d+)%]");
	if sAltCritRange then
		rAction.nCrit = tonumber(sAltCritRange) or 20;
		if (rAction.nCrit <= 1) or (rAction.nCrit > 20) then
			rAction.nCrit = 20;
		end
	end

	rAction.nFirstDie = 0;
	if #(rRoll.aDice) > 0 then
		rAction.nFirstDie = rRoll.aDice[1].result or 0;
	end

	rAction.bCritThreat = false;

	
	
	if rAction.nFirstDie >= rAction.nCrit then
	--Debug.chat(rAction,rSource.sType)
		rAction.bSpecial = true;
		if rRoll.sType == "attack" then
			local nTotal = rRoll.aDice[1].result + rRoll.nMod;

			if rTarget == nil then
				nDefenseVal = 0;
			end	
			if  rSource.sType == "pc" then
				if nTotal >= nDefenseVal then
					rAction.sResult = "crit";
					table.insert(rAction.aMessages, "[CRITICAL HIT]");
				else
					rAction.sResult = "hit";
					table.insert(rAction.aMessages, "[AUTOMATIC HIT]");
				end
			else
				rAction.sResult = "crit";
				table.insert(rAction.aMessages, "[CRITICAL HIT]");
			end
		end
		if rRoll.sType == "ab" then
			local nTotal = rRoll.aDice[1].result + rRoll.nMod;

			if rTarget == nil then
				nDefenseVal = 0;
			end
			rAction.sResult = "hit";
			table.insert(rAction.aMessages, "[AUTOMATIC SUCCESS]");
		end

	elseif rAction.nFirstDie == 1 then
		if rRoll.sType == "ab" then
			table.insert(rAction.aMessages, "[AUTOMATIC FAIL]");
			rAction.sResult = "fail";
		else
			table.insert(rAction.aMessages, "[AUTOMATIC MISS]");
			rAction.sResult = "fumble";
		end
	elseif nDefenseVal then

		if rAction.nTotal >= nDefenseVal then
			--if (rRoll.sType == "attack" or rRoll.sType == "ab" or rRoll.sType == "cmb") and rAction.nFirstDie >= rAction.nCrit then
			if (rRoll.sType == "attack" ) and rAction.nFirstDie >= rAction.nCrit then
				rAction.sResult = "crit";
				table.insert(rAction.aMessages, "[CRITICAL HIT]");
			else
				if rRoll.sType == "attack" then
					rAction.sResult = "hit";
					table.insert(rAction.aMessages, "[HIT vs. " .. nDefenseVal .. " Defense]");
				elseif rRoll.sType == "cmb" then
					rAction.sResult = "hit";
					table.insert(rAction.aMessages, "[HIT vs. " .. nDefenseVal .. " CMD]");

				else
					rAction.sResult = "hit";
					if nDefenseVal == 0 then
						if rRoll.oppchk == 1 then
							table.insert(rAction.aMessages, "[OPPOSED CHECK]");
						else
							table.insert(rAction.aMessages, "[SUCCESS]");
						end
					else
						table.insert(rAction.aMessages, "[SUCCESS vs. DC" .. nDefenseVal .. "]");
					end
				end
			end
		else
			if rRoll.sType == "attack" then
				rAction.sResult = "miss";
				table.insert(rAction.aMessages, "[MISS]");
			else
				rAction.sResult = "miss";
				if rRoll.oppchk == 1 then
					table.insert(rAction.aMessages, "[OPPOSED CHECK]");
				else
					table.insert(rAction.aMessages, "[FAILED]");
				end
			end
		end
	elseif rRoll.sType == "attack" and rAction.nFirstDie >= rAction.nCrit then
		rAction.sResult = "crit";
		table.insert(rAction.aMessages, "[CHECK FOR CRITICAL]");
	end

	Comm.deliverChatMessage(rMessage);

	if rAction.sResult == "crit" then
		setCritState(rSource, rTarget);
	end

	if rTarget then
		notifyApplyAttack(rSource, rTarget, rRoll.bTower, rRoll.sType, rRoll.sDesc, rAction.nTotal, table.concat(rAction.aMessages, " "));

		-- REMOVE TARGET ON MISS OPTION
		if (rAction.sResult == "miss" or rAction.sResult == "fumble") and not string.match(rRoll.sDesc, "%[FULL%]") then
			local bRemoveTarget = false;
			if OptionsManager.isOption("RMMT", "on") then
				bRemoveTarget = true;
			elseif rRoll.bRemoveOnMiss then
				bRemoveTarget = true;
			end

			if bRemoveTarget then
				TargetingManager.removeTarget(ActorManager.getCTNodeName(rSource), ActorManager.getCTNodeName(rTarget));
			end
		end
	end
	if nMissChance == nil then
		nMissChance = 0;
	end
	if rAction.sResult ~= "miss" and nMissChance > 0 then
		table.insert(rAction.aMessages, "[MISS CHANCE " .. nMissChance .. "%]");
		local aMissChanceDice = { "d100" };
		if Interface.getVersion() < 4 then
			table.insert(aMissChanceDice, "d10");
		end
		local rMissChanceRoll = { sType = "misschance", sDesc = rRoll.sDesc .. " [MISS CHANCE " .. nMissChance .. "%]", aDice = aMissChanceDice, nMod = 0 };
		ActionsManager.roll(rSource, rTarget, rMissChanceRoll);
	end

	-- HANDLE FUMBLE/CRIT HOUSE RULES
	local sOptionHRFC = OptionsManager.getOption("HRFC");
	if rAction.sResult == "fumble" and ((sOptionHRFC == "both") or (sOptionHRFC == "fumble")) then
		notifyApplyHRFC("Fumble");
	end
	if rAction.sResult == "crit" and ((sOptionHRFC == "both") or (sOptionHRFC == "criticalhit")) then
		notifyApplyHRFC("Critical Hit");
	end
end

function onGrapple(rSource, rTarget, rRoll)
	--Debug.chat("Function onGrapple()")
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	if rTarget then
		rMessage.text = rMessage.text .. " [at " .. rTarget.sName .. "]";
	end

	if not rSource then
		rMessage.sender = nil;
	end
	Comm.deliverChatMessage(rMessage);

end

function onMissChance(rSource, rTarget, rRoll)
	--Debug.chat("Function onMissChance")
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	local nTotal = ActionsManager.total(rRoll);
	local nMissChance = tonumber(string.match(rMessage.text, "%[MISS CHANCE (%d+)%%%]")) or 0;
	if nTotal <= nMissChance then
		rMessage.text = rMessage.text .. " [MISS]";
		if rTarget then
			rMessage.icon = "roll_attack_miss";
			clearCritState(rSource, rTarget);
		else
			rMessage.icon = "roll_attack";
		end
	else
		rMessage.text = rMessage.text .. " [HIT]";
		if rTarget then
			rMessage.icon = "roll_attack_hit";
		else
			rMessage.icon = "roll_attack";
		end
	end

	Comm.deliverChatMessage(rMessage);
end

function applyAttack(rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	--Debug.chat("Function applyAttack()",rSource, rTarget, bSecret, sAttackType, sDesc, nTotal, sResults)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};

	if sAttackType == "cmb" then
		msgShort.text = "Combat Man. ->";
		msgLong.text = "Combat Man. [" .. nTotal .. "] ->";
	else
		if sAttackType == "ab" then
			msgShort.text = "Check ->";
			if sResults ~= "" then
				msgLong.text = "Check [" .. nTotal .. "]--" .. sResults .. " ->";
			else
				msgLong.text = "Check [" .. nTotal .. "] ->";
			end
		else
			msgShort.text = "Attack ->";
			msgLong.text = "Attack [" .. nTotal .. "] ->";
		end
	end
	if rTarget then
		if sAttackType == "ab" then
			msgShort.text = msgShort.text .. " [" .. rTarget.sName .. "]";
			msgLong.text = msgLong.text .. " [" .. rTarget.sName .. "]";
		else
			msgShort.text = msgShort.text .. " [at " .. rTarget.sName .. "]";
			msgLong.text = msgLong.text .. " [at " .. rTarget.sName .. "]";
		end
	end
	if sResults ~= "" and sAttackType ~= "ab" then
		msgLong.text = msgLong.text .. " " .. sResults;
	end

	msgShort.icon = "roll_attack";
	if string.match(sResults, "%[CRITICAL HIT%]") then
		msgLong.icon = "roll_attack_crit";
	elseif string.match(sResults, "HIT%]") then
		msgLong.icon = "roll_attack_hit";
	elseif string.match(sResults, "MISS%]") then
		msgLong.icon = "roll_attack_miss";
	elseif string.match(sResults, "CRITICAL THREAT%]") then
		msgLong.icon = "roll_attack_hit";
	else
		msgLong.icon = "roll_attack";
	end

	ActionsManager.outputResult(bSecret, rSource, rTarget, msgLong, msgShort);
end

local aCritState = {};

function setCritState(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end

	if not aCritState[sSourceCT] then
		aCritState[sSourceCT] = {};
	end
	table.insert(aCritState[sSourceCT], sTargetCT);
end

function clearCritState(rSource, rTarget)
	if rTarget then
		isCrit(rSource, rTarget);
		return;
	end

	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT ~= "" then
		aCritState[sSourceCT] = nil;
	end
end

function isCrit(rSource, rTarget)
	local sSourceCT = ActorManager.getCreatureNodeName(rSource);
	if sSourceCT == "" then
		return;
	end
	local sTargetCT = "";
	if rTarget then
		sTargetCT = ActorManager.getCTNodeName(rTarget);
	end

	if not aCritState[sSourceCT] then
		return false;
	end

	for k,v in ipairs(aCritState[sSourceCT]) do
		if v == sTargetCT then
			table.remove(aCritState[sSourceCT], k);
			return true;
		end
	end

	return false;
end
