--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
OOB_MSGTYPE_APPLYEFF = "applyeff";
OOB_MSGTYPE_EXPIREEFF = "expireeff";

EFFECT_TAG = "EFFECT";

local nLocked = 0;
local aExpireOnLockRelease = {};

local aEffectVarMap = {
	["sName"] = { sDBType = "string", sDBField = "label" },
	["nGMOnly"] = { sDBType = "number", sDBField = "isgmonly" },
	["sSource"] = { sDBType = "string", sDBField = "source_name", bClearOnUntargetedDrop = true },
	["sTarget"] = { sDBType = "string", bClearOnUntargetedDrop = true },
	["nDuration"] = { sDBType = "number", sDBField = "duration", vDBDefault = 1, sDisplay = "[D: %d]" },
	["nInit"] = { sDBType = "number", sDBField = "init", sSourceChangeSet = "initresult", bClearOnUntargetedDrop = true },
};
-- NOTE: isactive is a DB field that is part of all CT effects, but not tracked in the effect record

function onInit()
	EffectManager.registerEffectVar("sUnits", { sDBType = "string", sDBField = "unit", bSkipAdd = true });
	EffectManager.registerEffectVar("sApply", { sDBType = "string", sDBField = "apply", sDisplay = "[%s]" });
	EffectManager.registerEffectVar("sTargeting", { sDBType = "string", bClearOnUntargetedDrop = true });

	EffectManager.setCustomOnEffectAddStart(onEffectAddStart);

	EffectManager.setCustomOnEffectRollEncode(onEffectRollEncode);
	EffectManager.setCustomOnEffectTextEncode(onEffectTextEncode);
	EffectManager.setCustomOnEffectTextDecode(onEffectTextDecode);

	EffectManager.setCustomOnEffectActorStartTurn(onEffectActorStartTurn);


end

--
-- EFFECT MANAGER OVERRIDES
--

function onEffectAddStart(rEffect)
	rEffect.nDuration = rEffect.nDuration or 1;
	if rEffect.sUnits == "minute" then
		rEffect.nDuration = rEffect.nDuration * 10;
	elseif rEffect.sUnits == "hour" or rEffect.sUnits == "day" then
		rEffect.nDuration = 0;
	end
	rEffect.sUnits = "";
end

function onEffectRollEncode(rRoll, rEffect)
	if rEffect.sTargeting and rEffect.sTargeting == "self" then
		rRoll.bSelfTarget = true;
	end
end

function onEffectTextEncode(rEffect)
	local aMessage = {};

	if rEffect.sUnits and rEffect.sUnits ~= "" then
		local sOutputUnits = nil;
		if rEffect.sUnits == "minute" then
			sOutputUnits = "MIN";
		elseif rEffect.sUnits == "hour" then
			sOutputUnits = "HR";
		elseif rEffect.sUnits == "day" then
			sOutputUnits = "DAY";
		end

		if sOutputUnits then
			table.insert(aMessage, "[UNITS " .. sOutputUnits .. "]");
		end
	end
	if rEffect.sTargeting and rEffect.sTargeting ~= "" then
		table.insert(aMessage, "[" .. rEffect.sTargeting:upper() .. "]");
	end
	if rEffect.sApply and rEffect.sApply ~= "" then
		table.insert(aMessage, "[" .. rEffect.sApply:upper() .. "]");
	end

	return table.concat(aMessage, " ");
end

function onEffectTextDecode(sEffect, rEffect)
	local s = sEffect;

	local sUnits = s:match("%[UNITS ([^]]+)]");
	if sUnits then
		s = s:gsub("%[UNITS ([^]]+)]", "");
		if sUnits == "MIN" then
			rEffect.sUnits = "minute";
		elseif sUnits == "HR" then
			rEffect.sUnits = "hour";
		elseif sUnits == "DAY" then
			rEffect.sUnits = "day";
		end
	end
	if s:match("%[SELF%]") then
		s = s:gsub("%[SELF%]", "");
		rEffect.sTargeting = "self";
	end
	if s:match("%[ACTION%]") then
		s = s:gsub("%[ACTION%]", "");
		rEffect.sApply = "action";
	elseif s:match("%[ROLL%]") then
		s = s:gsub("%[ROLL%]", "");
		rEffect.sApply = "roll";
	elseif s:match("%[SINGLE%]") then
		s = s:gsub("%[SINGLE%]", "");
		rEffect.sApply = "single";
	end

	return s;
end

function onEffectActorStartTurn(nodeActor, nodeEffect)
	local sEffName = DB.getValue(nodeEffect, "label", "");
	local aEffectComps = EffectManager.parseEffect(sEffName);

	for _,sEffectComp in ipairs(aEffectComps) do
		local rEffectComp = parseEffectComp(sEffectComp);
		-- Conditionals
		if rEffectComp.type == "IFT" then
			break;
		elseif rEffectComp.type == "IF" then
			local rActor = ActorManager.getActorFromCT(nodeActor);
			if not checkConditional(rActor, nodeEffect, rEffectComp.remainder) then
				break;
			end

			-- Ongoing damage, fast healing and regeneration
		elseif rEffectComp.type == "DMGO" or rEffectComp.type == "FHEAL" or rEffectComp.type == "REGEN" then
			local nActive = DB.getValue(nodeEffect, "isactive", 0);
			if nActive == 2 then
				DB.setValue(nodeEffect, "isactive", "number", 1);
			else
				applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp);
			end
		end
	end
end

