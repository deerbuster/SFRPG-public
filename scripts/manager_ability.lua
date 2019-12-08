--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
-- Update Ability Class Blocks

aSkillSelect = {};

-- Reset power points and individual Abilitys cast
function resetAbilitys(nodeCaster)
	for _,nodeAbilityClass in pairs(DB.getChildren(nodeCaster, "abilityset")) do
		DB.setValue(nodeAbilityClass, "pointsused", "number", 0);

		for _,nodeLevel in pairs(DB.getChildren(nodeAbilityClass, "levels")) do
			for _,nodeAbility in pairs(DB.getChildren(nodeLevel, "Abilitys")) do
				DB.setValue(nodeAbility, "cast", "number", 0);
			end
		end
	end
end

-- Iterate through each Ability to reset
function resetPrepared(nodeCaster)
	for _,nodeAbilityClass in pairs(DB.getChildren(nodeCaster, "Abilityset")) do
		for _,nodeLevel in pairs(DB.getChildren(nodeAbilityClass, "levels")) do
			for _,nodeAbility in pairs(DB.getChildren(nodeLevel, "Abilitys")) do
				DB.setValue(nodeAbility, "prepared", "number", 0);
			end
		end
	end
end

function convertAbilityDescToFormattedText(nodeAbility)
	local nodeDesc = nodeAbility.getChild("text");
	if nodeDesc == "" then
		nodeDesc = nodeAbility.getChild("description");
	end
	if nodeDesc then
		local sDescType = nodeDesc.getType();
		if sDescType == "string" then
			local sValue = "<p>" .. nodeDesc.getValue() .. "</p>";
			sValue = sValue:gsub("\r", "</p><p>");

			local nodeLinkedAbilitys = nodeAbility.getChild("linkedAbilitys");
			if nodeLinkedAbilitys then
				if nodeLinkedAbilitys.getChildCount() > 0 then
					sValue = sValue .. "<linklist>";
					for _,v in pairs(nodeLinkedAbilitys.getChildren()) do
						local sLinkName = DB.getValue(v, "linkedname", "");
						local sLinkClass, sLinkRecord = DB.getValue(v, "link", "", "");
						sValue = sValue .. "<link class=\"" .. sLinkClass .. "\" recordname=\"" .. sLinkRecord .. "\">" .. sLinkName .. "</link>";
					end
					sValue = sValue .. "</linklist>";
				end
			end

			nodeDesc.delete();
			DB.setValue(nodeAbility, "description", "formattedtext", sValue);
		end
	end
end

function convertAbilityDescToString(nodeAbility)
	local nodeDesc = nodeAbility.getChild("text");
	if nodeDesc == "" then
		nodeDesc = nodeAbility.getChild("description");
	end
	if nodeDesc then
		local sDescType = nodeDesc.getType();
		if sDescType == "formattedtext" then
			local sDesc = nodeDesc.getText();
			local sValue = nodeDesc.getValue();

			nodeDesc.delete();
			DB.setValue(nodeAbility, "text", "formattedtext", sDesc);

			local nodeLinkedAbilitys = nodeAbility.createChild("linkedAbilitys");
			if nodeLinkedAbilitys then
				local nIndex = 1;
				local nLinkStartB, nLinkStartE, sClass, sRecord = string.find(sValue, "<link class=\"([^\"]*)\" recordname=\"([^\"]*)\">", nIndex);
				while nLinkStartB and sClass and sRecord do
					local nLinkEndB, nLinkEndE = string.find(sValue, "</link>", nLinkStartE + 1);

					if nLinkEndB then
						local sText = string.sub(sValue, nLinkStartE + 1, nLinkEndB - 1);

						local nodeLink = nodeLinkedAbilitys.createChild();
						if nodeLink then
							DB.setValue(nodeLink, "link", "windowreference", sClass, sRecord);
							DB.setValue(nodeLink, "linkedname", "string", sText);
						end

						nIndex = nLinkEndE + 1;
						nLinkStartB, nLinkStartE, sClass, sRecord = string.find(sValue, "<link class=\"([^\"]*)\" recordname=\"([^\"]*)\">", nIndex);
					else
						nLinkStartB = nil;
					end
				end
			end
		end
	end
end

function convertAbilityShortDescToString(nodeAbility)
	local nodeDesc = nodeAbility.getChild("summary");
	if nodeDesc then
		local sDescType = nodeDesc.getType();
		if sDescType == "formattedtext" then
			local sDesc = nodeDesc.getText();
			local sValue = nodeDesc.getValue();

			nodeDesc.delete();
			DB.setValue(nodeAbility, "shortdescription", "string", sDesc);
		end
	end
end

function addAbility(nodeSource, nodeAbilityClass, nLevel)

	-- Validate
	if not nodeSource or not nodeAbilityClass or not nLevel then
		return nil;
	end
	local nodeTargetLevelAbilitys;
	-- Create the new Ability entry
	if nLevel < 10 then
		nodeTargetLevelAbilitys = nodeAbilityClass.getChild("levels.level0" .. nLevel .. ".abilities");
	else
		nodeTargetLevelAbilitys = nodeAbilityClass.getChild("levels.level" .. nLevel .. ".abilities");
	end
	if not nodeTargetLevelAbilitys then
		return nil;
	end
	local nodeNewAbility = nodeTargetLevelAbilitys.createChild();
	if not nodeNewAbility then
		return nil;
	end
	convertAbilityDescToFormattedText(nodeNewAbility);
	-- Copy the Ability details over
	DB.copyNode(nodeSource, nodeNewAbility);

	-- Convert the short description field from module data
	convertAbilityShortDescToString(nodeNewAbility);
	-- Convert the description field from module data
	--convertAbilityDescToString(nodeNewAbility);

	local nodeParent = nodeTargetLevelAbilitys.getParent();
	if nodeParent then
		-- Set the default cost for points casters
		local nCost = tonumber(string.sub(nodeParent.getName(), -1)) or 0;
		if nCost > 0 then
			nCost = 0;
		end
		DB.setValue(nodeNewAbility, "cost", "number", nCost);

		-- If Ability level not visible, then make it so.
		local sAvailablePath = "....available" .. nodeParent.getName();
		local nAvailable = DB.getValue(nodeTargetLevelAbilitys, sAvailablePath, 1);
		if nAvailable <= 0 then
			DB.setValue(nodeTargetLevelAbilitys, sAvailablePath, "number", 1);
		end
	end

	-- Parse Ability details to create actions
	if DB.getChildCount(nodeNewAbility, "actions") == 0 then
		parseAbility(nodeNewAbility);
	end

	return nodeNewAbility;
end

