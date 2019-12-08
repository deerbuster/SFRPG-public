--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

OOB_MSGTYPE_APPLYSAVE = "applysave";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_APPLYSAVE, handleApplySave);

	ActionsManager.registerModHandler("save", modSave);
	ActionsManager.registerResultHandler("save", onSave);
end

function handleApplySave(msgOOB)
	local rSource = ActorManager.getActor(msgOOB.sSourceType, msgOOB.sSourceNode);
	local rOrigin = ActorManager.getActor(msgOOB.sTargetType, msgOOB.sTargetNode);

	local rAction = {};
	rAction.bSecret = (tonumber(msgOOB.nSecret) == 1);
	rAction.sDesc = msgOOB.sDesc;
	rAction.nTotal = tonumber(msgOOB.nTotal) or 0;
	rAction.sSaveDesc = msgOOB.sSaveDesc;
	rAction.nTarget = tonumber(msgOOB.nTarget) or 0;
	rAction.bRemoveOnMiss = (tonumber(msgOOB.nRemoveOnMiss) == 1);

	applySave(rSource, rOrigin, rAction);
end

function notifyApplySave(rSource, bSecret, rRoll)
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_APPLYSAVE;

	if rRoll.bTower then
		msgOOB.nSecret = 1;
	else
		msgOOB.nSecret = 0;
	end
	msgOOB.sDesc = rRoll.sDesc;
	msgOOB.nTotal = ActionsManager.total(rRoll);
	msgOOB.sSaveDesc = rRoll.sSaveDesc;
	msgOOB.nTarget = rRoll.nTarget;
	if rRoll.bRemoveOnMiss then msgOOB.nRemoveOnMiss = 1; end

	local sSourceType, sSourceNode = ActorManager.getTypeAndNodeName(rSource);
	msgOOB.sSourceType = sSourceType;
	msgOOB.sSourceNode = sSourceNode;

	if rRoll.sSource ~= "" then
		msgOOB.sTargetType = "ct";
		msgOOB.sTargetNode = rRoll.sSource;
	else
		msgOOB.sTargetType = "";
		msgOOB.sTargetNode = "";
	end

	Comm.deliverOOBMessage(msgOOB, "");
end

function performPartySheetRoll(draginfo, rActor, sSave)
	local rRoll = getRoll(rActor, sSave);

	local nTargetDC = DB.getValue("partysheet.savedc", 0);
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

function performVsRoll(draginfo, rActor, sSave, nTargetDC, bSecretRoll, rSource, bRemoveOnMiss, sSaveDesc)
	local rRoll = getRoll(rActor, sSave);

	if bSecretRoll then
		rRoll.bSecret = true;
	end
	rRoll.nTarget = nTargetDC;
	if bRemoveOnMiss then
		rRoll.bRemoveOnMiss = "true";
	end
	if sSaveDesc then
		rRoll.sSaveDesc = sSaveDesc;
	end
	if rSource then
		rRoll.sSource = ActorManager.getCTNodeName(rSource);
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function performRoll(draginfo, rActor, sSave)
	local rRoll = getRoll(rActor, sSave);

	if User.isHost() and CombatManager.isCTHidden(ActorManager.getCTNode(rActor)) then
		rRoll.bSecret = true;
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, sSave)
	local rRoll = {};
	rRoll.sType = "save";
	rRoll.aDice = { "d20" };
	rRoll.nMod = 0;

	-- Look up actor specific information
	local sAbility = nil;
	local sActorType, nodeActor = ActorManager.getTypeAndNode(rActor);
	if nodeActor then
		if sActorType == "pc" then
			rRoll.nMod = DB.getValue(nodeActor, "saves." .. sSave .. ".total", 0);
			sAbility = DB.getValue(nodeActor, "saves." .. sSave .. ".ability", "");
		else
			rRoll.nMod = DB.getValue(nodeActor, sSave .. "save", 0);
		end
	end

	rRoll.sDesc = "[SAVE] " .. StringManager.capitalize(sSave);
	if sAbility and sAbility ~= "" then
		if (sSave == "fortitude" and sAbility ~= "constitution") or
			(sSave == "reflex" and sAbility ~= "dexterity") or
			(sSave == "will" and sAbility ~= "wisdom") then
			local sAbilityEffect = DataCommon.ability_ltos[sAbility];
			if sAbilityEffect then
				rRoll.sDesc = rRoll.sDesc .. " [MOD:" .. sAbilityEffect .. "]";
			end
		end
	end

	return rRoll;
end

