--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

CT_PHASE = "combattracker.phase"

function onInit()
	CombatManager.setCustomSort(CombatManager2.sortfuncStandard) 
	--Sort Options
	--[sortfuncSimple] No Sorting
	--[sortfuncStandard] InitResult/InitBonus/Faction/Name(Alpha)
	--[sortfuncDnD] InitResult/Name(Alpha)

	CombatManager.setCustomAddNPC(addNPC)
	CombatManager.setCustomNPCSpaceReach(getNPCSpaceReach)

	CombatManager.setCustomRoundStart(onRoundStart)
	CombatManager.setCustomTurnStart(onTurnStart)
	CombatManager.setCustomTurnEnd(onTurnEnd)
	CombatManager.setCustomCombatReset(resetInit)
end
--
-- RESET FUNCTIONS
--

--
-- TURN FUNCTIONS
--

function onRoundStart(nCurrent)
	if OptionsManager.isOption("HRIR", "on") then
		rollInit()
	end
	CombatManager2.callForEachCombatantRoundDamage(onRoundStart)
end

function onTurnStart(nodeEntry)
	if not nodeEntry then
		return
	end
	-- Handle beginning of turn changes
	DB.setValue(nodeEntry, "immediate", "number", 0)
	-- Handle Check for Dying Effect at Turn Start
	local bDying = 0
	if EffectManagerSFRPG.hasEffect(nodeEntry, "Dying") then
		bDying = 1
		DB.setValue(nodeEntry, "dyingstart", "number", bDying)
	end

	DB.setValue(nodeEntry, "dyingstart", "number", bDying)
end

function onTurnEnd(nodeEntry)
	if not nodeEntry then
		return
	end
	local nDyingStart = DB.getValue(nodeEntry, "dyingstart", 0)
	-- Check for stabilization (based on option)
	local sOptionHRST = OptionsManager.getOption("HRST")
	if sOptionHRST ~= "off" then
		if (sOptionHRST == "all") or (DB.getValue(nodeEntry, "friendfoe", "") == "friend") then
			local nHP = DB.getValue(nodeEntry, "hp", 0)
			local nWounds = DB.getValue(nodeEntry, "wounds", 0)
			local rActor = ActorManager.getActorFromCT(nodeEntry)
			local nDying = GameSystem.getDeathThreshold(rActor)
			if nHP > 0 and nWounds > nHP and nWounds < nHP + nDying then
				if not EffectManagerSFRPG.hasEffect(rActor, "Stable") then
					ActionDamage.performStabilizationRoll(rActor)
				end
			end
		end
	end
--TURNDAMAGE
	-- if nDyingStart == 1 then
		-- DB.setValue(nodeEntry, "rpdmgtype", "string", "rp-1")
		-- handleResolveDamage(nodeEntry, "")
		-- DB.setValue(nodeEntry, "dyingstart", "number", 0)
	-- end
end

function handleResolveDamage(nodeEntry, rTarget)
	-- Handle Resolve if Dying or Stable
	if nodeEntry == "" and rTarget ~= "" then
		nodeEntry = rTarget;
	end

	local bDying = EffectManagerSFRPG.hasEffect(nodeEntry, "Dying");
	local bStable = EffectManagerSFRPG.hasEffect(nodeEntry, "Stable");
	if not bDying and not bStable then
		return;
	end
	local aEffect = {};

	local nDyingStart = DB.getValue(nodeEntry, "dyingstart", 0);
	local bZeroResolve = false;
	local nTurnDamage = DB.getValue(nodeEntry, "turndamage", 0);
--TURNDAMAGE
	--Handle Adjusting RP
	--First Damage 1 RP
	--Any Dmg After first
	--Turn
	if bStable and nTurnDamage == 1 then
	--  ----Debug.chat("Remove Stable and ADD Dying")
	    EffectManager.removeEffect(nodeEntry, "Stable");
	    aEffect = { sName = "Dying", nDuration = 0 };
	    EffectManager.addEffect("", "", nodeEntry, aEffect, true);
	end

	if bDying then
		local nRP = DB.getValue(nodeEntry, "rp", 0);
		local sRPDmgType = DB.getValue(nodeEntry, "rpdmgtype", "");
		local nNewRP;

        if sRPDmgType == "rp-0" then
            nNewRP = nRP;
        elseif sRPDmgType == "rp-1" then
            nNewRP = nRP - 1;
        elseif sRPDmgType == "dead" then
            nNewRP = nRP;
            aEffect = {sName = "Massive Damage (DEAD)", nDuration = 0};
            EffectManager.removeEffect(nodeEntry, "Dying");
            EffectManager.removeEffect(nodeEntry, "Unconscious");
            EffectManager.addEffect("", "", nodeEntry, aEffect, true);
        end

 		if nNewRP > 0 then
            DB.setValue(nodeEntry, "rp", "number", nNewRP);
        end
        if nNewRP <= 0 then
            DB.setValue(nodeEntry, "rp", "number", 0);
            bZeroResolve = true
        end
		-- Handle Effects (Zero Resolve)
		if bZeroResolve then
            aEffect = {sName = "Dead [No Resolve]", nDuration = 0}
			--local sOwner = DB.getOwner(ActorManager.getCreatureNode(nodeEntry));
			if not EffectManagerSFRPG.hasEffect(nodeEntry, "Dead [No Resolve]") then
				EffectManager.removeEffect(nodeEntry, "Dying")
				EffectManager.removeEffect(nodeEntry, "Unconscious")
				EffectManager.addEffect("", "", nodeEntry, aEffect, true)
			end
		end
	end
end

function nextPhase()
	if not User.isHost() then
		return
	end

	-- NOT GETTING THE CURRENT FROM DB
	local sCurrent = DB.getValue(CT_PHASE)
	if sCurrent == "" or nCurrent == nil then
		sCurrent = "[ ENGINEERING SETUP ]"
		nCurrent = 0
		local nodeActive = CombatManager.getActiveCT()
		local aEntries = CombatManager.getSortedCombatantList()
		DB.setValue(nodeActive, "active", "number", 0)
		CombatManager.clearGMIdentity()
	end

	if nCurrent == 0 then
		sCurrent = "[ ENGINEERING SETUP ]"
	elseif nCurrent == 1 then
		sCurrent = "[ ENGINEERING PHASE ]"
	elseif nCurrent == 2 then
		sCurrent = "[ HELM SETUP ]"
	elseif nCurrent == 3 then
		sCurrent = "[ HELM PHASE ]"
	elseif nCurrent == 4 then
		sCurrent = "[ GUNNERY SETUP ]"
	elseif nCurrent == 5 then
		sCurrent = "[ GUNNERY PHASE ]"
	end
	-- Announce round
	nCurrent = nCurrent + 1
	if nCurrent == 6 then
		nCurrent = 0
	end
	local msg = {font = "narratorfont", icon = "turn_flag"}
	msg.text = sCurrent
	Comm.deliverChatMessage(msg)
	-- Update Phase counter
	DB.setValue(CT_PHASE, "string", sCurrent)

	return sCurrent
end

--
-- ADD FUNCTIONS
--

function getNPCSpaceReach(nodeNPC)
	local nSpace = GameSystem.getDistanceUnitsPerGrid()
	local nReach = nSpace
	local nNPCSpace = DB.getValue(nodeNPC, "space", 0)
	local nNPCReach = DB.getValue(nodeNPC, "reach", 0)
	if nNPCSpace ~= 0 then
		nSpace = nNPCSpace or nSpace
		nReach = nNPCReach or nReach
	end
	return nSpace, nReach
end

function getNPCSpecialAbility(nodeNPC, sSAName)
	for _, specialability in pairs(DB.getChildren(nodeNPC, "specialabilities")) do
		local sName = DB.getValue(specialability, "name", "")
		local nStart,
			nEnd = sName:find(".*%s%(")
		if nStart ~= nil and nEnd ~= nil then
			sName = sName:sub(nStart, nEnd - 2)
			if sName:lower() == sSAName:lower() then
				return specialability
			end
		end
	end
	return nil
end