--
-- CUSTOM FUNCTIONS
--
function onCriticalEffect(rSource, rTarget, rRoll)
	local nodeSource = ActorManager.getCTNode(rSource);
	local nodeTarget = ActorManager.getCTNode(rTarget);
	local sCriticalEffect = rRoll.critical;
	local aEffect = {};
	local sDice = "";
	local sEffectName = "";
	local sEffect = "";
	local nDuration = 0;
	local bEffect = false;
	local bReplace = false;
	local bEffectStack = false;
	--local aEffect = {sName = "Stable", nDuration = 0 };
	-- %(([^)]*)%)
	local aWords = StringManager.parseWords(sCriticalEffect, "%[%]%(%):");
	local sEffect = "";
	local aDice = {};
	local nMod = 0;
	local nDie = 0;
	local nDieCount = 0;
	local sDie = "";
	if #aWords > 0 then
		sName = (aWords[1]);
		if #aWords > 1 then
			if StringManager.isDiceString(aWords[2]) then
				aDice, nMod = StringManager.convertStringToDice(aWords[2]);
				nRemainderIndex = 3;
			end

			if aWords[2] ~= "wound" or aWords[2] ~= nil then
				sDie = aWords[2];
			end

			if sDie ~= "" then
				aDiceSplit = StringManager.split(sDie, "d");
				sDyetype = aDiceSplit[2];
				if sDyetype ~= nil then
					sDieName = "d" .. sDyetype;
				end
			end
		end
	end
	if aWords[1]:lower() == "arc" then
		sEffectName = "Arc";
		sEffect = "; (" .. aWords[2] .. " electricity) to 1 Target AOE 10ft. ";
		nDuration = 1;
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "bleed" then
		sEffectName = "Bleeding";  --Coded
		sEffect = ";DMGO: " .. aWords[2] .. " bleeding";
		--nDuration = 0;
		bReplace = AdjustEffects(nodeTarget, sEffectName, sDie, "replace");
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "burn" then
		sEffectName = "Burning " .. sDieName;
		sDieAdj = AdjustEffects(nodeTarget, sEffectName, sDie, "stackcombine");
		if sDie ~= sDieAdj and sDieAdj ~= nil then
			sEffect = ";DMGO: " .. sDieAdj .. " fire";
			bReplace = true;
		else
			sEffect = ";DMGO: " .. sDie .. " fire";
			bEffectStack = true
		end
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "corrode" then
		sEffectName = "Corrode " .. sDieName;
		sDieAdj = AdjustEffects(nodeTarget, sEffectName, sDie, "stackcombine");
		if sDie ~= sDieAdj and sDieAdj ~= nil then
			sEffect = ";DMGO: " .. sDieAdj .. " acid";
			bReplace = true;
		else
			sEffect = ";DMGO: " .. sDie .. " acid";
			bEffectStack = true
		end
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "deafen" then
		sEffectName = "Deafened";
		sEffect = "";
		nDuration = ((math.random(4))* 10);
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "injection" then
		sEffectName = "Injection Save DC +2";
		sEffect = "";
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "knockdown" then
		sEffectName = "Prone";
		sEffect = "";
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "staggered" then
		sEffectName = "Staggered [Fort]";
		sEffect = "";
		nDuration = 1;
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "stunned" then
		sEffectName = "Stunned";
		sEffect = "";
		nDuration = 1;
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
		sEffectName = "Flat-footed";
		sEffect = "";
		nDuration = 1;
		appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	elseif aWords[1]:lower() == "wound" then
		aWoundInfo = {};
		aWoundInfo = getWoundLoc();
		sEffectName = "Wound [" .. aWoundInfo[1] .. "]";
		sEffect = aWoundInfo[2];
		applyWound(rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie);
	elseif aWords[1] == "Severe" then
		aWoundInfo = {};
		aWoundInfo = getWoundLoc();
		sEffectName = "Severe Wound [" .. aWoundInfo[1] .. "]";
		sEffect = aWoundInfo[2];
		sWound = applyWound(rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie);
		aWoundInfo = {};
		aWoundInfo = getWoundLoc();
		sEffectName = "Severe Wound [" .. aWoundInfo[1] .. "]";
		sEffect = aWoundInfo[2];
		applyWound(rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie);
	end
end

function AdjustEffects(nodeTarget, sEffectName, sDie, sAdjustType)

	local sType = nil;
	local aDice = {};
	local nMod = 0;
	local aRemainder = {};
	local nRemainderIndex = 1;
	aDiceSplit = StringManager.split(sDie, "d");
	nDieCount = tonumber(aDiceSplit[1]);
	nDie = tonumber(aDiceSplit[2]);
	if sAdjustType == "replace" then
		for _,nodeEffect in pairs(DB.getChildren(nodeTarget, "effects")) do
			if DB.getValue(nodeEffect, "label", ""):match(sEffectName) then
				sEffect = DB.getValue(nodeEffect, "label", "");
				local aWords = StringManager.parseWords(sEffect, "%[%]%(%):");
				aDiceSplit = StringManager.split(aWords[3], "d");
				nEffectDieCount = tonumber(aDiceSplit[1]);
				nEffectDie = tonumber(aDiceSplit[2]);
				if nDieCount > nEffectDieCount or nDie > nEffectDie then
					return true;
				else
					return false;
				end
			end
		end
	end
	if sAdjustType == "stackadd" then
		for _,nodeEffect in pairs(DB.getChildren(nodeTarget, "effects")) do
			bAdd = false;
			if DB.getValue(nodeEffect, "label", ""):match(sEffectName) then
				sEffect = DB.getValue(nodeEffect, "label", "");
				local aWords = StringManager.parseWords(sEffect, "%[%]%(%):");
				aDiceSplit = StringManager.split(aWords[3], "d");
				nEffectDieCount = tonumber(aDiceSplit[1]);
				nEffectDie = tonumber(aDiceSplit[2]);
				if nDie == nEffectDie then
					nDieCount = nDieCount + nEffectDieCount;
					sDie = nDieCount .. "d" .. nDie;
					return sDie;
				end
			end
		end
	end
	if sAdjustType == "stackcombine" then

		local bFound = false
		for _,nodeEffect in pairs(DB.getChildren(nodeTarget, "effects")) do
			if DB.getValue(nodeEffect, "label", ""):match(sEffectName) then
				sEffect = DB.getValue(nodeEffect, "label", "");
				local aWords = StringManager.parseWords(sEffect, "%[%]%(%):");
				aDiceSplit = StringManager.split(aWords[4], "d");
				nEffectDieCount = tonumber(aDiceSplit[1]);
				nEffectDie = tonumber(aDiceSplit[2]);
				if nDie == nEffectDie then
					nDieCount = nDieCount + nEffectDieCount;
					sDie = nDieCount .. "d" .. nDie;
					bFound = true
				end
			end
		end
		return sDie;
	end