function addAbilityCastAction(nodeAbility)
	local nodeActions = nodeAbility.createChild("actions");
	if not nodeActions then
		return nil;
	end
	local nodeAction = nodeActions.createChild();
	if not nodeAction then
		return nil;
	end

	DB.setValue(nodeAction, "type", "string", "cast");

	local sSave = DB.getValue(nodeAbility, "save", ""):lower();
	if not sSave:match("harmless") then
		if sSave:match("^fortitude ") then
			DB.setValue(nodeAction, "savetype", "string", "fortitude");
		elseif sSave:match("^reflex ") then
			DB.setValue(nodeAction, "savetype", "string", "reflex");
		elseif sSave:match("^will ") then
			DB.setValue(nodeAction, "savetype", "string", "will");
		end

		if sSave:match("half") then
			DB.setValue(nodeAction, "onmissdamage", "string", "half");
		else
			local bHalf = parseAbilitySave(nodeAbility);
			if bHalf then
				DB.setValue(nodeAction, "onmissdamage", "string", "half");
			end
		end
	end

	local sSR = DB.getValue(nodeAbility, "sr", ""):lower();
	if sSR:match("harmless") or sSR:match("^no") then
		DB.setValue(nodeAction, "srnotallowed", "number", 1);
	end

	local sDesc = DB.getValue(nodeAbility, "text", ""):lower();
	if sDesc:match("ranged attack") then
		if sDesc:match("kac") then
			DB.setValue(nodeAction, "atktype", "string", "ranged");
		else
			DB.setValue(nodeAction, "atktype", "string", "rtouch");
		end
	elseif sDesc:match("melee attack") then
		if sDesc:match("kac") then
			DB.setValue(nodeAction, "atktype", "string", "melee");
		else
			DB.setValue(nodeAction, "atktype", "string", "mtouch");
		end
	else
		DB.setValue(nodeAction, "atktype", "string", "ab");

	end

	-- Check for custom DC in the Ability name
	local sDC = DB.getValue(nodeAbility, "name", ""):lower():match("%(dc (%d+)%)");
	if sDC then
		local nCustomDC = tonumber(sDC) or 0;
		if nCustomDC > 0 then
			local nDC = getActionSaveDC(nodeAction);
			if nDC ~= nCustomDC then
				DB.setValue(nodeAction, "savedcmod", "number", nCustomDC - nDC);
			end
		end


	end
end

function parseAbilitySave(nodeAbility)
	-- Get the description minos some problem characters and in lowercase
	local sDesc = string.lower(DB.getValue(nodeAbility, "text", ""));

	sDesc = string.gsub(sDesc, "�", "'");
	sDesc = string.gsub(sDesc, "�", "-");
	local aWords = StringManager.parseWords(sDesc);
	--Look for Half Damage on Save
	local i = 1;
	local bHalf = false;
	while aWords[i] do
		if StringManager.isWord(aWords[i], "damage") then
			local j = i - 1;
			if StringManager.isWord(aWords[j], "half") then
				bHalf = true;
			end
		end
		-- Increment word counter
		i = i + 1;
	end
	return bHalf;
end