function addNPC(sClass, nodeNPC, sName)
	local nodeEntry,
		nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName)

	-- Defensive properties
	DB.setValue(nodeEntry, "eac", "number", DB.getValue(nodeNPC, "eac", 10))
	DB.setValue(nodeEntry, "kac", "number", DB.getValue(nodeNPC, "kac", 10))

	-- Offensive properties
	local nodeAttacks = nodeEntry.createChild("attacks")
	if nodeAttacks then
		-- delete any existing entries
		for _, v in pairs(nodeAttacks.getChildren()) do
			v.delete()
		end

		local nAttacks = 0

		-- Melee
		if DB.getValue(nodeNPC, "npctype", "") == "Trap" then
			local sMeleeAttacks = DB.getValue(nodeNPC, "effect", "")
			------Debug.chat(sMeleeAttacks)
			if sMeleeAttacks ~= "" then
				local sMeleeAttack = string.gsub(sMeleeAttacks, " and ", "|")
				local aAttacks = StringManager.split(sMeleeAttacks, "|", false)
				local sMeleeAttacks = table.concat(aAttacks, " and ")
				local nodeValue = nodeAttacks.createChild()
				if nodeValue then
					DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sMeleeAttacks))
					DB.setValue(nodeValue, "type", "number", 0)
					nAttacks = nAttacks + 1
				end
			end
		else
			local sMeleeAttacks = DB.getValue(nodeNPC, "melee", "")
			if sMeleeAttacks ~= "" then
				local sMeleeAttack = string.gsub(sMeleeAttacks, " and ", "|")
				local aAttacks = StringManager.split(sMeleeAttacks, "|", false)
				local sMeleeAttacks = table.concat(aAttacks, " and ")
				local nodeValue = nodeAttacks.createChild()
				if nodeValue then
					DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sMeleeAttacks))
					DB.setValue(nodeValue, "type", "number", 0)
					nAttacks = nAttacks + 1
				end
			end
		end
		--Multi
		local sMultiAttacks = DB.getValue(nodeNPC, "multiatk", "")
		if sMultiAttacks ~= "" then
			local sMultiAttack = string.gsub(sMultiAttacks, " and ", "|")
			local aAttacks = StringManager.split(sMultiAttacks, "|", false)
			local sMultiAttacks = table.concat(aAttacks, " and ")
			local nodeValue = nodeAttacks.createChild()
			if nodeValue then
				DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sMultiAttacks))
				DB.setValue(nodeValue, "type", "number", 1)
				nAttacks = nAttacks + 1
			end
		end

		--Ranged
		local sRangedAttacks = DB.getValue(nodeNPC, "ranged", "")
		if sRangedAttacks ~= "" then
			local sRangedAttacks = string.gsub(sRangedAttacks, " or ", "|")
			local aAttacks = StringManager.split(sRangedAttacks, "|", false)
			local sRangedAttacks = table.concat(aAttacks, " or ")
			local nodeValue = nodeAttacks.createChild()
			if nodeValue then
				DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sRangedAttacks))
				DB.setValue(nodeValue, "type", "number", 2)
				nAttacks = nAttacks + 1
			end
		end

		for _, nodeSpellSet in pairs(DB.getChildren(nodeNPC, "spellset")) do
			for _, nodeSpellLevel in pairs(DB.getChildren(nodeSpellSet, "levels")) do
				for _, nodeSpell in pairs(DB.getChildren(nodeSpellLevel, "spells")) do
					local sName = DB.getValue(nodeSpell, "name", "")
					if sName ~= "" then
						local nodeValue = nodeAttacks.createChild()
						if nodeValue then
							DB.setValue(nodeValue, "value", "string", sName)
							DB.setValue(nodeValue, "link", "windowreference", "spelldesc2", nodeSpell.getNodeName())
							DB.setValue(nodeValue, "activatelink", "number", 1)
							DB.setValue(nodeValue, "type", "number", 3)
							nAttacks = nAttacks + 1
						end
					end
				end
			end
		end

		for _, nodeSpecialAbility in pairs(DB.getChildren(nodeNPC, "specialabilities")) do
			local sName = DB.getValue(nodeSpecialAbility, "name", "")
			if sName ~= "" then
				local nodeValue = nodeAttacks.createChild()
				if nodeValue then
					DB.setValue(nodeValue, "value", "string", sName)

					DB.setValue(nodeValue, "link", "windowreference", "npc_specialability", nodeSpecialAbility.getNodeName())
					DB.setValue(nodeValue, "activatelink", "number", 1)
					DB.setValue(nodeValue, "type", "number", 4)
					nAttacks = nAttacks + 1
				end
			end
		end

		if nAttacks == 0 then
			nodeAttacks.createChild()
		end
	end

	-- Track additional damage types and intrinsic effects
	local aEffects = {}
	local aAddDamageTypes = {}

	-- Decode monster type qualities
	local sType = DB.getValue(nodeNPC, "type", ""):lower()
	local sSubType = DB.getValue(nodeNPC, "subtype", ""):lower()
	local aTypes = StringManager.split(sType, ",", true)
	local aSubTypes = StringManager.split(sSubType, ",", true)

	if StringManager.contains(aSubTypes, "lawful") then
		table.insert(aAddDamageTypes, "lawful")
	end
	if StringManager.contains(aSubTypes, "chaotic") then
		table.insert(aAddDamageTypes, "chaotic")
	end
	if StringManager.contains(aSubTypes, "good") then
		table.insert(aAddDamageTypes, "good")
	end
	if StringManager.contains(aSubTypes, "evil") then
		table.insert(aAddDamageTypes, "evil")
	end

	-- Decode NPC Type adjustments
	if StringManager.contains(aTypes, "aberration") then
		--	table.insert(aEffects, "SAVE:2,Will");
		table.insert(aEffects, "Aberration traits")
	elseif StringManager.contains(aTypes, "animal") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:2,Refl");
		table.insert(aEffects, "Animal traits")
	elseif StringManager.contains(aTypes, "construct") then
		table.insert(aEffects, "Construct traits")
		--	table.insert(aEffects, "SAVE:-2");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: death effects")
		table.insert(aEffects, "IMMUNE: disease")
		table.insert(aEffects, "IMMUNE: mind-affecting")
		table.insert(aEffects, "IMMUNE: necromancy")
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "dragon") then
		--	table.insert(aEffects, "SAVE:2");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Dragon traits")
	elseif StringManager.contains(aTypes, "fey") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:2,Refl");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Fey traits")
	elseif StringManager.contains(aTypes, "humanoid") then
		table.insert(aEffects, "Humanoid traits")
	elseif StringManager.contains(aTypes, "magical beast") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:2,Refl");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Magical Beast traits")
	elseif StringManager.contains(aTypes, "monstrous humanoid") then
		--	table.insert(aEffects, "SAVE:2,Will");
		--	table.insert(aEffects, "SAVE:2,Refl");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Monstrous Humanoid traits")
	elseif StringManager.contains(aTypes, "ooze") then
		table.insert(aEffects, "Ooze traits")
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:-2,Refl");
		--	table.insert(aEffects, "SAVE:-2,Will");
		table.insert(aEffects, "IMMUNE: critical")
		table.insert(aEffects, "IMMUNE: posion")
		table.insert(aEffects, "IMMUNE: polymorph")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "outsider") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Outsider traits")
	elseif StringManager.contains(aTypes, "plant") then
		table.insert(aEffects, "Plant traits")
		--	table.insert(aEffects, "SAVE:2,Fort");
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: polymorph")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "undead") then
		table.insert(aEffects, "Undead traits")
		--	table.insert(aEffects, "SAVE:2,Will");
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: death effects")
		table.insert(aEffects, "IMMUNE: disease")
		table.insert(aEffects, "IMMUNE: mind-affecting")
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "vermin") then
		table.insert(aEffects, "Vermin traits")
	--	table.insert(aEffects, "SAVE:2,Fort");
	end

	-- Decode NPC SubType immunities (1.0.12 Changed "IMMUNE: "bleed" to "IMMUNE: "bleeding" to match effect.)
	if StringManager.contains(aTypes, "elemental") then
		table.insert(aEffects, "Elemental traits")
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: critical")
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "swarm") then
		table.insert(aEffects, "Elemental traits")
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: critical")
		table.insert(aEffects, "IMMUNE: flat-footed")
		table.insert(aEffects, "IMMUNE: off-target")
		table.insert(aEffects, "IMMUNE: pinned")
		table.insert(aEffects, "IMMUNE: prone")
		table.insert(aEffects, "IMMUNE: staggered")
		table.insert(aEffects, "IMMUNE: stunning")
	end

	-- DECODE DEFENSIVE ABILITIES
	local sDefensiveAbilities = string.lower(DB.getValue(nodeNPC, "defensiveabilities", ""))
	local aDAWords = StringManager.parseWords(sDefensiveAbilities)
	local i = 1
	while aDAWords[i] do
		-- HARDNESS
		if StringManager.isWord(aDAWords[i], "hardness") and StringManager.isNumberString(aDAWords[i + 1]) then
			-- DAMAGE REDUCTION
			i = i + 1
			local sHardnessAmount = aDAWords[i]
			if (tonumber(aDAWords[i + 1]) or 0) <= 20 then
				table.insert(aEffects, "DR: " .. sHardnessAmount .. " adamantine; RESIST: " .. sHardnessAmount .. " all")
			else
				table.insert(aEffects, "DR: " .. sHardnessAmount .. " all; RESIST: " .. sHardnessAmount .. " all")
			end
		elseif
			StringManager.isWord(aDAWords[i], "dr") or (StringManager.isWord(aDAWords[i], "damage") and StringManager.isWord(aDAWords[i + 1], "reduction"))
		 then
			-- SPELL RESISTANCE
			if aDAWords[i] ~= "dr" then
				i = i + 1
			end

			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				local sDRAmount = aDAWords[i]
				local aDRTypes = {}

				while aDAWords[i + 1] do
					if StringManager.isWord(aDAWords[i + 1], {"and", "or"}) then
						table.insert(aDRTypes, aDAWords[i + 1])
					elseif StringManager.isWord(aDAWords[i + 1], {"epic", "magic"}) then
						table.insert(aDRTypes, aDAWords[i + 1])
						table.insert(aAddDamageTypes, aDAWords[i + 1])
					elseif StringManager.isWord(aDAWords[i + 1], "cold") and StringManager.isWord(aDAWords[i + 2], "iron") then
						table.insert(aDRTypes, "cold iron")
						i = i + 1
					elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
						table.insert(aDRTypes, aDAWords[i + 1])
					else
						break
					end

					i = i + 1
				end

				local sDREffect = "DR: " .. sDRAmount
				if #aDRTypes > 0 then
					sDREffect = sDREffect .. " " .. table.concat(aDRTypes, " ")
				end
				table.insert(aEffects, sDREffect)
			end
		elseif
			StringManager.isWord(aDAWords[i], "sr") or (StringManager.isWord(aDAWords[i], "spell") and StringManager.isWord(aDAWords[i + 1], "resistance"))
		 then
			-- FAST HEALING
			if aDAWords[i] ~= "sr" then
				i = i + 1
			end

			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				DB.setValue(nodeEntry, "sr", "number", tonumber(aDAWords[i]) or 0)
			end
		elseif StringManager.isWord(aDAWords[i], "fast") and StringManager.isWord(aDAWords[i + 1], {"healing", "heal"}) then
			-- REGENERATION
			i = i + 1
			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				table.insert(aEffects, "FHEAL: " .. aDAWords[i])
			end
		elseif StringManager.isWord(aDAWords[i], "regeneration") then
			-- RESISTANCES
			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				local sRegenAmount = aDAWords[i]
				local aRegenTypes = {}

				while aDAWords[i + 1] do
					if StringManager.isWord(aDAWords[i + 1], {"and", "or"}) then
						table.insert(aRegenTypes, aDAWords[i + 1])
					elseif StringManager.isWord(aDAWords[i + 1], "cold") and StringManager.isWord(aDAWords[i + 2], "iron") then
						table.insert(aRegenTypes, "cold iron")
						i = i + 1
					elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
						table.insert(aRegenTypes, aDAWords[i + 1])
					else
						break
					end

					i = i + 1
				end
				i = i - 1

				local sRegenEffect = "REGEN: " .. sRegenAmount
				if #aRegenTypes > 0 then
					sRegenEffect = sRegenEffect .. " " .. table.concat(aRegenTypes, " ")
				end
				table.insert(aEffects, sRegenEffect)
			end
		elseif StringManager.isWord(aDAWords[i], "resistances") then
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], "and") then
					-- SKIP
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.energytypes) and StringManager.isNumberString(aDAWords[i + 2]) then
					i = i + 1
					table.insert(aEffects, "RESIST: " .. aDAWords[i + 1] .. " " .. aDAWords[i])
				else
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], "resist") then
			-- WEAKNESSES
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], DataCommon.energytypes) and StringManager.isNumberString(aDAWords[i + 2]) then
					i = i + 1
					table.insert(aEffects, "RESIST: " .. aDAWords[i + 1] .. " " .. aDAWords[i])
				elseif not StringManager.isWord(aDAWords[i + 1], "and") then
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], {"weakness", "weaknesses"}) then
			-- IMMUNITY
			i = i + 1
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i], "and") then
					-- SKIP
				elseif
					StringManager.isWord(aDAWords[i], "light") and
						(StringManager.isWord(aDAWords[i + 1], "sensitivity") or StringManager.isWord(aDAWords[i + 1], "blindness"))
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i] .. " " .. aDAWords[i + 1])
					i = i + 1
				elseif
					StringManager.isWord(aDAWords[i], "sunlight") and
						(StringManager.isWord(aDAWords[i + 1], "dependency") or StringManager.isWord(aDAWords[i + 1], "blindness"))
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i] .. " " .. aDAWords[i + 1])
					i = i + 1
				elseif
					StringManager.isWord(aDAWords[i], "vulnerable") and StringManager.isWord(aDAWords[i + 1], "to") and
						StringManager.isWord(aDAWords[i + 2], DataCommon.energytypes)
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i + 2])
					i = i + 2
				elseif
					StringManager.isWord(aDAWords[i], "vulnerable") and StringManager.isWord(aDAWords[i + 1], "to") and
						StringManager.isWord(aDAWords[i + 2], "critical")
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i + 2])
					i = i + 2
				elseif StringManager.isWord(aDAWords[i], DataCommon.energytypes) then
					table.insert(aEffects, "VULN: " .. aDAWords[i])
				elseif StringManager.isWord(aDAWords[i], DataCommon.conditions) then
					table.insert(aEffects, "VULN: " .. aDAWords[i])
				elseif StringManager.isWord(aDAWords[i], "atrophied") then
					table.insert(aEffects, "VULN: " .. aDAWords[i])
				else
					break
				end

				i = i + 1
			end
		elseif
			StringManager.isWord(aDAWords[i], "immunities") and
				(StringManager.isWord(aDAWords[i + 1], DataCommon.immunetypes) or StringManager.isWord(aDAWords[i + 1], DataCommon.damagetypes) or
					(StringManager.isWord(aDAWords[i + 1], DataCommon.creaturetype) and StringManager.isWord(aDAWords[i + 2], "immunities")))
		 then
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], "and") then
					-- SKIP
				elseif StringManager.isWord(aDAWords[i + 2], "immunities") then
					-- Add exception for "magic immunity", which is also a damage type
					--	table.insert(aEffects, "IMMUNE: " .. aDAWords[i+1] .. " " .. aDAWords[i+2]);
					i = i + 1
				elseif StringManager.isWord(aDAWords[i + 1], "magic") then
					table.insert(aEffects, "IMMUNE: spell")
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.immunetypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
					if StringManager.isWord(aDAWords[i + 2], "effects") then
						i = i + 1
					end
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
				else
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], "immune") then
			-- SPECIAL DEFENSES
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], "and") then
					--SKIP
				elseif StringManager.isWord(aDAWords[i + 1], "traits") then
					-- SKIP+
					-- Add exception for "magic immunity", which is also a damage type
				elseif StringManager.isWord(aDAWords[i + 1], "magic") then
					table.insert(aEffects, "IMMUNE: spell")
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.immunetypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
					if StringManager.isWord(aDAWords[i + 2], "effects") then
						i = i + 1
					end
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
				else
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], "uncanny") and StringManager.isWord(aDAWords[i + 1], "agility") then
			if StringManager.isWord(aDAWords[i - 1], "improved") then
				table.insert(aEffects, "Improved Uncanny Agility")
			else
				table.insert(aEffects, "Uncanny Agility")
			end
			i = i + 1
		elseif StringManager.isWord(aDAWords[i], "evasion") then
			-- TRAITS
			if StringManager.isWord(aDAWords[i - 1], "improved") then
				table.insert(aEffects, "Improved Evasion")
			else
				table.insert(aEffects, "Evasion")
			end
		elseif StringManager.isWord(aDAWords[i], "incorporeal") then
			table.insert(aEffects, "Incorporeal")
		elseif StringManager.isWord(aDAWords[i], "blur") then
			table.insert(aEffects, "CONC")
		elseif StringManager.isWord(aDAWords[i], "natural") and StringManager.isWord(aDAWords[i + 1], "invisibility") then
			table.insert(aEffects, "Invisible")
		else
			local specialAbilityNode = getNPCSpecialAbility(nodeNPC, aDAWords[i]) -- .. " " .. aDAWords[i+1]
			if specialAbilityNode ~= nil then
				local sNPCEffectName = DB.getValue(specialAbilityNode, "name", "")
				local sNPCEffects = DB.getValue(specialAbilityNode, "effect", "")
				local aNPCEffects = StringManager.split(sNPCEffects, "%;", true)
				if #aNPCEffects > 0 then
					table.insert(aEffects, sNPCEffectName)
				end
				for _, sEffect in pairs(aNPCEffects) do
					table.insert(aEffects, sEffect)
				end
			end
		end

		-- ITERATE SPECIAL QUALITIES DECODE
		i = i + 1
	end
    -- FINISH ADDING EXTRA DAMAGE TYPES
	if #aAddDamageTypes > 0 then
		table.insert(aEffects, "DMGTYPE: " .. table.concat(aAddDamageTypes, ","))
	end
	-- ADD DECODED EFFECTS
	if #aEffects > 0 then
		for _, sEffect in pairs(aEffects) do
			EffectManager.addEffect("", "", nodeEntry, {sName = sEffect, nDuration = 0, nGMOnly = 1}, false)
		end
	end


	-- Roll initiative and sort
	local sOptINIT = OptionsManager.getOption("INIT")
	if sOptINIT == "group" then
		if nodeLastMatch then
			local nLastInit = DB.getValue(nodeLastMatch, "initresult", 0)
			DB.setValue(nodeEntry, "initresult", "number", nLastInit)
		else
			DB.setValue(nodeEntry, "initresult", "number", math.random(20) + DB.getValue(nodeEntry, "init", 0))
		end
	elseif sOptINIT == "on" then
		DB.setValue(nodeEntry, "initresult", "number", math.random(20) + DB.getValue(nodeEntry, "init", 0))
	end

	return nodeEntry
