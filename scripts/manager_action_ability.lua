--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
OOB_MSGTYPE_APPLYSAVEVS = "applysavevs";

function onInit()
	ActionsManager.registerModHandler("ab", modRoll);
	ActionsManager.registerResultHandler("ab", onRoll);
	ActionsManager.registerModHandler("ability", modRoll);
	ActionsManager.registerResultHandler("ability", onRoll);
	-- Ability Tab Section
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYSAVEVS, handleApplySave);

	ActionsManager.registerTargetingHandler("cast", onAbilityTargeting);
	ActionsManager.registerTargetingHandler("clc", onAbilityTargeting);
	ActionsManager.registerTargetingHandler("ab", onAbilityTargeting);
	ActionsManager.registerTargetingHandler("spellsave", onAbilityTargeting);

	ActionsManager.registerModHandler("castsave", modCastSave);
	ActionsManager.registerModHandler("spellsave", modCastSave);
	ActionsManager.registerModHandler("clc", modCLC);
	ActionsManager.registerModHandler("ab", modDC);
	ActionsManager.registerModHandler("concentration", modConcentration);

	ActionsManager.registerResultHandler("cast", onAbilityCast);
	ActionsManager.registerResultHandler("ab", onAbilityCast)
	ActionsManager.registerResultHandler("castclc", onCastCLC);
	ActionsManager.registerResultHandler("castsave", onCastSave);
	ActionsManager.registerResultHandler("clc", onCLC);
	ActionsManager.registerResultHandler("spellsave", onAbilitySave);
end

-- Iterate through each spell to reset
function resetUsesPerDay(nodeChar)
	for _,nodeAbilityClass in pairs(DB.getChildren(nodeChar, "abilityset")) do
		for _,nodeLevel in pairs(DB.getChildren(nodeAbilityClass, "levels")) do
			for _,nodeAbility in pairs(DB.getChildren(nodeLevel, "abilities")) do
				DB.setValue(nodeAbility, "cast", "number", 0);
			end
		end
	end
end

function performPartySheetRoll(draginfo, rActor, sAbilityStat)
	local rRoll = getRoll(rActor, sAbilityStat);

	local nTargetDC = DB.getValue("partysheet.abilitydc", 0);
	if nTargetDC == 0 then
		nTargetDC = nil;
	end
	rRoll.nTarget = nTargetDC;
	if DB.getValue("partysheet.hiderollresults", 0) == 1 then
		rRoll.bSecret = true;
		rRoll.bTower = true;
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function performRoll(draginfo, rActor, sAbilityStat)
	local rRoll = getRoll(rActor, sAbilityStat);

	if User.isHost() and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, sAbilityStat)
	local rRoll = {};
	rRoll.sType = "ability";
	rRoll.aDice = { "d20" };
	rRoll.nMod = ActorManager2.getAbilityBonus(rActor, sAbilityStat);

	rRoll.sDesc = "[ABILITY]";
	rRoll.sDesc = rRoll.sDesc .. " " .. StringManager.capitalize(sAbilityStat);
	rRoll.sDesc = rRoll.sDesc .. " check";

	return rRoll;
end

function modRoll(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;

	if rSource then
		local bEffects = false;

		local sActionStat = nil;
		local sAbility = string.match(rRoll.sDesc, "%[ABILITY%] (%w+) check");
		if sAbility then
			sAbility = string.lower(sAbility);
		else
			if string.match(rRoll.sDesc, "%[STABILIZATION%]") then
				sAbility = "constitution";
			end
		end

		-- GET ACTION MODIFIERS
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"ABIL"}, false, {sAbility});
		if (nEffectCount > 0) then
			bEffects = true;
		end

		-- GET CONDITION MODIFIERS
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Frightened") or
			EffectManagerSFRPG.hasEffectCondition(rSource, "Panicked") or
			EffectManagerSFRPG.hasEffectCondition(rSource, "Shaken") then
			nAddMod = nAddMod - 2;
			bEffects = true;
		end
		if EffectManagerSFRPG.hasEffectCondition(rSource, "Sickened") then
			nAddMod = nAddMod - 2;
			bEffects = true;
		end

		-- GET STAT MODIFIERS
		local nBonusStat, nBonusEffects = ActorManager2.getAbilityEffectsBonus(rSource, sAbility);
		if nBonusEffects > 0 then
			bEffects = true;
			nAddMod = nAddMod + nBonusStat;
		end

		-- HANDLE NEGATIVE LEVELS
		local nNegLevelMod, nNegLevelCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			nAddMod = nAddMod - nNegLevelMod;
			bEffects = true;
		end

		-- IF EFFECTS HAPPENED, THEN ADD NOTE
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
	rRoll.nMod = rRoll.nMod + nAddMod;