end

function getWoundLoc()
	nWoundLoc = math.random(20);
	aWoundInfo = {};
	sWound = "";
	if nWoundLoc < 11 then
		sWound = "General Save:None Effect:Bleed 1d6";
		table.insert(aWoundInfo, "Gen");
		table.insert(aWoundInfo, ";DMGO:1d6 bleeding");
		table.insert(aWoundInfo, "0")
	elseif nWoundLoc > 10 and nWoundLoc < 14 then
		sWound = "Eye (sensory)  Save:Ref  Effect:Lost eye(–2 Perception) ";
		table.insert(aWoundInfo, "Eye(Ref)");
		table.insert(aWoundInfo, " Lost Eye;SKILL:-2 perception");
		table.insert(aWoundInfo, "0")
	elseif nWoundLoc > 13 and nWoundLoc < 16 then
		sWound = "Leg (mobility)  Save:Fort  Effect:Severed limb, –10 land speed ";
		table.insert(aWoundInfo, "Leg(Fort)");
		table.insert(aWoundInfo, " Severed limb;SPEED -10");
		table.insert(aWoundInfo, "0")
	elseif nWoundLoc > 15 and nWoundLoc < 18 then
		sWound = "Arm (manipulation  Save:Ref  Effect:Severed limb, lose a hand ";
		table.insert(aWoundInfo, "Arm(Ref)");
		table.insert(aWoundInfo, " Severed limb;Lose Hand");
		table.insert(aWoundInfo, "0")
	elseif nWoundLoc > 17 and nWoundLoc < 20 then
		nCon = math.random(4);
		sWound = "Vital organ  Save:Fort  Effect:1d4 Con damage [" .. nCon .. "]";
		table.insert(aWoundInfo, "Vital organ(Fort)");
		table.insert(aWoundInfo, ";CON Dmg:" .. nCon);
		table.insert(aWoundInfo, "0")
	elseif nWoundLoc == 20 then
		sWound = "Brain  Save:Fort  Effect:Stunned 1 round ";
		table.insert(aWoundInfo, "Brain(Fort)");
		table.insert(aWoundInfo, ";Flat-footed");
		table.insert(aWoundInfo, "1")
	end
	local msg = {font = "msgfont"};
	msg.text = "[WOUND ROLL] " .. "(" .. nWoundLoc .. ") " .. sWound;
	Comm.deliverChatMessage(msg);
	return aWoundInfo;

end

function applyWound(rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie)
	local aEffectAdd = {sName = (sEffectName .. sEffect), nDuration = nDuration, nDieCount = nDieCount, nDie = nDie};
	if rTarget then
		EffectManager.notifyApply(aEffectAdd, rTarget.sCTNode);
	end
	return;
end

function appltCriticalEffect(rSource, rTarget, sEffectName, sEffect, nDuration, nDieCount, nDie, bEffectStack, bReplace)
	local nodeSource = ActorManager.getCTNode(rSource);
	local nodeTarget = ActorManager.getCTNode(rTarget);
	local msg = {font = "msgfont"};
	local sTarget = DB.getValue(nodeTarget, "name","");
	local bEffect = false;
	if EffectManagerSFRPG.hasEffect(nodeTarget, sEffectName) then
		bEffect = true
	end
	if bEffectStack then  --Add Effect (Effect is Stackable Different Die Type)
		bEffect = false;
	end

	if not bEffect then
		local aEffectAdd = {sName = (sEffectName .. sEffect), nDuration = nDuration, nDieCount = nDieCount, nDie = nDie};
		if rTarget then
			EffectManager.notifyApply(aEffectAdd, rTarget.sCTNode);
		end

	end
	if bReplace then
		local aDiceSplit = StringManager.split(sDie, "d");
		local sDie = aDiceSplit[2];
		for _,nodeEffect in pairs(DB.getChildren(nodeTarget, "effects")) do
			if DB.getValue(nodeEffect, "label", ""):match(sEffectName) then
				EffectManager.removeEffect(nodeTarget, sEffectName);
				local aEffectAdd = {sName = (sEffectName .. sEffect), nDuration = nDuration};
				EffectManager.notifyApply(aEffectAdd, rTarget.sCTNode);
				msg.text = "[CRITICAL EFFECT UPDATED] " .. "(" .. sEffectName .. ") " .. sTarget;
				Comm.deliverChatMessage(msg);
			end
		end
	end
	return;
end