end

--
-- RESET FUNCTIONS
--
function resetInit()
	-- De-activate all entries
	for _, v in pairs(CombatManager.getCombatantNodes()) do
		DB.setValue(v, "active", "number", 0)
	end

	-- Clear GM identity additions (based on option)
	CombatManager.clearGMIdentity()

	-- Reset the round counter - phase counter
	DB.setValue(CombatManager.CT_ROUND, "number", 1)
	DB.setValue(CombatManager.CT_PHASE, "string", "Setup")
	--CombatManager.onCombatResetEvent()

	local resetCombatantInit = function(nodeCT)
		DB.setValue(nodeCT, "initresult", "number", 0)
		DB.setValue(nodeCT, "immediate", "number", 0)
	end
	CombatManager.callForEachCombatant(resetCombatantInit)
end

function clearExpiringEffects(bShort)
	function checkEffectExpire(nodeEffect, bShort)
		local sLabel = DB.getValue(nodeEffect, "label", "")
		local nDuration = DB.getValue(nodeEffect, "duration", 0)
		local sApply = DB.getValue(nodeEffect, "apply", "")

		if nDuration ~= 0 or sApply ~= "" or sLabel == "" then
			if bShort then
				if nDuration > 50 then
					DB.setValue(nodeEffect, "duration", "number", nDuration - 50)
				else
					nodeEffect.delete()
				end
			else
				nodeEffect.delete()
			end
		end
	end
	CombatManager.callForEachCombatantEffect(checkEffectExpire, bShort)