end

function onRoll(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	if rRoll.nTarget then
		local nTotal = ActionsManager.total(rRoll);
		local nTargetDC = tonumber(rRoll.nTarget) or 0;

		rMessage.text = rMessage.text .. " (vs. DC " .. nTargetDC .. ")";
		if nTotal >= nTargetDC then
			rMessage.text = rMessage.text .. " [SUCCESS]";
		else
			rMessage.text = rMessage.text .. " [FAILURE]";
		end
	end

	Comm.deliverChatMessage(rMessage);
end

-- Ability Tab Section
function handleApplySave(msgOOB)
	-- GET THE TARGET ACTOR
	local rSource = ActorManager2.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rTarget = ActorManager2.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);

	local sSaveShort, sSaveDC = string.match(msgOOB.sDesc, "%[(%w+) DC (%d+)%]")
	if sSaveShort then
		local sSave = DataCommon.save_stol[sSaveShort];
		if sSave then
			ActionSave.performVsRoll(nil, rTarget, sSave, msgOOB.nDC, (tonumber(msgOOB.nSecret) == 1), rSource, msgOOB.bRemoveOnMiss, msgOOB.sDesc);
		end
	end
end

function notifyApplySave(rSource, rTarget, bSecret, sDesc, nDC, bRemoveOnMiss)
	if not rTarget then
		return;
	end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYSAVEVS;

	if bSecret then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sDesc = sDesc;
	msgOOB.nDC = nDC;

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	local sTargetType, sTargetNode = ActorManager.getTypeAndNodeName(rTarget);
	msgOOB.sTargetType = sTargetType;
	msgOOB.sTargetNode = sTargetNode;

	if bRemoveOnMiss then
		msgOOB.bRemoveOnMiss = 1;
	end

	if ActorManager.getType(rTarget) == "pc" then
		local nodePC = ActorManager.getCreatureNode(rTarget);
		if nodePC then
			if User.isHost() then
				local sOwner = DB.getOwner(nodePC);
				if sOwner ~= "" then
					for _,vUser in ipairs(User.getActiveUsers()) do
						if vUser == sOwner then
							for _,vIdentity in ipairs(User.getActiveIdentities(vUser)) do
								if nodePC.getName() == vIdentity then
									Comm.deliverOOBMessage(msgOOB, sOwner);
									return;
								end
							end
						end
					end
				end
			else
				if DB.isOwner(nodePC) then
					handleApplySave(msgOOB);
					return;
				end
			end
		end
	end

	Comm.deliverOOBMessage(msgOOB, "");
end