function parseAbility(nodeAbility)
	-- CLean out old actions
	local nodeActions = nodeAbility.createChild("actions");
	for k, v in pairs(nodeActions.getChildren()) do
		v.delete();
	end
	-- Get the description minos some problem characters and in lowercase
	local sDesc = string.lower(DB.getValue(nodeAbility, "text", ""));
	----Debug.chat("sDesc", sDesc)
	sDesc = string.gsub(sDesc, "�", "'");
	sDesc = string.gsub(sDesc, "�", "-");


	local aWords = StringManager.parseWords(sDesc);

	-- Damage/Heal setup
	local aDamages = {};
	local aHeals = {};
	local sLevel = DB.getValue(nodeAbility, "level", 0);
	local i = 1;
	while aWords[i] do
		-- Main trigger ("damage")
		if StringManager.isWord(aWords[i], "damage") then
			local j = i - 1;


			-- Get damage type
			local sDamageType = "";
			if j > 0 and StringManager.isWord(aWords[j], DataCommon.dmgtypes) then
				sDamageType = aWords[j];
				j = j - 1;
			else
				local t = j - 3;
				sDamageType = aWords[t];
			end

			-- Skip "of"
			if StringManager.isWord(aWords[j], "of") then
				j = j - 1;
			end

			-- Get heal or damage
			local sRollType = nil;
			local sRollDice = nil;
			if StringManager.isWord(aWords[j], { "points", "point" }) then
				j = j - 1;
			end
			-- Skip "hit"
			if StringManager.isWord(aWords[j], "hit") then
				j = j - 1;
			end
			--	--Debug.chat(aWords[j])
			if StringManager.isDiceString(aWords[j]) then
				sRollDice = aWords[j];
				j = j - 1;
				if StringManager.isWord(aWords[j], { "deal", "deals", "take", "takes", "dealt", "dealing", "taking", "causes", "damage" }) then
					sRollType = "damage";
				elseif StringManager.isWord(aWords[j], { "damage", "and", "or" }) then
					sRollType = "damage";
				elseif StringManager.isWord(aWords[j], { "yellow", "orange", "red" }) then
					sRollType = "damage";
				elseif StringManager.isWord(aWords[j], { "cure", "cures", "restore", "restores" }) then
					sRollType = "heal";
				end
			end

			-- end

			-- If we have a roll
			if sRollType and sRollDice then

				local k = i + 1;
				local bScaling = false;
				local bPointMode = false;
				local bHalfLevel = false;
				local sMaxRollDice = nil;

				if StringManager.isWord(aWords[k], "+1") and StringManager.isWord(aWords[k+1], "point") then
					bPointMode = true;
					k = k + 2;
				elseif StringManager.isWord(aWords[k], "+") and StringManager.isWord(aWords[k+1], "1") and StringManager.isWord(aWords[k+2], "point") then
					bPointMode = true;
					k = k + 3;
				end

				if StringManager.isWord(aWords[k], "per") then
					k = k + 1;
					if StringManager.isWord(aWords[k], "two") then
						k = k + 1;
						bHalfLevel = true;
					end
					if StringManager.isWord(aWords[k], "caster") then
						k = k + 1;
					end
					if StringManager.isWord(aWords[k], { "level", "levels" }) then
						k = k + 1;
						bScaling = true;

						if StringManager.isWord(aWords[k], "of") and StringManager.isWord(aWords[k+1], "the") and StringManager.isWord(aWords[k+2], "caster") then
							k = k + 3;
						end

						if StringManager.isWord(aWords[k], "maximum") then
							sMaxRollDice = aWords[k + 1];
						elseif StringManager.isWord(aWords[k], "to") and
							StringManager.isWord(aWords[k+1], "a") and
							StringManager.isWord(aWords[k+2], "maximum") and
							StringManager.isWord(aWords[k+3], "of") then
							sMaxRollDice = aWords[k + 4];
						end
					end
				end

				local rRoll = {};
				rRoll.aDice, rRoll.nMod = StringManager.convertStringToDice(sRollDice);
				rRoll.sType = sDamageType;
				if bScaling then
					local sMult;
					if bHalfLevel then
						sMult = "halfcl";
					else
						sMult = "cl";
					end

					if bPointMode or #(rRoll.aDice) == 0 then
						rRoll.sModStat = sMult;
					else
						rRoll.sDiceStat = sMult;
					end

					if sMaxRollDice then
						local aMaxDice, nMaxMod = StringManager.convertStringToDice(sMaxRollDice);
						if bPointMode then
							rRoll.nMaxStat = nMaxMod;
						elseif #(rRoll.aDice) > 0 then
							rRoll.nMaxStat = math.floor(#aMaxDice / #(rRoll.aDice))
						else
							rRoll.nMaxStat = math.floor(nMaxMod / rRoll.nMod);
						end
					end
				end

				if sRollType == "heal" then
					table.insert(aHeals, rRoll);
				elseif sRollType == "spheal" then
					table.insert(aHeals, rRoll);
				else
					table.insert(aDamages, rRoll);
				end
			end
		end
		if StringManager.isWord(aWords[i], {"restore", "restores", "extra"}) then
			--or StringManager.isWord(aWords[i], "extra") then
			local j = i + 1;

			-- Get heal
			local sRollType = nil;
			local sRollDice = nil;
			if StringManager.isWord(aWords[j], { "points", "point" }) then
				j = j - 1;
			end
			-- Skip "hit"
			if StringManager.isWord(aWords[j], "hit") then
				j = j - 1;
			end

			if StringManager.isDiceString(aWords[j]) then
				sRollDice = aWords[j];
				j = j - 1;
				if StringManager.isWord(aWords[j], { "deal", "deals", "take", "takes", "dealt", "dealing", "taking", "causes", "damage" }) then
					sRollType = "damage";
				elseif StringManager.isWord(aWords[j], { "damage", "and", "or" }) then
					sRollType = "damage";
				elseif StringManager.isWord(aWords[j], { "yellow", "orange", "red" }) then
					sRollType = "damage";
				elseif StringManager.isWord(aWords[j], { "cure", "cures", "restore", "restores", "extra" }) then
					sRollType = "heal";
				end
			end

			-- end

			-- If we have a roll
			if sRollType and sRollDice then
				local k = i + 1;
				local bScaling = false;
				local bPointMode = false;
				local bHalfLevel = false;
				local bStat = false;
				local sMaxRollDice = nil;
				local sStat = "";

				if StringManager.isWord(aWords[k], "+1") and StringManager.isWord(aWords[k+1], "point") then
					bPointMode = true;
					k = k + 2;
				elseif StringManager.isWord(aWords[k], "+") and StringManager.isWord(aWords[k+1], "1") and StringManager.isWord(aWords[k+2], "point") then
					bPointMode = true;
					k = k + 3;
				elseif StringManager.isWord(aWords[k+3], DataCommon.abilities) then
					bScaling = true;
				end

				if StringManager.isWord(aWords[k], "per") then
					k = k + 1;
					if StringManager.isWord(aWords[k], "two") then
						k = k + 1;
						bHalfLevel = true;
					end
					if StringManager.isWord(aWords[k], "caster") then
						k = k + 1;
					end
					if StringManager.isWord(aWords[k], { "level", "levels" }) then
						k = k + 1;
						bScaling = true;

						if StringManager.isWord(aWords[k], "of") and StringManager.isWord(aWords[k+1], "the") and StringManager.isWord(aWords[k+2], "caster") then
							k = k + 3;
						end

						if StringManager.isWord(aWords[k], "maximum") then
							sMaxRollDice = aWords[k + 1];
						elseif StringManager.isWord(aWords[k], "to") and
							StringManager.isWord(aWords[k+1], "a") and
							StringManager.isWord(aWords[k+2], "maximum") and
							StringManager.isWord(aWords[k+3], "of") then
							sMaxRollDice = aWords[k + 4];
						end
					end

				end

				local rRoll = {};
				rRoll.aDice, rRoll.nMod = StringManager.convertStringToDice(sRollDice);
				rRoll.sType = sDamageType;
				if bScaling then

					local sMult;
					if bHalfLevel then
						sMult = "halfcl";
					else
						sMult = "cl";
					end

					if bPointMode or #(rRoll.aDice) == 0 then
						rRoll.sModStat = sMult;
					elseif StringManager.isWord(aWords[k+3], DataCommon.abilities) then
						sMult = aWords[k+3];
						rRoll.sModStat = sMult;
					else
						rRoll.sDiceStat = sMult;
					end

					if sMaxRollDice then
						local aMaxDice, nMaxMod = StringManager.convertStringToDice(sMaxRollDice);
						if bPointMode then
							rRoll.nMaxStat = nMaxMod;
						elseif #(rRoll.aDice) > 0 then
							rRoll.nMaxStat = math.floor(#aMaxDice / #(rRoll.aDice))
						else
							rRoll.nMaxStat = math.floor(nMaxMod / rRoll.nMod);
						end
					end

				end

				if sRollType == "heal" then
					table.insert(aHeals, rRoll);
				else
					table.insert(aDamages, rRoll);
				end
			end
		end
		if StringManager.isWord(aWords[i], {"restore", "restores", "extra"}) then

		end
		-- Increment word counter
		i = i + 1;
	end


	-- Always create a cast action
	addAbilityCastAction(nodeAbility);
	-- Add the Damage and Heal rolls
	for i = 1, #aDamages do
		local rRoll = aDamages[i];
		local nodeAction = DB.createChild(nodeActions);

		DB.setValue(nodeAction, "type", "string", "damage");

		local nodeDmgList = DB.createChild(nodeAction, "damagelist");
		local nodeDmgEntry = DB.createChild(nodeDmgList);

		DB.setValue(nodeDmgEntry, "dice", "dice", rRoll.aDice);
		if rRoll.sDiceStat then
			DB.setValue(nodeDmgEntry, "dicestat", "string", rRoll.sDiceStat);
			if rRoll.nMaxStat then
				DB.setValue(nodeDmgEntry, "dicestatmax", "number", rRoll.nMaxStat);
			end
		end

		if rRoll.sModStat then
			DB.setValue(nodeDmgEntry, "stat", "string", rRoll.sModStat);
			DB.setValue(nodeDmgEntry, "statmult", "number", rRoll.nMod);
			if rRoll.nMaxStat then
				DB.setValue(nodeDmgEntry, "statmax", "number", rRoll.nMaxStat);
			end
		else
			DB.setValue(nodeDmgEntry, "bonus", "number", rRoll.nMod);
		end

		DB.setValue(nodeDmgEntry, "type", "string", rRoll.sType);
	end
	for i = 1, #aHeals do
		local rRoll = aHeals[i];
		local nodeAction = nodeActions.createChild();

		DB.setValue(nodeAction, "type", "string", "heal");

		local nodeHealList = DB.createChild(nodeAction, "heallist");
		local nodeHealEntry = DB.createChild(nodeHealList);

		DB.setValue(nodeHealEntry, "dice", "dice", rRoll.aDice);
		if rRoll.sDiceStat then
			DB.setValue(nodeHealEntry, "dicestat", "string", rRoll.sDiceStat);
			if rRoll.nMaxStat then
				DB.setValue(nodeHealEntry, "dicestatmax", "number", rRoll.nMaxStat);
			end
		end

		if rRoll.sModStat then
			DB.setValue(nodeHealEntry, "stat", "string", rRoll.sModStat);
			DB.setValue(nodeHealEntry, "statmult", "number", rRoll.nMod);
			if rRoll.nMaxStat then
				DB.setValue(nodeHealEntry, "statmax", "number", rRoll.nMaxStat);
			end
		else
			DB.setValue(nodeHealEntry, "bonus", "number", rRoll.nMod);
		end
	end

	-- Effects setup
	local aEffects = {};

	i = 1;
	while aWords[i] do
		if StringManager.isWord(aWords[i], DataCommon.Abilityeffects) then
			local k = i;
			while StringManager.isWord(aWords[k + 1], DataCommon.Abilityeffects) or StringManager.isWord(aWords[k + 1], "and") do
				k = k + 1;
			end

			local bValidEffect = false;
			local j = i - 1;
			if StringManager.isWord(aWords[j], { "immediately", "only" }) then
				j = j - 1;
			end
			if StringManager.isWord(aWords[j], { "is", "are" }) then
				if not StringManager.isWord(aWords[j - 1], { "beams", "power", "that" }) then
					bValidEffect = true;
				end
			elseif StringManager.isWord(aWords[j], { "become", "becomes" }) then
				if not StringManager.isWord(aWords[j - 1], { "not", "never" }) then
					bValidEffect = true;
				end
			elseif StringManager.isWord(aWords[j], "being") then
				if not StringManager.isWord(aWords[j - 1], "as") then
					bValidEffect = true;
				end
			elseif StringManager.isWord(aWords[j], { "be", "and", "or", "then", "remains", "subject" }) then
				bValidEffect = true;
			end

			if bValidEffect then
				local rEffect = {};

				local aEffectWords = {};
				for z = i, k do
					if aWords[z] ~= "and" then
						local sWord = StringManager.capitalize(aWords[z]);
						table.insert(aEffectWords, sWord);
					end
				end

				rEffect.sName = table.concat(aEffectWords, "; ");

				local m = k + 1;
				if StringManager.isWord(aWords[m], "as") and
					StringManager.isWord(aWords[m + 1], "by") and
					StringManager.isWord(aWords[m + 2], "the") and
					StringManager.isWord(aWords[m + 4], "Ability") then
					m = m + 5;
				end
				if StringManager.isWord(aWords[m], "for") then
					m = m + 1;

					if StringManager.isDiceString(aWords[m]) then
						local sDiceMod = aWords[m];
						m = m + 1;

						local sUnits = nil;
						if StringManager.isWord(aWords[m], { "round", "rounds" }) then
							sUnits = "";
						elseif StringManager.isWord(aWords[m], { "minute", "minutes" }) then
							sUnits = "minute";
						elseif StringManager.isWord(aWords[m], { "hour", "hours" }) then
							sUnits = "hour";
						elseif StringManager.isWord(aWords[m], { "day", "days" }) then
							sUnits = "day";
						end
						m = m + 1;

						if sUnits then
							rEffect.aDice, rEffect.nMod = StringManager.convertStringToDice(sDiceMod);

							if StringManager.isWord(aWords[m], "per") and
								StringManager.isWord(aWords[m + 1], "caster") and
								StringManager.isWord(aWords[m + 2], "level") then
								rEffect.bCLMult = true;
							end

							rEffect.sUnits = sUnits;
						end
					end
				end

				table.insert(aEffects, rEffect);
			end

			i = k;

		elseif StringManager.isWord(aWords[i], { "daze", "dazes" }) and
			StringManager.isWord(aWords[i+1], "one") and
			StringManager.isWord(aWords[i+2], "living") and
			StringManager.isWord(aWords[i+3], "creature") then

			local rEffect = {};
			rEffect.sName = "Dazed";

			table.insert(aEffects, rEffect);

			i = i + 3;
		end

		-- Increment word counter
		i = i + 1;
	end

	-- Remove duplicates
	local aFinalEffects = {};
	for i = 1, #aEffects do
		local bFirstUnique = true;
		for j = i - 1, 1, -1 do
			if aEffects[i].sName == aEffects[j].sName then
				bFirstUnique = false;
				break;
			end
		end
		if bFirstUnique then
			table.insert(aFinalEffects, aEffects[i]);
		end
	end

	-- Add the Effects
	for i = 1, #aFinalEffects do
		local rRoll = aFinalEffects[i];
		local nodeAction = nodeActions.createChild();

		DB.setValue(nodeAction, "type", "string", "effect");
		DB.setValue(nodeAction, "label", "string", rRoll.sName);

		-- If duration is specified in the Ability description
		if rRoll.sUnits then
			DB.setValue(nodeAction, "durdice", "dice", rRoll.aDice);
			DB.setValue(nodeAction, "durunit", "string", rRoll.sUnits);

			if rRoll.bCLMult then
				DB.setValue(nodeAction, "durmult", "number", rRoll.nMod);
			else
				DB.setValue(nodeAction, "durmod", "number", rRoll.nMod);
			end

			-- Otherwise, use the Ability duration (if available), or permanent (if not)
		else
			local sAbilityDur = DB.getValue(nodeAction, "...duration", "");
			local aDurWords = StringManager.parseWords(sAbilityDur);

			i = 1;
			if StringManager.isNumberString(aDurWords[i]) then
				local nAbilityDur = tonumber(aDurWords[i]);
				i = i + 1;

				local sUnits = nil;
				if StringManager.isWord(aDurWords[i], { "round", "rounds" }) then
					sUnits = "";
				elseif StringManager.isWord(aDurWords[i], { "min", "minute", "minutes" }) then
					sUnits = "minute";
				elseif StringManager.isWord(aDurWords[i], { "hour", "hours" }) then
					sUnits = "hour";
				elseif StringManager.isWord(aDurWords[i], { "day", "days" }) then
					sUnits = "day";
				end

				if sUnits then
					i = i + 1;

					local nMult = 1;
					if StringManager.isWord(aDurWords[i], "per") then
						i = i + 1;
						if StringManager.isWord(aDurWords[i], "two") then
							nMult = 0.5;
							i = i + 1;
						elseif StringManager.isWord(aDurWords[i], "three") then
							nMult = 0.34;
							i = i + 1;
						end
					end

					local bUseCL = false;
					if StringManager.isWord(aDurWords[i], { "level", "levels" }) then
						bUseCL = true;
					end

					if bUseCL then
						local nFinalDur = math.max(math.floor(nAbilityDur * nMult), nMult);
						DB.setValue(nodeAction, "durmult", "number", nFinalDur);
					else
						DB.setValue(nodeAction, "durmod", "number", nAbilityDur);
					end
					DB.setValue(nodeAction, "durunit", "string", sUnits);
				end
			end
		end
	end
end

function updateAbilityClassCounts(nodeAbilityClass)
	local sCasterType = DB.getValue(nodeAbilityClass, "castertype", "");

	if sCasterType ~= "" then
		DB.setValue(nodeAbilityClass, "castertype", "string", "");
	--return;
	end
	if sCasterType == "points" then
		return;
	end

	for _,vLevel in pairs(DB.getChildren(nodeAbilityClass, "levels")) do
		-- Calculate Ability statistics
		local nTotalCast = 0;
		local nTotalPrepared = 0;
		local nMaxPrepared = 0;
		local nAbilitys = 0;

		for _,vAbility in pairs(DB.getChildren(vLevel, "Abilitys")) do

			nAbilitys = nAbilitys + 1;

			local nCast = DB.getValue(vAbility, "cast", 0);
			nTotalCast = nTotalCast + nCast;

			local nPrepared = 0;
			if sCasterType ~= "spontaneous" then
				nPrepared = DB.getValue(vAbility, "prepared", 0);
				nTotalPrepared = nTotalPrepared + nPrepared;
				if nPrepared > nMaxPrepared then
					nMaxPrepared = nPrepared;
				end
			end
		end

		DB.setValue(vLevel, "totalcast", "number", nTotalCast);
		DB.setValue(vLevel, "totalprepared", "number", nTotalPrepared);
		DB.setValue(vLevel, "maxprepared", "number", nMaxPrepared);
	end
end

function getAbilityActionOutputOrder(nodeAction)
	if not nodeAction then
		return 1;
	end
	local nodeActionList = nodeAction.getParent();
	if not nodeActionList then
		return 1;
	end

	-- First, pull some ability attributes
	local sType = DB.getValue(nodeAction, "type", "");
	local nOrder = DB.getValue(nodeAction, "order", 0);

	-- Iterate through list node
	local nOutputOrder = 1;
	for k, v in pairs(nodeActionList.getChildren()) do
		if DB.getValue(v, "type", "") == sType then
			if DB.getValue(v, "order", 0) < nOrder then
				nOutputOrder = nOutputOrder + 1;
			end
		end
	end

	return nOutputOrder;
end

function getAbilityAction(rActor, nodeAction, sSubRoll)
	if not nodeAction then
		return;
	end

	local sType = DB.getValue(nodeAction, "type", "");
	local rAction = {};
	rAction.type = sType;
	rAction.label = DB.getValue(nodeAction, "...name", "");
	rAction.order = getAbilityActionOutputOrder(nodeAction);

	if sType == "cast" then
		rAction.subtype = sSubRoll;
		rAction.onmissdamage = DB.getValue(nodeAction, "onmissdamage", "");

		local sAttackType = DB.getValue(nodeAction, "atktype", "");
		local sSkillSelect = DB.getValue(nodeAction, "skill_select", "");
		if sAttackType ~= "" then
			if sAttackType == "mtouch" then
				rAction.range = "M";
				rAction.touch = true;
			elseif sAttackType == "rtouch" then
				rAction.range = "R";
				rAction.touch = true;
			elseif sAttackType == "ranged" then
				rAction.range = "R";
			elseif sAttackType == "cm" then
				rAction.range = "M";
				rAction.cm = true;
			elseif sAttackType == "ab" then
				rAction.range = "-";
				rAction.ab = true;
				rAction.skill = sSkillSelect;
			else
				rAction.range = "M";
			end

			if rAction.cm then
				rAction.modifier = ActorManager2.getAbilityScore(rActor, "cmb") + DB.getValue(nodeAction, "atkmod", 0);
				rAction.dctype = DB.getValue(nodeAction, "dctype", 0);
				rAction.dcbase = DB.getValue(nodeAction, "dcbase", 0);
				rAction.dcmod = DB.getValue(nodeAction, "dcmod", 0);
			elseif rAction.ab then
				--Debug.chat("Change this to fix Ability Attack Mod bonus")
				local sType, nodeChar = ActorManager.getTypeAndNode(rActor);
				local aSkills = DB.getChildren(nodeChar, "skilllist");
				local sSkillSelected = sSkillSelect:lower();
				local nSkillMod = 0;
				for _,nodeSkill in pairs (aSkills) do
					local sSkillName = DB.getValue(nodeSkill, "label", ""):lower();
					if sSkillName == sSkillSelected then
						nSkillMod = DB.getValue(nodeSkill, "total", 0);
					end
				end

				--local nSkillMod = DB.getValue(nodeChar, "skill", 0); -- make field get the score from the Skill not the action
				rAction.modifier = DB.getValue(nodeAction, "atkmod", 0) + nSkillMod;
				rAction.dctype = DB.getValue(nodeAction, "dctype", 0);
				rAction.dcbase = DB.getValue(nodeAction, "dcbase", 0);
				rAction.dcmod = DB.getValue(nodeAction, "dcmod", 0);
				rAction.opposed_chk = DB.getValue(nodeAction, "opposed_chk", 0);
			else
				rAction.modifier = ActorManager2.getAbilityScore(rActor, "bab") + DB.getValue(nodeAction, "atkmod", 0);
				rAction.dctype = DB.getValue(nodeAction, "dctype", 0);
				rAction.dcbase = DB.getValue(nodeAction, "dcbase", 0);
				rAction.dcmod = DB.getValue(nodeAction, "dcmod", 0);
			end
			--rAction.modifier = rAction.modifier + DB.getValue(nodeAction, "atkmod", 0);
			--rAction.modifier = DB.getValue(nodeAction, "atkmod", 0);
			rAction.crit = 20;

			local sType, nodeActor = ActorManager.getTypeAndNode(rActor);
			if sType == "pc" then
				if rAction.range == "R" then
					rAction.stat = DB.getValue(nodeActor, "attackbonus.ranged.ability", "");
					if rAction.stat == "" then
						rAction.stat = "dexterity";
					end
					if sType == "pc" then
						rAction.modifier = rAction.modifier + DB.getValue(nodeActor, "attackbonus.ranged.size", 0) + DB.getValue(nodeActor, "attackbonus.ranged.misc", 0);
					end
				elseif rAction.cm then
					rAction.stat = DB.getValue(nodeActor, "attackbonus.grapple.ability", "");
					if rAction.stat == "" then
						rAction.stat = "strength";
					end
					if sType == "pc" then
						rAction.modifier = rAction.modifier + DB.getValue(nodeActor, "attackbonus.grapple.size", 0) + DB.getValue(nodeActor, "attackbonus.grapple.misc", 0);
					end
				else
					rAction.stat = DB.getValue(nodeActor, "attackbonus.melee.ability", "");
					if rAction.stat == "" and not rAction.ab then
						rAction.stat = "strength";
					end
					if not rAction.ab then
						rAction.modifier = rAction.modifier + DB.getValue(nodeActor, "attackbonus.melee.size", 0) + DB.getValue(nodeActor, "attackbonus.melee.misc", 0);
					end
					--end
				end
				if rAction.ab then
					rAction.modifier = rAction.modifier;
				else
					--rAction.modifier = rAction.modifier + ActorManager2.getAbilityScore(rActor, "bab") + ActorManager2.getAbilityBonus(rActor, rAction.stat);
					rAction.modifier = rAction.modifier + ActorManager2.getAbilityBonus(rActor, rAction.stat);
				end
			else
				if rAction.range == "R" then
					rAction.stat = "dexterity";
				else
					rAction.stat = "strength";
				end
				if rAction.cm then
					rAction.modifier = rAction.modifier + ActorManager2.getAbilityScore(rActor, "cmb");
				else
					rAction.modifier = rAction.modifier + ActorManager2.getAbilityScore(rActor, "bab") + ActorManager2.getAbilityBonus(rActor, rAction.stat);
				end
			end
		end

		rAction.clc = AbilityManager.getActionCLC(nodeAction);
		rAction.sr = "yes";

		if (DB.getValue(nodeAction, "srnotallowed", 0) == 1) then
			rAction.sr = "no";
		end

		rAction.dcstat = DB.getValue(nodeAction, ".......dc.ability", "");

		local sSaveType = DB.getValue(nodeAction, "savetype", "");
		if sSaveType ~= "" then
			rAction.save = sSaveType;
			rAction.savemod = AbilityManager.getActionSaveDC(nodeAction);
		else
			rAction.save = "";
			rAction.savemod = 0;
		end

	elseif sType == "damage" then
		rAction.clauses = getActionDamage(rActor, nodeAction);

		rAction.meta = DB.getValue(nodeAction, "meta", "");

		local bAbilityDamage = (DB.getValue(nodeAction, "dmgnotAbility", 0) == 0);
		if bAbilityDamage then
			for _,vClause in ipairs(rAction.clauses) do
				if not vClause.dmgtype or vClause.dmgtype == "" then
					vClause.dmgtype = "Ability";
				else
					vClause.dmgtype = vClause.dmgtype .. ",Ability";
				end
			end
		end

	elseif sType == "heal" then
		rAction.clauses = getActionHeal(rActor, nodeAction);

		rAction.subtype = DB.getValue(nodeAction, "healtype", "");
		rAction.meta = DB.getValue(nodeAction, "meta", "");

	elseif sType == "effect" then
		local nodeAbilityClass = DB.getChild(nodeAction, ".......");
		rAction.sName = EffectManagerSFRPG.evalEffect(rActor, DB.getValue(nodeAction, "label", ""), nodeAbilityClass);

		rAction.sApply = DB.getValue(nodeAction, "apply", "");
		rAction.sTargeting = DB.getValue(nodeAction, "targeting", "");

		rAction.aDice, rAction.nDuration = getActionEffectDuration(rActor, nodeAction);

		rAction.sUnits = DB.getValue(nodeAction, "durunit", "");
	end
	--Debug.chat(rAction)
	return rAction;
end

function onAbilityAction(draginfo, nodeAction, sSubRoll)

	if not nodeAction then
		return;
	end
	local rActor = ActorManager.getActor("", nodeAction.getChild("........."));
	if not rActor then
		return;
	end
	local rAction = getAbilityAction(rActor, nodeAction, sSubRoll);
	--Debug.chat("onAbilityAction",rAction)
	local rRolls = {};
	local rCustom = nil;
	if rAction.type == "cast" then
		if not rAction.subtype then
			table.insert(rRolls, ActionAbility.getAbilityCastRoll(rActor, rAction));
		end

		if not rAction.subtype or rAction.subtype == "atk" then
			--if rAction.subtype == "atk" or rAction.subtype == "ab" then
			if rAction.range then
				table.insert(rRolls, ActionAttack.getRoll(rActor, rAction));
			end
		end

		--	if not rAction.subtype or rAction.subtype == "clc" then
		--		local rRoll = ActionAbility.getCLCRoll(rActor, rAction);
		--		if not rAction.subtype then
		--			rRoll.sType = "castclc";
		--			rRoll.aDice = {};
		--		end
		--		table.insert(rRolls, rRoll);
		--	end

		if not rAction.subtype or rAction.subtype == "save" then
			if rAction.save and rAction.save ~= "" then
				local rRoll = ActionAbility.getSaveVsRoll(rActor, rAction);
				if not rAction.subtype then
					rRoll.sType = "castsave";
				end
				table.insert(rRolls, rRoll);
			end
		end

	elseif rAction.type == "damage" then
		local rRoll = ActionDamage.getRoll(rActor, rAction);
		rRoll.sType = "spdamage";

		table.insert(rRolls, rRoll);

	elseif rAction.type == "heal" then
		table.insert(rRolls, ActionHeal.getRoll(rActor, rAction));

	elseif rAction.type == "effect" then
		local rRoll;
		rRoll = ActionEffect.getRoll(draginfo, rActor, rAction);
		if rRoll then
			table.insert(rRolls, rRoll);
		end
	end

	if #rRolls > 0 then
		ActionsManager.performMultiAction(draginfo, rActor, rRolls[1].sType, rRolls);
	end
end

function getActionCLC(nodeAction)
	local nStat = DB.getValue(nodeAction, ".......cl", 0);
	local nPen = DB.getValue(nodeAction, ".......sp", 0);
	local nMod = DB.getValue(nodeAction, "clcmod", 0);

	return nStat + nPen + nMod;
end

function getActionSaveDC(nodeAction)
	local nTotal;

	if DB.getValue(nodeAction, "savedctype", "") == "fixed" then
		nTotal = DB.getValue(nodeAction, "savedcmod", 0);
	elseif DB.getValue(nodeAction, "savedctype", "") == "casterlevel" then
		local nStat = DB.getValue(nodeAction, ".......dc.abilitymod", 0);
		local nLevel = math.floor(DB.getValue(nodeAction, ".......cl", 0)/2);
		local nMod = DB.getValue(nodeAction, "savedcmod", 0);

		nTotal = 10 + nStat + nLevel + nMod;

	else
		local nStat = DB.getValue(nodeAction, ".......dc.total", 0);
		local nLevel = DB.getValue(nodeAction, ".....level", 0);
		local nMod = DB.getValue(nodeAction, "savedcmod", 0);

		nTotal = nStat + nLevel + nMod;
	--If NPC get BaseDC by Array Type from datacommon

	end

	return nTotal;
end

function getActionMod(rActor, nodeAction, sStat, nStatMax)
	local nStat;

	if sStat == "" then
		nStat = 0;
	elseif sStat == "cl" or sStat == "halfcl" or sStat == "oddcl" then
		nStat = DB.getValue(nodeAction, ".......cl", 0);
		if sStat == "halfcl" then
			nStat = math.floor((nStat + 0.5) / 2);
		elseif sStat == "oddcl" then
			nStat = math.floor((nStat + 1.5) / 2);
		end
	else
		nStat = ActorManager2.getAbilityBonus(rActor, sStat);
	end

	if nStat > 0 and nStatMax and nStatMax > 0 then
		nStat = math.max(math.min(nStat, nStatMax), 0);
	end

	return nStat;
end

function getActionDamage(rActor, nodeAction)
	if not nodeAction then
		return {};
	end

	local clauses = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeAction, "damagelist"));
	for _,v in ipairs(aDamageNodes) do
		local aDmgDice = DB.getValue(v, "dice", {});
		if #aDmgDice > 0 then
			local sDiceStat = DB.getValue(v, "dicestat", "");
			local nDiceStatMax = DB.getValue(v, "dicestatmax", 0);

			local nDiceMult = math.max(getActionMod(rActor, nodeAction, sDiceStat, nDiceStatMax), 1);
			if nDiceMult > 1 then
				local nCopy = #aDmgDice;
				for i = 2, nDiceMult do
					for j = 1, nCopy do
						table.insert(aDmgDice, aDmgDice[j]);
					end
				end
			end
		end

		local nDmgMod = DB.getValue(v, "bonus", 0);

		local sDmgStat = DB.getValue(v, "stat", "");
		local nDmgStatMult = 1;
		local nDmgStatMax = 0;
		if sDmgStat ~= "" then
			nDmgStatMult = math.max(DB.getValue(v, "statmult", 1), 1);
			nDmgStatMax = math.max(DB.getValue(v, "statmax", 0), 0);

			local nDmgStat = getActionMod(rActor, nodeAction, sDmgStat, nDmgStatMax);
			nDmgMod = nDmgMod + (nDmgStat * nDmgStatMult);
		end

		local aDamageTypes = ActionDamage.getDamageTypesFromString(DB.getValue(v, "type", ""));
		local sDmgType = table.concat(aDamageTypes, ",");

		table.insert(clauses, { dice = aDmgDice, modifier = nDmgMod, mult = 2, stat = sDmgStat, statmax = nDmgStatMax, statmult = nDmgStatMult, dmgtype = sDmgType });
	end

	return clauses;