end

function rest(bShort)
	CombatManager.resetInit()
	clearExpiringEffects(bShort)

	if not bShort then
		for _, vChild in pairs(CombatManager.getCombatantNodes()) do
			local sClass,
				sRecord = DB.getValue(vChild, "link", "", "")
			if sClass == "charsheet" and sRecord ~= "" then
				local nodePC = DB.findNode(sRecord)
				if nodePC then
					CharManager.rest(nodePC)
				end
			end
		end
	end
end

function rollEntryInit(nodeEntry)
--Debug.chat("rollEntryInit",nodeEntry)
	if not nodeEntry then
		return
	end
--Debug.chat("1")
	-- Start with the base initiative bonus
	local nInit = DB.getValue(nodeEntry, "init", 0)
--Debug.chat("2")
	-- Get any effect modifiers
	local rActor = ActorManager.getActorFromCT(nodeEntry)
	local aEffectDice,
		nEffectBonus = EffectManagerSFRPG.getEffectsBonus(rActor, "INIT")
	nInit = nInit + StringManager.evalDice(aEffectDice, nEffectBonus)
--Debug.chat("3")
	-- For PCs, we always roll unique initiative
	local sClass,sRecord = DB.getValue(nodeEntry, "link", "", "")
--Debug.chat("4",sClass,sRecord)	
	if sClass == "charsheet" then	
		local nInitRoll = math.random(20)
--Debug.chat("4a",nInitRoll)
		local nInitResult = nInitRoll + nInit
--Debug.chat("4b",nInitResult)		
		DB.setValue(nodeEntry, "initresult", "number", nInitResult)
--Debug.chat("4c")		
			CombatManager2.handleCompanionInit(nodeEntry, nInitResult)
		return
	end
--Debug.chat("5")
	-- For NPCs, if NPC init option is not group, then roll unique initiative
	local sOptINIT = OptionsManager.getOption("INIT")
	if sOptINIT ~= "group" then
		local nInitResult = math.random(20) + nInit
		DB.setValue(nodeEntry, "initresult", "number", nInitResult)
		return
	end
--Debug.chat("6")
	-- For NPCs with group option enabled

	-- Get the entry's database node name and creature name
	local sStripName = CombatManager.stripCreatureNumber(DB.getValue(nodeEntry, "name", ""))
	if sStripName == "" then
		local nInitResult = math.random(20) + nInit
		DB.setValue(nodeEntry, "initresult", "number", nInitResult)
		return
	end
--Debug.chat("7")
	-- Iterate through list looking for other creature's with same name
	local nLastInit = nil
	local sEntryFaction = DB.getValue(nodeEntry, "friendfoe", "")
	for _, v in pairs(CombatManager.getCombatantNodes()) do
		if v.getName() ~= nodeEntry.getName() then
			if DB.getValue(v, "friendfoe", "") == sEntryFaction then
				local sTemp = CombatManager.stripCreatureNumber(DB.getValue(v, "name", ""))
				if sTemp == sStripName then
					local nChildInit = DB.getValue(v, "initresult", 0)
					if nChildInit ~= -10000 then
						nLastInit = nChildInit
					end
				end
			end
		end
	end
--Debug.chat("8")
	-- If we found similar creatures, then match the initiative of the last one found
	if nLastInit then
		DB.setValue(nodeEntry, "initresult", "number", nLastInit)
	else
		local nInitResult = math.random(20) + nInit
		DB.setValue(nodeEntry, "initresult", "number", nInitResult)
	end
--Debug.chat("9 End")	
end

function rollInit(sType)
--Debug.chat("rollInit",sType)
	rollTypeInit(sType, rollEntryInit)
end

function callForEachCombatantRoundDamage(f, ...)
	--Resets Turn Damage for All
	for _, v in pairs(CombatManager.getCombatantNodes()) do
		DB.setValue(v, "turndamage", "number", 0)
	end