function parseEffectComp(s)
	local sType = nil;
	local aDice = {};
	local nMod = 0;
	local aRemainder = {};
	local nRemainderIndex = 1;

	local aWords, aWordStats = StringManager.parseWords(s, "%[%]%(%):");
	if #aWords > 0 then
		sType = aWords[1]:match("^([^:]+):");
		if sType then
			nRemainderIndex = 2;

			local sValueCheck = aWords[1]:sub(#sType + 2);
			if sValueCheck ~= "" then
				table.insert(aWords, 2, sValueCheck);
				table.insert(aWordStats, 2, { startpos = aWordStats[1].startpos + #sType + 1, endpos = aWordStats[1].endpos });
				aWords[1] = aWords[1]:sub(1, #sType + 1);
				aWordStats[1].endpos = #sType + 1;
			end

			if #aWords > 1 then
				if StringManager.isDiceString(aWords[2]) then
					aDice, nMod = StringManager.convertStringToDice(aWords[2]);
					nRemainderIndex = 3;
				end
			end
		end

		if nRemainderIndex <= #aWords then
			while nRemainderIndex <= #aWords and aWords[nRemainderIndex]:match("^%[%a+%]$") do
				table.insert(aRemainder, aWords[nRemainderIndex]);
				nRemainderIndex = nRemainderIndex + 1;
			end
		end

		if nRemainderIndex <= #aWords then
			local sRemainder = s:sub(aWordStats[nRemainderIndex].startpos);
			local nStartRemainderPhrase = 1;
			local i = 1;
			while i < #sRemainder do
				local sCheck = sRemainder:sub(i, i);
				if sCheck == "," then
					local sRemainderPhrase = sRemainder:sub(nStartRemainderPhrase, i - 1);
					if sRemainderPhrase and sRemainderPhrase ~= "" then
						sRemainderPhrase = StringManager.trim(sRemainderPhrase);
						table.insert(aRemainder, sRemainderPhrase);
					end
					nStartRemainderPhrase = i + 1;
				elseif sCheck == "(" then
					while i < #sRemainder do
						if sRemainder:sub(i, i) == ")" then
							break;
						end
						i = i + 1;
					end
				elseif sCheck == "[" then
					while i < #sRemainder do
						if sRemainder:sub(i, i) == "]" then
							break;
						end
						i = i + 1;
					end
				end
				i = i + 1;
			end
			local sRemainderPhrase = sRemainder:sub(nStartRemainderPhrase, #sRemainder);
			if sRemainderPhrase and sRemainderPhrase ~= "" then
				sRemainderPhrase = StringManager.trim(sRemainderPhrase);
				table.insert(aRemainder, sRemainderPhrase);
			end
		end
	end

	return  {
		type = sType or "",
		mod = nMod,
		dice = aDice,
		remainder = aRemainder,
		original = StringManager.trim(s)
	};
end

function rebuildParsedEffectComp(rComp)
	if not rComp then
		return "";
	end

	local aComp = {};
	if rComp.type ~= "" then
		table.insert(aComp, rComp.type .. ":");
	end
	local sDiceString = StringManager.convertDiceToString(rComp.dice, rComp.mod);
	if sDiceString ~= "" then
		table.insert(aComp, sDiceString);
	end
	if #(rComp.remainder) > 0 then
		table.insert(aComp, table.concat(rComp.remainder, ","));
	end
	return table.concat(aComp, " ");
end

function applyOngoingDamageAdjustment(nodeActor, nodeEffect, rEffectComp)
	if #(rEffectComp.dice) == 0 and rEffectComp.mod == 0 then
		return;
	end

	local aResults = {};
	if rEffectComp.type == "FHEAL" then
		if DB.getValue(nodeActor, "wounds", 0) == 0 and DB.getValue(nodeActor, "nonlethal", 0) == 0 then
			return;
		end
		table.insert(aResults, "[FHEAL] Fast Heal");

	elseif rEffectComp.type == "REGEN" then
		if DB.getValue(nodeActor, "wounds", 0) == 0 and DB.getValue(nodeActor, "nonlethal", 0) == 0 then
			return;
		end
		table.insert(aResults, "[REGEN] Regeneration");

	else
		table.insert(aResults, "[DAMAGE] Ongoing Damage");
		if #(rEffectComp.remainder) > 0 then
			table.insert(aResults, "[TYPE: " .. table.concat(rEffectComp.remainder, ","):lower() .. "]");
		end
	end

	local rTarget = ActorManager.getActorFromCT(nodeActor);
	local rRoll = { sType = "damage", sDesc = table.concat(aResults, " "), aDice = rEffectComp.dice, nMod = rEffectComp.mod };
	if EffectManager.isGMEffect(nodeActor, nodeEffect) then
		rRoll.bSecret = true;
	end
	ActionsManager.roll(nil, rTarget, rRoll);
end

function evalAbilityHelper(rActor, sEffectAbility, nodeSpellClass)
	--local sSign, sModifier, sShortAbility = sEffectAbility:match("^%[([%+%-]?)([H2]?)([A-Z][A-Z][A-Z]?)%]$");
	local sSign, sModifier, sShortAbility = sEffectAbility:match("^%[([%+%-]?)([H%d]?)([A-Z]+)%]$");
	local nAbility = nil;
	if sShortAbility == "STR" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "strength");
	elseif sShortAbility == "DEX" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "dexterity");
	elseif sShortAbility == "CON" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "constitution");
	elseif sShortAbility == "INT" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "intelligence");
	elseif sShortAbility == "WIS" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "wisdom");
	elseif sShortAbility == "CHA" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "charisma");
	elseif sShortAbility == "LVL" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "level");
	elseif sShortAbility == "BAB" then
		nAbility = ActorManager2.getAbilityBonus(rActor, "bab");
	elseif sShortAbility == "CL" then
		if nodeSpellClass then
			nAbility = DB.getValue(nodeSpellClass, "cl", 0);
		end
	else
		nAbility = ActorManager2.getAbilityScore(rActor, sShortAbility:lower());
	end

	if nAbility then
		if sSign == "-" then
			nAbility = 0 - nAbility;
		end
		if sModifier == "H" then
			if nAbility > 0 then
				nAbility = math.floor(nAbility / 2);
			else
				nAbility = math.ceil(nAbility / 2);
			end
		elseif sModifier == "2" then
			nAbility = nAbility * 2;
		end
	end

	return nAbility;