function onAbilityTargeting(rSource, aTargeting, rRolls)
	local bRemoveOnMiss = false;
	local sOptRMMT = OptionsManager.getOption("RMMT");
	if sOptRMMT == "on" then
		bRemoveOnMiss = true;
	elseif sOptRMMT == "multi" then
		local aTargets = {};
		for _,vTargetGroup in ipairs(aTargeting) do
			for _,vTarget in ipairs(vTargetGroup) do
				table.insert(aTargets, vTarget);
			end
		end
		bRemoveOnMiss = (#aTargets > 1);
	end

	if bRemoveOnMiss then
		for _,vRoll in ipairs(rRolls) do
			vRoll.bRemoveOnMiss = "true";
		end
	end

	return aTargeting;
end

function getAbilityCastRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "cast";
	rRoll.aDice = {};
	rRoll.nMod = 0;

	rRoll.sDesc = "[use";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;

	return rRoll;
end

function getCLCRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "clc";
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.clc or 0;

	rRoll.sDesc = "[CL CHECK";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	if rAction.sr == "no" then
		rRoll.sDesc = rRoll.sDesc .. " [SR NOT ALLOWED]";
	end

	return rRoll;
end

function getDCRoll(rActor, rAction)
	--Debug.chat("getDCRoll",rActor, rAction)
	local rRoll = {};
	rRoll.sType = "ab";
	rRoll.aDice = { "d20" };
	rRoll.nMod = rAction.dc or 0;
	rRoll.nMod = 0;
	rRoll.sDesc = "[ABILITY CHECK";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;

	return rRoll;
end

function getSaveVsRoll(rActor, rAction)
	local rRoll = {};
	rRoll.sType = "spellsave";
	rRoll.aDice = {};
	rRoll.nMod = rAction.savemod or 0;

	rRoll.sDesc = "[SAVE VS";
	if rAction.order and rAction.order > 1 then
		rRoll.sDesc = rRoll.sDesc .. " #" .. rAction.order;
	end
	rRoll.sDesc = rRoll.sDesc .. "] " .. rAction.label;
	if rAction.save == "fortitude" then
		rRoll.sDesc = rRoll.sDesc .. " [FORT DC " .. rAction.savemod .. "]";
	elseif rAction.save == "reflex" then
		rRoll.sDesc = rRoll.sDesc .. " [REF DC " .. rAction.savemod .. "]";
	elseif rAction.save == "will" then
		rRoll.sDesc = rRoll.sDesc .. " [WILL DC " .. rAction.savemod .. "]";
	end

	if rAction.dcstat then
		local sAbilityEffect = DataCommon.ability_ltos[rAction.dcstat];
		if sAbilityEffect then
			rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
		end
	end
	if rAction.onmissdamage == "half" then
		rRoll.sDesc = rRoll.sDesc .. " [HALF ON SAVE]";
	end

	return rRoll;
end

function modCastSave(rSource, rTarget, rRoll)
	if rSource then
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		if sActionStat then
			local nBonusStat, nBonusEffects = ActorManager2.getAbilityEffectsBonus(rSource, sActionStat);
			if nBonusEffects > 0 then
				local sFormat = "[" .. Interface.getString("effects_tag") .. " %+d]";
				rRoll.sDesc = rRoll.sDesc .. " " .. string.format(sFormat, nBonusStat);
				rRoll.nMod = rRoll.nMod + nBonusStat;
			end
		end
	end
end

function modCLC(rSource, rTarget, rRoll)
	if rSource then
		local aAddDice = {};
		local nAddMod = 0;
		local bEffects = false;

		-- Get CLC modifier effects
		local nCLCMod, nCLCCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"CLC"}, true, nil, rTarget);
		if nCLCCount > 0 then
			bEffects = true;
			nAddMod = nAddMod + nCLCMod;
		end

		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end

		if bEffects then
			local sEffects = "[" .. Interface.getString("effects_tag");
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = sEffects .. " " .. sMod;
			end
			sEffects = sEffects .. "]";
			rRoll.sDesc = rRoll.sDesc .. " " .. sEffects;
			for _,vDie in ipairs(aAddDice) do
				if vDie:sub(1,1) == "-" then
					table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
				else
					table.insert(rRoll.aDice, "p" .. vDie:sub(2));
				end
			end
			rRoll.nMod = rRoll.nMod + nAddMod;
		end
	end
end