end
--
-- PARSE CT ATTACK LINE
--
function parseAttackLine(rActor, sLine, bRanged)
	-- SETUP
	local rAttackRolls = {}
	local rDamageRolls = {}
	local rAttackCombos = {}

	-- Check the anonymous NPC attacks option
	local sOptANPC = OptionsManager.getOption("ANPC")

	-- PARSE 'OR'/'AND' PHRASES
	sLine = sLine:gsub("�", "-")
	local aPhrasesOR,
		aSkipOR = ActionDamage.decodeAndOrClauses(sLine)

	-- PARSE EACH ATTACK
	local nAttackIndex = 1
	local nLineIndex = 1
	local aCurrentCombo = {}
	local nStarts,
		nEnds,
		sAll,
		sAttackCount,
		sAttackLabel,
		sAttackModifier,
		sAttackType,
		nDamageStart,
		sDamage,
		nDamageEnd
	for kOR, vOR in ipairs(aPhrasesOR) do
		for kAND, sAND in ipairs(vOR) do
			-- Look for the right patterns
			nStarts,
				nEnds,
				sAll,
				sAttackCount,
				sAttackLabel,
				sAttackModifier,
				sAttackType,
				nDamageStart,
				sDamage,
				nDamageEnd = string.find(sAND, "((%+?%d*) ?([%w%s,%[%]%(%)%+%-]*) ([%+%-%d][%+%-%d/]*)([^%(]*)%(()([^%)]*)()%))")

			if not nStarts then
				nStarts,
					nEnds,
					sAll,
					sAttackLabel,
					nDamageStart,
					sDamage,
					nDamageEnd = sAND:find("(([%w%s,%[%]%(%)%+%-]*)%(()([^%)]*)()%))")
				if nStarts then
					sAttackCount = ""
					sAttackModifier = "+0"
					sAttackType = ""
				end
			end

			-- Make sure we got a match
			if nStarts then
				local rAttack = {}
				rAttack.startpos = nLineIndex + nStarts - 1
				rAttack.endpos = nLineIndex + nEnds

				local rDamage = {}
				rDamage.startpos = nLineIndex + nDamageStart - 1
				rDamage.endpos = nLineIndex + nDamageEnd - 1

				-- Check for implicit damage types
				local aImplicitDamageType = {}

				local aDamage = StringManager.split(sDamage, ";")
				local sCritical = aDamage[2]
				----Debug.chat("DAMAGE", aDamage)
				local aLabelWords = StringManager.parseWords(aDamage[1]:lower())
				local i = 1

				while aLabelWords[i] do
					if aLabelWords[i] == "a" then
						table.insert(aImplicitDamageType, "acid")
					elseif aLabelWords[i] == "c" then
						table.insert(aImplicitDamageType, "cold")
					elseif aLabelWords[i] == "e" then
						table.insert(aImplicitDamageType, "electricity")
					elseif aLabelWords[i] == "f" then
						table.insert(aImplicitDamageType, "fire")
					elseif aLabelWords[i] == "so" then
						table.insert(aImplicitDamageType, "sonic")
					elseif aLabelWords[i] == "b" then
						table.insert(aImplicitDamageType, "bludgeoning")
					elseif aLabelWords[i] == "p" then
						table.insert(aImplicitDamageType, "piercing")
					elseif aLabelWords[i] == "s" then
						table.insert(aImplicitDamageType, "slashing")
					elseif aLabelWords[i] == "burn" then
						table.insert(aImplicitDamageType, "burn")
					elseif aLabelWords[i] == "adamantine" or aLabelWords[i] == "silver" then
						table.insert(aImplicitDamageType, aLabelWords[i])
					elseif aLabelWords[i] == "holy" then
						table.insert(aImplicitDamageType, "good")
					elseif aLabelWords[i] == "unholy" then
						table.insert(aImplicitDamageType, "evil")
					elseif aLabelWords[i] == "anarchic" then
						table.insert(aImplicitDamageType, "chaotic")
					elseif aLabelWords[i] == "axiomatic" then
						table.insert(aImplicitDamageType, "lawful")
					else
						--if aLabelWords[i]:sub(-1) == "s" then
						--	aLabelWords[i] = aLabelWords[i]:sub(1, -2);
						--end

						if DataCommon.naturaldmgtypes[aLabelWords[i]] then
							table.insert(aImplicitDamageType, DataCommon.naturaldmgtypes[aLabelWords[i]])
						elseif DataCommon.weapondmgtypes[aLabelWords[i]] then
							if type(DataCommon.weapondmgtypes[aLabelWords[i]]) == "table" then
								if aLabelWords[i - 1] and DataCommon.weapondmgtypes[aLabelWords[i]][aLabelWords[i - 1]] then
									table.insert(aImplicitDamageType, DataCommon.weapondmgtypes[aLabelWords[i]][aLabelWords[i - 1]])
								elseif DataCommon.weapondmgtypes[aLabelWords[i]]["*"] then
									table.insert(aImplicitDamageType, DataCommon.weapondmgtypes[aLabelWords[i]]["*"])
								end
							else
								table.insert(aImplicitDamageType, DataCommon.weapondmgtypes[aLabelWords[i]])
							end
						end
					end

					i = i + 1
				end
				-- Clean up the attack count field (i.e. magical weapon bonuses up front, no attack count)
				local bMagicAttack = false
				local bEpicAttack = false
				local nAttackCount = 1
				if string.sub(sAttackCount, 1, 1) == "+" then
					bMagicAttack = true
					if sOptANPC ~= "on" then
						sAttackLabel = sAttackCount .. " " .. sAttackLabel
					end
					local nAttackPlus = tonumber(sAttackCount) or 1
					if nAttackPlus > 5 then
						bEpicAttack = true
					end
				elseif #sAttackCount then
					nAttackCount = tonumber(sAttackCount) or 1
					if nAttackCount < 1 then
						nAttackCount = 1
					end
				end

				-- Capitalize first letter of label
				sAttackLabel = StringManager.capitalize(sAttackLabel)

				-- If the anonymize option is on, then remove any label text within parentheses or brackets
				if sOptANPC == "on" then
					-- Strip out label information enclosed in ()
					sAttackLabel = string.gsub(sAttackLabel, "%s?%b()", "")

					-- Strip out label information enclosed in []
					sAttackLabel = string.gsub(sAttackLabel, "%s?%b[]", "")
				end

				rAttack.label = sAttackLabel
				rAttack.count = nAttackCount
				rAttack.modifier = sAttackModifier or 0

				rDamage.label = sAttackLabel

				-- Determine if vs KAC or EAC
				local bKAC = false

				for k, v in pairs(aImplicitDamageType) do
					----Debug.chat("DAM TYPE", k,v)
					if v == "bludgeoning" or v == "piercing" or v == "slashing" then
						bKAC = true
					end
				end

				if not bKAC then
					rAttack.touch = true
				end

				-- Determine attack type
				if bRanged then
					rAttack.range = "R"
					rDamage.range = "R"
					rAttack.stat = "dexterity"
				else
					rAttack.range = "M"
					rDamage.range = "M"
					rAttack.stat = "strength"
				end

				-- Determine critical information
				rAttack.crit = 20
				local nCritStart,
					nCritEnd,
					sCritThreshold = string.find(sDamage, "/(%d+)%-20")
				if sCritThreshold then
					rAttack.crit = tonumber(sCritThreshold) or 20
					if rAttack.crit < 2 or rAttack.crit > 20 then
						rAttack.crit = 20
					end
				end

				-- Determine damage clauses
				rDamage.clauses = {}

				local aClausesDamage = {}
				local nIndexDamage = 1
				local nStartDamage,
					nEndDamage
				while nIndexDamage < #sDamage do
					nStartDamage,
						nEndDamage = string.find(sDamage, " plus ", nIndexDamage)
					if nStartDamage then
						table.insert(aClausesDamage, string.sub(sDamage, nIndexDamage, nStartDamage - 1))
						nIndexDamage = nEndDamage
					else
						table.insert(aClausesDamage, string.sub(sDamage, nIndexDamage))
						nIndexDamage = #sDamage
					end
				end

				for kClause, sClause in pairs(aClausesDamage) do
					local aDamageAttrib = StringManager.split(sClause, ";", true)

					local aWordType = {}
					local sDamageRoll,
						sDamageTypes = string.match(aDamageAttrib[1], "^([d%d%+%-%s]+)([%w%s,%&]*)")
					if not sDamageRoll then
						sDamageRoll,
							sDamageTypes = string.match(aDamageAttrib[1], "^[%w%s%[]+%d+%s?ft%.%,%s([d%d%+%-%s]+)([%w%s,]*)")
					end
					local bCriticalEffect = false
					local sCriticalEffect = ""
					if aDamageAttrib[2] ~= nil then
						bCriticalEffect = true
						sCriticalEffect = aDamageAttrib[2]
						sCriticalEffect = string.gsub(sCriticalEffect, "critical ", "")
						sCriticalEffect = StringManager.capitalize(sCriticalEffect)
					end
					if sDamageRoll then
						if sDamageTypes then
							if string.match(sDamageTypes, " and ") then
								sDamageTypes = string.gsub(sDamageTypes, " and .*$", "")
							end
							table.insert(aWordType, sDamageTypes)
						end

						local sCrit
						for nAttrib = 2, #aDamageAttrib do
							sCrit,
								sDamageTypes = string.match(aDamageAttrib[nAttrib], "^(%s)([%w%s,]*)")
							--sCrit, sDamageTypes = string.match(aDamageAttrib[nAttrib], "^x(%d)([%w%s,]*)");
							if not sCrit then
								sDamageTypes = string.match(aDamageAttrib[nAttrib], "^%d+%-20%s?([%w%s,]*)")
							end

							if sDamageTypes then
								table.insert(aWordType, sDamageTypes)
							end
						end

						local aWordDice,
							nWordMod = StringManager.convertStringToDice(sDamageRoll)
						if #aWordDice > 0 or nWordMod ~= 0 then
							local rDamageClause = {dice = {}}
							for kDie, vDie in ipairs(aWordDice) do
								table.insert(rDamageClause.dice, vDie)
							end
							rDamageClause.modifier = nWordMod

							if kClause == 1 then
								rDamageClause.mult = 2
							else
								rDamageClause.mult = 1
							end
							rDamageClause.mult = tonumber(sCrit) or rDamageClause.mult

							if not bRanged then
								rDamageClause.stat = "strength"
							end

							local aDamageType = ActionDamage.getDamageTypesFromString(table.concat(aWordType, ","))
							if #aDamageType == 0 then
								for kType, sType in ipairs(aImplicitDamageType) do
									table.insert(aDamageType, sType)
								end
							end
							if bMagicAttack then
								table.insert(aDamageType, "magic")
							end
							if bEpicAttack then
								table.insert(aDamageType, "epic")
							end

							if bCriticalEffect then
								--	table.insert(rDamageClause.critical, sCriticalEffect);
								rDamage.critical = sCriticalEffect
							end
							rDamageClause.dmgtype = table.concat(aDamageType, ",")

							table.insert(rDamage.clauses, rDamageClause)
						end
					end
				end

				if #(rDamage.clauses) > 0 then
					if bRanged then
						local nDmgBonus = rDamage.clauses[1].modifier
						if nDmgBonus > 0 then
							local nStatBonus = ActorManager2.getAbilityBonus(rActor, "strength")
							if (nDmgBonus >= nStatBonus) then
								rDamage.statmult = 1
							end
						end
					else
						local nDmgBonus = rDamage.clauses[1].modifier
						local nStatBonus = ActorManager2.getAbilityBonus(rActor, "strength")

						if (nStatBonus > 0) and (nDmgBonus > 0) then
							if nDmgBonus >= math.floor(nStatBonus * 1.5) then
								rDamage.statmult = 1.5
							elseif nDmgBonus >= nStatBonus then
								rDamage.statmult = 1
							else
								rDamage.statmult = 0.5
							end
						elseif (nStatBonus == 1) and (nDmgBonus == 0) then
							rDamage.statmult = 0.5
						end
					end
				end

				-- Add to roll list
				table.insert(rAttackRolls, rAttack)
				table.insert(rDamageRolls, rDamage)

				-- Add to combo
				table.insert(aCurrentCombo, nAttackIndex)
				nAttackIndex = nAttackIndex + 1
			end

			nLineIndex = nLineIndex + #sAND
			nLineIndex = nLineIndex + aSkipOR[kOR][kAND]
		end

		-- Finish combination
		if #aCurrentCombo > 0 then
			table.insert(rAttackCombos, aCurrentCombo)
			aCurrentCombo = {}
		end
	end

	return rAttackRolls, rDamageRolls, rAttackCombos
end

--
--	XP FUNCTIONS
--

function getCRFromXP(nXP)
	local nCR = 0
	if nXP > 0 then
		if nXP <= 50 then
			nCR = 0.125
		elseif nXP <= 65 then
			nCR = 0.166
		elseif nXP <= 100 then
			nCR = 0.25
		elseif nXP <= 135 then
			nCR = 0.333
		elseif nXP <= 200 then
			nCR = 0.5
		elseif nXP <= 400 then
			nCR = 1
		elseif nXP <= 600 then
			nCR = 2
		elseif nXP <= 800 then
			nCR = 3
		elseif nXP <= 1200 then
			nCR = 4
		elseif nXP <= 1600 then
			nCR = 5
		elseif nXP <= 2400 then
			nCR = 6
		elseif nXP <= 3200 then
			nCR = 7
		elseif nXP <= 4800 then
			nCR = 8
		elseif nXP <= 6400 then
			nCR = 9
		elseif nXP <= 9600 then
			nCR = 10
		elseif nXP <= 12800 then
			nCR = 11
		elseif nXP <= 19200 then
			nCR = 12
		elseif nXP <= 25600 then
			nCR = 13
		elseif nXP <= 38400 then
			nCR = 14
		elseif nXP <= 51200 then
			nCR = 15
		elseif nXP <= 76800 then
			nCR = 16
		elseif nXP <= 102400 then
			nCR = 17
		elseif nXP <= 153600 then
			nCR = 18
		elseif nXP <= 204800 then
			nCR = 19
		elseif nXP <= 307200 then
			nCR = 20
		elseif nXP <= 409600 then
			nCR = 21
		elseif nXP <= 614400 then
			nCR = 22
		elseif nXP <= 819200 then
			nCR = 23
		elseif nXP <= 1228800 then
			nCR = 24
		elseif nXP <= 1638400 then
			nCR = 25
		elseif nXP <= 2457600 then
			nCR = 26
		elseif nXP <= 3276800 then
			nCR = 27
		elseif nXP <= 4915200 then
			nCR = 28
		elseif nXP <= 6553600 then
			nCR = 29
		elseif nXP <= 9830400 then
			nCR = 30
		else
			nCR = 31
		end
	end
	return nCR
end