end

function evalEffect(rActor, s, nodeSpellClass)
	if not s then
		return "";
	end
	if not rActor then
		return s;
	end

	local aNewEffectComps = {};
	local aEffectComps = EffectManager.parseEffect(s);
	for _,sComp in ipairs(aEffectComps) do
		local rEffectComp = parseEffectComp(sComp);
		for i = #(rEffectComp.remainder), 1, -1 do
			-- if rEffectComp.remainder[i]:match("^%[([%+%-]?)([H2]?)([A-Z][A-Z][A-Z]?)%]$") then
			-- 	local nAbility = evalAbilityHelper(rActor, rEffectComp.remainder[i], nodeSpellClass);
			-- 	if nAbility then
			-- 		rEffectComp.mod = rEffectComp.mod + nAbility;
			-- 		table.remove(rEffectComp.remainder, i);
			-- 	end
			-- end
			if rEffectComp.remainder[i]:match("^%[([%+%-]?)([H%d]?)([A-Z]+)%]$") then
				local nAbility = evalAbilityHelper(rActor, rEffectComp.remainder[i], nodeSpellClass);
				if nAbility then
					rEffectComp.mod = rEffectComp.mod + nAbility;
					table.remove(rEffectComp.remainder, i);
				end
			end
		end
		table.insert(aNewEffectComps, rebuildParsedEffectComp(rEffectComp));
	end
	local sOutput = EffectManager.rebuildParsedEffect(aNewEffectComps);

	return sOutput;
end

function getEffectsByType(rActor, sEffectType, aFilter, rFilterActor, bTargetedOnly)
	if not rActor then
		return {};
	end
	local results = {};

	-- Set up filters
	local aRangeFilter = {};
	local aOtherFilter = {};
	if aFilter then
		for _,v in pairs(aFilter) do
			if type(v) ~= "string" then
				table.insert(aOtherFilter, v);
			elseif StringManager.contains(DataCommon.rangetypes, v) then
				table.insert(aRangeFilter, v);
			else
				table.insert(aOtherFilter, v);
			end
		end
	end

	-- Determine effect type targeting
	local bTargetSupport = StringManager.isWord(sEffectType, DataCommon.targetableeffectcomps);

	-- Iterate through effects
	for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		-- Check active
		local nActive = DB.getValue(v, "isactive", 0);
		if (nActive ~= 0) then
			-- Check targeting
			local bTargeted = EffectManager.isTargetedEffect(v);
			if not bTargeted or EffectManager.isEffectTarget(v, rFilterActor) then
				local sLabel = DB.getValue(v, "label", "");
				local aEffectComps = EffectManager.parseEffect(sLabel);

				-- Look for type/subtype match
				local nMatch = 0;
				for kEffectComp, sEffectComp in ipairs(aEffectComps) do
					local rEffectComp = parseEffectComp(sEffectComp);
					-- Handle conditionals
					if rEffectComp.type == "IF" then
						if not checkConditional(rActor, v, rEffectComp.remainder) then
							break;
						end
					elseif rEffectComp.type == "IFT" then
						if not rFilterActor then
							break;
						end
						if not checkConditional(rFilterActor, v, rEffectComp.remainder, rActor) then
							break;
						end
						bTargeted = true;

					-- Compare other attributes
					else
						-- Strip energy/bonus types for subtype comparison
						local aEffectRangeFilter = {};
						local aEffectOtherFilter = {};

						local aComponents = {};
						for _,vPhrase in ipairs(rEffectComp.remainder) do
							local nTempIndexOR = 0;
							local aPhraseOR = {};
							repeat
								local nStartOR, nEndOR = vPhrase:find("%s+or%s+", nTempIndexOR);
								if nStartOR then
									table.insert(aPhraseOR, vPhrase:sub(nTempIndexOR, nStartOR - nTempIndexOR));
									nTempIndexOR = nEndOR;
								else
									table.insert(aPhraseOR, vPhrase:sub(nTempIndexOR));
								end
							until nStartOR == nil;

							for _,vPhraseOR in ipairs(aPhraseOR) do
								local nTempIndexAND = 0;
								repeat
									local nStartAND, nEndAND = vPhraseOR:find("%s+and%s+", nTempIndexAND);
									if nStartAND then
										local sInsert = StringManager.trim(vPhraseOR:sub(nTempIndexAND, nStartAND - nTempIndexAND));
										table.insert(aComponents, sInsert);
										nTempIndexAND = nEndAND;
									else
										local sInsert = StringManager.trim(vPhraseOR:sub(nTempIndexAND));
										table.insert(aComponents, sInsert);
									end
								until nStartAND == nil;
							end
						end
						local j = 1;
						while aComponents[j] do
							if StringManager.contains(DataCommon.dmgtypes, aComponents[j]) or
								StringManager.contains(DataCommon.bonustypes, aComponents[j]) or
								aComponents[j] == "all" then
							-- Skip
							elseif StringManager.contains(DataCommon.rangetypes, aComponents[j]) then
								table.insert(aEffectRangeFilter, aComponents[j]);
							else
								table.insert(aEffectOtherFilter, aComponents[j]);
							end

							j = j + 1;
						end

						-- Check for match
						local comp_match = false;
						if rEffectComp.type == sEffectType then

							-- Check effect targeting
							if bTargetedOnly and not bTargeted then
								comp_match = false;
							else
								comp_match = true;
							end

							-- Check filters
							if #aEffectRangeFilter > 0 then
								local bRangeMatch = false;
								for _,v2 in pairs(aRangeFilter) do
									if StringManager.contains(aEffectRangeFilter, v2) then
										bRangeMatch = true;
										break;
									end
								end
								if not bRangeMatch then
									comp_match = false;
								end
							end
							if #aEffectOtherFilter > 0 then
								local bOtherMatch = false;
								for _,v2 in pairs(aOtherFilter) do
									if type(v2) == "table" then
										local bOtherTableMatch = true;
										for k3, v3 in pairs(v2) do
											if not StringManager.contains(aEffectOtherFilter, v3) then
												bOtherTableMatch = false;
												break;
											end
										end
										if bOtherTableMatch then
											bOtherMatch = true;
											break;
										end
									elseif StringManager.contains(aEffectOtherFilter, v2) then
										bOtherMatch = true;
										break;
									end
								end
								if not bOtherMatch then
									comp_match = false;
								end
							end
						end

						-- Match!
						if comp_match then
							nMatch = kEffectComp;
							if nActive == 1 then
								table.insert(results, rEffectComp);
							end
						end
					end
				end -- END EFFECT COMPONENT LOOP

				-- Remove one shot effects
				if nMatch > 0 then
					if nActive == 2 then
						DB.setValue(v, "isactive", "number", 1);
					else
						local sApply = DB.getValue(v, "apply", "");
						if sApply == "action" then
							EffectManager.notifyExpire(v, 0);
						elseif sApply == "roll" then
							EffectManager.notifyExpire(v, 0, true);
						elseif sApply == "single" then
							EffectManager.notifyExpire(v, nMatch, true);
						end
					end
				end
			end -- END TARGET CHECK
		end  -- END ACTIVE CHECK
	end  -- END EFFECT LOOP

	return results;