end

function getActionHeal(rActor, nodeAction)
	if not nodeAction then
		return {};
	end

	local clauses = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeAction, "heallist"));
	for _,v in ipairs(aDamageNodes) do
		local aDice = DB.getValue(v, "dice", {});
		if #aDice > 0 then
			local sDiceStat = DB.getValue(v, "dicestat", "");
			local nDiceStatMax = DB.getValue(v, "dicestatmax", 0);

			local nDiceMult = math.max(getActionMod(rActor, nodeAction, sDiceStat, nDiceStatMax), 1);
			if nDiceMult > 1 then
				local nCopy = #aDice;
				for i = 2, nDiceMult do
					for j = 1, nCopy do
						table.insert(aDice, aDice[j]);
					end
				end
			end
		end

		local nMod = DB.getValue(v, "bonus", 0);

		local sStat = DB.getValue(v, "stat", "");
		local nStatMult = 1;
		local nStatMax = 0;
		if sStat ~= "" then
			nStatMult = math.max(DB.getValue(v, "statmult", 1), 1);
			nStatMax = math.max(DB.getValue(v, "statmax", 0), 0);

			local nStat = getActionMod(rActor, nodeAction, sStat, nStatMax);
			nMod = nMod + (nStat * nStatMult);
		end

		table.insert(clauses, { dice = aDice, modifier = nMod, mult = 2, stat = sStat, statmax = nStatMax, statmult = nStatMult });
	end

	return clauses;