function getXPFromCR(nCR)
	local nXP = 0
	if nCR > 0 then
		if nCR <= 0.125 then
			nXP = 50
		elseif nCR <= 0.167 then
			nXP = 65
		elseif nCR <= 0.25 then
			nXP = 100
		elseif nCR <= 0.334 then
			nXP = 135
		elseif nCR <= 0.5 then
			nXP = 200
		elseif nCR <= 1 then
			nXP = 400
		elseif nCR <= 2 then
			nXP = 600
		elseif nCR <= 3 then
			nXP = 800
		elseif nCR <= 4 then
			nXP = 1200
		elseif nCR <= 5 then
			nXP = 1600
		elseif nCR <= 6 then
			nXP = 2400
		elseif nCR <= 7 then
			nXP = 3200
		elseif nCR <= 8 then
			nXP = 4800
		elseif nCR <= 9 then
			nXP = 6400
		elseif nCR <= 10 then
			nXP = 9600
		elseif nCR <= 11 then
			nXP = 12800
		elseif nCR <= 12 then
			nXP = 19200
		elseif nCR <= 13 then
			nXP = 25600
		elseif nCR <= 14 then
			nXP = 38400
		elseif nCR <= 15 then
			nXP = 51200
		elseif nCR <= 16 then
			nXP = 76800
		elseif nCR <= 17 then
			nXP = 102400
		elseif nCR <= 18 then
			nXP = 153600
		elseif nCR <= 19 then
			nXP = 204800
		elseif nCR <= 20 then
			nXP = 307200
		elseif nCR <= 21 then
			nXP = 409600
		elseif nCR <= 22 then
			nXP = 614400
		elseif nCR <= 23 then
			nXP = 819200
		elseif nCR <= 24 then
			nXP = 1228800
		elseif nCR <= 25 then
			nXP = 1638400
		elseif nCR <= 26 then
			nXP = 2457600
		elseif nCR <= 27 then
			nXP = 3276800
		elseif nCR <= 28 then
			nXP = 4915200
		elseif nCR <= 29 then
			nXP = 6553600
		else
			nXP = 9830400
		end
	end
	return nXP
end

function calcBattleXP(nodeBattle)
	local sTargetNPCList = LibraryData.getCustomData("battle", "npclist") or "npclist"

	local nXP = 0
	for _, vNPCItem in pairs(DB.getChildren(nodeBattle, sTargetNPCList)) do
		local sClass,
			sRecord = DB.getValue(vNPCItem, "link", "", "")
		if sRecord ~= "" then
			local nodeCompanion = DB.findNode(sRecord)
			if nodeCompanion then
				local nXPNPC = getXPFromCR(DB.getValue(nodeCompanion, "cr", 0))
				if nXPNPC >= 0 then
					nXP = nXP + (DB.getValue(vNPCItem, "count", 0) * nXPNPC)
				else
					local sMsg = string.format(Interface.getString("enc_message_refreshxp_missingnpcxp"), DB.getValue(vNPCItem, "name", ""))
					ChatManager.SystemMessage(sMsg)
				end
			else
				local sMsg = string.format(Interface.getString("enc_message_refreshxp_missingnpclink"), DB.getValue(vNPCItem, "name", ""))
				ChatManager.SystemMessage(sMsg)
			end
		end
	end

	DB.setValue(nodeBattle, "exp", "number", nXP)
end

function calcBattleCR(nodeBattle)
	calcBattleXP(nodeBattle)

	local nXP = DB.getValue(nodeBattle, "exp", 0)
	local nCR = getCRFromXP(nXP)
	DB.setValue(nodeBattle, "level", "number", nCR)
end

--
--	COMBAT ACTION FUNCTIONS
--