function modSave(rSource, rTarget, rRoll)
	local aAddDesc = {};
	local aAddDice = {};
	local nAddMod = 0;

	if rSource then
		local bEffects = false;

		-- Determine ability used
		local sSave = nil;
		local sSaveMatch = string.match(rRoll.sDesc, "%[SAVE%] ([^[]+)");
		if sSaveMatch then
			sSave = string.lower(StringManager.trim(sSaveMatch));
		end
		local sActionStat = nil;
		local sModStat = string.match(rRoll.sDesc, "%[MOD:(%w+)%]");
		if sModStat then
			sActionStat = DataCommon.ability_stol[sModStat];
		end
		if not sActionStat then
			if sSave == "fortitude" then
				sActionStat = "constitution";
			elseif sSave == "reflex" then
				sActionStat = "dexterity";
			elseif sSave == "will" then
				sActionStat = "wisdom";
			end
		end

		-- Build save filter
		local aSaveFilter = {};
		if sSave then
			table.insert(aSaveFilter, sSave);
		end

		-- Get effect modifiers
		local rSaveSource = nil;
		if rRoll.sSource then
			rSaveSource = ActorManager.getActor("ct", rRoll.sSource);
		end
		local nEffectCount;
		aAddDice, nAddMod, nEffectCount = EffectManagerSFRPG.getEffectsBonus(rSource, "SAVE", false, aSaveFilter, rSaveSource);
		if (nEffectCount > 0) then
			bEffects = true;
		end

		-- Get condition modifiers
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
		if sSave == "reflex" and EffectManagerSFRPG.hasEffectCondition(rSource, "Slowed") then
			nAddMod = nAddMod - 1;
			bEffects = true;
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

function onSave(rSource, rTarget, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	Comm.deliverChatMessage(rMessage);

	if rRoll.nTarget then
		notifyApplySave(rSource, rMessage.secret, rRoll);
	end
end


function applySave(rSource, rOrigin, rAction, sUser)
	local msgShort = {font = "msgfont"};
	local msgLong = {font = "msgfont"};

	msgShort.text = "Save";
	msgLong.text = "Save [" .. rAction.nTotal ..  "]";
	if rAction.nTarget then
		msgLong.text = msgLong.text .. "[vs. DC " .. rAction.nTarget .. "]";
	end
	msgShort.text = msgShort.text .. " ->";
	msgLong.text = msgLong.text .. " ->";
	if rSource then
		msgShort.text = msgShort.text .. " [for " .. rSource.sName .. "]";
		msgLong.text = msgLong.text .. " [for " .. rSource.sName .. "]";
	end
	if rOrigin then
		msgShort.text = msgShort.text .. " [vs " .. rOrigin.sName .. "]";
		msgLong.text = msgLong.text .. " [vs " .. rOrigin.sName .. "]";
	end

	msgShort.icon = "roll_cast";

	local sAttack = "";
	local bHalfMatch = false;
	if rAction.sSaveDesc then
		sAttack = rAction.sSaveDesc:match("%[SAVE VS[^]]*%] ([^[]+)") or "";
		bHalfMatch = (rAction.sSaveDesc:match("%[HALF ON SAVE%]") ~= nil);
	end
	rAction.sResult = "";

	if rAction.nTotal >= rAction.nTarget then
		msgLong.text = msgLong.text .. " [SUCCESS]";

		if rSource then
			local bHalfDamage = bHalfMatch;
			local bAvoidDamage = false;
			if bHalfDamage then
				local sSave = rAction.sDesc:match("%[SAVE%] (%w+)");
				if sSave then
					sSave = sSave:lower();
				end
				if sSave == "reflex" then
					if EffectManagerSFRPG.hasEffectCondition(rSource, "Improved Evasion") then
						bAvoidDamage = true;
						msgLong.text = msgLong.text .. " [IMPROVED EVASION]";
					elseif EffectManagerSFRPG.hasEffectCondition(rSource, "Evasion") then
						bAvoidDamage = true;
						msgLong.text = msgLong.text .. " [EVASION]";
					end
				end
			end

			if bAvoidDamage then
				rAction.sResult = "none";
				rAction.bRemoveOnMiss = false;
			elseif bHalfDamage then
				rAction.sResult = "half_success";
				rAction.bRemoveOnMiss = false;
			end

			if rOrigin and rAction.bRemoveOnMiss then
				TargetingManager.removeTarget(ActorManager.getCTNodeName(rOrigin), ActorManager.getCTNodeName(rSource));
			end
		end
	else
		msgLong.text = msgLong.text .. " [FAILURE]";

		if rSource then
			local bHalfDamage = false;
			if bHalfMatch then
				local sSave = rAction.sDesc:match("%[SAVE%] (%w+)");
				if sSave then
					sSave = sSave:lower();
				end
				if sSave == "reflex" then
					if EffectManagerSFRPG.hasEffectCondition(rSource, "Improved Evasion") then
						bHalfDamage = true;
						msgLong.text = msgLong.text .. " [IMPROVED EVASION]";
					end
				end
			end

			if bHalfDamage then
				rAction.sResult = "half_failure";
			end
		end
	end

	ActionsManager.outputResult(bSecret, rSource, rOrigin, msgLong, msgShort);

	if rSource and rOrigin then
		ActionDamage.setDamageState(rOrigin, rSource, StringManager.trim(sAttack), rAction.sResult);
	end
end