end

function getEffectsBonusByType(rActor, aEffectType, bAddEmptyBonus, aFilter, rFilterActor, bTargetedOnly)
	if not rActor or not aEffectType then
		return {}, 0;
	end

	-- MAKE BONUS TYPE INTO TABLE, IF NEEDED
	if type(aEffectType) ~= "table" then
		aEffectType = { aEffectType };
	end

	-- PER EFFECT TYPE VARIABLES
	local results = {};
	local bonuses = {};
	local penalties = {};
	local nEffectCount = 0;

	for k, v in pairs(aEffectType) do
		-- LOOK FOR EFFECTS THAT MATCH BONUSTYPE
		local aEffectsByType = getEffectsByType(rActor, v, aFilter, rFilterActor, bTargetedOnly);

		-- ITERATE THROUGH EFFECTS THAT MATCHED
		for k2,v2 in pairs(aEffectsByType) do
			-- LOOK FOR ENERGY OR BONUS TYPES
			local dmg_type = nil;
			local mod_type = nil;
			for _,v3 in pairs(v2.remainder) do
				if StringManager.contains(DataCommon.dmgtypes, v3) or StringManager.contains(DataCommon.immunetypes, v3) or v3 == "all" then
					dmg_type = v3;
					break;
				elseif StringManager.contains(DataCommon.bonustypes, v3) then
					mod_type = v3;
					break;
				end
			end

			-- IF MODIFIER TYPE IS UNTYPED, THEN APPEND MODIFIERS
			-- (SUPPORTS DICE)
			if dmg_type or not mod_type then
				-- ADD EFFECT RESULTS
				local new_key = dmg_type or "";
				local new_results = results[new_key] or {dice = {}, mod = 0, remainder = {}};

				-- BUILD THE NEW RESULT
				for _,v3 in pairs(v2.dice) do
					table.insert(new_results.dice, v3);
				end
				if bAddEmptyBonus then
					new_results.mod = new_results.mod + v2.mod;
				else
					new_results.mod = math.max(new_results.mod, v2.mod);
				end
				for _,v3 in pairs(v2.remainder) do
					table.insert(new_results.remainder, v3);
				end

				-- SET THE NEW DICE RESULTS BASED ON ENERGY TYPE
				results[new_key] = new_results;

			-- OTHERWISE, TRACK BONUSES AND PENALTIES BY MODIFIER TYPE
			-- (IGNORE DICE, ONLY TAKE BIGGEST BONUS AND/OR PENALTY FOR EACH MODIFIER TYPE)
			else
				local bStackable = StringManager.contains(DataCommon.stackablebonustypes, mod_type);
				if v2.mod >= 0 then
					if bStackable then
						bonuses[mod_type] = (bonuses[mod_type] or 0) + v2.mod;
					else
						bonuses[mod_type] = math.max(v2.mod, bonuses[mod_type] or 0);
					end
				elseif v2.mod < 0 then
					if bStackable then
						penalties[mod_type] = (penalties[mod_type] or 0) + v2.mod;
					else
						penalties[mod_type] = math.min(v2.mod, penalties[mod_type] or 0);
					end
				end

			end

			-- INCREMENT EFFECT COUNT
			nEffectCount = nEffectCount + 1;
		end
	end

	-- COMBINE BONUSES AND PENALTIES FOR NON-ENERGY TYPED MODIFIERS
	for k2,v2 in pairs(bonuses) do
		if results[k2] then
			results[k2].mod = results[k2].mod + v2;
		else
			results[k2] = {dice = {}, mod = v2, remainder = {}};
		end
	end
	for k2,v2 in pairs(penalties) do
		if results[k2] then
			results[k2].mod = results[k2].mod + v2;
		else
			results[k2] = {dice = {}, mod = v2, remainder = {}};
		end
	end

	return results, nEffectCount;
end