function addRightClickDiceToClauses(rRoll)
	if #rRoll.clauses > 0 then
		local nOrigDamageDice = 0
		for _, vClause in ipairs(rRoll.clauses) do
			nOrigDamageDice = nOrigDamageDice + #vClause.dice
		end
		if #rRoll.aDice > nOrigDamageDice then
			local v = rRoll.clauses[#rRoll.clauses].dice
			for i = nOrigDamageDice + 1, #rRoll.aDice do
				table.insert(rRoll.clauses[1].dice, rRoll.aDice[i])
			end
		end
	end
end

--
--	Effects FUNCTIONS
--
function addEffectResolve(sUser, rTarget, rActor, aEffect)
	local sTargetCT = ActorManager.getCTNode(rTarget)
	local rEffect = aEffect
	EffectManager.addEffect(sUser, "", sTargetCT, aEffect, false)
	if rEffect.sSource == "" then
		local sSourceCT = ""
		if ActorManager.getType(rSource) == "pc" then
			sSourceCT = ActorManager.getCTNodeName(rSource)
		end
		if sSourceCT == "" then
			local nodeTempCT = nil
			if User.isHost() then
				nodeTempCT = CombatManager.getActiveCT()
			else
				nodeTempCT = CombatManager.getCTFromNode("charsheet." .. User.getCurrentIdentity())
			end
			if nodeTempCT then
				sSourceCT = nodeTempCT.getNodeName()
			end
		end
		if sSourceCT ~= "" then
			rEffect.sSource = sSourceCT
			EffectManager.onEffectSourceChanged(rEffect, DB.findNode(sSourceCT))
		end
	end

	-- If source is same as target, then don't specify a source
	if rEffect.sSource == sTargetCT then
		rEffect.sSource = ""
	end

	-- If source is non-friendly faction and target does not exist or is non-friendly, then effect should be GM only
	if (rSource and ActorManager.getFaction(rSource) ~= "friend") and (not rTarget or ActorManager.getFaction(rTarget) ~= "friend") then
		rEffect.nGMOnly = 1
	end
	EffectManager.notifyApply(rEffect, sTargetCT)
	return
end

--- Companion FUNCTIONS
function addCompanion(nodeCompanion)
	-- Parameter validation
	if not nodeCompanion then
		return
	end

	-- Create a new combat tracker window
	local nodeEntry = DB.createChild(CombatManager.CT_LIST)
	if not nodeEntry then
		return
	end	
	local sToken = DB.getValue(nodeCompanion, "token", nil);
	-- Set up the CT specific information
	DB.setValue(nodeEntry, "link", "windowreference", "companionsheet", nodeCompanion.getNodeName())
	DB.setValue(nodeEntry, "friendfoe", "string", "friend")
	if not sToken or sToken == "" then
		sToken = "portrait_" .. nodeCompanion.getName() .. "_token"
	end
	DB.setValue(nodeEntry, "token", "token", sToken);
	local nSpace = DB.getValue(nodeCompanion, "space", 5);
	local nReach = DB.getValue(nodeCompanion, "reach", 5);
	DB.setValue(nodeEntry, "space", "number", nSpace);
	DB.setValue(nodeEntry, "reach", "number", nReach);
	
	
	--Write Owner Name to CT DB
	local sOwnersName = DB.getValue(nodeCompanion,"owner","");
	DB.setValue(nodeEntry, "owner", "string", sOwnersName)
	-- Offensive properties
	local nodeAttacks = nodeEntry.createChild("attacks")
	if nodeAttacks then
		-- delete any existing entries
		for _, v in pairs(nodeAttacks.getChildren()) do
			v.delete()
		end

		local nAttacks = 0
		local sMeleeAttacks = DB.getValue(nodeCompanion, "melee", "")
		local aAttackWords = StringManager.parseWords(sMeleeAttacks)
		for i, v in pairs(aAttackWords) do
			if DataCommon.dmgtypes_stol[v] ~= nil then
			----Debug.chat("found index: ",i);
			end
		end

	--[[
		if sMeleeAttacks ~= "" then
			local sMeleeAttack = string.gsub(sMeleeAttacks, " and ", "|");
			local aAttacks = StringManager.split(sMeleeAttacks, "|", false);
			local sMeleeAttacks = table.concat(aAttacks," and ");				
			local nodeValue = nodeAttacks.createChild();
			if nodeValue then					
				DB.setValue(nodeValue, "value", "string", StringManager.capitalize(sMeleeAttacks));
				DB.setValue(nodeValue, "type", "number", 0);
				nAttacks = nAttacks + 1;
			end
        end
        ]]
	--
    end
	local aEffects = {};
	local aAddDamageTypes = {};
	-- Decode monster type qualities
	local sType = DB.getValue(nodeCompanion, "type", ""):lower()
	local sSubType = DB.getValue(nodeCompanion, "subtype", ""):lower()
	local aTypes = StringManager.split(sType, ",", true)
	local aSubTypes = StringManager.split(sSubType, ",", true)

	if StringManager.contains(aSubTypes, "lawful") then
		table.insert(aAddDamageTypes, "lawful")
	end
	if StringManager.contains(aSubTypes, "chaotic") then
		table.insert(aAddDamageTypes, "chaotic")
	end
	if StringManager.contains(aSubTypes, "good") then
		table.insert(aAddDamageTypes, "good")
	end
	if StringManager.contains(aSubTypes, "evil") then
		table.insert(aAddDamageTypes, "evil")
	end

	-- Decode NPC Type adjustments
	if StringManager.contains(aTypes, "aberration") then
		--	table.insert(aEffects, "SAVE:2,Will");
		table.insert(aEffects, "Aberration traits")
	elseif StringManager.contains(aTypes, "animal") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:2,Refl");
		table.insert(aEffects, "Animal traits")
	elseif StringManager.contains(aTypes, "construct") then
		table.insert(aEffects, "Construct traits")
		--	table.insert(aEffects, "SAVE:-2");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: death effects")
		table.insert(aEffects, "IMMUNE: disease")
		table.insert(aEffects, "IMMUNE: mind-affecting")
		table.insert(aEffects, "IMMUNE: necromancy")
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "dragon") then
		--	table.insert(aEffects, "SAVE:2");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Dragon traits")
	elseif StringManager.contains(aTypes, "fey") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:2,Refl");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Fey traits")
	elseif StringManager.contains(aTypes, "humanoid") then
		table.insert(aEffects, "Humanoid traits")
	elseif StringManager.contains(aTypes, "magical beast") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:2,Refl");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Magical Beast traits")
	elseif StringManager.contains(aTypes, "monstrous humanoid") then
		--	table.insert(aEffects, "SAVE:2,Will");
		--	table.insert(aEffects, "SAVE:2,Refl");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Monstrous Humanoid traits")
	elseif StringManager.contains(aTypes, "ooze") then
		table.insert(aEffects, "Ooze traits")
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "SAVE:-2,Refl");
		--	table.insert(aEffects, "SAVE:-2,Will");
		table.insert(aEffects, "IMMUNE: critical")
		table.insert(aEffects, "IMMUNE: posion")
		table.insert(aEffects, "IMMUNE: polymorph")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "outsider") then
		--	table.insert(aEffects, "SAVE:2,Fort");
		--	table.insert(aEffects, "ATK:1");
		table.insert(aEffects, "Outsider traits")
	elseif StringManager.contains(aTypes, "plant") then
		table.insert(aEffects, "Plant traits")
		--	table.insert(aEffects, "SAVE:2,Fort");
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: polymorph")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "undead") then
		table.insert(aEffects, "Undead traits")
		--	table.insert(aEffects, "SAVE:2,Will");
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: death effects")
		table.insert(aEffects, "IMMUNE: disease")
		table.insert(aEffects, "IMMUNE: mind-affecting")
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "vermin") then
		table.insert(aEffects, "Vermin traits")
	--	table.insert(aEffects, "SAVE:2,Fort");
	end

	-- Decode NPC SubType immunities (1.0.12 Changed "IMMUNE: "bleed" to "IMMUNE: "bleeding" to match effect.)
	if StringManager.contains(aTypes, "elemental") then
		table.insert(aEffects, "Elemental traits")
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: critical")
		table.insert(aEffects, "IMMUNE: paralysis")
		table.insert(aEffects, "IMMUNE: poison")
		table.insert(aEffects, "IMMUNE: sleep")
		table.insert(aEffects, "IMMUNE: stunning")
	elseif StringManager.contains(aTypes, "swarm") then
		table.insert(aEffects, "Elemental traits")
		table.insert(aEffects, "IMMUNE: bleeding")
		table.insert(aEffects, "IMMUNE: critical")
		table.insert(aEffects, "IMMUNE: flat-footed")
		table.insert(aEffects, "IMMUNE: off-target")
		table.insert(aEffects, "IMMUNE: pinned")
		table.insert(aEffects, "IMMUNE: prone")
		table.insert(aEffects, "IMMUNE: staggered")
		table.insert(aEffects, "IMMUNE: stunning")
	end

	-- DECODE DEFENSIVE ABILITIES
	local sDefensiveAbilities = string.lower(DB.getValue(nodeCompanion, "defensiveabilities", ""))
	local aDAWords = StringManager.parseWords(sDefensiveAbilities)
	local i = 1
	while aDAWords[i] do
		-- HARDNESS
		if StringManager.isWord(aDAWords[i], "hardness") and StringManager.isNumberString(aDAWords[i + 1]) then
			-- DAMAGE REDUCTION
			i = i + 1
			local sHardnessAmount = aDAWords[i]
			if (tonumber(aDAWords[i + 1]) or 0) <= 20 then
				table.insert(aEffects, "DR: " .. sHardnessAmount .. " adamantine; RESIST: " .. sHardnessAmount .. " all")
			else
				table.insert(aEffects, "DR: " .. sHardnessAmount .. " all; RESIST: " .. sHardnessAmount .. " all")
			end
		elseif
			StringManager.isWord(aDAWords[i], "dr") or (StringManager.isWord(aDAWords[i], "damage") and StringManager.isWord(aDAWords[i + 1], "reduction"))
		 then
			-- SPELL RESISTANCE
			if aDAWords[i] ~= "dr" then
				i = i + 1
			end

			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				local sDRAmount = aDAWords[i]
				local aDRTypes = {}

				while aDAWords[i + 1] do
					if StringManager.isWord(aDAWords[i + 1], {"and", "or"}) then
						table.insert(aDRTypes, aDAWords[i + 1])
					elseif StringManager.isWord(aDAWords[i + 1], {"epic", "magic"}) then
						table.insert(aDRTypes, aDAWords[i + 1])
						table.insert(aAddDamageTypes, aDAWords[i + 1])
					elseif StringManager.isWord(aDAWords[i + 1], "cold") and StringManager.isWord(aDAWords[i + 2], "iron") then
						table.insert(aDRTypes, "cold iron")
						i = i + 1
					elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
						table.insert(aDRTypes, aDAWords[i + 1])
					else
						break
					end

					i = i + 1
				end

				local sDREffect = "DR: " .. sDRAmount
				if #aDRTypes > 0 then
					sDREffect = sDREffect .. " " .. table.concat(aDRTypes, " ")
				end
				table.insert(aEffects, sDREffect)
			end
		elseif
			StringManager.isWord(aDAWords[i], "sr") or (StringManager.isWord(aDAWords[i], "spell") and StringManager.isWord(aDAWords[i + 1], "resistance"))
		 then
			-- FAST HEALING
			if aDAWords[i] ~= "sr" then
				i = i + 1
			end

			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				DB.setValue(nodeEntry, "sr", "number", tonumber(aDAWords[i]) or 0)
			end
		elseif StringManager.isWord(aDAWords[i], "fast") and StringManager.isWord(aDAWords[i + 1], {"healing", "heal"}) then
			-- REGENERATION
			i = i + 1
			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				table.insert(aEffects, "FHEAL: " .. aDAWords[i])
			end
		elseif StringManager.isWord(aDAWords[i], "regeneration") then
			-- RESISTANCES
			if StringManager.isNumberString(aDAWords[i + 1]) then
				i = i + 1
				local sRegenAmount = aDAWords[i]
				local aRegenTypes = {}

				while aDAWords[i + 1] do
					if StringManager.isWord(aDAWords[i + 1], {"and", "or"}) then
						table.insert(aRegenTypes, aDAWords[i + 1])
					elseif StringManager.isWord(aDAWords[i + 1], "cold") and StringManager.isWord(aDAWords[i + 2], "iron") then
						table.insert(aRegenTypes, "cold iron")
						i = i + 1
					elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
						table.insert(aRegenTypes, aDAWords[i + 1])
					else
						break
					end

					i = i + 1
				end
				i = i - 1

				local sRegenEffect = "REGEN: " .. sRegenAmount
				if #aRegenTypes > 0 then
					sRegenEffect = sRegenEffect .. " " .. table.concat(aRegenTypes, " ")
				end
				table.insert(aEffects, sRegenEffect)
			end
		elseif StringManager.isWord(aDAWords[i], "resistances") then
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], "and") then
					-- SKIP
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.energytypes) and StringManager.isNumberString(aDAWords[i + 2]) then
					i = i + 1
					table.insert(aEffects, "RESIST: " .. aDAWords[i + 1] .. " " .. aDAWords[i])
				else
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], "resist") then
			-- WEAKNESSES
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], DataCommon.energytypes) and StringManager.isNumberString(aDAWords[i + 2]) then
					i = i + 1
					table.insert(aEffects, "RESIST: " .. aDAWords[i + 1] .. " " .. aDAWords[i])
				elseif not StringManager.isWord(aDAWords[i + 1], "and") then
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], {"weakness", "weaknesses"}) then
			-- IMMUNITY
			i = i + 1
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i], "and") then
					-- SKIP
				elseif
					StringManager.isWord(aDAWords[i], "light") and
						(StringManager.isWord(aDAWords[i + 1], "sensitivity") or StringManager.isWord(aDAWords[i + 1], "blindness"))
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i] .. " " .. aDAWords[i + 1])
					i = i + 1
				elseif
					StringManager.isWord(aDAWords[i], "sunlight") and
						(StringManager.isWord(aDAWords[i + 1], "dependency") or StringManager.isWord(aDAWords[i + 1], "blindness"))
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i] .. " " .. aDAWords[i + 1])
					i = i + 1
				elseif
					StringManager.isWord(aDAWords[i], "vulnerable") and StringManager.isWord(aDAWords[i + 1], "to") and
						StringManager.isWord(aDAWords[i + 2], DataCommon.energytypes)
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i + 2])
					i = i + 2
				elseif
					StringManager.isWord(aDAWords[i], "vulnerable") and StringManager.isWord(aDAWords[i + 1], "to") and
						StringManager.isWord(aDAWords[i + 2], "critical")
				 then
					table.insert(aEffects, "VULN: " .. aDAWords[i + 2])
					i = i + 2
				elseif StringManager.isWord(aDAWords[i], DataCommon.energytypes) then
					table.insert(aEffects, "VULN: " .. aDAWords[i])
				elseif StringManager.isWord(aDAWords[i], DataCommon.conditions) then
					table.insert(aEffects, "VULN: " .. aDAWords[i])
				elseif StringManager.isWord(aDAWords[i], "atrophied") then
					table.insert(aEffects, "VULN: " .. aDAWords[i])
				else
					break
				end

				i = i + 1
			end
		elseif
			StringManager.isWord(aDAWords[i], "immunities") and
				(StringManager.isWord(aDAWords[i + 1], DataCommon.immunetypes) or StringManager.isWord(aDAWords[i + 1], DataCommon.damagetypes) or
					(StringManager.isWord(aDAWords[i + 1], DataCommon.creaturetype) and StringManager.isWord(aDAWords[i + 2], "immunities")))
		 then
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], "and") then
					-- SKIP
				elseif StringManager.isWord(aDAWords[i + 2], "immunities") then
					-- Add exception for "magic immunity", which is also a damage type
					--	table.insert(aEffects, "IMMUNE: " .. aDAWords[i+1] .. " " .. aDAWords[i+2]);
					i = i + 1
				elseif StringManager.isWord(aDAWords[i + 1], "magic") then
					table.insert(aEffects, "IMMUNE: spell")
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.immunetypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
					if StringManager.isWord(aDAWords[i + 2], "effects") then
						i = i + 1
					end
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
				else
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], "immune") then
			-- SPECIAL DEFENSES
			while aDAWords[i + 1] do
				if StringManager.isWord(aDAWords[i + 1], "and") then
					--SKIP
				elseif StringManager.isWord(aDAWords[i + 1], "traits") then
					-- SKIP+
					-- Add exception for "magic immunity", which is also a damage type
				elseif StringManager.isWord(aDAWords[i + 1], "magic") then
					table.insert(aEffects, "IMMUNE: spell")
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.immunetypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
					if StringManager.isWord(aDAWords[i + 2], "effects") then
						i = i + 1
					end
				elseif StringManager.isWord(aDAWords[i + 1], DataCommon.dmgtypes) then
					table.insert(aEffects, "IMMUNE: " .. aDAWords[i + 1])
				else
					break
				end

				i = i + 1
			end
		elseif StringManager.isWord(aDAWords[i], "uncanny") and StringManager.isWord(aDAWords[i + 1], "agility") then
			if StringManager.isWord(aDAWords[i - 1], "improved") then
				table.insert(aEffects, "Improved Uncanny Agility")
			else
				table.insert(aEffects, "Uncanny Agility")
			end
			i = i + 1
		elseif StringManager.isWord(aDAWords[i], "evasion") then
			-- TRAITS
			if StringManager.isWord(aDAWords[i - 1], "improved") then
				table.insert(aEffects, "Improved Evasion")
			else
				table.insert(aEffects, "Evasion")
			end
		elseif StringManager.isWord(aDAWords[i], "incorporeal") then
			table.insert(aEffects, "Incorporeal")
		elseif StringManager.isWord(aDAWords[i], "blur") then
			table.insert(aEffects, "CONC")
		elseif StringManager.isWord(aDAWords[i], "natural") and StringManager.isWord(aDAWords[i + 1], "invisibility") then
			table.insert(aEffects, "Invisible")
		else
			local specialAbilityNode = getNPCSpecialAbility(nodeCompanion, aDAWords[i]) -- .. " " .. aDAWords[i+1]
			if specialAbilityNode ~= nil then
				local sNPCEffectName = DB.getValue(specialAbilityNode, "name", "")
				local sNPCEffects = DB.getValue(specialAbilityNode, "effect", "")
				local aNPCEffects = StringManager.split(sNPCEffects, "%;", true)
				if #aNPCEffects > 0 then
					table.insert(aEffects, sNPCEffectName)
				end
				for _, sEffect in pairs(aNPCEffects) do
					table.insert(aEffects, sEffect)
				end
			end
		end

		-- ITERATE SPECIAL QUALITIES DECODE
		i = i + 1
	end
    -- FINISH ADDING EXTRA DAMAGE TYPES
	if #aAddDamageTypes > 0 then
		table.insert(aEffects, "DMGTYPE: " .. table.concat(aAddDamageTypes, ","))
	end

	-- ADD DECODED EFFECTS
	if #aEffects > 0 then
		for _, sEffect in pairs(aEffects) do
			EffectManager.addEffect("", "", nodeEntry, {sName = sEffect, nDuration = 0, nGMOnly = 1}, false)
		end
	end