function modDC(rSource, rTarget, rRoll)
	--Debug.chat("ModDC")
	if rSource then
		local aAddDice = {};
		local nAddMod = 0;
		local bEffects = false;
		--Get DC modifier
		local nDCMod, nCLCCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"DC"}, true, nil, rTarget);
		if nCLCCount > 0 then
			bEffects = true;
			nAddMod = nAddMod + nDCMod;
		end


		-- Get negative levels
		local nNegLevelMod, nNegLevelCount = EffectManagerSFRPG.getEffectsBonus(rSource, {"NLVL"}, true);
		if nNegLevelCount > 0 then
			bEffects = true;
			nAddMod = nAddMod - nNegLevelMod;
		end

		if bEffects then
			local sEffects = "[" .. Interface.getString("effects_tag");
			local sMod = StringManager.convertDiceToString(aAddDice, nAddMod, true);
			if sMod ~= "" then
				sEffects = sEffects .. " " .. sMod;
			end
			sEffects = sEffects .. "]";
			rRoll.sDesc = rRoll.sDesc .. " " .. sEffects;
			for _,vDie in ipairs(aAddDice) do
				if vDie:sub(1,1) == "-" then
					table.insert(rRoll.aDice, "-p" .. vDie:sub(3));
				else
					table.insert(rRoll.aDice, "p" .. vDie:sub(2));
				end
			end
			rRoll.nMod = rRoll.nMod + nAddMod;
		end
	end
end

function modConcentration(rSource, rTarget, rRoll)
	if rSource then
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end

		local nBonusStat, nBonusEffects = ActorManager2.getAbilityEffectsBonus(rSource, sActionStat);
		if nBonusEffects > 0 then
			rRoll.nMod = rRoll.nMod + nBonusStat;

			if nBonusStat ~= 0 then
				local sFormat = "%s [" .. Interface.getString("effects_tag") .. " %+d]";
				rRoll.sDesc = string.format(sFormat, rRoll.sDesc, nBonusStat);
			else
				rRoll.sDesc = rRoll.sDesc .. " [" .. Interface.getString("effects_tag") .. "]";
			end
		end
	end
end

function onAbilityCast(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	rMessage.dice = nil;
	rMessage.icon = "spell_cast";

	if rTarget then
		rMessage.text = rMessage.text .. " [at " .. rTarget.sName .. "]";
	end

	Comm.deliverChatMessage(rMessage);
end

function onCastCLC(rSource, rTarget, rRoll)
	if rTarget then
		local nSR = ActorManager2.getSpellDefense(rTarget);
		if nSR > 0 then
			if not string.match(rRoll.sDesc, "%[SR NOT ALLOWED%]") then
				local rRoll = { sType = "clc", sDesc = rRoll.sDesc, aDice = {"d20"}, nMod = rRoll.nMod, bRemoveOnMiss = rRoll.bRemoveOnMiss };
				ActionsManager.roll(rSource, rTarget, rRoll);
				return true;
			end
		end
	end
end

function onCastSave(rSource, rTarget, rRoll)
	if rTarget then
		local sSaveShort, sSaveDC = string.match(rRoll.sDesc, "%[(%w+) DC (%d+)%]")
		if sSaveShort then
			local sSave = DataCommon.save_stol[sSaveShort];
			if sSave then
				notifyApplySave(rSource, rTarget, rRoll.bSecret, rRoll.sDesc, rRoll.nMod, rRoll.bRemoveOnMiss);
				return true;
			end
		end
	end

	return false;
end

function onCLC(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local nTotal = ActionsManager.total(rRoll);
	local bSRAllowed = not string.match(rRoll.sDesc, "%[SR NOT ALLOWED%]");

	if rTarget then
		rMessage.text = rMessage.text .. " [at " .. rTarget.sName .. "]";

		if bSRAllowed then
			local nSR = ActorManager2.getSpellDefense(rTarget);
			if nSR > 0 then
				if nTotal >= nSR then
					rMessage.text = rMessage.text .. " [SUCCESS]";
				else
					rMessage.text = rMessage.text .. " [FAILURE]";
					if rSource then
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
			else
				rMessage.text = rMessage.text .. " [TARGET HAS NO SR]";
			end
		end
	end

	Comm.deliverChatMessage(rMessage);
end

function onAbilitySave(rSource, rTarget, rRoll)
	if onCastSave(rSource, rTarget, rRoll) then
		return;
	end

	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);
end