function getEffectsBonus(rActor, aEffectType, bModOnly, aFilter, rFilterActor, bTargetedOnly)
	if not rActor or not aEffectType then
		if bModOnly then
			return 0, 0;
		end
		return {}, 0, 0;
	end

	-- MAKE BONUS TYPE INTO TABLE, IF NEEDED
	if type(aEffectType) ~= "table" then
		aEffectType = { aEffectType };
	end

	-- START WITH AN EMPTY MODIFIER TOTAL
	local aTotalDice = {};
	local nTotalMod = 0;
	local nEffectCount = 0;

	-- ITERATE THROUGH EACH BONUS TYPE
	local masterbonuses = {};
	local masterpenalties = {};
	for k, v in pairs(aEffectType) do
		-- GET THE MODIFIERS FOR THIS MODIFIER TYPE
		local effbonusbytype, nEffectSubCount = getEffectsBonusByType(rActor, v, true, aFilter, rFilterActor, bTargetedOnly);

		-- ITERATE THROUGH THE MODIFIERS
		for k2, v2 in pairs(effbonusbytype) do
			-- IF MODIFIER TYPE IS UNTYPED, THEN APPEND TO TOTAL MODIFIER
			-- (SUPPORTS DICE)
			if k2 == "" or StringManager.contains(DataCommon.dmgtypes, k2) then
				for k3, v3 in pairs(v2.dice) do
					table.insert(aTotalDice, v3);
				end
				nTotalMod = nTotalMod + v2.mod;

			-- OTHERWISE, WE HAVE A NON-ENERGY MODIFIER TYPE, WHICH MEANS WE NEED TO INTEGRATE
			-- (IGNORE DICE, ONLY TAKE BIGGEST BONUS AND/OR PENALTY FOR EACH MODIFIER TYPE)
			else
				if v2.mod >= 0 then
					masterbonuses[k2] = math.max(v2.mod, masterbonuses[k2] or 0);
				elseif v2.mod < 0 then
					masterpenalties[k2] = math.min(v2.mod, masterpenalties[k2] or 0);
				end
			end
		end

		-- ADD TO EFFECT COUNT
		nEffectCount = nEffectCount + nEffectSubCount;
	end

	-- ADD INTEGRATED BONUSES AND PENALTIES FOR NON-ENERGY TYPED MODIFIERS
	for k,v in pairs(masterbonuses) do
		nTotalMod = nTotalMod + v;
	end
	for k,v in pairs(masterpenalties) do
		nTotalMod = nTotalMod + v;
	end

	if bModOnly then
		return nTotalMod, nEffectCount;
	end
	return aTotalDice, nTotalMod, nEffectCount;
end

function hasEffectCondition(rActor, sEffect)
	return hasEffect(rActor, sEffect, nil, false, true);
end

function hasEffect(rActor, sEffect, rTarget, bTargetedOnly, bIgnoreEffectTargets)

	if not sEffect or not rActor then
		return false;
	end
	local sLowerEffect = sEffect:lower();

	-- Iterate through each effect
	local aMatch = {};
	for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		local nActive = DB.getValue(v, "isactive", 0);
		if nActive ~= 0 then
			-- Parse each effect label
			local sLabel = DB.getValue(v, "label", "");
			local bTargeted = EffectManager.isTargetedEffect(v);
			local aEffectComps = EffectManager.parseEffect(sLabel);

			-- Iterate through each effect component looking for a type match
			local nMatch = 0;
			for kEffectComp, sEffectComp in ipairs(aEffectComps) do
				local rEffectComp = parseEffectComp(sEffectComp);
				-- Check conditionals
				if rEffectComp.type == "IF" then
					if not checkConditional(rActor, v, rEffectComp.remainder) then
						break;
					end
				elseif rEffectComp.type == "IFT" then
					if not rTarget then
						break;
					end
					if not checkConditional(rTarget, v, rEffectComp.remainder, rActor) then
						break;
					end

					-- Check for match
				elseif rEffectComp.original:lower() == sLowerEffect then
					if bTargeted and not bIgnoreEffectTargets then
						if EffectManager.isEffectTarget(v, rTarget) then
							nMatch = kEffectComp;
						end
					elseif not bTargetedOnly then
						nMatch = kEffectComp;
					end
				end

			end

			-- If matched, then remove one-off effects
			if nMatch > 0 then
				if nActive == 2 then
					DB.setValue(v, "isactive", "number", 1);
				else
					table.insert(aMatch, v);
					local sApply = DB.getValue(v, "apply", "");
					if sApply == "action" then
						EffectManager.notifyExpire(v, 0);
					elseif sApply == "roll" then
						EffectManager.notifyExpire(v, 0, true);
					elseif sApply == "single" then
						EffectManager.notifyExpire(v, nMatch, true);
					end
				end
			end
		end
	end

	if #aMatch > 0 then
		return true;
	end
	return false;
end