end

function getActionEffectDuration(rActor, nodeAction)
	if not nodeAction then
		return {}, 0;
	end

	local aDice = DB.getValue(nodeAction, "durdice", {});
	if #aDice > 0 then
		local sDiceStat = DB.getValue(nodeAction, "durdicestat", "");
		local nDiceStatMax = DB.getValue(nodeAction, "durdicestatmax", 0);

		local nDiceMult = math.max(getActionMod(rActor, nodeAction, sDiceStat, nDiceStatMax), 1);
		if nDiceMult > 1 then
			local nCopy = #aDice;
			for i = 2, nDiceMult do
				for j = 1, nCopy do
					table.insert(aDice, aDice[j]);
				end
			end
		end
	end

	local nMod = DB.getValue(nodeAction, "durmod", 0);

	local sStat = DB.getValue(nodeAction, "durstat", "");
	local nStatMult = 1;
	local nStatMax = 0;
	if sStat ~= "" then
		nStatMult = math.max(DB.getValue(nodeAction, "durmult", 1), 1);
		nStatMax = math.max(DB.getValue(nodeAction, "dmaxstat", 0), 0);

		local nStat = getActionMod(rActor, nodeAction, sStat, nStatMax);
		nMod = nMod + (nStat * nStatMult);
	end

	return aDice, nMod;