end

function rollTypeInit(sType, fRollCombatantEntryInit, ...)
--Debug.chat("rollTypeInit",sType, fRollCombatantEntryInit, ...)	
	for f, v in pairs(CombatManager.getCombatantNodes()) do	
		local bRoll = true
		if sType == nil then
			local sClass,NodeString = DB.getValue(v, "link", "", "")
	--Debug.chat(sClass,NodeString)
		if sClass == "companionsheet" then
				bRoll = false				
			end
		end
		if sType then
			local sClass,_ = DB.getValue(v, "link", "", "")
			if sType == "npc" and sClass == "charsheet" then
				bRoll = false
			elseif sType == "npc" and sClass == "companionsheet" then
				bRoll = false
			elseif sType == "pc" and sClass ~= "charsheet" then
				bRoll = false
			end
		end

		if bRoll then
			DB.setValue(v, "initresult", "number", -10000)
		end
	end

	for _, v in pairs(CombatManager.getCombatantNodes()) do
		local bRoll = true
		if sType == nil then
			local sClass,_ = DB.getValue(v, "link", "", "")
			if sClass == "companionsheet" then
				bRoll = false
			end
		end
		if sType then
			local sClass,_ = DB.getValue(v, "link", "", "")
			if sType == "npc" and sClass == "charsheet" then
				bRoll = false
			elseif sType == "npc" and sClass == "companionsheet" then
				bRoll = false
			elseif sType == "pc" and sClass ~= "charsheet" then
				bRoll = false
			end
		end

		if bRoll then
			fRollCombatantEntryInit(v, ...)
		end
	end
end

function handleCompanionInit(rSource, nTotal)
	if not rSource then
		return;
	end
	local sType,nodeSource = ActorManager.getTypeAndNode(rSource);		
	local sCompanionName = DB.getValue(nodeSource, "companion","");
		if sCompanionName ~= "" then			
			--get Companions CT Node
			local sClass, sRecord = DB.getValue(nodeSource, "companionlink", "", "");			
			local nodeCompanion = DB.findNode(sRecord);
			local rActor = ActorManager2.getActor("companion", nodeCompanion);	
			-- Write Companions Init to CT

			local nodeCompanion = ActorManager.DB.findNode(rActor.sCTNode);			
			DB.setValue(ActorManager.DB.findNode(rActor.sCTNode), "initresult", "number", nTotal);
		end
	return;
end

function sortfuncStandard(node1, node2)
	local bHost = User.isHost();
	local sOptCTSI = OptionsManager.getOption("CTSI");
	
	local sFaction1 = DB.getValue(node1, "friendfoe", "");
	local sFaction2 = DB.getValue(node2, "friendfoe", "");
	
	local bShowInit1 = bHost or ((sOptCTSI == "friend") and (sFaction1 == "friend")) or (sOptCTSI == "on");
	local bShowInit2 = bHost or ((sOptCTSI == "friend") and (sFaction2 == "friend")) or (sOptCTSI == "on");
	
	if bShowInit1 ~= bShowInit2 then
		if bShowInit1 then
			return true;
		elseif bShowInit2 then
			return false;
		end
	else
		if bShowInit1 then
			local nValue1 = DB.getValue(node1, "initresult", 0);
			local nValue2 = DB.getValue(node2, "initresult", 0);
			if nValue1 ~= nValue2 then
				return nValue1 > nValue2;
			end
		else
			if sFaction1 ~= sFaction2 then
				if sFaction1 == "friend" then
					return true;
				elseif sFaction2 == "friend" then
					return false;
				end
			end
		end
	end
	
	local sValue1 = DB.getValue(node1, "name", "");
	local sValue2 = DB.getValue(node2, "name", "");
	local sClass1 = DB.getValue(node1, "link", "", "");
	local sClass2 = DB.getValue(node2, "link", "", "");
	local sCompOwner1 = DB.getValue(node1,"owner", "");
	local sCompOwner2 = DB.getValue(node2,"owner", "");			
	if sValue1 ~= sValue2 then		
		if sClass1 == "companionsheet" and sCompOwner1 ~= "" then
			if sCompOwner1 == sValue2 then
				return sValue1 > sValue2;
			end
		elseif	sClass2 == "companionsheet" and sCompOwner2 ~= "" then
			if sCompOwner2 == sValue1 then
				return sValue1 > sValue2;
			end				
		else
			return sValue1 < sValue2;
		end
	end
	return node1.getNodeName() < node2.getNodeName();
end

function addPC(nodePC)
	if fCustomAddPC then
		return fCustomAddPC(nodePC);
	end
	
	-- Parameter validation
	if not nodePC then
		return;
	end

	-- Create a new combat tracker window
	local nodeEntry = DB.createChild(CombatManager.CT_LIST);
	if not nodeEntry then
		return;
	end
	
	-- Set up the CT specific information
	DB.setValue(nodeEntry, "link", "windowreference", "charsheet", nodePC.getNodeName());
	DB.setValue(nodeEntry, "friendfoe", "string", "friend");
	DB.setValue(nodeEntry, "turndamage", "number", 0);
	local sToken = DB.getValue(nodePC, "token", nil);
	if not sToken or sToken == "" then
		sToken = "portrait_" .. nodePC.getName() .. "_token"
	end
    DB.setValue(nodeEntry, "token", "token", sToken);
    local encstat = DB.getValue(nodePC, "encumbrance.encstat", 1);
    if encstat > 1 then
        local encstate = DB.getValue(nodePC, "encumbrance.state", "");
        aEffect = { sName = encstate, nDuration = 0 };
	    EffectManager.addEffect("", "", nodeEntry, aEffect, true);
    end
end