function checkConditional(rActor, nodeEffect, aConditions, rTarget, aIgnore)
	local bReturn = true;

	if not aIgnore then
		aIgnore = {};
	end
	table.insert(aIgnore, nodeEffect.getNodeName());

	for _,v in ipairs(aConditions) do
		local sLower = v:lower();
		if sLower == DataCommon.healthstatusfull then
			local nPercentWounded = ActorManager2.getPercentWounded("ct", ActorManager.getCTNode(rActor));
			if nPercentWounded > 0 then
				bReturn = false;
			end
		elseif sLower == DataCommon.healthstatushalf then
			local nPercentWounded = ActorManager2.getPercentWounded("ct", ActorManager.getCTNode(rActor));
			if nPercentWounded < .5 then
				bReturn = false;
			end
		elseif sLower == DataCommon.healthstatuswounded then
			local nPercentWounded = ActorManager2.getPercentWounded("ct", ActorManager.getCTNode(rActor));
			if nPercentWounded == 0 then
				bReturn = false;
			end
		elseif StringManager.contains(DataCommon.conditions, sLower) then
			if not checkConditionalHelper(rActor, sLower, rTarget, aIgnore) then
				bReturn = false;
			end
		elseif StringManager.contains(DataCommon.conditionaltags, sLower) then
			if not checkConditionalHelper(rActor, sLower, rTarget, aIgnore) then
				bReturn = false;
			end
		else
			local sAlignCheck = sLower:match("^align%s*%(([^)]+)%)$");
			local sSizeCheck = sLower:match("^size%s*%(([^)]+)%)$");
			local sTypeCheck = sLower:match("^type%s*%(([^)]+)%)$");
			local sCustomCheck = sLower:match("^custom%s*%(([^)]+)%)$");
			if sAlignCheck then
				if not ActorManager2.isAlignment(rActor, sAlignCheck) then
					bReturn = false;
				end
			elseif sSizeCheck then
				if not ActorManager2.isSize(rActor, sSizeCheck) then
					bReturn = false;
				end
			elseif sTypeCheck then
				if not ActorManager2.isCreatureType(rActor, sTypeCheck) then
					bReturn = false;
				end
			elseif sCustomCheck then
				if not checkConditionalHelper(rActor, sCustomCheck, rTarget, aIgnore) then
					bReturn = false;
				end
			end
		end
	end

	table.remove(aIgnore);

	return bReturn;
end

function checkConditionalHelper(rActor, sEffect, rTarget, aIgnore)
	if not rActor then
		return false;
	end

	local bReturn = false;

	for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		local nActive = DB.getValue(v, "isactive", 0);
		if nActive ~= 0 and not StringManager.contains(aIgnore, v.getNodeName()) then
			-- Parse each effect label
			local sLabel = DB.getValue(v, "label", "");
			local bTargeted = EffectManager.isTargetedEffect(v);
			local aEffectComps = EffectManager.parseEffect(sLabel);

			-- Iterate through each effect component looking for a type match
			local nMatch = 0;
			for kEffectComp, sEffectComp in ipairs(aEffectComps) do
				local rEffectComp = parseEffectComp(sEffectComp);
				--Check conditionals
				if rEffectComp.type == "IF" then
					if not checkConditional(rActor, v, rEffectComp.remainder, nil, aIgnore) then
						break;
					end
				elseif rEffectComp.type == "IFT" then
					if not rTarget then
						break;
					end
					if not checkConditional(rTarget, v, rEffectComp.remainder, rActor, aIgnore) then
						break;
					end

					-- Check for match
				elseif rEffectComp.original:lower() == sEffect then
					if bTargeted then
						if EffectManager.isEffectTarget(v, rTarget) then
							bReturn = true;
						end
					else
						bReturn = true;
					end
				end
			end
		end
	end

	return bReturn;
end

--Update 1.2.0
function getEffectsString(nodeCTEntry, bPublicOnly)
	local aOutputEffects = {};
	
	-- Iterate through each effect
	local aSorted = {};
	for _,nodeChild in pairs(DB.getChildren(nodeCTEntry, "effects")) do
		table.insert(aSorted, nodeChild);
	end
	table.sort(aSorted, function (a, b) return a.getName() < b.getName() end);
	for _,v in pairs(aSorted) do
		local sEffect = getEffectString(v, bPublicOnly);
		if sEffect ~= "" then
			table.insert(aOutputEffects, sEffect);
		end
	end
	
	return table.concat(aOutputEffects, " | ");
end
function getEffectString(nodeEffect, bPublicOnly)
	if DB.getValue(nodeEffect, "isactive", 0) ~= 1 then
		return "";
	end
	
	local sLabel = DB.getValue(nodeEffect, "label", "");

	local bAddEffect = true;
	local bGMOnly = false;
	if sLabel == "" then
		bAddEffect = false;
	elseif DB.getValue(nodeEffect, "isgmonly", 0) == 1 then
		if User.isHost() and not bPublicOnly then
			bGMOnly = true;
		else
			bAddEffect = false;
		end
	end

	if not bAddEffect then
		return "";
	end
	
	local aEffectComps = EffectManager.parseEffect(sLabel);

	if EffectManager.isTargetedEffect(nodeEffect) then
		local sTargets = table.concat(getEffectTargets(nodeEffect, true), ",");
		table.insert(aEffectComps, 1, "[TRGT: " .. sTargets .. "]");
	end
	
	for k,v in pairs(aEffectVarMap) do
		if v.fDisplay then
			local vValue = v.fDisplay(nodeEffect);
			if vValue then
				table.insert(aEffectComps, vValue);
			end
		elseif v.sDisplay and v.sDBField then
			local vDBValue;
			if v.sDBType == "number" then
				vDBValue = DB.getValue(nodeEffect, v.sDBField, v.vDBDefault or 0);
				if vDBValue == 0 then
					vDBValue = nil;
				end
			else
				vDBValue = DB.getValue(nodeEffect, v.sDBField, v.vDBDefault or "");
				if vDBValue == "" then
					vDBValue = nil;
				end
			end
			if vDBValue then
				table.insert(aEffectComps, string.format(v.sDisplay, tostring(vDBValue):upper()));
			end
		end
	end

	local sOutputLabel = EffectManager.rebuildParsedEffect(aEffectComps);
	if bGMOnly then
		sOutputLabel = "(" .. sOutputLabel .. ")";
	end

	return sOutputLabel;
end
function getEffectTargets(nodeEffect, bUseName)
	local aTargets = {};
	
	for _,nodeTarget in pairs(DB.getChildren(nodeEffect, "targets")) do
		local sNode = DB.getValue(nodeTarget, "noderef", "");
		if bUseName then
			table.insert(aTargets, ActorManager2.getDisplayName(sNode));
		else
			table.insert(aTargets, sNode);
		end
	end

	return aTargets;
end