end

--
-- DISPLAY FUNCTIONS
--

function getActionAttackText(nodeAction)
	--if nodeAction then
	local nodeChar = nodeAction.getParent().getParent().getParent().getParent().getParent().getParent().getParent().getParent();
	--end
	local sAttack = "";

	local sAttackType = DB.getValue(nodeAction, "atktype", "");
	local nAttackMod = DB.getValue(nodeAction, "atkmod", 0);
	if sAttackType == "melee" then
		sAttack = Interface.getString("power_label_atktypemelee");
	elseif sAttackType == "ranged" then
		sAttack = Interface.getString("power_label_atktyperanged");
	elseif sAttackType == "mtouch" then
		sAttack = Interface.getString("power_label_atktypemtouch");
	elseif sAttackType == "rtouch" then
		sAttack = Interface.getString("power_label_atktypertouch");
	elseif sAttackType == "cm" then
		sAttack = Interface.getString("power_label_atktypegrapple");
	elseif sAttackType == "ab" then
		local nSkillMod = 0;
		sAttack = Interface.getString("power_label_atktypeab");
		local sSkill = (DB.getValue(nodeAction, "skill_select", ""));

		local aSkills = DB.getChildren(nodeChar, "skilllist");
		for _,sSkillSet in pairs (aSkills) do
			local sSkillName = DB.getValue(sSkillSet, "label", "");

			if sSkillName == sSkill then
				nSkillMod = DB.getValue(sSkillSet, "total",0);

			end
		end

		nAttackMod = nAttackMod + nSkillMod;
	end
	if sAttack ~= "" and nAttackMod ~= 0 then
		sAttack = sAttack .. " + " .. nAttackMod;
	end

	return sAttack;
end

function getActionRPText(nodeAction)
	local sRP = "";

	local sAttackType = DB.getValue(nodeAction, "atktype", "");
	local nRPCost = (DB.getValue(nodeAction, "rpcost", 0));
	if sAttackType == "ab" then
		sRP = Interface.getString("power_label_rpcost");
	end
	if sRP ~= "" then
		sRP = nRPCost;
	end

	return sRP;
end

function getActionSaveText(nodeAction)
	local sSave = "";

	local sSaveType = DB.getValue(nodeAction, "savetype", "");
	local nDC = AbilityManager.getActionSaveDC(nodeAction);

	if sSaveType ~= "" and nDC ~= 0 then
		if sSaveType == "fortitude" then
			sSave = Interface.getString("power_label_savetypefort");
		elseif sSaveType == "reflex" then
			sSave = Interface.getString("power_label_savetyperef");
		elseif sSaveType == "will" then
			sSave = Interface.getString("power_label_savetypewill");
		end

		sSave = string.format("%s DC %d", sSave, nDC);
		if DB.getValue(nodeAction, "onmissdamage", "") == "half" then
			sSave = sSave .. " (H)";
		end
	end

	return sSave;
end

function getActionDamageText(nodeAction)
	local nodeActor = nodeAction.getChild(".........")
	local rActor = ActorManager.getActor("", nodeActor);

	local clauses = AbilityManager.getActionDamage(rActor, nodeAction);

	local aOutput = {};
	local aDamage = ActionDamage.getDamageStrings(clauses);
	for _,rDamage in ipairs(aDamage) do
		local sDice = StringManager.convertDiceToString(rDamage.aDice, rDamage.nMod);
		if sDice ~= "" then
			if rDamage.sType ~= "" then
				table.insert(aOutput, string.format("%s %s", sDice, rDamage.sType));
			else
				table.insert(aOutput, sDice);
			end
		end
	end
	local sDamage = table.concat(aOutput, " + ");

	local sMeta = DB.getValue(nodeAction, "meta", "");
	if sMeta == "empower" then
		sDamage = sDamage .. " [E]";
	elseif sMeta == "maximize" then
		sDamage = sDamage .. " [M]";
	end

	return sDamage;
end

function getActionHealText(nodeAction)
	local nodeActor = nodeAction.getChild(".........")
	local rActor = ActorManager.getActor("", nodeActor);

	local clauses = AbilityManager.getActionHeal(rActor, nodeAction);

	local aHealDice = {};
	local nHealMod = 0;
	for _,vClause in ipairs(clauses) do
		for _,vDie in ipairs(vClause.dice) do
			table.insert(aHealDice, vDie);
		end
		nHealMod = nHealMod + vClause.modifier;
	end

	local sHeal = StringManager.convertDiceToString(aHealDice, nHealMod);
	if DB.getValue(nodeAction, "healtype", "") == "temp" then
		sHeal = sHeal .. " temporary";
	elseif DB.getValue(nodeAction, "healtype", "") == "sp" then
		sHeal = sHeal .. " sp";
	end

	local sMeta = DB.getValue(nodeAction, "meta", "");
	if sMeta == "empower" then
		sHeal = sHeal .. " [E]";
	elseif sMeta == "maximize" then
		sHeal = sHeal .. " [M]";
	end

	return sHeal;
end

function getActionEffectDurationText(nodeAction)
	local nodeActor = nodeAction.getChild(".........")
	local rActor = ActorManager.getActor("", nodeActor);

	local aDice, nMod = getActionEffectDuration(rActor, nodeAction);

	local sDuration = StringManager.convertDiceToString(aDice, nMod);

	local sUnits = DB.getValue(nodeAction, "durunit", "");
	if sDuration ~= "" then
		if sUnits == "minute" then
			sDuration = sDuration .. " min";
		elseif sUnits == "hour" then
			sDuration = sDuration .. " hr";
		elseif sUnits == "day" then
			sDuration = sDuration .. " dy";
		else
			sDuration = sDuration .. " rd";
		end
	end

	return sDuration;
end

--Skill Select Cycler
function getAvaliableSkills(node)
	local nodeParent = node.getChild(".........");
	for _,sSkill in pairs(DB.getChildren(nodeParent, "skilllist")) do
		local sSkillName = DB.getValue(sSkill, "label","");
		if (sSkillName) then
			table.insert(aSkillSelect,sSkillName);
		end
		table.sort(aSkillSelect, sortClasses);
	end
	----Debug.chat(aSkillSelect)
	return aSkillSelect;
end

function useResolve(draginfo, node, sSubRoll)
	if not node then
		return;
	end
	local nodeAbility = node.getChild("...");
	local nodeChar = nodeAbility.getChild(".......");
	local nodeSpellClass = nodeAbility.getChild(".....");
	local rActor = ActorManager.getActor("", nodeAbility.getChild("......."))
	local nCost = DB.getValue(node, "rpcost", 0);
	local bNoRP = false;
	local sMessage;
	local nodeRP = nodeChar.getChild("rp");
	local nCurrentRP = DB.getValue(nodeRP, "current", 0);
	if nCost ~= 0 then
		sMessage = DB.getValue(nodeAbility, "name", "");
		if nCurrentRP < nCost then
			sMessage = sMessage .. " [INSUFFICIENT RP AVAILABLE (" .. nCost .. " REQUIRED)]";
			bNoRP = true
		else
			sMessage = sMessage.. " [SPENT " .. nCost .. " RP]";
			local nNewCurrentRP = nCurrentRP - nCost;
			if nNewCurrentRP == 0 then
				sMessage = sMessage.. " RESOLVE NOW 0";
			end
			DB.setValue(nodeRP, "current", "number", nNewCurrentRP);
			updateActionClassesRP(nodeChar,nNewCurrentRP);
		end
		--	end
			
		ChatManager.Message(sMessage, ActorManager.isPC(rActor), rActor);

	end
	if not bNoRP then
		AbilityManager.onAbilityAction(draginfo, node, sSubRoll);
	end
end

function updateActionClassesRP(nodeChar,nNewCurrentRP)
	local aClasses = DB.getChildren(nodeChar, "abilityset");
	for _,nodeActionClasses in pairs (aClasses) do			
		DB.setValue(nodeActionClasses, "points", "number", nNewCurrentRP);
	end		
end