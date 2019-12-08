-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

RACIAL_TRAIT_ABILITY_D20PFSRD = "^ability score racial traits$";
RACIAL_TRAIT_ABILITY_SW = "attribute adjustments$";
RACIAL_TRAIT_LANGUAGES = "^languages$";
RACIAL_TRAIT_SIZE = "^size$";
RACIAL_TRAIT_SIZE_MEDIUM = "^medium$";
RACIAL_TRAIT_SIZE_SMALL = "^small$";
RACIAL_TRAIT_SPEED_GENERIC = "^speed$";
RACIAL_TRAIT_SPEED_D20PFSRD = "^base speed$";
RACIAL_TRAIT_SPEED_SRD_NORMAL = "^normal speed$";
RACIAL_TRAIT_SPEED_SRD_SLOW = "^slow speed$";
RACIAL_TRAIT_SLOW_AND_STEADY = "^slow and steady$";
RACIAL_TRAIT_DARKVISION = "^darkvision$";
RACIAL_TRAIT_LOWLIGHTVISION = "^low light vision$";
RACIAL_TRAIT_SUPERIORDARKVISION = "^superior darkvision$";
RACIAL_TRAIT_BLINDSENSE = "^blindsense$";
RACIAL_TRAIT_TELEPATHY = "^telepathy$";
RACIAL_TRAIT_LIMITED_TELEPATHY = "^limited telepathy$";
RACIAL_TRAIT_WEAPONFAMILIARITY = "^weapon familiarity$";

TRAIT_MULTITALENTED = "multitalented";

CLASS_NAME_ENVOY = "Envoy";
CLASS_NAME_MECHANIC = "Mechanic";
CLASS_NAME_MYSTIC = "Mystic";
CLASS_NAME_OPERATIVE = "Operative";
CLASS_NAME_SOLARIAN = "Solarian";
CLASS_NAME_SOLDIER = "Soldier";
CLASS_NAME_TECHNOMANCER = "Technomancer";
CLASS_NAME_ADEPT = "Adept";
CLASS_NAME_ALCHEMIST = "Alchemist";
CLASS_NAME_BARD = "Bard";
CLASS_NAME_CLERIC = "Cleric";
CLASS_NAME_DRUID = "Druid";
CLASS_NAME_INQUISITOR = "Inquisitor";
CLASS_NAME_MYSTIC_THEURGE = "Mystic Theurge";
CLASS_NAME_ORACLE = "Oracle";
CLASS_NAME_PALADIN = "Paladin";
CLASS_NAME_RANGER = "Ranger";
CLASS_NAME_SORCERER = "Sorcerer";
CLASS_NAME_SUMMONER = "Summoner";
CLASS_NAME_WITCH = "Witch";
CLASS_NAME_WIZARD = "Wizard";

CLASS_BAB_DRONE = "drone";
CLASS_BAB_FAST = "fast";
CLASS_BAB_MEDIUM = "medium";
CLASS_BAB_SLOW = "slow";

CLASS_SAVE_GOOD = "good";
CLASS_SAVE_BAD = "bad";
CLASS_SAVE_GOOD_DRONE = "dgood";
CLASS_SAVE_BAD_DRONE = "dbad";

CLASS_FEATURE_PROFICIENCY = "^weapon and armor proficiency$";
CLASS_FEATURE_SPELLS_PER_DAY = "^spells per day";
CLASS_FEATURE_EXTRACTS_PER_DAY = "^extracts per day";
CLASS_FEATURE_SPELLS = "^spells$";
CLASS_FEATURE_ALCHEMY = "^alchemy$";
CLASS_FEATURE_DOMAINS = "^domains$";
CLASS_FEATURE_DOMAIN_SPELLS = "Domain Spells";

FEAT_MULTIPLE_TIMES = "multiple times";
FEAT_TOUGHNESS = "toughness";

CURRENT_NODECHAR = nil;
CURRENT_CLASS = nil;
CURRENT_LEVEL = nil;
OOB_MSGTYPE_RESOLVE_STAB = "stablize";
function onInit()	
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_RESOLVE_STAB, notifyResolveStab);
	OOBManager.registerOOBMsgHandler("claimcompanion", claimCompanion);

	--OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_RESOLVE_STAY, onResolveStay);
	ItemManager.setCustomCharAdd(onCharItemAdd);
	ItemManager.setCustomCharRemove(onCharItemDelete);
	initWeaponIDTracking();	
end
--
-- RESOLVE MANAGEMENT
--
function onResolveStam(nodeChar, rActor)
	--local nodeChar = window.getDatabaseNode();
	--local rActor = ActorManager.getActor("pc", window.getDatabaseNode());						
	local nResolve = DB.getValue(nodeChar, "rp.current", 0);	
	local nStamina = DB.getValue(nodeChar, "sp.current", 0);
	local nStaminaTotal = DB.getValue(nodeChar, "sp.total", 0);		
						
	local msg = {font = "msgfont"};					
		if nResolve > 0 then	
			if nStamina < nStaminaTotal then
				DB.setValue(nodeChar, "sp.fatique", "number", 0);
				nResolveNew = nResolve - 1;
				DB.setValue(nodeChar, "rp.current", "number", nResolveNew);
				AbilityManager.updateActionClassesRP(nodeChar,nResolveNew);
				msg.text = "[RESOLVE] " .. rActor.sName .. " spending resolve and taking a 10 min (Short Rest) to recover stamina.";
				Comm.deliverChatMessage(msg);
				
			else
				msg.text = "[RESOLVE] " .. rActor.sName .. " Stamina at MAX.";
				Comm.deliverChatMessage(msg);
			end
		end
					
end	
function onResolveStab(nodeChar, rActor)
	local nHpCurr = DB.getValue(nodeChar, "hp.current", 0);
	local nResolveBase = DB.getValue(nodeChar, "rp.total", 0);
	local nResolveMod = DB.getValue(nodeChar, "rp.mod", 0);
	local nResolve = DB.getValue(nodeChar, "rp.current", 0);
	local nResolveMax = nResolveBase + nResolveMod;					
	local nResolveCost = 0;
	local msg = {font = "msgfont"};
	local nResolveCost = math.floor(nResolveMax / 4);
		if nResolveCost > 3 then
			nResolveCost = 3;					
		elseif nResolveCost < 1 then
			nResolveCost = 1;
		else
			local nResolveCost = math.floor(nResolveMax / 4);
		end
					
	local bResolveTest = false;
		if (nResolve - nResolveCost) > -1 then
		   bResolveTest = true;
		end
					
		if not EffectManagerSFRPG.hasEffect(rActor, "Dying") then
			msg.text = "[RESOLVE] " .. rActor.sName .. " : No Effect (Dying)";
			Comm.deliverChatMessage(msg);
		elseif nHpCurr == 0 and nResolve > 0 and bResolveTest then					
			if User.isHost() then
				if not EffectManagerSFRPG.hasEffect(rActor, "Stable") then														
					nResolve = nResolve - nResolveCost;		
					DB.setValue(nodeChar, "rp.current", "number", nResolve);
					AbilityManager.updateActionClassesRP(nodeChar,nResolve);
					local nodeCT = CombatManager.getCTFromNode(nodeChar);
					local aEffect = { sName = "Stable", nDuration = 0 };					
						if nodeCT then
							EffectManager.removeEffect(nodeCT, "Dying");									
							EffectManager.addEffect("", "", nodeCT, aEffect, true);
							
						end								
							msg.text = "[RESOLVE] " .. rActor.sName .. " is using " .. nResolveCost .. " resolve to STABILIZE";
							Comm.deliverChatMessage(msg);								
						end
				else
                    --USER IS CLIENT Button was pressd by Client
                    --REMOVE "Dying" and ADD "Stable"
					local nodeCT = CombatManager.getCTFromNode(nodeChar);															
						nResolve = nResolve - nResolveCost;		
						DB.setValue(nodeChar, "rp.current", "number", nResolve);
						AbilityManager.updateActionClassesRP(nodeChar,nResolve);
					if not EffectManagerSFRPG.hasEffect(rActor, "Stable") then								
						msg.text = "[RESOLVE] " .. rActor.sName .. " is using " .. nResolveCost .. " resolve to STABILIZE";
						Comm.deliverChatMessage(msg);

							EffectManager.removeEffect(nodeCT, "Dying");
						local aEffect = {sName = "Stable", nDuration = 0 };
							EffectManager.notifyApply(aEffect, rActor.sCTNode);						
					end
				end
			end
				
					
end	
function onResolveStay(nodeChar, rActor)
	--local nodeChar = window.getDatabaseNode();
	--local rActor = ActorManager.getActor("pc", window.getDatabaseNode());						
	local nHpCurr = DB.getValue(nodeChar, "hp.current", 0);
	local nWounds = DB.getValue(nodeChar, "hp.wounds", 0);
	local nResolve = DB.getValue(nodeChar, "rp.current", 0);	
	local msg = {font = "msgfont"};
		if User.isHost() then
			if nHpCurr == 0 and nResolve > 0 then
				if EffectManagerSFRPG.hasEffect(rActor, "Stable") then							
					nWounds = nWounds - 1;
					nResolve = nResolve - 1	;						
						
					DB.setValue(nodeChar, "hp.wounds", "number", nWounds);
					DB.setValue(nodeChar, "rp.current", "number", nResolve);
					AbilityManager.updateActionClassesRP(nodeChar,nResolve);			
					local nodeCT = CombatManager.getCTFromNode(nodeChar);
					if nodeCT then
						EffectManager.removeEffect(nodeCT, "Stable");
						EffectManager.removeEffect(nodeCT, "Unconscious");
					end						
					msg.text = "[RESOLVE] " .. rActor.sName .. " is using a Resolve to STAY IN FIGHT";
					Comm.deliverChatMessage(msg);
				else							
					msg.text = "[RESOLVE] " .. rActor.sName .. "is not STABLE";
					Comm.deliverChatMessage(msg);
				end						
			end
		else
            --USER IS CLIENT Button was pressd by Client
            --NEED TO REMOVE "Stable" and "Unconscious"
            --notifyExpire(varEffect, nMatch, bImmediate)
			if EffectManagerSFRPG.hasEffect(rActor, "Stable") then
			--Send Msg to inform GM
				msg.text = "[RESOLVE] " .. rActor.sName .. " used a resolve to STAY IN FIGHT";
				Comm.deliverChatMessage(msg);
			-- Add 1 HP
				nWounds = nWounds - 1;
					nResolve = nResolve - 1	;							
					DB.setValue(nodeChar, "hp.wounds", "number", nWounds);
					DB.setValue(nodeChar, "rp.current", "number", nResolve);
					AbilityManager.updateActionClassesRP(nodeChar,nResolve);
			-- Remove Effects
				for _,v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do				
					local sLabel = DB.getValue(v, "label", "");
					if sLabel == "Stable" or sLabel == "Unconscious" then
						EffectManager.notifyExpire(v, 0, true);	
					end
				end	
			else							
				msg.text = "[RESOLVE] " .. rActor.sName .. "is not STABLE";
				Comm.deliverChatMessage(msg);				
			end
		end
end				


--
-- CLASS MANAGEMENT
--				
function calcLevel(nodeChar)
	local nLevel = 0;
	
	for _,nodeChild in pairs(DB.getChildren(nodeChar, "classes")) do
		nLevel = nLevel + DB.getValue(nodeChild, "level", 0);
	end
	
	DB.setValue(nodeChar, "level", "number", nLevel);
end

function sortClasses(a,b)
	return a.getName() < b.getName();
end

function getClassLevelSummary(nodeChar, bLong)
	if not nodeChar then
		return "";
	end
	
	local aClasses = {};

	local aSorted = {};
	for _,nodeChild in pairs(DB.getChildren(nodeChar, "classes")) do
		table.insert(aSorted, nodeChild);
	end
	table.sort(aSorted, sortClasses);
			
	local bLongClassNames = bLong and #aSorted <= 3;
	for _,nodeChild in pairs(aSorted) do
		local sClass = DB.getValue(nodeChild, "name", "");
		local nLevel = DB.getValue(nodeChild, "level", 0);
		if nLevel > 0 then
			nLevel = math.floor(nLevel*100)*0.01;
			if bLongClassNames then
				table.insert(aClasses, sClass .. " " .. nLevel);
			else
				table.insert(aClasses, string.sub(sClass, 1, 3) .. " " .. nLevel);
			end
		end
	end

	local sSummary = table.concat(aClasses, " / ");
	return sSummary;
end


--
-- ITEM/FOCUS MANAGEMENT
--

function onCharItemAdd(nodeItem)
	DB.setValue(nodeItem, "carried", "number", 1);
	DB.setValue(nodeItem, "showonminisheet", "number", 1);

	if DB.getValue(nodeItem, "type", "") == "Goods and Services" then
		local sSubType = DB.getValue(nodeItem, "subtype", "");
		if (sType == "Goods and Services") and StringManager.contains({"Mounts and Related Gear", "Transport", "Spellcasting and Services"}, sSubType) then
			DB.setValue(nodeItem, "carried", "number", 0);
		end
	end
	
	addToArmorDB(nodeItem);
	addToWeaponDB(nodeItem);
end

function onCharItemDelete(nodeItem)
	removeFromArmorDB(nodeItem);
	removeFromWeaponDB(nodeItem);
end

--
-- ARMOR MANAGEMENT
-- 

function removeFromArmorDB(nodeItem)
	-- Parameter validation
	if not ItemManager2.isArmor(nodeItem) then
		return;
	end
	
	-- If this armor was worn, recalculate AC
	if DB.getValue(nodeItem, "carried", 0) == 2 then
		DB.setValue(nodeItem, "carried", "number", 1);
	end
end

function addToArmorDB(nodeItem)
	-- Parameter validation
	local bIsArmor, _, sSubtypeLower = ItemManager2.isArmor(nodeItem);
	if not bIsArmor then
		return;
	end
	local bIsShield = (sSubtypeLower == "shield");
	
	-- Determine whether to auto-equip armor
	local bArmorAllowed = true;
	local bShieldAllowed = true;
	local nodeChar = nodeItem.getChild("...");
	if (bArmorAllowed and not bIsShield) or (bShieldAllowed and bIsShield) then
		local bArmorEquipped = false;
		local bShieldEquipped = false;
		for _,v in pairs(DB.getChildren(nodeItem, "..")) do
			if DB.getValue(v, "carried", 0) == 2 then
				local bIsItemArmor, _, sItemSubtypeLower = ItemManager2.isArmor(v);
				if bIsItemArmor then
					if (sItemSubtypeLower == "shield") then
						bShieldEquipped = true;
					else
						bArmorEquipped = true;
					end
				end
			end
		end
		if bShieldAllowed and bIsShield and not bShieldEquipped then
			DB.setValue(nodeItem, "carried", "number", 2);
		elseif bArmorAllowed and not bIsShield and not bArmorEquipped then
			DB.setValue(nodeItem, "carried", "number", 2);
		end
	end
end

function calcItemArmorClass(nodeChar)
	local nStrAdj = 0;
	local nStrMod = 0;
	local nMainKArmorTotal = 0;	
	local nMainKShieldTotal = 0;
	local nMainEArmorTotal = 0;
	local nMainEShieldTotal = 0;
	local nMainMaxStatBonus = 0;
	local nMainCheckPenalty = 0;
	local nMainSpellFailure = 0;
	local nMainSpeed30 = 0;
	local nMainSpeed20 = 0;
	local nEncPower = 0;
	local nEncStr = 0;
	local nItemBonus = 0;	
	--local nEncStr = 0;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		--if DB.getValue(vNode, "carried", 0) == 1 then
		--						DB.setValue (nodeChar, "abilities.strength.damage", "number", 0);
		--end
		if DB.getValue(vNode, "carried", 0) == 2 then
			local bIsArmor, _, sSubtypeLower = ItemManager2.isArmor(vNode);
			if bIsArmor then
				local bID = LibraryData.getIDState("item", vNode, true);
				
				local bIsShield = (sSubtypeLower == "shield");
				if bIsShield then
					if bID then
						nMainKShieldTotal = nMainKShieldTotal + DB.getValue(vNode, "kacbonus", 0) + DB.getValue(vNode, "bonus", 0);						
					else
						nMainKShieldTotal = nMainKShieldTotal + DB.getValue(vNode, "kacbonus", 0);						
					end
				else
					if bID then
						--Adjust AC Values
						nMainKArmorTotal = nMainKArmorTotal + DB.getValue(vNode, "kacbonus", 0) + DB.getValue(vNode, "bonus", 0);
						nMainEArmorTotal = nMainEArmorTotal + DB.getValue(vNode, "eacbonus", 0) + DB.getValue(vNode, "bonus", 0);				
						--Adjust STR for Powered Armor							
							local nItemStrBonusMod = DB.getValue(vNode, "strengthmod", 0);
							local nStrItem = 0;
							local nCharStrEnc = DB.getValue(nodeChar, "abilitiesedit.strength.encumbrance", 0);
							local nCharStr = DB.getValue(nodeChar, "abilities.strength.score", 10);
							local sStrItem = DB.getValue(vNode, "strength");
								
							if sStrItem == "" or sStrItem == nil then
								nStrItem = 0;
							else
								nStrItem = tonumber(sStrItem);
							end								
														
							if nStrItem > 0 then								
								nItemBonus = (nItemStrBonusMod);
								if nStrItem > nCharStr then
								nEncStr = ((nStrItem - nCharStr) +  nCharStrEnc); --Adds to Str to increase Str to Items Str Value
								nEncPower = (nStrItem);
								else
								nEncStr =- ((nCharStr - nStrItem) +  nCharStrEnc); --Subtracts from Str to decrease Str to Items Str Value
								nEncPower = (nStrItem);
								end
							end
							
					else
						nMainKArmorTotal = nMainKArmorTotal + DB.getValue(vNode, "kac", 0);
						nMainEArmorTotal = nMainEArmorTotal + DB.getValue(vNode, "eac", 0);
						
						--Adjust STR for Powered Armor
						local sStrItem = DB.getValue(vNode, "strength");
						if sStrItem == "" or sStrItem == nil then
							nStrItem = 0;
						else
							nStrItem = tonumber(sStrItem);
						end
						local nItemStrBonusMod = DB.getValue(vNode, "strengthmod", 0);																		
						
						local nCharStrEnc = DB.getValue(nodeChar, "abilitiesedit.strength.encumbrance", 0);
						local nCharStr = DB.getValue(nodeChar, "abilities.strength.score", 10);
						
						if nStrItem > 0 then								
							nItemBonus = (nItemStrBonusMod);
							if nStrItem > nCharStr then
							nEncPower = ((nStrItem - nCharStr) +  nCharStrEnc); --Adds to Str to increase Str to Items Str Value
							nEncPower = (nStrItem);
							else
							nEncPower = ((nCharStr - nStrItem) +  nCharStrEnc); --Subtracts from Str to decrease Str to Items Str Value
							nEncPower = (nStrItem);
							end
						end
					end
				end
					
				local sMaxStatBonus = DB.getValue(vNode, "maxdexbonus", "");
				nMaxStatBonus = tonumber(sMaxStatBonus);
				
				if nMaxStatBonus == nil then nMaxStatBonus = 0 end
				if nMaxStatBonus > 0 then
					nMainMaxStatBonus = math.max(nMainMaxStatBonus, nMaxStatBonus);
				end
				
				local sCheckPenalty = DB.getValue(vNode, "acpenalty", 0);
				nCheckPenalty = tonumber(sCheckPenalty);
				
				if nCheckPenalty > 0 then
				  nCheckPenalty = nCheckPenalty - (nCheckPenalty *2);
				
				end
				if nCheckPenalty < 0 then
					nMainCheckPenalty = nMainCheckPenalty + nCheckPenalty;
				end
				
				local sSpellFailure = DB.getValue(vNode, "spellfailure", 0);
				nSpellFailure = tonumber(sSpellFailure);
				if nSpellFailure > 0 then
					nMainSpellFailure = nMainSpellFailure + nSpellFailure;
				end		
			end
		end
	end
 	
	
	
	DB.setValue(nodeChar, "ac.sources.kac.armor", "number", nMainKArmorTotal);
	DB.setValue(nodeChar, "ac.sources.kac.shield", "number", nMainKShieldTotal);
	DB.setValue(nodeChar, "ac.sources.eac.armor", "number", nMainEArmorTotal);
	DB.setValue(nodeChar, "abilitiesedit.strength.encumbrance", "number", nEncStr);
	DB.setValue(nodeChar, "encumbrance.encpower", "number", nEncPower);	
	
	
	if nMainMaxStatBonus > 0 then
		DB.setValue(nodeChar, "encumbrance.armormaxstatbonusactive", "number", 1);
		DB.setValue(nodeChar, "encumbrance.armormaxstatbonus", "number", nMainMaxStatBonus);
	else
		DB.setValue(nodeChar, "encumbrance.armormaxstatbonusactive", "number", 0);
		DB.setValue(nodeChar, "encumbrance.armormaxstatbonus", "number", 0);
	end
	DB.setValue(nodeChar, "encumbrance.armorcheckpenalty", "number", nMainCheckPenalty);
	DB.setValue(nodeChar, "encumbrance.spellfailure", "number", nMainSpellFailure);
	
	local bApplySpeedPenalty = true;
	if hasTrait(nodeChar, "Slow and Steady") then
		bApplySpeedPenalty = false;
	end

	local nSpeedBase = DB.getValue(nodeChar, "speed.base", 0);
	local nSpeedArmor = 0;
	if bApplySpeedPenalty then
		if (nSpeedBase >= 30) and (nMainSpeed30 > 0) then
			nSpeedArmor = nMainSpeed30 - 30;
		elseif (nSpeedBase < 30) and (nMainSpeed20 > 0) then
			nSpeedArmor = nMainSpeed20 - 20;
		end
	end
	DB.setValue(nodeChar, "speed.armor", "number", nSpeedArmor);
	local nSpeedTotal = nSpeedBase + nSpeedArmor + DB.getValue(nodeChar, "speed.misc", 0) + DB.getValue(nodeChar, "speed.temporary", 0);
	DB.setValue(nodeChar, "speed.final", "number", nSpeedTotal);
end

--
-- WEAPON MANAGEMENT
--

function removeFromWeaponDB(nodeItem)
	if not nodeItem then
		return false;
	end
	
	-- Check to see if any of the weapon nodes linked to this item node should be deleted
	local sItemNode = nodeItem.getNodeName();
	local sItemNode2 = "....inventorylist." .. nodeItem.getName();
	local bMeleeFound = false;
	local bRangedFound = false;
	for _,v in pairs(DB.getChildren(nodeItem, "...weaponlist")) do
		local sClass, sRecord = DB.getValue(v, "shortcut", "", "");
		if sRecord == sItemNode or sRecord == sItemNode2 then
			local sType = DB.getValue(v, "type", 0);
			if sType == 1 and not bMeleeFound then
				bMeleeFound = true;
				v.delete();
			elseif sType == 0 and not bRangedFound then
				bRangedFound = true;
				v.delete();
			end
		end
	end

	-- We didn't find any linked weapons
	return (bMeleeFound or bRangedFound);
end

function addToWeaponDB(nodeItem)
	-- Parameter validation
	if DB.getValue(nodeItem, "type", "") ~= "Weapon" or DB.getValue(nodeItem,"subtype","") == "Ammunition" then
		return;
	end
	
	-- Get the weapon list we are going to add to
	local nodeChar = nodeItem.getChild("...");
	local nodeWeapons = nodeChar.createChild("weaponlist");
	if not nodeWeapons then
		return nil;
	end
	
	-- Set new weapons as equipped
	DB.setValue(nodeItem, "carried", "number", 2);

	-- Determine identification
	local nItemID = 0;
	if LibraryData.getIDState("item", nodeItem, true) then
		nItemID = 1;
	end
	
	-- Grab some information from the source node to populate the new weapon entries
	local sName;
	if nItemID == 1 then
		sName = DB.getValue(nodeItem, "name", "");
	else
		sName = DB.getValue(nodeItem, "nonid_name", "");
		if sName == "" then
			sName = Interface.getString("item_unidentified");
		end
		sName = "** " .. sName .. " **";
	end
	local nBonus = 0;
	if nItemID == 1 then
		nBonus = DB.getValue(nodeItem, "bonus", 0);
	end
	-- Set Ammo Uses for Ranged Weapon
	local sSetRange = DB.getValue(nodeItem, "range", "");
	local sRangestrip = StringManager.strip(sSetRange):gsub("ft.","");
	local nRange = tonumber(sRangestrip);	
	 if nRange == nil then
	  nRange = 0;
	 end			
		local nMaxAmmo = 0;
		local sAmmo = DB.getValue(nodeItem, "capacity", ""):lower();
		if sAmmo == "drawn" then
		 nUses = 1;
		else
			for _,ammo in pairs(DataCommon.ammotypes) do
			local sAmmoStrip = StringManager.strip(sAmmo):gsub(ammo,"");
			local nAmmo = tonumber(sAmmoStrip);	
				if nAmmo ~= nil then
				 nMaxAmmo = nAmmo;
				end				
			end
			local sAmmoUsage = DB.getValue(nodeItem, "usage", "1");
			local nAmmoUsage = tonumber(sAmmoUsage);
			if nAmmoUsage == nil then
			   nAmmoUsage = 1;
			end
				nUses = math.floor(nMaxAmmo / nAmmoUsage);				
		end 
	local nAtkBonus = nBonus;

	local sType = string.lower(DB.getValue(nodeItem, "subtype", ""));
	local bMelee = false;
	local bRanged = true;
	if string.find(sType, "melee") then	
		bMelee = true;	
		local sRangedTest = DB.getValue(nodeItem, "special", ""):lower();
		if string.find(sRangedTest, "thrown") then
			bRanged = true;
			nUses = 1;
		else
			bRanged = false;
		end
		
	end
	
	local bDouble = false;	
	local sProps = DB.getValue(nodeItem, "properties", "");
	
	local sPropsLower = sProps:lower();
	if sPropsLower:match("double") then
		bDouble = true;
	end
	
	if nAtkBonus == 0 and (sPropsLower:match("masterwork") or sPropsLower:match("adamantine")) then
		nAtkBonus = 1;
	end
	local bTwoWeaponFight = false;
	if hasFeat(nodeChar, "Multi Weapon Fighting") then
		bTwoWeaponFight = true;
	end
	
	local aDamage = {};
	local bCritEffect = false;
	local sDamage = DB.getValue(nodeItem, "damage", "");
	local aDamageSplit = StringManager.split(sDamage, "/");
	for kDamage, vDamage in ipairs(aDamageSplit) do
		local diceDamage, nDamage = StringManager.convertStringToDice(vDamage);
		table.insert(aDamage, { dice = diceDamage, mod = nDamage });
	end
	
	local sDamageType = string.lower(DB.getValue(nodeItem, "damagetype", ""));
	
	sCritical = "";
	local sCritical = DB.getValue(nodeItem, "critical", "");
	
		if sCritical ~= "" and sCritical ~= "-" then
		  bCritEffect = true;
		end
	
	sDamageType = string.gsub(sDamageType, " and ", ",");
	sDamageType = string.gsub(sDamageType, " or ", ",");
	
	local sDmg = "";
	if sDamageType == "" then
		if string.find(sDamage, "%d+d%d+[%+|%-]*%d*%s(.*)") then
			sDmg = string.match(sDamage, "%d+d%d+[%+|%-]*%d*%s(.*)");
			sDmg = string.gsub(sDmg, " & ", ",");
		end
	end		
	local aDamageTypes = ActionDamage.getDamageTypesFromString(sDmg);		
	local aCritThreshold = { 20 };
	local aCritMult = { 2 };	 
	--local aCrit = StringManager.split(sCritical, "/");
	local nThresholdIndex = 1;
	local nMultIndex = 1;
	--for kCrit, sCrit in ipairs(aCrit) do
		--local sCritThreshold = string.match(sCrit, "(%d+)[%-�]20");
		--if sCritThreshold then
		--	aCritThreshold[nThresholdIndex] = tonumber(sCritThreshold) or 20;
		--	nThresholdIndex = nThresholdIndex + 1;
		--end		
	--	local sCritMult = string.match(sCrit, "x(%d)");
	--	if sCritMult then
	--		aCritMult[nMultIndex] = tonumber(sCritMult) or 2;
	--		nMultIndex = nMultIndex + 1;
	--	end
	--end
	
	-- Get some character data to pre-fill weapon info
	local nBAB = DB.getValue(nodeChar, "attackbonus.base", 0);
	--local nAttacks = math.floor((nBAB - 1) / 5) + 1;
	--if nAttacks < 1 then
	local nAttacks = 2;
	--end
	local sMeleeAttackStat = DB.getValue(nodeChar, "attackbonus.melee.ability", "");
	local sRangedAttackStat = DB.getValue(nodeChar, "attackbonus.ranged.ability", "");
	
	if bMelee then
		local nodeWeapon = nodeWeapons.createChild();
		if nodeWeapon then
			DB.setValue(nodeWeapon, "isidentified", "number", nItemID);
			DB.setValue(nodeWeapon, "shortcut", "windowreference", "item", "....inventorylist." .. nodeItem.getName());
			
			if bDouble then
				DB.setValue(nodeWeapon, "name", "string", sName .. " (2H)");
			else
				DB.setValue(nodeWeapon, "name", "string", sName);
			end
			DB.setValue(nodeWeapon, "type", "number", 0);
			DB.setValue(nodeWeapon, "properties", "string", sProps);
			
			DB.setValue(nodeWeapon, "attacks", "number", nAttacks);
			DB.setValue(nodeWeapon, "attackstat", "string", sMeleeAttackStat);
			DB.setValue(nodeWeapon, "bonus", "number", nAtkBonus);

			DB.setValue(nodeWeapon, "critatkrange", "number", aCritThreshold[1]);
			
            DB.setValue(nodeWeapon, "special", "string", DB.getValue(nodeItem, "special",""));
            --UPDATE
            DB.setValue(nodeWeapon, "subtype", "string", sType);
			local nodeDmgList = DB.createChild(nodeWeapon, "damagelist");
			if nodeDmgList then			 
				local nodeDmg = DB.createChild(nodeDmgList);
				if nodeDmg then
					if aDamage[1] then
						DB.setValue(nodeDmg, "dice", "dice", aDamage[1].dice);
						DB.setValue(nodeDmg, "bonus", "number", nBonus + aDamage[1].mod);
					else
						DB.setValue(nodeDmg, "bonus", "number", nBonus);
					end
					
					DB.setValue(nodeDmg, "stat", "string", "strength");
					if string.find(sType, "two%-handed") then
						DB.setValue(nodeDmg, "statmult", "number", 1.5);
					end
					
					DB.setValue(nodeDmg, "critmult", "number", aCritMult[1]);
					DB.setValue(nodeDmg, "criteffect", "string", sCritical);
					if bDouble then					
						if aDamageTypes[1] then
							if bCritEffect then 
								DB.setValue(nodeDmg, "type", "string", aDamageTypes[1] .. ";" .. sCritical);
							else
								DB.setValue(nodeDmg, "type", "string", aDamageTypes[1]);
							end
						end
					else
						if bCritEffect then	
							DB.setValue(nodeDmg, "type", "string", table.concat(aDamageTypes, ",") .. ";" .. sCritical, " ,");
						else
							DB.setValue(nodeDmg, "type", "string", table.concat(aDamageTypes,","));
						end
					end
				end
			end
		end
	end

	-- Double head 1
	if bMelee and bDouble then
		local nodeWeapon = nodeWeapons.createChild();
		if nodeWeapon then
			DB.setValue(nodeWeapon, "isidentified", "number", nItemID);
			DB.setValue(nodeWeapon, "shortcut", "windowreference", "item", "....inventorylist." .. nodeItem.getName());
			
			DB.setValue(nodeWeapon, "name", "string", sName .. " (D1)");
			DB.setValue(nodeWeapon, "type", "number", 0);
			DB.setValue(nodeWeapon, "properties", "string", sProps);

			DB.setValue(nodeWeapon, "attacks", "number", nAttacks);
			DB.setValue(nodeWeapon, "attackstat", "string", sMeleeAttackStat);
			if bTwoWeaponFight then
				DB.setValue(nodeWeapon, "bonus", "number", nAtkBonus - 2);
			else
				DB.setValue(nodeWeapon, "bonus", "number", nAtkBonus - 4);
			end
			
			DB.setValue(nodeWeapon, "critatkrange", "number", aCritThreshold[1]);
			DB.setValue(nodeWeapon, "special", "string", DB.getValue(nodeItem, "special",""));
            --UPDATE
            DB.setValue(nodeWeapon, "subtype", "string", sType);
			local nodeDmgList = DB.createChild(nodeWeapon, "damagelist");
			if nodeDmgList then
				local nodeDmg = DB.createChild(nodeDmgList);
				if nodeDmg then
					if aDamage[1] then
						DB.setValue(nodeDmg, "dice", "dice", aDamage[1].dice);
						DB.setValue(nodeDmg, "bonus", "number", nBonus + aDamage[1].mod);
					else
						DB.setValue(nodeDmg, "bonus", "number", nBonus);
					end

					DB.setValue(nodeDmg, "critmult", "number", aCritMult[1]);
					DB.setValue(nodeWeapon, "criteffect", "string", sCritical);
					DB.setValue(nodeDmg, "stat", "string", "strength");
					
					if aDamageTypes[2] then
						DB.setValue(nodeDmg, "type", "string", aDamageTypes[2] .. "; " .. sCritical);
					end
				end
			end
		end
	end

	-- Double head 2
	if bMelee and bDouble then
		local nodeWeapon = nodeWeapons.createChild();
		if nodeWeapon then
			DB.setValue(nodeWeapon, "isidentified", "number", nItemID);
			DB.setValue(nodeWeapon, "shortcut", "windowreference", "item", "....inventorylist." .. nodeItem.getName());
			
			DB.setValue(nodeWeapon, "name", "string", sName .. " (D2)");
			DB.setValue(nodeWeapon, "type", "number", 0);
			DB.setValue(nodeWeapon, "properties", "string", sProps);

			DB.setValue(nodeWeapon, "attacks", "number", 1);
			DB.setValue(nodeWeapon, "attackstat", "string", sMeleeAttackStat);
			DB.setValue(nodeWeapon, "special", "string", DB.getValue(nodeItem, "special",""));
			if bTwoWeaponFight then
				DB.setValue(nodeWeapon, "bonus", "number", nAtkBonus - 2);
			else
				DB.setValue(nodeWeapon, "bonus", "number", nAtkBonus - 8);
			end
			
			if aCritThreshold[2] then
				DB.setValue(nodeWeapon, "critatkrange", "number", aCritThreshold[2]);
			else
				DB.setValue(nodeWeapon, "critatkrange", "number", aCritThreshold[1]);
			end
            --UPDATE
            DB.setValue(nodeWeapon, "subtype", "string", sType);

			local nodeDmgList = DB.createChild(nodeWeapon, "damagelist");
			if nodeDmgList then
				local nodeDmg = DB.createChild(nodeDmgList);
				if nodeDmg then
					if aDamage[2] then
						DB.setValue(nodeDmg, "dice", "dice", aDamage[2].dice);
						DB.setValue(nodeDmg, "bonus", "number", nBonus + aDamage[2].mod);
					elseif aDamage[1] then
						DB.setValue(nodeDmg, "dice", "dice", aDamage[1].dice);
						DB.setValue(nodeDmg, "bonus", "number", nBonus + aDamage[1].mod);
					else
						DB.setValue(nodeDmg, "bonus", "number", nBonus);
					end

					if aCritMult[2] then
						DB.setValue(nodeDmg, "critmult", "number", aCritMult[2]);
						DB.setValue(nodeWeapon, "criteffect", "string", sCritical);
					else
						DB.setValue(nodeDmg, "critmult", "number", aCritMult[1]);
						DB.setValue(nodeWeapon, "criteffect", "string", sCritical);
					end
					
					DB.setValue(nodeDmg, "stat", "string", "strength");
					DB.setValue(nodeDmg, "statmult", "number", 0.5);
					
					if aDamageTypes[1] then
						if aDamageTypes[2] then
							DB.setValue(nodeDmg, "type", "string", aDamageTypes[2] .. "; " .. sCritical);
						else
							DB.setValue(nodeDmg, "type", "string", aDamageTypes[1] .. "; " .. sCritical);
						end
					end
				end
			end
		end
	end

	if bRanged then
		
		--local sUsage = DB.getValue(nodeItem, "usage", "");		
		--if nUses == "" then
		--elseif sUsage ~= "" then
		--local nUsage = tonumber(sUsage);
		--end
		
		local nodeWeapon = nodeWeapons.createChild();
		if nodeWeapon then
			DB.setValue(nodeWeapon, "isidentified", "number", nItemID);
			DB.setValue(nodeWeapon, "shortcut", "windowreference", "item", "....inventorylist." .. nodeItem.getName());			
			DB.setValue(nodeWeapon, "name", "string", sName);
			DB.setValue(nodeWeapon, "type", "number", 1);
			DB.setValue(nodeWeapon, "properties", "string", sProps);
			-- nRange is a "string" ie. 60ft 120ft. ect we need this to change to a number		
			DB.setValue(nodeWeapon, "rangeincrement", "number", nRange);			
			DB.setValue(nodeWeapon, "uses", "number", nUses);
			DB.setValue(nodeWeapon, "ammo", "number", 0)
			DB.setValue(nodeWeapon, "attacks", "number", nAttacks);
			DB.setValue(nodeWeapon, "attackstat", "string", sRangedAttackStat);
			DB.setValue(nodeWeapon, "bonus", "number", nAtkBonus);
			DB.setValue(nodeWeapon, "critatkrange", "number", aCritThreshold[1]);
			DB.setValue(nodeWeapon, "special", "string", DB.getValue(nodeItem, "special",""));
            --UPDATE
            DB.setValue(nodeWeapon, "subtype", "string", sType);
			local nodeDmgList = DB.createChild(nodeWeapon, "damagelist");
			if nodeDmgList then
				local nodeDmg = DB.createChild(nodeDmgList);
				if nodeDmg then
					if aDamage[1] then
						DB.setValue(nodeDmg, "dice", "dice", aDamage[1].dice);
						DB.setValue(nodeDmg, "bonus", "number", nBonus + aDamage[1].mod);
					else
						DB.setValue(nodeDmg, "bonus", "number", nBonus);
					end

					DB.setValue(nodeDmg, "critmult", "number", aCritMult[1]);
					DB.setValue(nodeWeapon, "criteffect", "string", sCritical);
					if string.find(sType, "melee") then	
						DB.setValue(nodeDmg, "stat", "string", "strength");
					elseif sSubType == "grenade" then
						DB.setValue(nodeDmg, "stat", "string", "");
						DB.setValue(nodeWeapon, "criteffect", "string", sCritical);
					elseif string.find(string.lower(sName), "crossbow") or sName == "Net" or sName == "Blowgun" then
						DB.setValue(nodeDmg, "stat", "string", "");
					else
						DB.setValue(nodeDmg, "stat", "string", "");
					end
					
					if bCritEffect then								
						DB.setValue(nodeDmg, "type", "string", table.concat(aDamageTypes, ", ") .. ";" .. sCritical, " ,");
					else
						DB.setValue(nodeDmg, "type", "string", table.concat(aDamageTypes, ", "));
					end
				end
			end
		end
	end
end
function initWeaponIDTracking()
	DB.addHandler("charsheet.*.inventorylist.*.isidentified", "onUpdate", onItemIDChanged);
end

function onItemIDChanged(nodeItemID)
	local nodeItem = nodeItemID.getChild("..");
	local nodeChar = nodeItemID.getChild("....");
	
	local sPath = nodeItem.getPath();
	for _,vWeapon in pairs(DB.getChildren(nodeChar, "weaponlist")) do
		local _,sRecord = DB.getValue(vWeapon, "shortcut", "", "");
		if sRecord == sPath then
			checkWeaponIDChange(vWeapon);
		end
	end
end

function checkWeaponIDChange(nodeWeapon)
	local _,sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
	if sRecord == "" then
		return;
	end
	local nodeItem = DB.findNode(sRecord);
	if not nodeItem then
		return;
	end
	
	local bItemID = LibraryData.getIDState("item", DB.findNode(sRecord), true);
	local bWeaponID = (DB.getValue(nodeWeapon, "isidentified", 1) == 1);
	if bItemID == bWeaponID then
		return;
	end
	
	local sOldName = DB.getValue(nodeWeapon, "name", "");
	local aOldParens = {};
	for w in sOldName:gmatch("%([^%)]+%)") do
		table.insert(aOldParens, w);
	end
	local sOldSuffix = nil;
	if #aOldParens > 0 then
		sOldSuffix = aOldParens[#aOldParens];
	end
	
	local sName;
	if bItemID then
		sName = DB.getValue(nodeItem, "name", "");
	else
		sName = DB.getValue(nodeItem, "nonid_name", "");
		if sName == "" then
			sName = Interface.getString("item_unidentified");
		end
		sName = "** " .. sName .. " **";
	end
	if sOldSuffix then
		sName = sName .. " " .. sOldSuffix;
	end
	DB.setValue(nodeWeapon, "name", "string", sName);
	
	local nBonus = 0;
	if bItemID then
		DB.setValue(nodeWeapon, "bonus", "number", DB.getValue(nodeWeapon, "bonus", 0) + DB.getValue(nodeItem, "bonus", 0));
		local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
		if #aDamageNodes > 0 then
			DB.setValue(aDamageNodes[1], "bonus", "number", DB.getValue(aDamageNodes[1], "bonus", 0) + DB.getValue(nodeItem, "bonus", 0));
		end
	else
		DB.setValue(nodeWeapon, "bonus", "number", DB.getValue(nodeWeapon, "bonus", 0) - DB.getValue(nodeItem, "bonus", 0));
		local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
		if #aDamageNodes > 0 then
			DB.setValue(aDamageNodes[1], "bonus", "number", DB.getValue(aDamageNodes[1], "bonus", 0) - DB.getValue(nodeItem, "bonus", 0));
		end
	end
	
	if bItemID then
		DB.setValue(nodeWeapon, "isidentified", "number", 1);
	else
		DB.setValue(nodeWeapon, "isidentified", "number", 0);
	end
end

function getWeaponAttackRollStructures(nodeWeapon, nAttack)
	if not nodeWeapon then
		return;
	end
	
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);

	local rAttack = {};
	rAttack.type = "attack";
	rAttack.label = DB.getValue(nodeWeapon, "name", "");
	local nType = DB.getValue(nodeWeapon, "type", 0);
	if nType == 2 then
		rAttack.range = "M";
		rAttack.cm = true;
	elseif nType == 1 then
		rAttack.range = "R";
	else
		rAttack.range = "M";
	end
	rAttack.crit = DB.getValue(nodeWeapon, "critatkrange", 20);
	rAttack.stat = DB.getValue(nodeWeapon, "attackstat", "");
	if rAttack.stat == "" then
		if rAttack.range == "M" then
			rAttack.stat = "strength";
		else
			rAttack.stat = "dexterity";
		end
	end
	
	local sProp = DB.getValue(nodeWeapon, "properties", ""):lower();
	if sProp:match("touch") or sProp:match("eac") then
		rAttack.touch = true;
	end
	
	return rActor, rAttack;
end

function getWeaponDamageRollStructures(nodeWeapon)
	local nodeChar = nodeWeapon.getChild("...");
	local rActor = ActorManager.getActor("pc", nodeChar);

	local bRanged = (DB.getValue(nodeWeapon, "type", 0) == 1);

	local rDamage = {};
	rDamage.type = "damage";
	rDamage.label = DB.getValue(nodeWeapon, "name", "");
	if bRanged then
		rDamage.range = "R";
	else
		rDamage.range = "M";
	end
	
	rDamage.clauses = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
	for _,v in ipairs(aDamageNodes) do
		local sDmgType = DB.getValue(v, "type", "");
		local aDmgDice = DB.getValue(v, "dice", {});
		local nDmgMod = DB.getValue(v, "bonus", 0);
		local nDmgMult = DB.getValue(v, "critmult", 2);

		local nMult = 1;
		local nMax = 0;
		local sDmgAbility = DB.getValue(v, "stat", "");
		if sDmgAbility ~= "" then
			nMult = DB.getValue(v, "statmult", 1);
			nMax = DB.getValue(v, "statmax", 0);
			local nAbilityBonus = ActorManager2.getAbilityBonus(rActor, sDmgAbility);
			if nMax > 0 then
				nAbilityBonus = math.min(nAbilityBonus, nMax);
			end
			if nAbilityBonus > 0 and nMult ~= 1 then
				nAbilityBonus = math.floor(nMult * nAbilityBonus);
			end
			nDmgMod = nDmgMod + nAbilityBonus;
		end
		
		table.insert(rDamage.clauses, 
				{ 
					dice = aDmgDice, 
					modifier = nDmgMod, 
					mult = nDmgMult,
					stat = sDmgAbility, 
					statmax = nMax,
					statmult = nMult,
					dmgtype = sDmgType, 
				});
	end
	
	return rActor, rDamage;
end

function onActionDrop(draginfo, nodeChar)
	if draginfo.isType("spellmove") then
		ChatManager.Message(Interface.getString("spell_error_dropclassmissing"));
		return true;
	elseif draginfo.isType("spelldescwithlevel") then
		ChatManager.Message(Interface.getString("spell_error_dropclassmissing"));
		return true;
	elseif draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		
		if sClass == "spelldesc" or sClass == "spelldesc2" then
			ChatManager.Message(Interface.getString("spell_error_dropclasslevelmissing"));
			return true;
		elseif LibraryData.isRecordDisplayClass("item", sClass) and ItemManager2.isWeapon(sRecord) then
			return ItemManager.handleAnyDrop(nodeChar, draginfo);
		end
	end
end

--
-- ACTIONS
--

function rest(nodeChar)
	SpellManager.resetSpells(nodeChar);
	ActionAbility.resetUsesPerDay(nodeChar)
	resetHealth(nodeChar);
end

function resetHealth(nodeChar)
	
	-- Clear temporary points HP/SP/RP
	DB.setValue(nodeChar, "hp.temporary", "number", 0);
	DB.setValue(nodeChar, "sp.temporary", "number", 0);
	DB.setValue(nodeChar, "rp.temporary", "number", 0);

	--SP
	local sCharType = DB.getValue(nodeChar, "data.type", "");
	if sCharType ~= "companion" or sCharType == nil then
		local nSpMax = DB.getValue(nodeChar, "sp.total", 0);	
		DB.setValue(nodeChar, "sp.fatique", "number", 0);
		DB.setValue(nodeChar, "sp.current", "number", nSpMax);
		--RP
		local nLevel = DB.getValue(nodeChar,"level",0);
		local nRpMod = DB.getValue(nodeChar,"rp.mod",0); 
		local nRpKeyAbilityMod = DB.getValue(nodeChar,"abilities.keyabilitymod",0);
		if nRpKeyAbilityMod < 0 then
			nRpKeyAbilityMod = 0;			
		end
		local nRpCal = math.floor(nLevel / 2);
		if nRpCal < 1 then
			nRpCal = 1;			
		end
			
		local nRpMax = nRpCal + nRpKeyAbilityMod + nRpMod;
		DB.setValue(nodeChar,"rp.total","number",nRpMax);
		DB.setValue(nodeChar,"rp.current","number",nRpMax);
		AbilityManager.updateActionClassesRP(nodeChar,nRpMax);
	end
	-- Heal hit points equal to character level
	local nHP = DB.getValue(nodeChar, "hp.total", 0);
	local nLevel = DB.getValue(nodeChar, "level", 0);
	
	local nWounds = DB.getValue(nodeChar, "hp.wounds", 0);
	nWounds = nWounds - nLevel;
	if nWounds + nLevel > nHP then
		local nodeCT = CombatManager.getCTFromNode(nodeChar);
		if nodeCT then
			EffectManager.removeEffect(nodeCT, "Stable");
		end
	end
	if nWounds < 0 then
		nWounds = 0;
	end
	DB.setValue(nodeChar, "hp.wounds", "number", nWounds);
	
	--local nNonlethal = DB.getValue(nodeChar, "hp.nonlethal", 0);
	--nNonlethal = nNonlethal - (nLevel * 8);
	--if nNonlethal < 0 then
	--	nNonlethal = 0;
	--end
	--DB.setValue(nodeChar, "hp.nonlethal", "number", nNonlethal);
	
	-- Heal ability damage
	local nAbilityDamage;
	for kAbility, vAbility in pairs(DataCommon.abilities) do
		nAbilityDamage = DB.getValue(nodeChar, "abilities." .. vAbility .. ".damage", 0);
		if nAbilityDamage > 0 then
			DB.setValue(nodeChar, "abilities." .. vAbility .. ".damage", "number", nAbilityDamage - 1);
		end
	end
end


--
-- DATA ACCESS
--

function getSkillValue(rActor, sSkill, sSubSkill)
	local nValue = 0;
	local bUntrained = false;
	local bTrainedOnly = false;
	local rSkill = DataCommon.skilldata[sSkill];
		if rSkill then 
			bTrainedOnly = (rSkill.trainedonly);
		else
			bTrainedOnly = false;
		end
	local nodeChar = ActorManager.getCreatureNode(rActor);
	if nodeChar then
		local sSkillLower = sSkill:lower();
		local sSubLower = nil;
		if sSubSkill then
			sSubLower = sSubSkill:lower();
		end
		
		local nodeSkill = nil;
		for _,vNode in pairs(DB.getChildren(nodeChar, "skilllist")) do
			local sNameLower = DB.getValue(vNode, "label", ""):lower();

			-- Capture exact matches
			if sNameLower == sSkillLower then
				if sSubLower then
					local sSubName = DB.getValue(vNode, "sublabel", ""):lower();
					if (sSubName == sSubLower) or (sSubLower == "planes" and sSubName == "the planes") then
						nodeSkill = vNode;
						break;
					end
				else
					nodeSkill = vNode;
					break;
				end
			
			-- And partial matches
			elseif sNameLower:sub(1, #sSkillLower) == sSkillLower then
				if sSubLower then
					local sSubName = sNameLower:sub(#sSkillLower + 1):match("%w[%w%s]*%w");
					if sSubName and ((sSubName == sSubLower) or (sSubLower == "planes" and sSubName == "the planes")) then
						nodeSkill = vNode;
						break;
					end
				end
			end
		end
		
		if nodeSkill then
			local nRanks = DB.getValue(nodeSkill, "ranks", 0);
			local nRanksFree = DB.getValue(nodeSkill, "freeranks", 0);
			local nAbility = DB.getValue(nodeSkill, "stat", 0);
			local nMisc = DB.getValue(nodeSkill, "misc", 0);			
			nValue = math.floor(nRanks) + math.floor(nRanksFree) + nAbility + nMisc;

			if nRanks > 0  or nRanksFree > 0 then
				local nState = DB.getValue(nodeSkill, "state", 0);
				if nState == 1 then
					nValue = nValue + 3;
				end
			end
			
			local nACMult = DB.getValue(nodeSkill, "armorcheckmultiplier", 0);
			if nACMult ~= 0 then
				local bApplyArmorMod = DB.getValue(nodeSkill, "...encumbrance.armormaxstatbonusactive", 0);
				if (bApplyArmorMod ~= 0) then
					local nACPenalty = DB.getValue(nodeSkill, "...encumbrance.armorcheckpenalty", 0);
					nValue = nValue + (nACMult * nACPenalty);
				end
			end

			if bTrainedOnly == 1 then			
				if (nRanks + nRanksFree) == 0 then
					bUntrained = true;
				end
			end
		else
			if rSkill then
				if rSkill.stat then
					nValue = nValue + ActorManager2.getAbilityBonus(rActor, rSkill.stat);
				end
				
				if rSkill.armorcheckmultiplier then
					local bApplyArmorMod = DB.getValue(nodeChar, "encumbrance.armormaxstatbonusactive", 0);
					if (bApplyArmorMod ~= 0) then
						local nArmorCheckPenalty = DB.getValue(nodeChar, "encumbrance.armorcheckpenalty", 0);
						nValue = nValue + (nArmorCheckPenalty * (tonumber(rSkill.armorcheckmultiplier) or 0));
					end
				end
			end
		
		end
	else
	return nValue, bUntrained;
	end
	return nValue, bUntrained;
end

function getBaseAttackRollStructures(sAttack, nodeChar)
	local rCreature = ActorManager.getActor("pc", nodeChar);

	local rAttack = {};
	rAttack.type = "attack";
	rAttack.label = sAttack;

	if string.match(string.lower(sAttack), "melee") then
		rAttack.range = "M";
		rAttack.modifier = DB.getValue(nodeChar, "attackbonus.melee.total", 0);
		rAttack.stat = DB.getValue(nodeChar, "attackbonus.melee.ability", "");
		if rAttack.stat == "" then
			rAttack.stat = "strength";
		end
	else
		rAttack.range = "R";
		rAttack.modifier = DB.getValue(nodeChar, "attackbonus.ranged.total", 0);
		rAttack.stat = DB.getValue(nodeChar, "attackbonus.ranged.ability", "");
		if rAttack.stat == "" then
			rAttack.stat = "dexterity";
		end
	end
	
	return rCreature, rAttack;
end

function getCombatManStructures(rActor, sAttack)
	local rAttack = {};
	rAttack.type = "attack";
	rAttack.label = sAttack;
	rAttack.range = "M";
	
	local nodeChar = ActorManager.getCreatureNode(rActor);
	if nodeChar then
		rAttack.modifier = DB.getValue(nodeChar, "attackbonus.grapple.total", 0);
		rAttack.stat = DB.getValue(nodeChar, "attackbonus.grapple.ability", "");
	end
	if rAttack.stat == "" then
		rAttack.stat = "strength";
	end

	return rAttack;
end

function getThrownRollStructures(rActor, sAttack)
	local rAttack = {};
	rAttack.type = "attack";
	rAttack.label = sAttack;
	rAttack.range = "M";
	
	local nodeChar = ActorManager.getCreatureNode(rActor);
	if nodeChar then
		rAttack.modifier = DB.getValue(nodeChar, "attackbonus.thrown.total", 0);
		rAttack.stat = DB.getValue(nodeChar, "attackbonus.thrown.ability", "");
	end
	if rAttack.stat == "" then
		rAttack.stat = "strength";
	end

	return rAttack;
end

function updateSkillPoints(nodeChar)
	if nodeChar == nil then
	 return;
	end	
	--local nodeChar = window.getDatabaseNode();
	local nSpentTotal = 0;	
	local nSpent = 0;
	local nFreeSpent = 0;
	local nSkillRanks = 0;
	local nFreeSkillSpent = 0;
	local nRanksAvab = 0;
	local nOpLevel = 0;
	for _,nodeChild in pairs(DB.getChildren(nodeChar, "classes")) do
			nSkillRanks = nSkillRanks + DB.getValue(nodeChild, "skillranks", 0);
	end	
	for _,vNode in pairs(DB.getChildren(nodeChar, "skilllist")) do	
			nFreeSkill = DB.getValue(vNode, "freeskill", 0);
			if nFreeSkill == nil then 
			nFreeSkill = 0; 
			end 
			if nFreeSkill == 1 then
				for _,vClass in pairs (DB.getChildren(nodeChar, "classes")) do
					if DB.getValue(vClass, "name", "") == "Operative" then
						nOpLevel = DB.getValue(vClass, "level", 1);	
							if nOpLevel == 0 then
							  nOpLevel = 1;
							end
					end
				end
					DB.setValue(vNode, "freeranks", "number", nOpLevel);
					nFreeSpent = nFreeSpent + nOpLevel;
					nSpent = nSpent + DB.getValue(vNode, "ranks", 0);
				else
					nSpent = nSpent + DB.getValue(vNode, "ranks", 0);
					-- DB.setValue(vNode, "ranksfree", "number", 0);
			end
	end
			
			nSpentTotal = nSpent - nFreeSpent;
			nRanksAvab = (nSkillRanks - nSpentTotal - nFreeSpent);
			nFinalTotal = (nSkillRanks + nFreeSpent);
			DB.setValue(nodeChar, "skillpoints.spent", "number", nSpent);
			DB.setValue(nodeChar,"skillpoints.avab","number", nRanksAvab);
			DB.setValue(nodeChar, "skillpoints.freespent", "number", nFreeSpent);
			DB.setValue(nodeChar,"skillpoints.total","number", nFinalTotal);
				
			
			
end

function updateEncumbrance(nodeChar)
	
	local nEncTotal = 0;

	local nCount, nWeight;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		local sItemName= DB.getValue(vNode,"name","");
		local sSubType= DB.getValue(vNode,"subtype","");
		if DB.getValue(vNode, "carried", 0) ~= 0 then
		
			nCount = DB.getValue(vNode, "count", 0);
			if nCount < 1 then
				nCount = 1;
			end	
		
				if string.find(sItemName,"Backpack") and DB.getValue(vNode, "carried", 0) == 2 then
				  nWeight = 0;				
				elseif string.find(sSubType,"Powered") then 
					if DB.getValue(vNode, "carried", 0) == 1 then
						nWeight = DB.getValue(vNode, "weight", 0);
					else
						 nWeight = 0;
					end
				else
					nWeight = DB.getValue(vNode, "weight", 0);
				end
						
			nEncTotal = (nEncTotal + (nCount * nWeight));
			
		end
	end
	local nUPB = DB.getValue(nodeChar, "coins.slot3.amount", 0);
	local nUPBBulk = math.floor(nUPB / 1000);
	nEncTotal = nEncTotal + nUPBBulk;
	DB.setValue(nodeChar, "encumbrance.load", "number", math.floor(nEncTotal));	
	ItemManager2.onEncumbranceChanged(nodeChar);
end

function hasFeat(nodeChar, sFeat)
	if not sFeat then
		return false;
	end
	local sLowerFeat = StringManager.trim(string.lower(sFeat));
	
	for _,vNode in pairs(DB.getChildren(nodeChar, "featlist")) do
		if StringManager.trim(DB.getValue(vNode, "name", ""):lower()) == sLowerFeat then
			return true;
		end
	end
	return false;
end

function hasTrait(nodeChar, sTrait)
	if not sTrait then
		return false;
	end
	local sLowerTrait = StringManager.trim(string.lower(sTrait));
	
	for _,vNode in pairs(DB.getChildren(nodeChar, "traitlist")) do
		if StringManager.trim(DB.getValue(vNode, "name", ""):lower()) == sLowerTrait then
			return true;
		end
	end
	return false;
end


--
-- CHARACTER SHEET DROPS
--

function addInfoDB(nodeChar, sClass, sRecord, nodeTargetList)
	if not nodeChar then
		return false;
	end
	
	if sClass == "race" then
		handleRaceCheck(nodeChar, sClass, sRecord);
	elseif sClass == "theme" then
		handleThemeCheck(nodeChar, sClass, sRecord, nodeTargetList);
	elseif sClass == "racialtrait" then
		addRacialTrait(nodeChar, sClass, sRecord, nodeTargetList);
	elseif sClass == "class" then
		addClass(nodeChar, sClass, sRecord);
		--resetHealth(nodeChar);
	elseif sClass == "class_feature" then
		addClassFeature(nodeChar, sClass, sRecord, nodeTargetList);	
	elseif sClass == "themefeature" then
		addThemeFeature(nodeChar, sClass, sRecord, nodeTargetList);
	elseif sClass == "feat" then
		addFeat(nodeChar, sClass, sRecord, nodeTargetList);	
	elseif sClass == "boon" then
		addBoon(nodeChar, sClass, sRecord, nodeTargetList);	
	elseif sClass == "augmentation" then
		addAug(nodeChar, sRecord, nodeTargetList);
	elseif sClass == "armor template" then
		addUpgrade(nodeChar, sRecord, nodeTargetList);
	else
		return false;
	end
	
	return true;
end

function handleRaceCheck(nodeChar, sClass, sRecord)
	local sRace = DB.getValue(nodeChar, "race","");
    if sRace == "" then
        addRace(nodeChar, sClass, sRecord);
    else
        ChatManager.SystemMessage(Interface.getString("char_error_raceassigned").." ["..sRace.."]");
        return;
    end
end

function handleThemeCheck(nodeChar, sClass, sRecord, nodeTargetList)
	local sTheme = DB.getValue(nodeChar, "theme","");
    if sTheme == "" then
        addTheme(nodeChar, sClass, sRecord, nodeTargetList);
    else
        ChatManager.SystemMessage(Interface.getString("char_error_themeassigned").." ["..sTheme.."]");
        return;
    end
end

function resolveRefNode(sRecord)
	local nodeSource = DB.findNode(sRecord);
	if not nodeSource then
		local sRecordSansModule = StringManager.split(sRecord, "@")[1];
		nodeSource = DB.findNode(sRecordSansModule .. "@*");
		if not nodeSource then
			ChatManager.SystemMessage(Interface.getString("char_error_missingrecord").." ["..sRecord.."]");
		end
	end
	return nodeSource;
end

function getSkillNode(nodeChar, sSkill, sSpecialty)
	if not sSkill then
		return nil;
	end

	local nodeSkill = nil;
	for _,vSkill in pairs(DB.getChildren(nodeChar, "skilllist")) do
		if DB.getValue(vSkill, "label", "") == sSkill then
			if sSpecialty then
				if DB.getValue(vSkill, "sublabel", "") == sSpecialty then
					nodeSkill = vSkill;
				end
			else
				nodeSkill = vSkill;
			end
		end
	end
	if not nodeSkill then
		local t = DataCommon.skilldata[sSkill];
		if t then
			local nodeSkillList = DB.createChild(nodeChar, "skilllist");
			nodeSkill = DB.createChild(nodeSkillList);
			
			DB.setValue(nodeSkill, "label", "string", sSkill);
			DB.setValue(nodeSkill, "statname", "string", t.stat or "");
			DB.setValue(nodeSkill, "showonminisheet", "number", 1);
			
			if t.sublabeling and sSpecialty then
				DB.setValue(nodeSkill, "sublabel", "string", sSpecialty);
			end
		end
	end
	return nodeSkill;
end

function getClassNode(nodeChar, sClassName)
	if not sClassName then
		return nil;
	end

	local nodeClass = nil;
	for _,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		if DB.getValue(vClass, "name", "") == sClassName then
			return vClass;
		end
	end
	return nil;
end

function addRace(nodeChar, sClass, sRecord)-- Modified for SFRPG Russ	
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	sRaceType = DB.getValue(nodeSource, "racetype", "");
	if sRaceType ~= "Companion" then
		local sRace = DB.getValue(nodeSource, "name", "");
		local nHp = DB.getValue(nodeSource, "hp",0);
		local nTotalHp = DB.getValue(nodeChar, "hp.total",0);
		local sSize = DB.getValue(nodeSource, "size","");
		local sFormat = Interface.getString("char_message_raceadd");
		local sMsg = string.format(sFormat, sRace, DB.getValue(nodeChar, "name", ""));
		ChatManager.SystemMessage(sMsg);
		LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Race", sRace);
		LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Racial Hit Points", nHp);		
		nTotalHp = nTotalHp + nHp;
		DB.setValue(nodeChar, "race", "string", sRace);
		DB.setValue(nodeChar, "racelink", "windowreference", sClass, nodeSource.getNodeName());
		DB.setValue(nodeChar, "hp.total", "number", nTotalHp);	
		DB.setValue(nodeChar, "size", "string", sSize);
		for _,v in pairs(DB.getChildren(nodeSource, "traits")) do
			addRacialTrait(nodeChar, "racialtrait", v.getPath());
		end
		-- Set Ability Score
		for k,v in pairs(DB.getChildren(nodeSource, "abilitymodifiers")) do
			local sStat = DB.getValue(nodeSource, "abilitymodifiers." .. k .. ".stat","");
			if sStat == "toany1ability" then
				local aAbilities = {};
				for _,v in ipairs(DataCommon.abilities) do
					table.insert(aAbilities, StringManager.capitalize(v));
				end
				local wSelect = Interface.openWindow("select_dialog", "");
				local sTitle = Interface.getString("char_title_selectabilityincrease");
				local sMessage = Interface.getString("char_message_selectabilityincrease");
				wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onRaceAbilitySelect, nodeChar, 1);
				bApplied = true;
			elseif StringManager.contains(DataCommon.abilities, sStat) then
				local nCurrent = DB.getValue(nodeChar, "abilitiesedit." .. sStat .. ".base", 10);
				local nAdj = (DB.getValue(nodeSource, "abilitymodifiers." .. k .. ".mod",0));
				local nMod = nCurrent + nAdj;	
				DB.setValue(nodeChar, "abilitiesedit." .. sStat .. ".base","number",nMod, 0);
				bSelect = false;
				sStat = ("[" .. DataCommon.ability_ltos[sStat] .. "] " .. nAdj);
				LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, "Racial Stat", sStat)
			end
		end
		local sThemeName = DB.getValue(nodeChar,"theme","");
		local sRaceName = DB.getValue(nodeChar,"name","");
		if sThemeName ~= "" and sRaceName ~= "" then
			local aStats = DB.getChildren(nodeChar, "abilitiesedit");
			for _,nodeStat in pairs (aStats) do			
				nScore = (DB.getValue(nodeStat, "base",0));
				--DB.setValue(nodeStat, "rts", "number", nScore);
			end			
			local wndAbilitiesEditor = Interface.openWindow("charsheet_abilitystats_editor", nodeChar);
			ChatManager.SystemMessage("Spend 10 Points on Ability Score Adjustments.");
		end
	end
	if sRaceType == "Companion" then	
	--Set info from Race record	
        DB.setValue(nodeChar, "race", "string", DB.getValue(nodeSource, "name", ""));
        DB.setValue(nodeChar, "racelink", "windowreference", sClass, nodeSource.getNodeName());
		DB.setValue(nodeChar, "data.type", "string", "companion");
        local sLevelRng = DB.getValue(nodeSource, "levelrange", "");
		local aLevelRng = StringManager.split(sLevelRng, "-");		
		local nLevel = tonumber(aLevelRng[1]);
        --Get DataCommon Info
		local aDataCommon = DataCommon.companiondatalvl[nLevel];
			
        DB.setValue(nodeChar, "data.minlevel", "number", nLevel);
        DB.setValue(nodeChar, "data.maxlevel", "number", tonumber(aLevelRng[2]));
        DB.setValue(nodeChar, "level", "number", DB.getValue(nodeChar, "data.minlevel", 0));

        local aAbilityModName = StringManager.split(DB.getValue(nodeSource, "abilitymods"), ",");
			aAbilityModName[2] = aAbilityModName[2]:gsub(" ", "");
        local sStatMod1 = aAbilityModName[1];
			sStatMod1 = DataCommon.ability_stol[sStatMod1]
        local sStatMod2 = aAbilityModName[2];
			sStatMod2 = DataCommon.ability_stol[sStatMod2]
        DB.setValue(nodeChar, "data.stat1", "string", sStatMod1);
        DB.setValue(nodeChar, "data.stat2", "string", sStatMod2);	
        DB.setValue(nodeChar, "senses", "string", DB.getValue(nodeSource, "senses",""));
        DB.setValue(nodeChar, "size", "string", DB.getValue(nodeSource, "size",""));
        DB.setValue(nodeChar, "type", "string", DB.getValue(nodeSource, "type",""));
        DB.setValue(nodeChar, "subtype", "string", DB.getValue(nodeSource, "subtype",""));DB.setValue(nodeChar, "aura", "string", DB.getValue(nodeSource, "aura",""));	
		DB.setValue(nodeChar, "defensiveabilities", "string", DB.getValue(nodeSource, "defensiveabilities",""));	
		DB.setValue(nodeChar, "weaknesses", "string", DB.getValue(nodeSource, "weaknesses",""));	
		
			
		
        DB.setValue(nodeChar, "space", "number", DB.getValue(nodeSource, "space",0));
        DB.setValue(nodeChar, "reach", "number", DB.getValue(nodeSource, "reach",0));
		DB.setValue(nodeChar, "reachnote", "string", DB.getValue(nodeSource, "reachnote",""));
		DB.setValue(nodeChar, "offensiveabilities", "string", DB.getValue(nodeSource, "offensiveabilities",""));
		DB.setValue(nodeChar, "spelllikeabilities", "string", DB.getValue(nodeSource, "spelllikeabilities",""));	
		
        DB.setValue(nodeChar, "currentcost", "number", 0);
        DB.setValue(nodeChar, "traincost", "number", 0);
        DB.setValue(nodeChar, "saves.fortitude.type", "string", DB.getValue(nodeSource, "fort",0));
        DB.setValue(nodeChar, "saves.reflex.type", "string", DB.getValue(nodeSource, "ref",0));
        DB.setValue(nodeChar, "saves.will.type", "string", DB.getValue(nodeSource, "will",0));
		DB.setValue(nodeChar, "attackbonus.melee.total", "number", 0);
		DB.setValue(nodeChar, "attackbonus.melee.misc", "number", 0);
		DB.setValue(nodeChar, "attackbonus.ranged.misc", "number", 0);
		DB.setValue(nodeChar, "attackbonus.ranged.total", "number", 0);
        local sSpeed = DB.getValue(nodeSource, "speed","");            	
        DB.setValue(nodeChar, "speed.special", "string",sSpeed);

        --Add Special Abilities	
		for _,v in pairs(DB.getChildren(nodeSource, "specialabilities")) do
			addCompanionAbility(nodeChar, "racialspecial", v.getPath());
		end

        --Add Attacks	
        --Melee       
		DB.setValue(nodeChar, "data.melee.original", "string", DB.getValue(nodeSource, "melee",""));
        --Ranged    
		DB.setValue(nodeChar, "data.ranged.original", "string", DB.getValue(nodeSource, "ranged",""));
		--Add Skills
        local sSkillSource
        sSkillSource = DB.getValue(nodeSource, "skills", "");	
        sSkillDataCommon = (DataCommon.companiondatalvl[1].skills);
        if sSkillSource ~= "" and sSkillSource ~= nil then
            sSkills = sSkillDataCommon .. "," .. sSkillSource;
        else
            sSkills = sSkillDataCommon;			
        end       
        DB.setValue(nodeChar, "data.skills", "string", sSkills);
        return onCompLevelUpdate(nodeChar, nLevel);
	end
	handleBaseStats(nodeChar)
end

function addTheme(nodeChar, sClass, sRecord)-- Added for SFRPG Russ
	local nodeSource = resolveRefNode(sRecord);
	local nLevel = DB.getValue(nodeChar, "level", 0);
	local sTheme = DB.getValue(nodeSource, "name", "");
	if not nodeSource then
		return;
	end	
	if nLevel == 0 then
		LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD,"Theme", sTheme);
	else
		LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD,"Theme Level", sTheme);
	end
	
	--Modify Ability Score
	if nLevel == 0 then
		nLevel = 1;	
		for _,v in pairs(DB.getChildren(nodeSource, "abilitymodifiers")) do
			if _ == "toany1ability" then
				local aAbilities = {};
				for _,v in ipairs(DataCommon.abilities) do
					table.insert(aAbilities, StringManager.capitalize(v));
				end
				local wSelect = Interface.openWindow("select_dialog", "");
				local sTitle = Interface.getString("char_title_selectabilityincrease");
				local sMessage = Interface.getString("char_message_selectabilityincrease");
				wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onThemeAbilitySelect, nodeChar, 1);
				bSelect = true;
			else
				local sStat = DB.getValue(nodeSource, "abilitymodifiers." .. _ .. ".stat","");
				local nCurrent = DB.getValue(nodeChar, "abilitiesedit." .. sStat .. ".base", 10);
				local nAdj = (DB.getValue(nodeSource, "abilitymodifiers." .. _ .. ".mod",0));
				local nMod = nCurrent + nAdj;	
				DB.setValue(nodeChar, "abilitiesedit." .. sStat .. ".base","number",nMod, 0);
				bSelect = false;
				sStat = ("[" .. DataCommon.ability_ltos[sStat] .. "] " .. nAdj);
				LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, "Theme Stat", sStat)
			end	
		end	
	end
	
	local nThemeLevel = DB.getValue(nodeChar,"level",0)+1;
	for _,v in pairs(DB.getChildren(nodeSource, "features")) do
		if DB.getValue(v, "level", 0) == nThemeLevel then
			addThemeFeature(nodeChar, "themefeature", v.getPath());			
		end
	end

	DB.setValue(nodeChar, "theme", "string", sTheme);
	DB.setValue(nodeChar, "themelink", "windowreference", sClass, nodeSource.getNodeName());
	DB.setValue(nodeChar, "themerecord", "string",nodeSource.getNodeName());
	local sFormat = Interface.getString("char_message_themeadd");
	local sMsg = string.format(sFormat, sTheme, DB.getValue(nodeChar, "name", ""));
	ChatManager.SystemMessage(sMsg);
	nLevel = DB.getValue(nodeChar, "level", 0);
	local sThemeName = DB.getValue(nodeChar,"theme","");
	local sRaceName = DB.getValue(nodeChar,"race","");
	if sThemeName ~= "" and sRaceName ~= "" and nLevel == 0 then
		local aStats = DB.getChildren(nodeChar, "abilitiesedit");
		for _,nodeStat in pairs (aStats) do			
			nScore = (DB.getValue(nodeStat, "base",0));
			--DB.setValue(nodeStat, "rts", "number", nScore);
		end
		local wndAbilitiesEditor = Interface.openWindow("charsheet_abilitystats_editor", nodeChar);
		ChatManager.SystemMessage("Spend 10 Points on Ability Score Adjustments.");
		handleBaseStats(nodeChar)
	end
	--
end
function handleBaseStats(nodeChar)
	local sThemeName = DB.getValue(nodeChar,"theme","");
	local sRaceName = DB.getValue(nodeChar,"race","");
	if sThemeName ~= "" and sRaceName ~= "" then
		local aStats = DB.getChildren(nodeChar, "abilitiesedit");
		for _,k in pairs (aStats) do
			DB.setValue(k, "rts", "number", (DB.getValue(k, "base",10)));
		end
	end
end
function addThemeFeature(nodeChar, sClass, sRecord, nodeTargetList)-- Added for SFRPG Russ
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return false;
	end
	
	local sThemeName = StringManager.strip(DB.getValue(nodeSource, "...name", ""));
	local sFeatureName = DB.getValue(nodeSource, "name", "");
	local sFeatureType = StringManager.strip(sFeatureName):lower();
	local sFeatureTypeWithTheme = sFeatureType .. " (" .. sThemeName:lower() .. ")";
	local bCreateFeatureEntry = true;
		
	if bCreateFeatureEntry then
		if not nodeTargetList then
			nodeTargetList = nodeChar.createChild("themeabilitylist");
			if not nodeTargetList then
				return false;
			end
		end
		local vNew = nodeTargetList.createChild();
		DB.copyNode(nodeSource, vNew);
		DB.setValue(vNew, "name", "string", sFeatureName);
		DB.setValue(vNew, "source", "string", sClassName);
		DB.setValue(vNew, "locked", "number", 1);
		LogManager.onListAdd(vNew);
	end

	local sFormat = Interface.getString("char_message_classfeatureadd");
	local sMsg = string.format(sFormat, sFeatureName, DB.getValue(nodeChar, "name", ""));
	ChatManager.SystemMessage(sMsg);
	return true;
end
function addRacialTrait(nodeChar, sClass, sRecord, nodeTargetList)
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return false;
	end
	
	local sTraitName = DB.getValue(nodeSource, "name", "");
	local sTraitType = StringManager.strip(sTraitName):gsub(" %(%a%a%)%s*$", ""):lower();
	
	if sTraitType:match(RACIAL_TRAIT_ABILITY_D20PFSRD) or sTraitType:match(RACIAL_TRAIT_ABILITY_SW) then
		if not handleRacialAbilitiesEmbedded(nodeChar, nodeSource) then
			return false;
		end
		
	elseif sTraitType:match(RACIAL_TRAIT_LANGUAGES) then
		return handleRacialLanguages(nodeChar, nodeSource);

	elseif sTraitType:match(RACIAL_TRAIT_SIZE) or 
			sTraitType:match(RACIAL_TRAIT_SIZE_MEDIUM) or 
			sTraitType:match(RACIAL_TRAIT_SIZE_SMALL) then
		if not handleRacialSize(nodeChar, nodeSource, sTraitType) then
			return false;
		end
	
	elseif sTraitType:match(RACIAL_TRAIT_SPEED_GENERIC) or 
			sTraitType:match(RACIAL_TRAIT_SPEED_D20PFSRD) or 
			sTraitType:match(RACIAL_TRAIT_SPEED_SRD_NORMAL) or 
			sTraitType:match(RACIAL_TRAIT_SPEED_SRD_SLOW) or 
			sTraitType:match(RACIAL_TRAIT_SLOW_AND_STEADY) then 
		if not handleRacialSpeed(nodeChar, nodeSource, sTraitType, nodeTargetList) then
			return false;
		end
	
	elseif sTraitType:match(RACIAL_TRAIT_DARKVISION) or 
			sTraitType:match(RACIAL_TRAIT_LOWLIGHTVISION) or 
			sTraitType:match(RACIAL_TRAIT_SUPERIORDARKVISION) or
			sTraitType:match(RACIAL_TRAIT_BLINDSENSE) or
			sTraitType:match(RACIAL_TRAIT_LIMITED_TELEPATHY) or
			sTraitType:match(RACIAL_TRAIT_TELEPATHY) then
		handleRacialVision(nodeChar, nodeSource);
		
	elseif sTraitType:match(RACIAL_TRAIT_WEAPONFAMILIARITY) then 
		if not handleRacialBasicTrait(nodeChar, nodeSource, nodeTargetList) then
			return false;
		end
		handleProficiencies (nodeChar, nodeSource);
	else
		if not checkForRacialAbilityInName(nodeChar, sTraitType) then
			if not handleRacialBasicTrait(nodeChar, nodeSource, nodeTargetList) then
				return false;
			end
			checkForRacialSkillBonus(nodeChar, nodeSource);
			checkForRacialSaveBonus(nodeChar, nodeSource);
		end
	end

	local sFormat = Interface.getString("char_message_racialtraitadd");
	local sMsg = string.format(sFormat, DB.getValue(nodeSource, "name", ""), DB.getValue(nodeChar, "name", ""));
	ChatManager.SystemMessage(sMsg);
	return true;
end
--Companions
function addCompanionAbility(nodeChar, sClass, sRecord, nodeTargetList)
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return false;
	end		
	local sFeatureName = DB.getValue(nodeSource, "name", "");	
	local sDesc = DB.getValue(nodeSource, "text");
	local bCreateFeatureEntry = true;		
	if bCreateFeatureEntry then
		if not nodeTargetList then
			nodeTargetList = nodeChar.createChild("specialabilities");
			if not nodeTargetList then
				return false;
			end
		end
		local vNew = nodeTargetList.createChild();
		DB.copyNode(nodeSource, vNew);
		DB.setValue(vNew, "name", "string", sFeatureName);
		DB.setValue(vNew, "text", "formattedtext", sDesc);
		DB.setValue(vNew, "locked", "number", 1);
	end	
	return true;
end

function onCompLevelUpdate(nodeChar, nLevel)
     --Cost
    local nTrainCost = 0;
    local nCost = DataCommon.companiondatalvl[nLevel].price;
    if nLevel == 20 or nLevel == nMax then
        nTrainCost = 0;
    else
        local nCostNext = DataCommon.companiondatalvl[nLevel + 1].price;
        nTrainCost = nCostNext - nCost;
    end
        DB.setValue(nodeChar, "currentcost", "number", nCost);
        DB.setValue(nodeChar, "traincost", "number", nTrainCost);

    --HP [hp]
    DB.setValue(nodeChar, "hp.total", "number" , DataCommon.companiondatalvl[nLevel].hp);
	DB.setValue(nodeChar, "hp.temporary", "number" , 0);
    DB.setValue(nodeChar, "hp.wounds", "number" , 0);
	
    --BAB [atkbonus]	
    DB.setValue(nodeChar, "attackbonus.base", "number", DataCommon.companiondatalvl[nLevel].atkbonus);   			
		
	 
    --AC [kac] [eac]
    DB.setValue(nodeChar, "ac.sources.kac.base", "number", DataCommon.companiondatalvl[nLevel].kac);
    DB.setValue(nodeChar, "ac.sources.eac.base", "number", DataCommon.companiondatalvl[nLevel].eac);

    --SAVES [poor] [good]
    local nPoor = (DataCommon.companiondatalvl[nLevel].poor);
    local nGood = (DataCommon.companiondatalvl[nLevel].good);
    local aSaves = DB.getChildren(nodeChar, "saves");
    for _,nodeSave in pairs (aSaves) do
        sType = DB.getValue(nodeSave, "type", "");
        if sType ~= "" then
            if sType == "Good" then
                DB.setValue(nodeSave, "base", "number", nGood);
            elseif sType == "Poor" then
                DB.setValue(nodeSave, "base", "number", nPoor);
            end
        end
    end

    --STAT MOD [abilitymod]
    local sStatNumbers = (DataCommon.companiondatalvl[nLevel].abilitymod);
    local aStatNumbers = StringManager.split(sStatNumbers, ",");
    for _,nodeAbility in pairs (DB.getChildren(nodeChar, "abilities")) do	
        local sStatNode = nodeAbility.getName();		
        local sStat1 = DB.getValue(nodeChar, "data.stat1");
        local sStat2 = DB.getValue(nodeChar, "data.stat2");
        if sStatNode == sStat1 then
            local nBase = 10 + (2 * aStatNumbers[1]);
            DB.setValue(nodeAbility,"base","number", nBase);        
        elseif sStatNode == sStat2 then
            local nBase = 10 + (2 * aStatNumbers[2]);
            DB.setValue(nodeAbility,"base","number", nBase);        
		elseif sStatNode == "intelligence" then            
            DB.setValue(nodeAbility,"base","number", 3);
		else
			DB.setValue(nodeAbility,"base","number", 10);
        end
    end
				
    --SKILL BONUS [skillpoints] "+#"
	-- Acrobatics, Athletics, Perception, Stealth, Survival
	local aSkillsNew = {};
	local sSkills = DB.getValue(nodeChar, "data.skills", "");
	local sSkillBonus = (DataCommon.companiondatalvl[nLevel].skillpoints);	
	local aSkills = StringManager.split(sSkills, ",");
	
	for _,sSkill in pairs (aSkills) do		
			sSkill = (sSkill .. " " .. sSkillBonus);
		table.insert(aSkillsNew, sSkill);		
	end
	sSkillsNew = (table.concat(aSkillsNew, ", "))	
	DB.setValue(nodeChar, "skills", "string", sSkillsNew);	
	DB.setValue(nodeChar, "level", "number", nLevel);
	
	rest(nodeChar);
	local nLevel = DB.getChild(nodeChar, "level").getValue();
	local nodeCompOwner = DB.getChild(nodeChar,"ownerlink");
	if nodeCompOwner then
		local sClass, sRecord = DB.getValue(nodeCompOwner,"","");
		local nodeOwner = DB.findNode(sRecord);
		local sName = DB.getChild(nodeChar, "name").getValue();
		local sMessage = sName .. " (LVL: ".. tostring(nLevel) .. ")";
		LogManager.LogMessage(nodeOwner,LogManager.LOG_ACTION_ADJUST, "Companion Level", sMessage);	
	end
	--DB.setValue(nodeChar, "rp.total", "number", 0);
	--DB.setValue(nodeChar, "rp.current", "number", 0);
	handleMeleeAttacks(nodeChar,nLevel);
end

function onCompLevelCheck(nodeChar,nLevel)
	local nMin = DB.getValue(nodeChar, "data.minlevel", 1);
	local nMax = DB.getValue(nodeChar, "data.maxlevel", nMin);
	local result = false;
		
		if nLevel < nMin then
			nLevelNew = nMin;			
			ChatManager.SystemMessage(Interface.getString("char_error_minlevel").." ["..nMin..")]");
		elseif nLevel > nMax then
			nLevelNew = nMax; 
			ChatManager.SystemMessage(Interface.getString("char_error_maxlevel").." ["..nMax..")]");
		else
			nLevelNew = nLevel;
			result = true;
		end		
		return result, nLevelNew;
end

function handleMeleeAttacks(nodeChar,nLevel)
	local sDamage = DataCommon.companiondatalvl[nLevel].damage;	
		--Dice
    local aWordDice, nWordMod = StringManager.convertStringToDice(sDamage);
    local sWordDice = StringManager.convertDiceToString(aWordDice);	
	--Attack
	local nAtkBonusMod = DB.getValue(nodeChar, "attackbonus.base", 0);
	local nMeleeMisc = DB.getValue(nodeChar, "attackbonus.melee.misc", 0);
	local sAttackTotal = tostring(nAtkBonusMod + nMeleeMisc);	
	--Damage
    local sDamage = DataCommon.companiondatalvl[nLevel].damage;		
	local nStrMod = DB.getValue(nodeChar, "abilities.strength.bonus", 0);
	local nDamageMod = nWordMod + nStrMod;
	
	--Modify Attack Sting
	local sAttacks = DB.getValue(nodeChar, "data.melee.original", "");
	local aAttacks = {};
	local sAtkName = "";	
		i=1;
		sAttacks = string.gsub(sAttacks, " or ", "|");
		aAttacks = StringManager.split(sAttacks, "|");
		for i,sAttack in pairs (aAttacks) do			
				aAttack = StringManager.split(sAttack, "(");				
				sNewAttack = (aAttack[1] .. "+" ..  sAttackTotal .. " (" .. sWordDice .. " " .. "+" .. tostring(nDamageMod) .. " " .. aAttack[2]);
			aAttacks[i] = sNewAttack;			
		end
		sNewAttacksString = table.concat(aAttacks, " or ");
		DB.setValue(nodeChar, "melee", "string", sNewAttacksString);
		
		handleRangedAttacks(nodeChar,nLevel)		
end
function handleRangedAttacks(nodeChar,nLevel)
	local sDamage = DataCommon.companiondatalvl[nLevel].damage;	
	--Dice
    local aWordDice, nWordMod = StringManager.convertStringToDice(sDamage);
    local sWordDice = StringManager.convertDiceToString(aWordDice);	
	--Attack
	local nAtkBonusMod = DB.getValue(nodeChar, "attackbonus.base", 0);
	local nRangedMisc = DB.getValue(nodeChar, "attackbonus.ranged.misc", 0);
	local sAttackTotal = tostring(nAtkBonusMod + nRangedMisc);	
	--Damage [damage]
    
	local nDamageMod = nWordMod;
	--Modify Attack Sting
	local sAttacks = DB.getValue(nodeChar, "data.ranged.original", "");
	local aAttacks = {};
	local sAtkName = "";
		i=1;
		sAttacks = string.gsub(sAttacks, " or ", "|");
		aAttacks = StringManager.split(sAttacks, "|");
		for i,sAttack in pairs (aAttacks) do			
				aAttack = StringManager.split(sAttack, "(");				
				sNewAttack = (aAttack[1] .. "+" ..  sAttackTotal .. " (" .. sWordDice .. " " .. "+" .. tostring(nDamageMod) .. " " .. aAttack[2]);
			aAttacks[i] = sNewAttack;			
		end
		sNewAttacksString = table.concat(aAttacks, " or ");
		DB.setValue(nodeChar, "ranged", "string", sNewAttacksString);	
end

function setCompanionOwner(nodeComp, sClass, nodeChar )
    if not nodeComp or not nodeChar then
        return;
    end
    DB.setValue(nodeComp, "owner", "string", DB.getChild(nodeChar, "name").getValue());
	DB.setValue(nodeComp, "initiative.total", "number", DB.getChild(nodeChar, "initiative.total").getValue());
    DB.setValue(nodeComp, "ownerlink", "windowreference", "charsheet", nodeChar.getNodeName());
    DB.setValue(nodeChar, "companion", "string", DB.getChild(nodeComp, "name").getValue());
	DB.setValue(nodeChar, "companionlink", "windowreference", "companionsheet", nodeComp.getNodeName());
	DB.setOwner(nodeComp, DB.getOwner(nodeChar));
	local nLevel = DB.getChild(nodeComp, "level").getValue();
	local sName = DB.getChild(nodeComp, "name").getValue();
	local sMessage = sName .. " (LVL: ".. tostring(nLevel) .. ")";
	LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Companion", sMessage);
end

function removeCompanionOwner(nodeChar)	
	local nodeOwnedComp = DB.getChild(nodeChar,"companionlink");
	local sClass, sRecord = DB.getValue(nodeOwnedComp,"","");
	local nodeComp = DB.findNode(sRecord);
    
	local sOwner = DB.getChild(nodeComp, "owner");
	if sOwner ~= nil then
		DB.setValue(nodeComp, "ownerlink", "windowreference", "", "");
		--DB.getChild(nodeComp, "owner").delete();
		DB.setValue(nodeComp, "owner", "string", "");
		DB.setValue(nodeComp, "initiative.total", "number", 0);
	end
	
	local sCompanion = DB.getChild(nodeChar, "companion");	
	if sCompanion ~= nil then
		nodeChar.setValue("companionlink", "", "");
		DB.setValue(nodeChar, "companionlink", "windowreference", "", "");
		--DB.getChild(nodeChar, "companion").delete();
		DB.setValue(nodeChar, "companion", "string", "");
		LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_REMOVE, "Companion", DB.getChild(nodeComp, "name").getValue());		
	end
end

--End Companions
function handleRacialBasicTrait(nodeChar, nodeTrait, nodeTargetList)
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("traitlist");
		if not nodeTargetList then
			return false;
		end
	end
	local nodeEntry = nodeTargetList.createChild();
	DB.copyNode(nodeTrait, nodeEntry);
	DB.setValue(nodeEntry, "source", "string", DB.getValue(nodeTrait, "...name", ""));
	DB.setValue(nodeEntry, "locked", "number", 1);
	LogManager.onListAdd(nodeEntry);
	return true;
end

function handleRacialAbilitiesEmbedded(nodeChar, nodeTrait)
	local sText = DB.getText(nodeTrait, "text");
	return handleRacialAbilities(nodeChar, sText);
end

function handleRacialAbilities(nodeChar, sText)
	local aWords = StringManager.parseWords(sText:lower());
	
	local aIncreases = {};
	local bChoice = false;
	local i = 1;
	while aWords[i] do
		if StringManager.isNumberString(aWords[i]) then
			local nMod = tonumber(aWords[i]) or 0;
			if nMod ~= 0 then
				if StringManager.contains(DataCommon.abilities, aWords[i+1]) then
					aIncreases[aWords[i+1]] = nMod;
				elseif StringManager.contains(DataCommon.abilities, aWords[i-1]) then
					aIncreases[aWords[i-1]] = nMod;
				else
					local j = i + 1;
					if StringManager.isWord(aWords[j], "bonus") then
						j = j + 1;
					end
					if StringManager.isPhrase(aWords, j, { "to", "one", "ability", "score" }) then
						bChoice = true;
					end
				end
			end
		end
		i = i + 1;
	end
	
	local bApplied = false;
	for k,v in pairs(aIncreases) do
		if StringManager.contains(DataCommon.abilities, k) then
			local sPath = "abilities." .. k .. ".score";
			DB.setValue(nodeChar, sPath, "number", DB.getValue(nodeChar, sPath, 10) + v);
			bApplied = true;
		end
	end
	
	if bChoice then
		local aAbilities = {};
		for _,v in ipairs(DataCommon.abilities) do
			table.insert(aAbilities, StringManager.capitalize(v));
		end
		local wSelect = Interface.openWindow("select_dialog", "");
		local sTitle = Interface.getString("char_title_selectabilityincrease");
		local sMessage = Interface.getString("char_message_selectabilityincrease");
		wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onRaceAbilitySelect, nodeChar, 1);
		bApplied = true;
	end
	
	return bApplied;
end

function handleRacialLanguages(nodeChar, nodeTrait)
	local sText = DB.getText(nodeTrait, "text");
	local aWords = StringManager.parseWords(sText);
	
	local aLanguages = {};
	local i = 1;
	while aWords[i] do
		if StringManager.isPhrase(aWords, i, { "begin", "play", "speaking" }) then
			local j = i + 3;
			while aWords[j] do
				if GameSystem.languages[aWords[j]] then
					table.insert(aLanguages, aWords[j]);
				elseif not StringManager.isWord(aWords[j], "and") then
					break;
				end
				j = j + 1;
			end
			break;
		end
		i = i + 1;
	end

	if #aLanguages == 0 then
		return false;
	end
	
	for _,v in ipairs(aLanguages) do
		addLanguage(nodeChar, v);
	end
	return true;
end

function handleRacialSize(nodeChar, nodeTrait, sTraitType)
	local sSize = "";
	if sTraitType:match(RACIAL_TRAIT_SIZE) then
		local sText = DB.getText(nodeTrait, "text"):lower();
		local aWords = StringManager.parseWords(sText);
		
		local i = 1;
		while aWords[i] do
			if StringManager.isPhrase(aWords, i, { "are", { "small", "medium" }, "creatures" }) then
				sSize = aWords[i+1];
				break;
			end
			i = i + 1;
		end
	elseif sTraitType:match(RACIAL_TRAIT_SIZE_MEDIUM) then
		sSize = "medium";
	elseif sTraitType:match(RACIAL_TRAIT_SIZE_SMALL) then
		sSize = "small";
	end
	
	if sSize == "" then
		return false;
	end
	
	DB.setValue(nodeChar, "size", "string", StringManager.capitalize(sTraitType));
	if sSize == "small" then
		DB.setValue(nodeChar, "ac.sources.size", "number", 1);
		DB.setValue(nodeChar, "attackbonus.melee.size", "number", 1);
		DB.setValue(nodeChar, "attackbonus.ranged.size", "number", 1);
		DB.setValue(nodeChar, "attackbonus.grapple.size", "number", -1);
	elseif sSize == "medium" then
		DB.setValue(nodeChar, "ac.sources.size", "number", 0);
		DB.setValue(nodeChar, "attackbonus.melee.size", "number", 0);
		DB.setValue(nodeChar, "attackbonus.ranged.size", "number", 0);
		DB.setValue(nodeChar, "attackbonus.grapple.size", "number", 0);
	end
	return true;
end

function handleRacialSpeed(nodeChar, nodeTrait, sTraitType, nodeTargetList)
	local nBaseSpeed = 0;
	if sTraitType:match(RACIAL_TRAIT_SPEED_SRD_NORMAL) then
		nBaseSpeed = 30;
	elseif sTraitType:match(RACIAL_TRAIT_SPEED_SRD_SLOW) or sTraitType:match(RACIAL_TRAIT_SLOW_AND_STEADY) then
		nBaseSpeed = 20;
	else
		local sSpeed = DB.getText(nodeTrait, "text");
		local sBaseSpeed = sSpeed:match("base speed of (%d+) feet");
		if sBaseSpeed then
			nBaseSpeed = tonumber(sBaseSpeed) or 0;
		end
	end
	
	if nBaseSpeed ~= 0 then
		DB.setValue(nodeChar, "speed.base", "number", nBaseSpeed);
	else
		return false;
	end
	
	if sTraitType:match(RACIAL_TRAIT_SLOW_AND_STEADY) then
		if not handleRacialBasicTrait(nodeChar, nodeTrait, nodeTargetList) then
			return false;
		end
	end
	return true;
end

function handleRacialVision(nodeChar, nodeTrait)
	local sSenses = DB.getValue(nodeChar, "senses", "");
	if sSenses ~= "" then
		sSenses = sSenses .. ", ";
	end
	sSenses = sSenses .. DB.getValue(nodeTrait, "name", "");	
	local sText = DB.getText(nodeTrait, "text");	
	if sText then
		local sDist = sText:match("%d+");
		if sDist then
			sSenses = sSenses .. " " .. sDist;
		end
	end
	
	DB.setValue(nodeChar, "senses", "string", sSenses);
end

function onRaceAbilitySelect(aSelection, nodeChar)
	for _,sAbility in ipairs(aSelection) do
		local k = sAbility:lower();
		if StringManager.contains(DataCommon.abilities, k) then
			local sPath = "abilitiesedit." .. k .. ".base";
			DB.setValue(nodeChar, sPath, "number", DB.getValue(nodeChar, sPath, 10) + 2);
			local nAdj = 2;
			sStat = ("[" .. DataCommon.ability_ltos[k] .. "] " .. nAdj);
            LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, "Stat", sStat)
			sPath = "abilitiesedit." .. k .. ".rts";
			DB.setValue(nodeChar, sPath, "number", DB.getValue(nodeChar, sPath, 10) + 2);
		end
	end
end
function onKeyAbilitySelect(aSelection, nodeChar)
	local aClasses = DB.getChildren(nodeChar, "classes");
	for _,sClass in pairs(aClasses) do
		local sName = DB.getValue(sClass, "name",""):lower(); 
		if sName == "soldier" then
		local nodeClass = sClass;
			for _,sAbility in ipairs(aSelection) do
				local sKeyAbility = sAbility:lower();
				local nMod= DB.getValue(nodeChar, "abilities." .. sKeyAbility .. ".bonus",0);			
					DB.setValue(nodeChar, "abilities.keyability", "string", sKeyAbility);
					DB.setValue(nodeClass, "classkey", "string", sAbility);
					DB.setValue(nodeClass, "classkeymod", "number", nMod);
					DB.setValue(nodeChar,"abilities.keyabilitymod", "number", nMod);
					DB.setValue(nodeChar,"abilities.key","number",1);			
			end
		end		 
	end 
	CharManager.resetHealth(nodeChar);	
end
function onKeyAbilityUpdate(aSelection, nodeClass)
	for _,sAbility in ipairs(aSelection) do
	local sKeyAbility = sAbility;				
		DB.setValue(nodeClass, "classkey", "string", sKeyAbility);								
	end
end
function onHandleMissingKeyAbility(nodeClass)
	local sClassKey = DB.getValue(nodeClass, "classkey","");
	if  sClassKey == "" or sClassKey == nil then
		local sName = DB.getValue(nodeClass, "name",""):lower();
		if sName == "soldier" then
			local aAbilities = {};
			for _,v in ipairs(DataCommon.abilities) do
				if v == "strength" or v == "dexterity" then
					table.insert(aAbilities, StringManager.capitalize(v));
				end
			end
		local wSelect = Interface.openWindow("select_dialog", "");			
		local sTitle = "Key Ability";			
		local sMessage = "What was your Soldier's Key Ability";					
		wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onKeyAbilityUpdate, nodeClass, 1);
		bApplied = true;		
		end
	else
	end	
end
function onThemeAbilitySelect(aSelection, nodeChar)
	for _,sAbility in ipairs(aSelection) do
		local k = sAbility:lower();
		if StringManager.contains(DataCommon.abilities, k) then
			local sPath = "abilitiesedit." .. k .. ".base";
			DB.setValue(nodeChar, sPath, "number", DB.getValue(nodeChar, sPath, 10) + 1);
			local nAdj = 1;
			sStat = ("[" .. DataCommon.ability_ltos[k] .. "] " .. nAdj);
			LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, "Stat", sStat)
		end
	end	
	local wndAbilitiesEditor = Interface.openWindow("charsheet_abilitystats_editor", nodeChar);
	ChatManager.SystemMessage("Spend 10 Points on Ability Score Adjustments.");
end
function checkForRacialAbilityInName(nodeChar, sTraitType)
	local bHandled = false;
	local aWords = StringManager.parseWords(sTraitType);
	if #aWords > 0 then
		local bRaceAttInName = true;
		local i = 1;
		while aWords[i] do
			if not StringManager.isNumberString(aWords[i]) and not StringManager.contains(DataCommon.abilities, aWords[i]) then
				bRaceAttInName = false;
				break;
			end
			i = i + 1;
		end
		if bRaceAttInName then
			bHandled = handleRacialAbilities(nodeChar, sTraitType);
		end
	end
	return bHandled;
end

function checkForRacialSkillBonus(nodeChar, nodeTrait)
	local sText = DB.getText(nodeTrait, "text", "");
	sText = sText:gsub(" due to their fearsome nature%.", "."); -- Half-orc Intimidating
	for sMod, sSkills in sText:gmatch("%+(%d) racial bonus on ([^.]+) checks[.;,]") do
		local nMod = tonumber(sMod) or 0;
		if sSkills and nMod ~= 0 then
			local aSkills = {};
			sSkills = sSkills:gsub(",? and ", ",");
			aSkills = StringManager.split(sSkills, ",", true);
			for _,vSkill in ipairs(aSkills) do
				vSkill = vSkill:gsub(" checks$", "");
				vSkill = vSkill:gsub(" skill$", "");
				local sSpecialty = vSkill:match("%(%w+%)");
				if sSpecialty then
					vSkill = StringManager.trim(vSkill:match("[^(]*"));
				end
				addSkillBonus(nodeChar, vSkill, nMod, sSpecialty);
			end
		end
	end
end

function checkForRacialSaveBonus(nodeChar, nodeTrait)
	local sText = DB.getText(nodeTrait, "text", "");
	local sMod = sText:match("%+(%d) racial bonus on all saving throws%.");
	local nMod = tonumber(sMod) or 0;
	if nMod ~= 0 then
		addSaveBonus(nodeChar, "fortitude", "misc", nMod);
		addSaveBonus(nodeChar, "reflex", "misc", nMod);
		addSaveBonus(nodeChar, "will", "misc", nMod);
	end
end

function addLanguage(nodeChar, sLanguage)
	local nodeList = nodeChar.createChild("languagelist");
	if not nodeList then
		return false;
	end
	
	if sLanguage ~= "Choice" then
		for _,v in pairs(nodeList.getChildren()) do
			if DB.getValue(v, "name", "") == sLanguage then
				return false;
			end
		end
	end

	local vNew = nodeList.createChild();
	DB.setValue(vNew, "name", "string", sLanguage);
	LogManager.onListAdd(vNew);
	local sFormat = Interface.getString("char_message_languageadd");
	local sMsg = string.format(sFormat, DB.getValue(vNew, "name", ""), DB.getValue(nodeChar, "name", ""));
	ChatManager.SystemMessage(sMsg);
	return true;
end

function addSkillBonus(nodeChar, sSkill, nBonus, sSpecialty)
	local nodeSkill = getSkillNode(nodeChar, sSkill, sSpecialty);
	if nodeSkill then
		DB.setValue(nodeSkill, "misc", "number", DB.getValue(nodeSkill, "misc", 0) + nBonus);
		
		if sSpecialty then
			sSkill = sSkill .. " (" .. sSpecialty .. ")";
		end
		local sFormat = Interface.getString("char_message_skillbonusadd");
		local sMsg = string.format(sFormat, nBonus, sSkill, DB.getValue(nodeChar, "name", ""));
		ChatManager.SystemMessage(sMsg);
		LogManager.LogMessage(nodeChar, LogManager.LOG_ACTION_ADD, sSkill, nBonus);
	end
end

function addSaveBonus(nodeChar, sSave, sBonusType, nBonus)
	if not DataCommon.save_ltos[sSave] or nBonus <= 0 or not StringManager.contains({ "base", "misc" }, sBonusType) then
		return;
	end
	
	DB.setValue(nodeChar, "saves." .. sSave .. "." .. sBonusType, "number", DB.getValue(nodeChar, "saves." .. sSave .. "." .. sBonusType, 0) + nBonus);
	
	local sFormat = Interface.getString("char_message_savebonusadd");
	local sMsg = string.format(sFormat, nBonus, StringManager.capitalize(sSave), DB.getValue(nodeChar, "name", ""));
	ChatManager.SystemMessage(sMsg);
	LogManager.LogMessage(nodeChar, LogManager.LOG_ACTION_ADD, StringManager.capitalize(sSave), nBonus);
end

function addClass(nodeChar, sClass, sRecord)
	local nodeSource = resolveRefNode(sRecord);	
	if not nodeSource then
		return;
	end
	local aStats = DB.getChildren(nodeChar, "abilitiesedit");
	for k,nodeStat in pairs (aStats) do
			local nBase = (DB.getValue(nodeStat, "base",0));
			nRTS = (DB.getValue(nodeStat, "rts",0));
			local nAdj = nBase - nRTS;
			if nRTS > 0 then
				sStat = ("[" .. DataCommon.ability_ltos[k] .. "] " .. nAdj);
				LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, "Stat [10 Points]", sStat)
				DB.setValue(nodeStat,"rts", "number", 0);
			end
	end
	-- Check that Theme and Race have been added first.
	local sThemeName = DB.getValue(nodeChar,"theme","");
	local sRaceName = DB.getValue(nodeChar,"race","");	
	if sThemeName == "" and ((sRaceName == "Combat Drone") or (sRaceName == "Hover Drone") or (sRaceName == "Stealth Drone")) then	
	elseif sThemeName == "" or sRaceName == "" then 	
		ChatManager.SystemMessage("Select Race and Theme Before Selecting Class.");
		ChatManager.SystemMessage("(Drones only need Race.)");
		return;			
	end
	-- Setup
	local nodeList = nodeChar.createChild("classes");
	if not nodeList then
		return;
	end
	--Get Class Key Ability
	local sClassName = DB.getValue(nodeSource, "name", "");		
	local sBab = DB.getValue(nodeSource, "bab", "");
	local sFort = DB.getValue(nodeSource, "fort", "");
	local sRef = DB.getValue(nodeSource, "ref", "");
	local sWill = DB.getValue(nodeSource, "will", "");
	local nStamina = DB.getValue(nodeSource, "sp", "");
	local sHP = DB.getValue(nodeSource, "hp", "");
	local sFormat = Interface.getString("char_message_classadd");
	local sMsg = string.format(sFormat, sClassName, DB.getValue(nodeChar, "name", ""));
	DB.setValue(nodeChar, "abilities.adjusted","string", "");
	ChatManager.SystemMessage(sMsg);
	
	-- Try and match an existing class entry, or create a new one
	local sRecordSansModule = StringManager.split(sRecord, "@")[1];
	local nodeClass = nil;
	for _,v in pairs(nodeList.getChildren()) do
		local _,sExistingClassPath = DB.getValue(v, "shortcut", "", "");
		if sExistingClassPath == "" then
			local sExistingClassName = StringManager.trim(DB.getValue(v, "name", "")):lower();
			if sExistingClassName ~= "" and (sExistingClassName == sClassNameLower) then
				nodeClass = v;
				break;
			end
		else
			local sExistingClassPathSansModule = StringManager.split(sExistingClassPath, "@")[1];
			if sExistingClassPathSansModule == sRecordSansModule then
				nodeClass = v;
				break;
			end
		end
	end
	
	local nLevel = 1;
	local bExistingClass = false;	
	if nodeClass then
		local bApplied = true		
			bExistingClass = true;
			nLevel = DB.getValue(nodeClass, "level", 1) + 1;
			local nCharLevel = DB.getValue(nodeChar, "level", 0) +1;
			local sClassName = DB.getValue(nodeSource, "name", "");
			local i = 0;
			if sClassName == "Drone (Combat)" or sClassName == "Drone (Hover)" or sClassName == "Drone (Stealth)" then
				if nLevel == 4 or nLevel == 7 or nLevel == 10 or nLevel == 13 or nLevel == 16 or nLevel == 19 then
					local aAbilities = {};
					for _,v in ipairs(DataCommon.abilities) do
						if v == "constitution" then
						else
						table.insert(aAbilities, StringManager.capitalize(v));
						end
					end
					local wSelect = Interface.openWindow("select_dialog", "");
					local sTitle = Interface.getString("char_title_selectabilityincrease");
					local sMessage = Interface.getString("char_message_selectlevelabilityincreasedrone");
					wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onAbilityIncreaseSelectDrone, nodeChar, 2);
					bApplied = true;				
				end
			elseif nCharLevel == 5 or nCharLevel == 10 or nCharLevel == 15 or nCharLevel == 20 then					
					local aAbilities = {};				
					for _,v in ipairs(DataCommon.abilities) do					
						table.insert(aAbilities, StringManager.capitalize(v));
					end

					local wSelect = Interface.openWindow("select_dialog", "");
					local sTitle = Interface.getString("char_title_selectabilityincrease");
					local sMessage = Interface.getString("char_message_selectlevelabilityincrease");
				
					wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onAbilityIncreaseSelect, nodeChar, 4);
					i = 1;
					bApplied = true;
			end	
			

			-- Adds Theme Features when Class is Leveled
			local sClass = "theme";			
			local sThemeRecord = DB.getValue(nodeChar,"themerecord","");				
				addTheme(nodeChar,sClass,sThemeRecord);			
	else
		nodeClass = nodeList.createChild();
		local nCharLevel = DB.getValue(nodeChar, "level", 0) +1;
		if nCharLevel == 5 or nCharLevel == 10 or nCharLevel == 15 or nCharLevel == 20 then			
			local aAbilities = {};
			for _,v in ipairs(DataCommon.abilities) do
				table.insert(aAbilities, StringManager.capitalize(v));
			end
			local wSelect = Interface.openWindow("select_dialog", "");
			local sTitle = Interface.getString("char_title_selectabilityincrease");
			local sMessage = Interface.getString("char_message_selectlevelabilityincrease");
			wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onAbilityIncreaseSelect, nodeChar, 4);
			
		end			
	end

	if not bExistingClass then
		DB.setValue(nodeClass, "name", "string", sClassName);
	end
	DB.setValue(nodeClass, "level", "number", nLevel);
--	DB.setValue(nodeClass, "classkey", "string", sKeyAbility);
	DB.setValue(nodeClass, "classstamina", "number", nStamina);
	DB.setValue(nodeClass, "shortcut", "windowreference", sClass, sRecord);
	
	
	local nTotalLevel = 0;
	for _,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		nTotalLevel = nTotalLevel + DB.getValue(vClass, "level", 0);		
	end
	if hasFeat(nodeChar, FEAT_TOUGHNESS) then
		applyToughness(nodeChar, false);
	end
	LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Class", sClassName);
	applyClassStats(nodeChar, nodeClass, nodeSource, nLevel, nTotalLevel);		
	
	-- LEVEL 1 PATH CHOICE and Soldier Level 9 Secondary Fighting Style
	-- Need to fix Issue at line 2077 and Add in a way to skip the Selection process if Specialabilities is empty.
	local sClassName = DB.getValue(nodeSource, "name", "None"):lower();
	CURRENT_LEVEL = nLevel;
	if nLevel == 1 then
		local aPathChoice = {};
		for _,v in pairs(DB.getChildren(nodeSource, "specialfeatures")) do
			if DB.getValue(v, "level", 0) == nLevel then
				if nLevel == 1 then
					table.insert(aPathChoice, DB.getValue(v, "name", ""));
					CURRENT_NODECHAR = nodeChar;
				end
			end
		end
		-- Added conditional check to ensure we don't open the path choice selection window if special features does not exist.
		if #aPathChoice > 0 then
			local wSelect = Interface.openWindow("select_dialog", "");
			local sTitle = Interface.getString("char_title_selectfeaturepath");
			local sMessage = Interface.getString("char_message_selectfeaturepath");
			wSelect.requestSelection(sTitle, sMessage, aPathChoice, CharManager.onFeaturePathSelect, nodeSource, 1);
			bApplied = true;
		end
    -- ADDED This is to go thru the PathChoice Select a second time for the Soldier. He gets to pick a second one at level 9. It pops up with the Selection and Adds it to Abilities but the new one is set to Level 1 instead of 9		
	elseif ((nLevel == 9) and (sClassName == "soldier")) then
		for _,v in pairs(DB.getChildren(nodeSource, "specialfeatures")) do
			if DB.getValue(v, "level", 0) == nLevel and hasClassFeature(DB.getValue(v, "name", ""), nodeChar) then
				addClassFeature(nodeChar, "classfeature", v.getPath());				
			end
		end	
		
		local aPathChoice = {};		
		for _,v in pairs(DB.getChildren(nodeSource, "specialfeatures")) do
			if DB.getValue(v, "level", 0) == nLevel then
				if nLevel == 9 then
					table.insert(aPathChoice, DB.getValue(v, "name", ""));
					CURRENT_NODECHAR = nodeChar;
				end
			end
		end
		if #aPathChoice > 0 then
			local wSelect = Interface.openWindow("select_dialog", "");
			local sTitle = Interface.getString("char_title_selectfeaturepath");
			local sMessage = Interface.getString("char_message_selectfeaturepath");
			wSelect.requestSelection(sTitle, sMessage, aPathChoice, CharManager.onFeaturePathSelect, nodeSource, 1);		
			bApplied = true;	
		end		
	else
		for _,v in pairs(DB.getChildren(nodeSource, "specialfeatures")) do
			if DB.getValue(v, "level", 0) == nLevel and hasClassFeature(DB.getValue(v, "name", ""), nodeChar) then
				addClassFeature(nodeChar, "classfeature", v.getPath());				
			end
		end				
	end
	for _,v in pairs(DB.getChildren(nodeSource, "features")) do
		if DB.getValue(v, "level", 0) == nLevel then
			addClassFeature(nodeChar, "classfeature", v.getPath());				
		end
	end	
	addClassSpellLevel(nodeChar, sClassName);	
	updateSkillPoints(nodeChar);		
end

function hasClassFeature(sFeatureName, nodeChar) 
	local bFound = false;
	for k,v in pairs(DB.getChildren(nodeChar, "specialabilitylist")) do
		if DB.getValue(v, "name", ""):lower() == sFeatureName:lower() then
			bFound = true;
		end
	end
	return bFound;
end

function onFeaturePathSelect(aSelection, nodeSource) 
	
	if CURRENT_NODECHAR == nil then return; end
	for _,sAbility in ipairs(aSelection) do
		local sFeatureName = sAbility:lower();
		for k,v in pairs(DB.getChildren(nodeSource, "specialfeatures")) do
			local sName = DB.getValue(v, "name", "");
			local nLevel = DB.getValue(v, "level", 0);	
			if sName:lower() == sFeatureName and nLevel == CURRENT_LEVEL then
				addClassFeature(CURRENT_NODECHAR, "classfeature", v.getNodeName());
			end
		end	
	end
	
	
end


function applyClassStats(nodeChar, nodeClass, nodeSource, nLevel, nTotalLevel)

	local sClassLookup = StringManager.strip(DB.getValue(nodeClass, "name", ""):lower());
	local sRaceLookup = StringManager.strip(DB.getValue(nodeChar, "race", ""):lower());
	local sThemeLookup = StringManager.strip(DB.getValue(nodeChar, "theme", ""):lower());
	local sClassType = DB.getValue(nodeSource, "classtype");
	local sHD = StringManager.trim(DB.getValue(nodeSource, "hitdie", ""));
	local sBAB = StringManager.trim(DB.getValue(nodeSource, "bab", "")):lower();
	local sFort = StringManager.trim(DB.getValue(nodeSource, "fort", "")):lower();
	local sRef = StringManager.trim(DB.getValue(nodeSource, "ref", "")):lower();
	local sWill = StringManager.trim(DB.getValue(nodeSource, "will", "")):lower();
	local nSkillPoints = DB.getValue(nodeSource, "skillranks", 0);
	local sClassSkills = DB.getValue(nodeSource, "classskills", "");	
	local nClassStamina = DB.getValue(nodeSource, "sp", 0);
	local nClassHP = DB.getValue(nodeSource, "hp", 0);
	local nRaceHP = DB.getValue(nodeChar, "hp.racehp", 0);	
	local sSourceClassKeyAbility = getClassKeyAbility(nodeSource,nodeChar,nodeClass);		
	local sCharKeyAbility = DB.getValue(nodeChar, "abilities.keyability", "");
	local sClassKeyAbility = DB.getValue(nodeClass, "classkey", ""):lower();
	
	if sClassLookup == "drone (combat)" or sClassLookup == "drone (hover)" or sClassLookup == "drone (stealth)" then
		nEac = (DB.getValue(nodeSource, "starteac", 0) - 10);
		if nLevel > 0 and nLevel < 11 then
			nEac = (nEac + (nLevel - 1));
			DB.setValue(nodeChar, "ac.sources.eac.naturalarmor","number", nEac);
		elseif nLevel > 11 then
			nEac = (nEac + (nLevel - 2));
			DB.setValue(nodeChar, "ac.sources.eac.naturalarmor","number", nEac);
		end	 
		nKac = (DB.getValue(nodeSource, "startkac", 0) - 10);
		if nLevel > 0 and nLevel < 11 then
			nKac = (nKac + (nLevel - 1));
			DB.setValue(nodeChar, "ac.sources.kac.naturalarmor","number", nKac);
		elseif nLevel > 11 then
			nKac = (nKac + (nLevel - 2));
			DB.setValue(nodeChar, "ac.sources.kac.naturalarmor","number", nKac);
		end
	end
	
	if DataCommon.classdata[sClassLookup] then
		if not sClassType then
			bPrestige = DataCommon.classdata[sClassLookup].bPrestige;
		end
		if not sHD:match("^%d?d%d+") then
			sHD = DataCommon.classdata[sClassLookup].hd;
		end
		if not StringManager.contains({ "fast", "medium", "slow" }, sBAB) then
			sBAB = DataCommon.classdata[sClassLookup].bab;	
		end
		if not StringManager.contains({ "good", "bad", "dgood", "dbad" }, sFort) then
			sFort = DataCommon.classdata[sClassLookup].fort;
		end
		if not StringManager.contains({ "good", "bad", "dgood", "dbad" }, sRef) then
			sRef = DataCommon.classdata[sClassLookup].ref;
		end
		if not StringManager.contains({ "good", "bad", "dgood", "dbad" }, sWill) then
			sWill = DataCommon.classdata[sClassLookup].will;
		end
		if nSkillPoints <= 0 then
			nSkillPoints = DataCommon.classdata[sClassLookup].skillranks;			
		end
		if sClassSkills == "" then
			sClassSkills = DataCommon.classdata[sClassLookup].skills;
		end
		if nClassStamina <= 0 then				
			nClassStamina = DataCommon.classdata[sClassLookup].classstamina;
			DB.setValue(nodeClass, "classstamina", "number", nClassStamina);			
		end
		
	end	
		
	if sClassKeyAbility == "" and sClassLookup ~= "soldier" then		
		setKeyAbility(nodeChar,nodeClass,sSourceClassKeyAbility);
		CharManager.resetHealth(nodeChar);
	end
	if sClassKeyAbility == "" and sClassLookup == "soldier" then		
		sSourceClassKeyAbility = getAbilitySelect(nodeChar);
		setKeyAbility(nodeChar,nodeClass,sSourceClassKeyAbility);
		CharManager.resetHealth(nodeChar);
	end
	for _,v in pairs (DB.getChildren(nodeChar, "classes")) do
		local sHasKeyAbility = DB.getValue(v, "classkey", ""):lower();
		local nMod= DB.getValue(nodeChar, "abilities." .. sHasKeyAbility .. ".bonus",0);
			DB.setValue(v, "classkeymod", "number", nMod);
	end
		if nClassHP <= 0 then
			nClassHP = DataCommon.classdata[sClassLookup].classhp;
			DB.setValue(nodeChar, "hp.classhp", "number", nClassHP);
		end
		
		-- Hit points/Resolve
		local nHP = DB.getValue(nodeChar, "hp.total", 0);
		local nST = DB.getValue(nodeChar, "sp.total", 0);
		local nConBonus = DB.getValue(nodeChar, "abilities.constitution.bonus", 0);	
		if nTotalLevel == 1 then
			--HP
			nHP = nHP + nClassHP;
			--Stamina
			local nAddST = nClassStamina + nConBonus;
			nST = nST + nAddST;
			local sFormat = Interface.getString("char_message_classhpstart");
			local sMsg = string.format(sFormat, DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", "")) .. " (" .. nClassHP .. ")";
			ChatManager.SystemMessage(sMsg);
			LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD,"Hit Points", nClassHP);
			local sFormat = Interface.getString("char_message_classstastart");
			local sMsg = string.format(sFormat, DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", "")) .. " (" .. nAddST .. ")";
			ChatManager.SystemMessage(sMsg);
			LogManager.LogMessage(nodeChar, LogManager.LOG_ACTION_ADD, "Stamina Points", nAddST);
		else
			--HP
			nHP = nHP + nClassHP;
			--Stamina
			local nAddST = nClassStamina + nConBonus;
			nST = nST + nAddST;
			local sFormat = Interface.getString("char_message_classhpadd");
			local sMsg = string.format(sFormat, DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", "")) .. " (" .. nClassHP .. ")";
			ChatManager.SystemMessage(sMsg);
			LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Hit Points", nClassHP);
			local sFormat = Interface.getString("char_message_classstaadd");
			local sMsg = string.format(sFormat, DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", "")) .. " (" .. nAddST .. ")";
			ChatManager.SystemMessage(sMsg);
			LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Stamina Points", nAddST);
		end
		--local nLevel= DB.getValue(nodeChar, "level", 1);
		local nKeyBonus= DB.getValue(nodeChar, "abilities.keyabilitymod", 1);
		local nRpLevel = math.floor(nLevel / 2);
		if nRpLevel < 1 then
			nRpLevel = 1;
		end
		nRpMax = nRpLevel + nKeyBonus;
		DB.setValue(nodeChar, "rp.total", "number", nRpMax);
		DB.setValue(nodeChar, "hp.total", "number", nHP);

	-- BAB
	if StringManager.contains({ CLASS_BAB_FAST, CLASS_BAB_MEDIUM, CLASS_BAB_SLOW, CLASS_BAB_DRONE }, sBAB) then
        --Debug.console("BAB",sBAB, nLevel)
		local nAddBAB = 0;
		if sBAB == CLASS_BAB_FAST then		
			nAddBAB = 1;
		elseif sBAB == CLASS_BAB_MEDIUM then
		
			if nLevel == 1 then
				nAddBAB = 0;
			elseif nLevel % 4 ~= 1 then
				nAddBAB = 1;
			end
		elseif sBAB == CLASS_BAB_DRONE then	
		
		local nLevel = nLevel % 4;
			if nLevel == 0 then
				nAddBAB = 0;
			else
				nAddBAB = 1;
			end
		elseif sBAB == CLASS_BAB_SLOW then
		
			if nLevel % 2 == 0 then
				nAddBAB = 1;
			end
		end
		
		if nAddBAB > 0 then
			DB.setValue(nodeChar, "attackbonus.base", "number", DB.getValue(nodeChar, "attackbonus.base", 0) + nAddBAB);
			local sFormat = Interface.getString("char_message_classbabadd");
			local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", "")) .. " (+" .. nAddBAB .. ")";
		end
	end
	
	-- Saves
	if StringManager.contains({ CLASS_SAVE_GOOD, CLASS_SAVE_BAD, CLASS_SAVE_GOOD_DRONE, CLASS_SAVE_BAD_DRONE }, sFort) then
		local nAddSave = 0;		
		if sFort == CLASS_SAVE_GOOD then
			if bPrestige then
				if nLevel % 2 == 1 then
					nAddSave = 1;
				end
			else
				if nLevel == 1 then
					nAddSave = 2;
				elseif nLevel % 2 == 0 then
					nAddSave = 1;
				end
			end
		elseif sFort == CLASS_SAVE_BAD then
			if bPrestige then
				if nLevel % 3 == 2 then
					nAddSave = 1;
				end
			else
				if nLevel % 3 == 0 then
					nAddSave = 1;
				end
			end
		elseif sFort == CLASS_SAVE_GOOD_DRONE then
			if nLevel == 1 then
				nAddSave = 2;
			elseif nLevel == 2 or nLevel == 5 or nLevel == 7 or nLevel == 10 or nLevel == 13 or nLevel == 15 or nLevel == 18 then			
				nAddSave = 1;				
			end
		elseif sFort == CLASS_SAVE_BAD_DRONE then		
			if nLevel == 3 or nLevel == 7 or nLevel == 11 or nLevel == 15 or nLevel == 19 then
				nAddSave = 1;
			end
		end
		if nAddSave > 0 then
			addSaveBonus(nodeChar, "fortitude", "base", nAddSave);
		end
	end
	if StringManager.contains({ CLASS_SAVE_GOOD, CLASS_SAVE_BAD, CLASS_SAVE_GOOD_DRONE, CLASS_SAVE_BAD_DRONE }, sRef) then
		local nAddSave = 0;
		if sRef == CLASS_SAVE_GOOD then
			if bPrestige then
				if nLevel % 2 == 1 then
					nAddSave = 1;
				end
			else
				if nLevel == 1 then
					nAddSave = 2;
				elseif nLevel % 2 == 0 then
					nAddSave = 1;
				end
			end
		elseif sRef == CLASS_SAVE_BAD then
			if bPrestige then
				if nLevel % 3 == 2 then
					nAddSave = 1;
				end
			else
				if nLevel % 3 == 0 then
					nAddSave = 1;
				end
			end
		elseif sRef == CLASS_SAVE_GOOD_DRONE then
			if nLevel == 1 then
				nAddSave = 2;
			elseif nLevel == 2 or nLevel == 5 or nLevel == 7 or nLevel == 10 or nLevel == 13 or nLevel == 15 or nLevel == 18 then			
				nAddSave = 1;				
			end
		elseif sRef == CLASS_SAVE_BAD_DRONE then		
			if nLevel == 3 or nLevel == 7 or nLevel == 11 or nLevel == 15 or nLevel == 19 then
				nAddSave = 1;
			end
		end
		if nAddSave > 0 then
			addSaveBonus(nodeChar, "reflex", "base", nAddSave);
		end
	end
	if StringManager.contains({ CLASS_SAVE_GOOD, CLASS_SAVE_BAD, CLASS_SAVE_GOOD_DRONE, CLASS_SAVE_BAD_DRONE }, sWill) then
		local nAddSave = 0;
		if sWill == CLASS_SAVE_GOOD then
			if bPrestige then
				if nLevel % 2 == 1 then
					nAddSave = 1;
				end
			else
				if nLevel == 1 then
					nAddSave = 2;
				elseif nLevel % 2 == 0 then
					nAddSave = 1;
				end
			end
		elseif sWill == CLASS_SAVE_BAD then
			if bPrestige then
				if nLevel % 3 == 2 then
					nAddSave = 1;
				end
			else
				if nLevel % 3 == 0 then
					nAddSave = 1;
				end
			end
		elseif sWill == CLASS_SAVE_GOOD_DRONE then
			if nLevel == 1 then
				nAddSave = 2;
			elseif nLevel == 2 or nLevel == 5 or nLevel == 7 or nLevel == 10 or nLevel == 13 or nLevel == 15 or nLevel == 18 then			
				nAddSave = 1;				
			end
		elseif sWill == CLASS_SAVE_BAD_DRONE then		
			if nLevel == 3 or nLevel == 7 or nLevel == 11 or nLevel == 15 or nLevel == 19 then
				nAddSave = 1;
			end
		end
		if nAddSave > 0 then
			addSaveBonus(nodeChar, "will", "base", nAddSave);
		end
	end
	
	-- Skill Points
	if nSkillPoints > 0 then
		local nAbilitySkillPoints = DB.getValue(nodeChar, "abilities.intelligence.bonus", 0);
		local nBonusSkillPoints = 0;
		if hasTrait(nodeChar, "Skilled") then
			nBonusSkillPoints = nBonusSkillPoints + 1;
		else
			if nTotalLevel == 1 then
				nSkillPoints = nSkillPoints;
			end
		end
		if nSkillPoints < 0 then
			nSkillPoints = 0;
		end
		DB.setValue(nodeClass,"classskillranks","number",nSkillPoints);
		if sClassLookup == "operative" then			
			DB.setValue(nodeClass,"skillranks", "number", DB.getValue(nodeClass, "skillranks", 0) + nSkillPoints + nAbilitySkillPoints + nBonusSkillPoints);
			local sClass = ("Operative");
			handleFreeRanks(nodeChar,nodeClass,sClass);
		else
			DB.setValue(nodeClass,"skillranks", "number", DB.getValue(nodeClass, "skillranks", 0) + nSkillPoints + nAbilitySkillPoints + nBonusSkillPoints);
		end
		if sClassLookup == "operative" then	
			sPoints = tostring(nSkillPoints) .. "+" .. tostring(nAbilitySkillPoints) .. "+" .. "2 Free Ranks." ;
		else	
			sPoints = tostring(nSkillPoints) .. "+" .. tostring(nAbilitySkillPoints);
		end
		if nBonusSkillPoints > 0 then
			sPoints = sPoints .. "+" .. nBonusSkillPoints;
		end
		local sFormat = Interface.getString("char_message_classskillranksadd");
		local sMsg = string.format(sFormat, DB.getValue(nodeClass, "name", ""), DB.getValue(nodeChar, "name", "")) .. " (" .. sPoints .. ")";
		ChatManager.SystemMessage(sMsg);		
		
	end
	
	-- Class Skills
	if nLevel == 1 and sClassSkills ~= "" then
		local aClassSkillsAdded = {};

		sClassSkills = sClassSkills:gsub(" and ", "");
		local aClassSkills = StringManager.split(sClassSkills, ",", true);
		for _,vSkill in ipairs(aClassSkills) do
			local sSkillAbility = vSkill:match("%((%w+)%)$");

			if sSkillAbility and (DataCommon.ability_ltos[sSkillAbility:lower()] or DataCommon.ability_stol[sSkillAbility:upper()]) then
				sSkillAbility = sSkillAbility:gsub("%s*%(%w+%)$", "");
				vSkill = vSkill:gsub("%s*%((%w+)%)$", "");
			end
			local sSkill = vSkill:match("[^(]+%w");

			if sSkill then
				--if addClassSkill(nodeChar, sSkill, vSkill:match("%(([^)]+)%)")) then
				local nodeSkill = getSkillNode(nodeChar, sSkill);
					if not nodeSkill then					
						--return false;						
					end		
				DB.setValue(nodeSkill, "state", "number", 1);
				table.insert(aClassSkillsAdded, vSkill);
				--end
			end
		end	
		
		if #aClassSkillsAdded > 0 then
			local sFormat = Interface.getString("char_message_classskillsadd");
			local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", "")) .. " (" .. table.concat(aClassSkillsAdded, ", ") .. ")";
			ChatManager.SystemMessage(sMsg);
			LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Class Skill", table.concat(aClassSkillsAdded, ", "));
		end
	end
	rest(nodeChar);
	return aClassStats;
	
end
--HANDLE KEY ABILITY SETUP
function getClassKeyAbility(nodeSource,nodeChar,nodeClass)
	-- Get Key Ability--
	
	local sSentence = DB.getValue(nodeSource,"keyabilityscore", ""):lower();
	local aProfWords = StringManager.parseWords(sSentence);		
		if aProfWords[1] == "your" then					
			sGetKeyAbility = (aProfWords[2]);				
		elseif aProfWords[1] == "you" then
			sGetKeyAbility = (aProfWords[5]);
		end
		if sGetKeyAbility == "strength" then
			sSourceClassKeyAbility = "Strength";
		elseif sGetKeyAbility == "dexterity" then
			sSourceClassKeyAbility = "Dexterity";
		elseif sGetKeyAbility == "constitution" then
			sSourceClassKeyAbility = "Constitution";
		elseif sGetKeyAbility == "intelligence" then
			sSourceClassKeyAbility = "Intelligence";
		elseif sGetKeyAbility == "wisdom" then
			sSourceClassKeyAbility = "Wisdom";
		elseif sGetKeyAbility == "charisma" then
			sSourceClassKeyAbility = "Charisma";
		end
	return sSourceClassKeyAbility;
end
function setKeyAbility(nodeChar,nodeClass,sSourceClassKeyAbility)
		if sSourceClassKeyAbility == nil then
			sSourceClassKeyAbility = "base";
		end
		local nMod= DB.getValue(nodeChar, "abilities." .. sSourceClassKeyAbility:lower() .. ".bonus",0);
		if DB.getValue(nodeChar, "abilities.keyability", "") == "" then
			DB.setValue(nodeChar, "abilities.keyability", "string", sSourceClassKeyAbility:lower());
			DB.setValue(nodeChar,"abilities.keyabilitymod", "number", nMod);
		end
		DB.setValue(nodeClass, "classkey", "string", sSourceClassKeyAbility);
		DB.setValue(nodeClass, "classkeymod", "number", nMod);
		DB.setValue(nodeChar,"abilities.key","number",1);
		return;
end
function addClassSkill(nodeChar, sSkill, sParens)
	if not sSkill then
		return false;
	end
	sSkill = StringManager.capitalizeAll(sSkill);
	sSkill = sSkill:gsub("Of", "of");
	local t = DataCommon.skilldata[sSkill];
	if not t then
		return false;
	end
	
	if t.sublabeling then
		if sParens then
			sParens = sParens:gsub(" and ", ",");
			sParens = sParens:gsub("all skills,? taken individually", "");
			sParens = sParens:gsub("all", "");
		end
		local aSpecialties = StringManager.split(sParens, ",", true);
		if #aSpecialties == 0 then
			local nodeSkill = getSkillNode(nodeChar, sSkill);
			if not nodeSkill then
				return false;
			end
			DB.setValue(nodeSkill, "state", "number", 1);
		else
			for _, sSpecialty in ipairs(aSpecialties) do
				local nodeSkill = getSkillNode(nodeChar, sSkill, StringManager.capitalize(sSpecialty));
				if nodeSkill then
					DB.setValue(nodeSkill, "state", "number", 1);
				end
			end
		end
	else
		local nodeSkill = getSkillNode(nodeChar, sSkill);
		if not nodeSkill then
			return false;
		end
		
		DB.setValue(nodeSkill, "state", "number", 1);
	end
end

function addClassFeature(nodeChar, sClass, sRecord, nodeTargetList) 
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return false;
	end
	
	local sClassName = StringManager.strip(DB.getValue(nodeSource, "...name", ""));
	local sFeatureName = DB.getValue(nodeSource, "name", "");
	local sFeatureType = StringManager.strip(sFeatureName):lower();
	local sFeatureTypeWithClass = sFeatureType .. " (" .. sClassName:lower() .. ")";
	local bCreateFeatureEntry = false;
	if not nodeTargetList and sFeatureType:match(CLASS_FEATURE_PROFICIENCY) then
		handleProficiencies(nodeChar, nodeSource);
	elseif sFeatureType:match(CLASS_FEATURE_SPELLS_PER_DAY) then
		local nChooseSpellClassIncrease = 1;
		if sClassName == CLASS_NAME_MYSTIC_THEURGE then
			nChooseSpellClassIncrease = 2;
		end
		
		local aOptions = {};
		for _,v in pairs(DB.getChildren(nodeChar, "spellset")) do
			local sSpellClassName = DB.getValue(v, "label", "");
			if sSpellClassName ~= CLASS_FEATURE_DOMAIN_SPELLS then
				table.insert(aOptions, sSpellClassName);
			end
		end
		table.sort(aOptions);
		
		if #aOptions > 0 then
			if #aOptions <= nChooseSpellClassIncrease then
				for _,v in ipairs(aOptions) do
					addClassSpellLevel(nodeChar, v);
				end
			else
				local wSelect = Interface.openWindow("select_dialog", "");
				local sTitle = Interface.getString("char_title_selectspellclassincrease");
				local sMessage = string.format(Interface.getString("char_message_selectspellclassincrease"), nChooseSpellClassIncrease);
				wSelect.requestSelection(sTitle, sMessage, aOptions, CharManager.onSpellClassIncreaseSelect, nodeChar, nChooseSpellClassIncrease);
			end
		end
	elseif sFeatureType:match(CLASS_FEATURE_EXTRACTS_PER_DAY) then
		addClassSpellLevel(nodeChar, CLASS_NAME_ALCHEMIST);
	else
		if not handleDuplicateFeatures(nodeChar, nodeSource, sFeatureType, nodeTargetList) then
			bCreateFeatureEntry = true;
			if sFeatureType:match(CLASS_FEATURE_SPELLS) or	sFeatureType:match(CLASS_FEATURE_ALCHEMY) then			
				handleClassFeatureSpells(nodeChar, nodeSource);				
			elseif sFeatureType:match(CLASS_FEATURE_DOMAINS) then
				handleClassFeatureDomains(nodeChar, nodeSource);
			end
		end		
	end	
	
	if bCreateFeatureEntry then
		if not nodeTargetList then
			nodeTargetList = nodeChar.createChild("specialabilitylist");
			if not nodeTargetList then
				return false;
			end
		end
		local vNew = nodeTargetList.createChild();
		DB.copyNode(nodeSource, vNew);
		DB.setValue(vNew, "name", "string", sFeatureName);
		DB.setValue(vNew, "source", "string", sClassName);
		DB.setValue(vNew, "locked", "number", 1);
		LogManager.onListAdd(vNew);
	if sClassName == "Operative" then
		for _,class in pairs(DB.getChildren(nodeChar, "classes")) do
			if DB.getValue(class, "name", "") == "Operative" then
			 nLevel = DB.getValue(class, "level",0);			
			end
			if nLevel == 1 then
				handleFreeSkills(nodeChar,nodeSource,sFeatureType); -- Adds Free Skill Tag for Operative Specializations	
			end
		end						
	end
	end
	
	local sFormat = Interface.getString("char_message_classfeatureadd");
	local sMsg = string.format(sFormat, sFeatureName, DB.getValue(nodeChar, "name", ""));
	ChatManager.SystemMessage(sMsg);
	
	return true;
end
function handleFreeSkills(nodeChar,nodeSource)-- Adds Free Skill Tag for Operative Specializations	
    local sAsscSkills = "";	
	sFreeSkillOne = "";
	sFreeSkillTwo = "";	
	sAsscSkills = DB.getValue(nodeSource, "abilities.id-00001.text", "");
	if sAsscSkills == "" then 
	 return;
	end
	aAsscList = StringManager.split(sAsscSkills, ":");	
	aAsscList = StringManager.split(aAsscList[2], ">");
	aAsscList = StringManager.split(aAsscList[2], ".");

	local sAsscList = aAsscList[1];
	sAsscList = sAsscList:gsub(" and ", ",");
	aList = StringManager.split(sAsscList, ",");

	sFreeSkillOne = aList[1];
	sFreeSkillTwo = aList[2];	
				
		for _,class in pairs(DB.getChildren(nodeChar, "classes")) do
			if DB.getValue(class, "name", "") == "Operative" then
			 nLevel = DB.getValue(class, "level",0);			
			end
		end
		for _,skill in pairs(DB.getChildren(nodeChar, "skilllist")) do
			sSkillName = DB.getValue(skill, "label","");
			if  sSkillName  == sFreeSkillOne or sSkillName  == sFreeSkillTwo then 
				DB.setValue(skill, "freeskill", "number", 1);		
			end
		end				
		handleFreeRanks(nodeChar);
end
function handleFreeRanks(nodeChar,nodeClass,sClass)
	for _,class in pairs(DB.getChildren(nodeChar, "classes")) do
		if DB.getValue(class, "name", "") == "Operative" then
			for _,skill in pairs(DB.getChildren(nodeChar, "skilllist")) do
				sSkillName = DB.getValue(skill, "label","");
				if DB.getValue(skill, "freeskill", 0) == 1 then				
					nRanks = DB.getValue(skill, "freeranks", 0);					
					DB.setValue(skill, "freeranks", "number", (nRanks + 1));
					local sFormat = ("Adding Free Skill Rank to " .. sSkillName) ;
					local sMsg = string.format(sFormat, sFeatureName, DB.getValue(nodeChar, "name", ""));
					ChatManager.SystemMessage(sMsg);
					LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADD, "Free Skill Rank", sSkillName);
				end							
			end			
		end
	end	
	updateSkillPoints(nodeChar);
end
function parseFeatureName(s)
	local nMult = 1;
	local sMult = s:match("%s+%((%d+)x%)$");
	if sMult then
		s = s:gsub("%s+%(%d+x%)$", "");
		nMult = tonumber(sMult) or 1;
	end
	
	local sSuffix = s:match("%s+%(?%+?%d+%)?$"); -- (+#) or +# or #
	if sSuffix then
		s = s:gsub("%s+%(?%+?%d+%)?$", "");
	else
		sSuffix = s:match("%s+%(?%d+/%-%)?$"); -- #/- or (#/-)
		if sSuffix then
			s = s:gsub("%s+%(?%d+/%-%)?$", "");
		else
			sSuffix = s:match("%s+%(?%+?%d+d6%)?$"); -- +#d6 or #d6
			if sSuffix then
				s = s:gsub("%s+%(?%+?%d+d6%)?$", "");
			else
				sSuffix = s:match("%s+%(?%d+/day%)?$"); -- #/day
				if sSuffix then
					s = s:gsub("%s+%(?%d+/day%)?$", "");
				else
					sSuffix = s:match("%s+%(?%d+ ft%.?%)?$"); -- # ft. or # ft
					if sSuffix then
						s = s:gsub("%s+%(?%d+ ft%.?%)?$", "");
					end
				end
			end
		end
	end
	
	return s:lower(), nMult, sSuffix;
end
function getAbilitySelect(nodeChar)
	local aAbilities = {};
		for _,v in ipairs(DataCommon.abilities) do
			if v == "strength" or v == "dexterity" then
				table.insert(aAbilities, StringManager.capitalize(v));
			end
		end
	local wSelect = Interface.openWindow("select_dialog", "");
	local sTitle = "Key Ability";
	local sMessage = "Select Key Ability";
		wSelect.requestSelection(sTitle, sMessage, aAbilities, CharManager.onKeyAbilitySelect, nodeChar, 1);
		bApplied = true;
	return sSourceClassKeyAbility;
end
function onAbilityIncreaseSelect(aSelection, nodeChar)

	for _,sAbility in ipairs(aSelection) do
	-- Get Ability List
		local k = sAbility:lower();
		if StringManager.contains(DataCommon.abilities, k) then
			local sPath = "abilitiesedit." .. k .. ".base";
			local nBase = DB.getValue(nodeChar, sPath, 10);
			local nLevel = DB.getValue(nodeChar, "level",0);
			if nBase > 16 then
				local nAdj = (DB.getValue(nodeChar, sPath) + 1);
				DB.setValue(nodeChar, sPath, "number", nAdj);
				LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, ("Stat Select Lvl " .. nLevel), ("[" .. DataCommon.ability_ltos[k] .. "] "  .. 1));
			else
				local nAdj = (DB.getValue(nodeChar, sPath) + 2);
				DB.setValue(nodeChar, sPath, "number", nAdj);
				LogManager.LogMessage(nodeChar,LogManager.LOG_ACTION_ADJUST, ("Stat Select Lvl " .. nLevel), ("[" .. DataCommon.ability_ltos[k] .. "] "  .. 2));
			end
		end	
	end
	for _,v in pairs (DB.getChildren(nodeChar, "classes")) do
		local sHasKeyAbility = DB.getValue(v, "classkey", ""):lower();
		local nMod= DB.getValue(nodeChar, "abilities." .. sHasKeyAbility .. ".bonus",0);
			DB.setValue(v, "classkeymod", "number", nMod);		
	end
	DB.setValue(nodeChar, "abilities.adjusted","string", "true");
	bApplied = false;
	
	return bApplied;
end
function onAbilityIncreaseSelectDrone(aSelection, nodeChar)
	for _,sAbility in ipairs(aSelection) do
		local k = sAbility:lower();
		if StringManager.contains(DataCommon.abilities, k) then
			local sPath = "abilitiesedit." .. k .. ".base";
			local nBase = DB.getValue(nodeChar, sPath, 10);			
			DB.setValue(nodeChar, sPath, "number", DB.getValue(nodeChar, sPath) + 1);			
		end
	end
	bApplied = true;
	return bApplied;
end

function handleDuplicateFeatures(nodeChar, nodeFeature, sFeatureType, nodeTargetList)
	local sClassName = StringManager.strip(DB.getValue(nodeFeature, "...name", ""));
	
	local sFeatureStrip = StringManager.strip(DB.getValue(nodeFeature, "name", ""));
	
	local nFeatureLevel = DB.get
	local sFeatureStripLower, nFeatureMult, sFeatureSuffix = parseFeatureName(sFeatureStrip);
	local nFeatureSuffix = 1;
	if sFeatureSuffix then
		nFeatureSuffix = tonumber(sFeatureSuffix:match("%d+")) or 1;
	end
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("specialabilitylist");
		if not nodeTargetList then
			return false;
		end
	end
	
	local nodeTarget = nil;
	for _,v in pairs(nodeTargetList.getChildren()) do
		local sStrip = StringManager.strip(DB.getValue(v, "name", ""));
		local sLower, nMult, sSuffix = parseFeatureName(sStrip);
		
		if sLower == sFeatureStripLower then
			local sSource = StringManager.strip(DB.getValue(v, "source", ""));
			if sSource ~= sClassName and sSource ~= "" then
				return false;
			end
			if (sSuffix and not sFeatureSuffix) or (not sSuffix and sFeatureSuffix) then
				return false;
			end

			DB.deleteNode(v);
			local vNew = nodeTargetList.createChild();
			DB.copyNode(nodeFeature, vNew);
			DB.setValue(vNew, "name", "string", sFeatureStrip);
			DB.setValue(vNew, "source", "string", sClassName);
			DB.setValue(vNew, "locked", "number", 1);
			--	addClassFeature(nodeChar, sClassName, nodeFeature.getPath(), nodeTargetList)			
			return true;
		end
	end

	return false;
end

function handleProficiencies(nodeChar, nodeFeature) --Adds Starting Prof
	local aWeapons = {};
	local aArmor = {};	
	local bIgnore = false;
	local sText = DB.getText(nodeFeature, "text", "");
	local aSentences = StringManager.split(sText, ".", true);
	bLight = false;
	bHeavy = false;
	bAdvanced = false;	
	for _,sSentence in ipairs(aSentences) do
		local aProfWords = StringManager.parseWords(sSentence);
		for i = 1,#aProfWords do
			if StringManager.isPhrase(aProfWords, i, { "gain", "no", "proficiency" }) then
				bIgnore = true;
				break;
			end
			if StringManager.isPhrase(aProfWords, i, { { "proficient", "skilled" }, "with" }) or 
					StringManager.isPhrase(aProfWords, i, { "proficient", "in", "the", "use", "of" }) then
				if not StringManager.isWord(aProfWords[i-1], "not") then
					local j = i + 2;
					while aProfWords[j] do
						if StringManager.isWord(aProfWords[j], "but") or StringManager.isPhrase(aProfWords, j, { "and", "treat", "any", "weapon" }) then
							break;
						elseif StringManager.isWord(aProfWords[j], "weapons") then
							if StringManager.isWord(aProfWords[j-2], "basic") then
								local sRecord = "reference.feat.basicmeleeweaponproficiency@Starfinder Core Rulebook";
								local sProfName = "basic melee weapon proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
							elseif StringManager.isWord(aProfWords[j-2], "advanced") then
								local sRecord = "reference.feat.advancedmeleeweaponproficiency@Starfinder Core Rulebook";
								local sProfName = "advanced melee weapon proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
									bAdvanced = true;
									-- ----Debug.chat("Advanced", bAdvanced)
							elseif StringManager.isWord(aProfWords[j-2], "small") then
								local sRecord = "reference.feat.smallarmproficiency@Starfinder Core Rulebook";
								local sProfName = "small arm proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
							elseif StringManager.isWord(aProfWords[j-1], "longarms") then
								local sRecord = "reference.feat.longarmproficiency@Starfinder Core Rulebook";
								local sProfName = "longarm proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
							elseif StringManager.isWord(aProfWords[j-1], "heavy") then
								local sRecord = "reference.feat.heavyweaponproficiency@Starfinder Core Rulebook";
								local sProfName = "heavy weapon proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
							elseif StringManager.isWord(aProfWords[j-1], "sniper") then
								local sRecord = "reference.feat.sniperweaponproficiency@Starfinder Core Rulebook";
								local sProfName = "sniper weapon proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
							elseif StringManager.isWord(aProfWords[j-1], "grenades") then
								local sRecord = "reference.feat.grenadeproficiency@Starfinder Core Rulebook";
								local sProfName = "grenade proficiency";
									addProfFeat(nodeChar,sClass,sRecord,sProfName);
							end
						elseif StringManager.isWord(aProfWords[j], "armor") then
							if StringManager.isPhrase(aProfWords, j-3, { "light", "and", "heavy" }) then
								local sClass = "feat";
								local sRecord = "reference.feat.lightarmorproficiency@Starfinder Core Rulebook";
								local sProfName = "light armor proficiency";
								addProfFeat(nodeChar,sClass,sRecord,sProfName);
								local sRecord = "reference.feat.heavyarmorproficiency@Starfinder Core Rulebook";
								local sProfName = "heavy armor proficiency";
								addProfFeat(nodeChar,sClass,sRecord,sProfName);
								bHeavy = true;
								bLight = true;
								elseif StringManager.isWord(aProfWords[j-1], "light") then
								local sRecord = "reference.feat.lightarmorproficiency@Starfinder Core Rulebook";
								local sClass = "feat";
								local sProfName = "light armor proficiency";
								addProfFeat(nodeChar,sClass,sRecord,sProfName);
								bLight = true
								elseif StringManager.isWord(aProfWords[j-1], "heavy") then
								local sRecord = "reference.feat.heavyarmorproficiency@Starfinder Core Rulebook";
								local sClass = "feat";
								local sProfName = "heavy armor proficiency";
								addProfFeat(nodeChar,sClass,sRecord,sProfName);
								bHeavy = true;
								elseif StringManager.isWord(aProfWords[j-1], "powered") then
								local sRecord = "reference.feat.poweredarmorproficiency@Starfinder Core Rulebook";
								local sClass = "feat";
								local sProfName = "powered armor proficiency";
								addProfFeat(nodeChar,sClass,sRecord,sProfName);
							end							
						
						elseif StringManager.isWord(aProfWords[j], "shield", "shields") then
								local sRecord = "reference.feat.shieldproficiency";
								local sClass = "feat";
								local sProfName = "shield proficiency";
						--		local nodeSource = resolveRefNode(sRecord);
						--		if nodeSource then
						--			addProfFeat(nodeChar,sClass,sRecord,sProfName);
						--			table.insert(aArmor, "shields");
						--		end							
						-- Class
						elseif StringManager.isPhrase(aProfWords, j, { { "hand", "light", "heavy" }, "crossbow" } ) then
							table.insert(aWeapons, table.concat(aProfWords, " ", j, j+1));
							j = j + 1;
						elseif StringManager.isPhrase(aProfWords, j, { "crossbow", "light", "or", "heavy" } ) then
							table.insert(aWeapons, aProfWords[j] .. " (" .. table.concat(aProfWords, " ", j+1, j+3) .. ")");
							j = j + 3;
						elseif StringManager.isPhrase(aProfWords, j, { "brass", "knuckles" } ) then
							table.insert(aWeapons, table.concat(aProfWords, " ", j, j+1));
							j = j + 1;
						elseif StringManager.isPhrase(aProfWords, j, { { "short", "long" }, "spear" } ) then
							table.insert(aWeapons, table.concat(aProfWords, " ", j, j+1));
							j = j + 1;
						elseif StringManager.isPhrase(aProfWords, j, { { "short", "long", "temple" }, "sword" } ) then
							table.insert(aWeapons, table.concat(aProfWords, " ", j, j+1));
							j = j + 1;
						elseif StringManager.isPhrase(aProfWords, j, { "one", "simple", "weapon" } ) then
							table.insert(aWeapons, table.concat(aProfWords, " ", j, j+2));
							j = j + 1;
						-- Prestige
						elseif StringManager.isPhrase(aProfWords, j, { "crossbow", "hand", "light", "or", "heavy" } ) then
							table.insert(aWeapons, aProfWords[j] .. " (" .. table.concat(aProfWords, ", ", j+1, j+2) .. " " .. table.concat(aProfWords, " ", j+3, j+4) .. ")");
							j = j + 4;
						elseif StringManager.isPhrase(aProfWords, j, { { "longbow", "shortbow" }, "normal", "and", "composite" } ) then
							table.insert(aWeapons, aProfWords[j] .. " (" .. table.concat(aProfWords, " ", j+1, j+3) .. ")");
							j = j + 3;
						-- Racial
						elseif StringManager.isWord(aProfWords[j], { "battleaxes", "blowguns", "falchions", "greataxes", "longswords", "nets", "rapiers", "slings", "warhammers" } ) then
							table.insert(aWeapons, aProfWords[j]);
						elseif StringManager.isPhrase(aProfWords, j, { "heavy", "picks" } ) then
							table.insert(aWeapons, table.concat(aProfWords, " ", j, j+1));
							j = j + 1;
						elseif StringManager.isPhrase(aProfWords, j, { { "longbows", "shortbows" }, "including", "composite", { "longbows", "shortbows" } } ) then
							table.insert(aWeapons, aProfWords[j] .. " (" .. table.concat(aProfWords, " ", j+1, j+3) .. ")");
							j = j + 3;
						-- Specific
						elseif StringManager.isWord(aProfWords[j], { "cestus", "club", "dagger", "dart", "handaxe", "javelin", "kama", "kukri", "longsword", "nunchaku", "quarterstaff", "rapier", "sai", "sap", "scimitar", "scythe", "shortbow", "shortspear", "shortsword", "shuriken", "siangham", "sickle", "sling", "spear", "whip" } ) then
							table.insert(aWeapons, aProfWords[j]);
						end
						j = j + 1;
					end
                --[[
                    if (bLight and bHeavy) or (bLight and bAdvanced) then
                        local sRecord = "reference.feat.shieldproficiency";
                        local sClass = "feat";
                        local sProfName = "shield proficiency";
                        local nodeSource = resolveRefNode(sRecord);
                        
                            if nodeSource ~= nil then
                                addProfFeat(nodeChar,sClass,sRecord,sProfName);
                                table.insert(aArmor, "shields");
                            end
                    end
                ]]
                end
			end
		end
	end
	
	if bIgnore then
		return true;
	end
	return (#aWeapons > 0) or (#aArmor > 0);
end

function handleClassFeatureSpells(nodeChar, nodeFeature)
	local sSpellcasting = DB.getText(nodeFeature, "text", "");
	local sAbility = sSpellcasting:match("must have an? (%a+) score equal to");
	
	local nodeSpellClassList = nodeChar.createChild("spellset");
	local nodeNewSpellClass = nodeSpellClassList.createChild();
	DB.setValue(nodeNewSpellClass, "label", "string", DB.getValue(nodeFeature, "...name", ""));
	DB.setValue(nodeNewSpellClass, "dc.ability", "string", sAbility:lower());
	if sSpellcasting:match("can cast any spell s?he knows without preparing") or 
			sSpellcasting:match("can cast any spell s?he knows at any time without preparing") then
		DB.setValue(nodeNewSpellClass, "castertype", "string", "spontaneous");
	end
		
	DB.setValue(nodeChar, "spellmode", "string", "standard");
	addClassSpellLevel(nodeChar, sClassName)
	return true;
end

function handleClassFeatureDomains(nodeChar, nodeFeature)
	local nodeSpellClassList = nodeChar.createChild("spellset");
	local nodeNewSpellClass = nodeSpellClassList.createChild();
	DB.setValue(nodeNewSpellClass, "label", "string", CLASS_FEATURE_DOMAIN_SPELLS);
	DB.setValue(nodeNewSpellClass, "dc.ability", "string", "wisdom");
	return true;
end

function onSpellClassIncreaseSelect(aSelection, nodeChar)
	for _,sClassName in ipairs(aSelection) do
		addClassSpellLevel(nodeChar, sClassName);
	end
end

function addClassSpellLevel(nodeChar, sClassName)
	for _,v in pairs(DB.getChildren(nodeChar, "spellset")) do
		sLabel = DB.getValue(v, "label", ""):lower();
		
		if sLabel == sClassName then
			addClassSpellLevelHelper(nodeChar, v);
		end
	end
	if sClassName == CLASS_NAME_CLERIC then
		addClassSpellLevel(nodeChar, CLASS_FEATURE_DOMAIN_SPELLS);
	end
end

function OLDaddClassSpellLevelHelper(nodeChar, nodeSpellClass)--
    ----Debug.chat("addClassSpellLevelHelper",nodeChar, nodeSpellClass)
	local sClassName = DB.getValue(nodeSpellClass, "label", "");

	-- Increment caster level
	local nCL = DB.getValue(nodeSpellClass, "cl", 0) + 1;
	DB.setValue(nodeSpellClass, "cl", "number", nCL);

	-- Update spell slots based on class
	local nNewSpellLevel = 0;

	if StringManager.contains({ CLASS_NAME_CLERIC, CLASS_NAME_DRUID, CLASS_NAME_WITCH, CLASS_NAME_WIZARD }, sClassName) then
		if nCL == 1 then
			addClassSpellLevelSlot(nodeSpellClass, 0, 1);
			addClassSpellLevelSlot(nodeSpellClass, 1);
			
			nNewSpellLevel = 1;
		elseif nCL == 2 then
			addClassSpellLevelSlot(nodeSpellClass, 0);
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 3 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			nNewSpellLevel = 2;
		elseif nCL == 4 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 5 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			nNewSpellLevel = 3;
		elseif nCL == 6 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 7 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 4);
			nNewSpellLevel = 4;
		elseif nCL == 8 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 9 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 5);
			nNewSpellLevel = 5;
		elseif nCL == 10 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 5);
		elseif nCL == 11 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 6);
			nNewSpellLevel = 6;
		elseif nCL == 12 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 6);
		elseif nCL == 13 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 7);
			nNewSpellLevel = 7;
		elseif nCL == 14 then
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelSlot(nodeSpellClass, 7);
		elseif nCL == 15 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 8);
			nNewSpellLevel = 8;
		elseif nCL == 16 then
			addClassSpellLevelSlot(nodeSpellClass, 7);
			addClassSpellLevelSlot(nodeSpellClass, 8);
		elseif nCL == 17 then
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelSlot(nodeSpellClass, 9);
			nNewSpellLevel = 9;
		elseif nCL == 18 then
			addClassSpellLevelSlot(nodeSpellClass, 8);
			addClassSpellLevelSlot(nodeSpellClass, 9);
		elseif nCL == 19 then
			addClassSpellLevelSlot(nodeSpellClass, 7);
			addClassSpellLevelSlot(nodeSpellClass, 9);
		elseif nCL == 20 then
			addClassSpellLevelSlot(nodeSpellClass, 8);
			addClassSpellLevelSlot(nodeSpellClass, 9);
		end
	elseif StringManager.contains({ CLASS_NAME_TECHNOMANCER, CLASS_NAME_MYSTIC }, sClassName) then	
		if nCL == 1 then	--2	--	
			addClassSpellLevelSlot(nodeSpellClass, 0, 1);
			addClassSpellLevelSlot(nodeSpellClass, 1, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass, 0, 4);
			addClassSpellLevelKnownSlot(nodeSpellClass,1, 2);
			nNewSpellLevel = 1;
		elseif nCL == 2 then --2--
			addClassSpellLevelKnownSlot(nodeSpellClass, 0, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,1, 1);
			-- No gain
		elseif nCL == 3 then --3--
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass, 0, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,1, 1);
		elseif nCL == 4 then --3,2--
			addClassSpellLevelSlot(nodeSpellClass, 2, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,2, 2);
			nNewSpellLevel = 2;
		elseif nCL == 5 then--4,2--
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,2, 1);
		elseif nCL == 6 then--4,3--
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,2, 1);
		elseif nCL == 7 then--4,3,2--
			addClassSpellLevelSlot(nodeSpellClass, 3, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,1, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,3, 2);
			nNewSpellLevel = 3;
		elseif nCL == 8 then--4,4,2--
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,3, 1);
		elseif nCL == 9 then--5,4,3--
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelKnownSlot(nodeSpellClass,3, 1);
		elseif nCL == 10 then--5,4,3,2--
			addClassSpellLevelSlot(nodeSpellClass, 4, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,2, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,4, 2);
			nNewSpellLevel = 4;
		elseif nCL == 11 then--5,4,4,2--
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelKnownSlot(nodeSpellClass,1, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,4, 1);
		elseif nCL == 12 then --5,5,4,3--
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelKnownSlot(nodeSpellClass,4, 1);
		elseif nCL == 13 then --5,5,4,3,2--
			addClassSpellLevelSlot(nodeSpellClass, 5, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,3, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,5, 2);
			nNewSpellLevel = 5;
		elseif nCL == 14 then --5,5,4,4,2--
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelKnownSlot(nodeSpellClass,2, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,5, 1);
		elseif nCL == 15 then --5,5,5,4,3--
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelKnownSlot(nodeSpellClass,5, 1);
		elseif nCL == 16 then --5,5,5,4,3,2
			addClassSpellLevelSlot(nodeSpellClass, 6, 2);
			addClassSpellLevelKnownSlot(nodeSpellClass,4, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,6, 2);			
			nNewSpellLevel = 6;
		elseif nCL == 17 then --5,5,5,4,4,2--
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelKnownSlot(nodeSpellClass,3, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,6, 1);
		elseif nCL == 18 then --5,5,5,5,4,3--
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelKnownSlot(nodeSpellClass,6, 1);
		elseif nCL == 19 then--5,5,5,5,5,4--
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelKnownSlot(nodeSpellClass,5, 1);
		elseif nCL == 20 then--5,5,5,5,5,5
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelKnownSlot(nodeSpellClass,4, 1);
			addClassSpellLevelKnownSlot(nodeSpellClass,6, 1);
		end
	elseif StringManager.contains({ CLASS_NAME_ALCHEMIST, CLASS_NAME_BARD, CLASS_NAME_INQUISITOR, CLASS_NAME_SUMMONER }, sClassName) then
		if nCL == 1 then
			if StringManager.contains({ CLASS_NAME_INQUISITOR, CLASS_NAME_SUMMONER }, sClassName) then
				addClassSpellLevelSlot(nodeSpellClass, 0);
			end
			addClassSpellLevelSlot(nodeSpellClass, 1);
			nNewSpellLevel = 1;
		elseif nCL == 2 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 3 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 4 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			nNewSpellLevel = 2;
		elseif nCL == 5 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 6 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 7 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			nNewSpellLevel = 3;
		elseif nCL == 8 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 9 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 10 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			nNewSpellLevel = 4;
		elseif nCL == 11 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 12 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 13 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			nNewSpellLevel = 5;
		elseif nCL == 14 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 5);
		elseif nCL == 15 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 5);
		elseif nCL == 16 then
			addClassSpellLevelSlot(nodeSpellClass, 6);
			nNewSpellLevel = 6;
		elseif nCL == 17 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 6);
		elseif nCL == 18 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 6);
		elseif nCL == 19 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 6);
		elseif nCL == 20 then
			addClassSpellLevelSlot(nodeSpellClass, 6);
		end
	elseif StringManager.contains({ CLASS_NAME_ORACLE, CLASS_NAME_SORCERER }, sClassName) then
		if nCL == 1 then
			addClassSpellLevelSlot(nodeSpellClass, 0);
			addClassSpellLevelSlot(nodeSpellClass, 1, 3);
			nNewSpellLevel = 1;
		elseif nCL == 2 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 3 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 4 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 2, 3);
			nNewSpellLevel = 2;
		elseif nCL == 5 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 6 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 3, 3);
			nNewSpellLevel = 3;
		elseif nCL == 7 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 8 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 4, 3);
			nNewSpellLevel = 4;
		elseif nCL == 9 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 10 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 5, 3);
			nNewSpellLevel = 5;
		elseif nCL == 11 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 5);
		elseif nCL == 12 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 6, 3);
			nNewSpellLevel = 6;
		elseif nCL == 13 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
			addClassSpellLevelSlot(nodeSpellClass, 6);
		elseif nCL == 14 then
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelSlot(nodeSpellClass, 7, 3);
			nNewSpellLevel = 7;
		elseif nCL == 15 then
			addClassSpellLevelSlot(nodeSpellClass, 6);
			addClassSpellLevelSlot(nodeSpellClass, 7);
		elseif nCL == 16 then
			addClassSpellLevelSlot(nodeSpellClass, 7);
			addClassSpellLevelSlot(nodeSpellClass, 8, 3);
			nNewSpellLevel = 8;
		elseif nCL == 17 then
			addClassSpellLevelSlot(nodeSpellClass, 7);
			addClassSpellLevelSlot(nodeSpellClass, 8);
		elseif nCL == 18 then
			addClassSpellLevelSlot(nodeSpellClass, 8);
			addClassSpellLevelSlot(nodeSpellClass, 9, 3);
			nNewSpellLevel = 9;
		elseif nCL == 19 then
			addClassSpellLevelSlot(nodeSpellClass, 8);
			addClassSpellLevelSlot(nodeSpellClass, 9);
		elseif nCL == 20 then
			addClassSpellLevelSlot(nodeSpellClass, 9, 2);
		end
	elseif StringManager.contains({ CLASS_NAME_PALADIN, CLASS_NAME_RANGER }, sClassName) then
		if nCL == 1 then
			nNewSpellLevel = 1;
		elseif nCL == 2 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 3 then
			-- No gain
		elseif nCL == 4 then
			nNewSpellLevel = 2;
		elseif nCL == 5 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 6 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 7 then
			nNewSpellLevel = 3;
		elseif nCL == 8 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 9 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 10 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			nNewSpellLevel = 4;
		elseif nCL == 11 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 12 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 13 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 14 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 15 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 16 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 17 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 4);
		end
	elseif StringManager.contains({ CLASS_NAME_ADEPT }, sClassName) then
		if nCL == 1 then
			addClassSpellLevelSlot(nodeSpellClass, 0, 3);
			addClassSpellLevelSlot(nodeSpellClass, 1);
			nNewSpellLevel = 1;
		elseif nCL == 2 then
			-- No gain
		elseif nCL == 3 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
		elseif nCL == 4 then
			nNewSpellLevel = 2;
		elseif nCL == 5 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 6 then
			-- No gain
		elseif nCL == 7 then
			addClassSpellLevelSlot(nodeSpellClass, 1);
			addClassSpellLevelSlot(nodeSpellClass, 2);
		elseif nCL == 8 then
			nNewSpellLevel = 3;
		elseif nCL == 9 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 10 then
			-- No gain
		elseif nCL == 11 then
			addClassSpellLevelSlot(nodeSpellClass, 2);
			addClassSpellLevelSlot(nodeSpellClass, 3);
		elseif nCL == 12 then
			nNewSpellLevel = 4;
		elseif nCL == 13 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 14 then
			-- No gain
		elseif nCL == 15 then
			addClassSpellLevelSlot(nodeSpellClass, 3);
			addClassSpellLevelSlot(nodeSpellClass, 4);
		elseif nCL == 16 then
			nNewSpellLevel = 5;
		elseif nCL == 17 then
			addClassSpellLevelSlot(nodeSpellClass, 5);
		elseif nCL == 18 then
			-- No gain
		elseif nCL == 19 then
			addClassSpellLevelSlot(nodeSpellClass, 4);
			addClassSpellLevelSlot(nodeSpellClass, 5);
		elseif nCL == 20 then
			-- No gain
		end
	elseif sClassName == CLASS_FEATURE_DOMAIN_SPELLS then
		if nCL % 2 == 1 then
			local nNewDomainSpellLevel = math.floor((nCL + 1) / 2);
			if nNewDomainSpellLevel >= 1 and nNewDomainSpellLevel <= 9 then
				addClassSpellLevelSlot(nodeSpellClass, nNewDomainSpellLevel);
			end
		end
	end
	
    -- Add bonus spell slots, if we just gained a new spell level
    --[[
    if nNewSpellLevel >= 1 and nNewSpellLevel <= 6 then
        local sSpellAbility = DB.getValue(nodeSpellClass, "dc.ability", "");
        if StringManager.contains(DataCommon.abilities, sSpellAbility) then
            local nBonus = 0;
            local nAbilityScore = DB.getValue(nodeChar, "abilities." .. sSpellAbility .. ".score", 10);
            if nAbilityScore >= (10 + (nNewSpellLevel * 2)) then
                nBonus = math.floor((nAbilityScore - (10 + (nNewSpellLevel * 2))) / 8) + 1;
            end
            if nBonus > 0 then
                DB.setValue(nodeSpellClass, "availablelevel" .. nNewSpellLevel, "number", DB.getValue(nodeSpellClass, "availablelevel" .. nNewSpellLevel, 0) + nBonus);
            end
        end
    end
    ]]
end
function OLDaddClassSpellLevelSlot(nodeSpellClass, nSpellLevel, nSlots)
	DB.setValue(nodeSpellClass, "availablelevel" .. nSpellLevel, "number", DB.getValue(nodeSpellClass, "availablelevel" .. nSpellLevel, 0) + (nSlots or 1));
end
function OLDaddClassSpellLevelKnownSlot(nodeSpellClass, nSpellLevel, nSlots)
	DB.setValue(nodeSpellClass, "knownlevel" .. nSpellLevel, "number", DB.getValue(nodeSpellClass, "knownlevel" .. nSpellLevel, 0) + (nSlots or 1));
end
function addClassSpellLevelHelper(nodeChar, nodeSpellClass, nClassLevel)
    ----Debug.chat("addClassSpellLevelHelper",nodeChar, nodeSpellClass)
	local sClassName = DB.getValue(nodeSpellClass, "label", "");
	local nCL = 0;

	--Increment caster level
	if nClassLevel == nil then		
		nCL = DB.getValue(nodeSpellClass, "cl", 0) + 1;		
		DB.setValue(nodeSpellClass, "cl", "number", nCL);
	else
		nCL = nClassLevel;
	end

	-- Update spell slots based on class
	local nNewSpellLevel = 0;
	local aLevelCast = {1,0,0,0,0,0,0}; --Levels 1-6
	local aLevelKnown = {0,0,0,0,0,0,0}; --Levels 0-6
	local nSpellLevel = 0
	if StringManager.contains({ CLASS_NAME_TECHNOMANCER, CLASS_NAME_MYSTIC }, sClassName) then	
		if nCL == 1 then	--2--4,2   --Spells Cast--Spells Known
			aLevelCast = {1,2,0,0,0,0,0};
			aLevelKnown = {4,2,0,0,0,0,0};
			nNewSpellLevel = 1;			
		elseif nCL == 2 then --2--5,3
			aLevelCast = {1,2,0,0,0,0,0};
			aLevelKnown = {5,3,0,0,0,0,0};
			-- No gain
		elseif nCL == 3 then --3--6,4
			aLevelCast = {1,3,0,0,0,0,0};
			aLevelKnown = {6,4,0,0,0,0,0};
		elseif nCL == 4 then --3,2--6,4,2
			aLevelCast = {1,3,2,0,0,0,0};
			aLevelKnown = {6,4,2,0,0,0,0};
			nNewSpellLevel = 2;
		elseif nCL == 5 then--4,2--6,4,3
			aLevelCast = {1,4,2,0,0,0,0};
			aLevelKnown = {6,4,3,0,0,0,0};
		elseif nCL == 6 then--4,3--6,4,4
			aLevelCast = {1,4,3,0,0,0,0};
			aLevelKnown = {6,4,4,0,0,0,0};
		elseif nCL == 7 then--4,3,2--6,5,4,2
			aLevelCast = {1,4,3,2,0,0,0};
			aLevelKnown = {6,5,4,2,0,0,0};
			nNewSpellLevel = 3;
		elseif nCL == 8 then--4,4,2--6,5,4,3
			aLevelCast = {1,4,4,2,0,0,0};
			aLevelKnown = {6,5,4,3,0,0,0};
		elseif nCL == 9 then--5,4,3--6,5,4,4
			aLevelCast = {1,5,4,3,0,0,0};
			aLevelKnown = {6,5,4,4,0,0,0};
		elseif nCL == 10 then--5,4,3,2--6,5,5,4,2
			aLevelCast = {1,5,4,3,2,0,0};
			aLevelKnown = {6,5,5,4,2,0,0};
			nNewSpellLevel = 4;
		elseif nCL == 11 then--5,4,4,2--6,6,5,4,3
			aLevelCast = {1,5,4,4,2,0,0};
			aLevelKnown = {6,6,5,4,3,0,0};
		elseif nCL == 12 then --5,5,4,3--6,6,5,4,4
			aLevelCast = {1,5,5,4,3,0,0};
			aLevelKnown = {6,6,5,4,4,0,0};
		elseif nCL == 13 then --5,5,4,3,2--6,6,5,5,4,2
			aLevelCast = {1,5,5,4,3,2,0};
			aLevelKnown = {6,6,5,5,4,2,0};
			nNewSpellLevel = 5;
		elseif nCL == 14 then --5,5,4,4,2--6,6,6,5,4,3
			aLevelCast = {1,5,5,4,4,2,0};
			aLevelKnown = {6,6,6,5,4,3,0};
		elseif nCL == 15 then --5,5,5,4,3--6,6,6,5,4,4
			aLevelCast = {1,5,5,5,4,3,0};
			aLevelKnown = {6,6,6,5,4,4,0};
		elseif nCL == 16 then --5,5,5,4,3,2--6,6,6,5,5,4,2
			aLevelCast = {1,5,5,5,4,3,2};
			aLevelKnown = {6,6,6,5,5,4,2};		
			nNewSpellLevel = 6;
		elseif nCL == 17 then --5,5,5,4,4,2--6,6,6,6,5,4,3
			aLevelCast = {1,5,5,5,4,4,2};
			aLevelKnown = {6,6,6,6,5,4,3};
		elseif nCL == 18 then --5,5,5,5,4,3--6,6,6,6,5,4,4
			aLevelCast = {1,5,5,5,5,4,3};
			aLevelKnown = {6,6,6,6,5,4,4};
		elseif nCL == 19 then--5,5,5,5,5,4--6,6,6,6,5,5,4
			aLevelCast = {1,5,5,5,5,5,4};
			aLevelKnown = {6,6,6,6,5,5,4};
		elseif nCL == 20 then--5,5,5,5,5,5--6,6,6,6,6,5,5
			aLevelCast = {1,5,5,5,5,5,5};
			aLevelKnown = {6,6,6,6,6,5,5};
		end
		
		addClassSpellLevelSlots(nodeSpellClass, aLevelCast)
		addClassSpellLevelKnownSlots(nodeSpellClass, aLevelKnown)
	end
end
	
function isProficient(nodeActor, sType)
    local bProf = false;
    local sFeatProf;
    local sWeaponProfType;

    for k,v in pairs(DB.getChildren(nodeActor, "proficiencylist")) do
        sFeatProf = DB.getValue(v, "refnode", "");
        sWeaponProfType = DataCommon.feat_proficiencies[sFeatProf];

        if sWeaponProfType ~= nil then
            if (sWeaponProfType):lower() == (sType):lower() then
                bProf = true;
                break;
            end
		else
			sWeaponProfType = DB.getValue(v, "weaponsubtype", "");
			 if (sWeaponProfType):lower() == (sType):lower() then
                bProf = true;
                break;
            end
        end
    end
    return bProf;
end

function addClassSpellLevelSlots(nodeSpellClass, aLevelCast)
	local nodeChar = nodeSpellClass.getChild("...");
	local aLevels = {0,1,2,3,4,5,6};
	local nLoc = 0;
	for _,v in pairs (aLevels) do	

		nLoc = v + 1; --set array location
		nCastPerDay = aLevelCast[nLoc];

		if nCastPerDay > 0 then
			local sSpellAbility = DB.getValue(nodeSpellClass, "dc.ability", "");
			if StringManager.contains(DataCommon.abilities, sSpellAbility) then
				local nAbilityScore = DB.getValue(nodeChar, "abilities." .. sSpellAbility .. ".score", 10);

				if nAbilityScore >= (10 + (v * 2)) then
					nCastPerDay = nCastPerDay + math.floor((nAbilityScore - (10 + (v * 2))) / 8) + 1;
				end			
			end			
		end
		DB.setValue(nodeSpellClass, "availablelevel" .. v, "number", nCastPerDay, 0);		
	end
end
function addClassSpellLevelKnownSlots(nodeSpellClass, aLevelKnown)
	local aLevels = {0,1,2,3,4,5,6};
	for _,v in pairs (aLevels) do
		local nLoc = v + 1; --set array location
		DB.setValue(nodeSpellClass, "knownlevel" .. v, "number", aLevelKnown[nLoc], 0);
	end
end

function onFavoredClassSelect(aSelection, rFavoredClassSelect)
	local aClassToAdd = {};
	for _,vClassSelect in ipairs(aSelection) do
		local bHandled = false;
		for _,vClass in pairs(DB.getChildren(rFavoredClassSelect.nodeChar, "classes")) do
			if DB.getValue(vClass, "name", "") == vClassSelect then
				DB.setValue(vClass, "favored", "number", 1);
				bHandled = true;
				break;
			end
		end
		if not bHandled then
			table.insert(aClassToAdd, vClassSelect);
		end
	end
	checkFavoredClassBonus(rFavoredClassSelect.nodeChar, rFavoredClassSelect.sCurrentClass);
	for _,vClassToAdd in ipairs(aClassToAdd) do
		local nodeList = rFavoredClassSelect.nodeChar.createChild("classes");
		if nodeList then
			local nodeClass = nodeList.createChild();
			DB.setValue(nodeClass, "name", "string", vClassToAdd);
			DB.setValue(nodeClass, "favored", "number", 1);
			for _,vClassOffered in ipairs(rFavoredClassSelect.aClassesOffered) do
				if vClassOffered.text == vClassToAdd then
					DB.setValue(nodeClass, "shortcut", "windowreference", vClassOffered.linkclass, vClassOffered.linkrecord);
					break;
				end
			end
		end
	end
end

function checkFavoredClassBonus(nodeChar, sClassName)
	local bApply = false;
	for _,vClass in pairs(DB.getChildren(nodeChar, "classes")) do
		if DB.getValue(vClass, "name", "") == sClassName and DB.getValue(vClass, "favored", 0) == 1 then
			bApply = true;
			break;
		end
	end
	if bApply then
		local aOptions = {};
		table.insert(aOptions, Interface.getString("char_value_favoredclasshpbonus"));
		table.insert(aOptions, Interface.getString("char_value_favoredclassskillbonus"));
		local wSelect = Interface.openWindow("select_dialog", "");
		local sTitle = Interface.getString("char_title_selectfavoredclassbonus");
		local sMessage = Interface.getString("char_message_selectfavoredclassbonus");
		local rFavoredClassBonusSelect = { nodeChar = nodeChar, sCurrentClass = sClassName };
		wSelect.requestSelection(sTitle, sMessage, aOptions, CharManager.onFavoredClassBonusSelect, rFavoredClassBonusSelect, 1);
		bApplied = true;
	end
end

function onFavoredClassBonusSelect(aSelection, rFavoredClassBonusSelect)
	if #aSelection == 0 then
		return;
	end
	if aSelection[1] == Interface.getString("char_value_favoredclasshpbonus") then
		DB.setValue(rFavoredClassBonusSelect.nodeChar, "hp.total", "number", DB.getValue(rFavoredClassBonusSelect.nodeChar, "hp.total", 0) + 1);
		
		local sMsg = string.format(Interface.getString("char_message_favoredclasshpadd"), DB.getValue(rFavoredClassBonusSelect.nodeChar, "name", ""));
		ChatManager.SystemMessage(sMsg);
	elseif aSelection[1] == Interface.getString("char_value_favoredclassskillbonus") then
		local nodeClass = getClassNode(rFavoredClassBonusSelect.nodeChar, rFavoredClassBonusSelect.sCurrentClass);
		if nodeClass then
			DB.setValue(nodeClass, "skillranks", "number", DB.getValue(nodeClass, "skillranks", 0) + 1);
		end
		
		local sMsg = string.format(Interface.getString("char_message_favoredclassskilladd"), DB.getValue(rFavoredClassBonusSelect.nodeChar, "name", ""));
		ChatManager.SystemMessage(sMsg);
	end
end

function addFeat(nodeChar, sClass, sRecord, nodeTargetList)
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("featlist");
		if not nodeTargetList then
			return;
		end
	end
	local aFeatLoc = StringManager.split(sRecord, "@");
	if not handleDuplicateFeats(nodeChar, nodeSource, aFeatLoc, nodeTargetList) then
		--[[ Not currently used
		if not parseFeatPreReqs(nodeChar, nodeSource) then
			return;
		end
		]]--
		-- Special handling
		if aFeatLoc[1] == "reference.feat.toughness" then
			applyToughness(nodeChar, true);
		end		
		local nodeEntry = nodeTargetList.createChild();
		DB.copyNode(nodeSource, nodeEntry);
		DB.setValue(nodeEntry, "refnode", "string", aFeatLoc[1]); 
		LogManager.onListAdd(nodeEntry);
	else
		local sFeatName = DB.getValue(nodeSource, "name", "");
		ChatManager.SystemMessage(Interface.getString("char_message_duplicatefeat").." ["..sFeatName.."]");
	end

end

function addProfFeat(nodeChar, sClass, sRecord, sProfName, nodeTargetList)
    ----Debug.chat("addProFeat")
	local nodeSource = resolveRefNode(sRecord);	
	if not nodeSource then
		return;
	end
	if not sClass then
		sClass = "feat";
		if not sClass then
			return;
		end
	end
	
    -- Search if Prof is all ready there
	local bFound = false;
	for k,v in pairs(DB.getChildren(nodeChar, "proficiencylist")) do
		if DB.getValue(v, "name", ""):lower() == (sProfName):lower() then
			bFound = true;
		end
	end	
	
	if not bFound then
		if not nodeTargetList then
			nodeTargetList = nodeChar.createChild("proficiencylist");
			if not nodeTargetList then
				return;
			end
		end
		aFeatLoc = StringManager.split(sRecord, "@");
		local nodeEntry = nodeTargetList.createChild();
		DB.copyNode(nodeSource, nodeEntry);
		DB.setValue(nodeEntry, "refnode", "string", aFeatLoc[1]);
		LogManager.onListAdd(nodeEntry);
	end
end
function addBoon(nodeChar, sClass, sRecord, nodeTargetList)
	local nodeSource = resolveRefNode(sRecord);
	if not nodeSource then
		return;
	end
	
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("boonlist");
		if not nodeTargetList then
			return;
		end
	end
	
	local nodeEntry = nodeTargetList.createChild();
	DB.copyNode(nodeSource, nodeEntry);
	LogManager.onListAdd(nodeEntry);
end
function addArchetype(nodeChar, sClass, sRecord, rCharClass)
	local nodeSource = resolveRefNode(sRecord);	
	
	if not nodeSource then
		return;
	end
	
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("archetype");
		if not nodeTargetList then		
			return;
		end
	end
	local nodeEntry = nodeTargetList.createChild();
	DB.copyNode(nodeSource, nodeEntry);
end
function addAug(nodeChar, nodeItem, nodeTargetList)
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("auglist");
		if not nodeTargetList then
			return false;
		end
	end

	local nodeEntry = nodeTargetList.createChild();
	DB.copyNode(nodeItem, nodeEntry);
	DB.setValue(nodeEntry, "source", "string", DB.getValue(nodeTrait, "...name", ""));
	DB.setValue(nodeEntry, "locked", "number", 1);
	LogManager.onListAdd(nodeEntry)
	return true;
end
function addUpgrade(nodeChar, nodeItem, nodeTargetList)
	if not nodeTargetList then
		nodeTargetList = nodeChar.createChild("upgradelist");
		if not nodeTargetList then
			return false;
		end
	end

	local nodeEntry = nodeTargetList.createChild();
	DB.copyNode(nodeItem, nodeEntry);
	DB.setValue(nodeEntry, "source", "string", DB.getValue(nodeTrait, "...name", ""));
	DB.setValue(nodeEntry, "locked", "number", 1);
	LogManager.onListAdd(nodeEntry);
	return true;
end

function isWeaponTooHeavy(nodeChar,sType, nLevel)
	if sType:lower() ~= "heavy" then
		return false;
	end
	local minStrength;
	if nLevel <= 10 then
		minStrength = 12;
	elseif nLevel > 10 then
		minStrength = 14;
	end
	local strength = DB.getValue(nodeChar,"abilities.strength.score",0);
	if strength < minStrength then
		return true;
	else
		return false;
	end
end


function handleDuplicateFeats(nodeChar, nodeFeature, aFeatLoc, nodeTargetList)
	local bMultiple = false;
	local sSpecial = DB.getValue(nodeFeature,"special");
	if sSpecial then
		bMultiple = (sSpecial:match(FEAT_MULTIPLE_TIMES) ~= nil);
	end
	if not bMultiple then
		for _, vNode in pairs(DB.getChildren(nodeChar, "featlist")) do
			local sRefnode = DB.getValue(vNode, "refnode", "");
			if sRefnode == aFeatLoc[1] then
				return true;
			end
		end
		for _, vNode in pairs(DB.getChildren(nodeChar, "proficiencylist")) do
			local sRefnode = DB.getValue(vNode, "refnode", "");
			if sRefnode == aFeatLoc[1] then
				return true;
			end
		end
	end
	return false;
end
--[[ Not Currently in use
function parseFeatPreReqs(nodeChar, nodeFeature)
	local sPrereq = DB.getValue(nodeFeature,"prequisite", "");
	local aWords = StringManager.parseWords(sPrereq:lower());
	local aPrereq = {};
	local i = 1;
	local nBAB = DB.getValue(nodeChar,"attackbonus.base", 0);
	while aWords[i] do
		if StringManager.isPhrase(aWords, i, { "base", "attack", "bonus" }) then
			if nBAB < tonumber(aWords[i + 3]) then
				table.insert(aPrereq, {"char_label_combatatkbase", tonumber(aWords[i + 3])});
			end
		end
		i = i + 1;
	end
	Debug.chat(aPrereq);
	return false;
end
]]--

function applyToughness(nodeChar, bInitialAdd)
	local nLevelSP = DB.getValue(nodeChar, "level", 0);
	local nCurrentSPMod = DB.getValue(nodeChar, "sp.mod", 0);
	local nOtherSPMod = 0;

	if not bInitialAdd then
		local nPrevLevelSP = nLevelSP - 1;
		nOtherSPMod = nCurrentSPMod - nPrevLevelSP;
		if nOtherSPMod < 0 then
			nOtherSPMod = 0;
		end
	end
	local nSPMod = nLevelSP + nOtherSPMod;
	local nSPDiff = nSPMod - nCurrentSPMod;
	DB.setValue(nodeChar, "sp.mod", "number", nSPMod);
	outputUserMessage("char_message_message_spaddfeat", StringManager.capitalizeAll(FEAT_TOUGHNESS), DB.getValue(nodeChar, "name", ""), nSPDiff);
end

function outputUserMessage(sResource, ...)
	local sFormat = Interface.getString(sResource);
	local sMsg = string.format(sFormat, ...);
	ChatManager.SystemMessage(sMsg);
end


function claimCompanion(msgOOB)
	if User.isHost() then
		local sClaimant = msgOOB.sClaimant or nil;

		if sClaimant then
			local nodeChar = DB.findNode(sClaimant);
			if nodeChar then
				local nodeOwnedComp = DB.getChild(nodeChar,"companionlink");
				if nodeOwnedComp then
					local sClass, sRecord = DB.getValue(nodeChar,"companionlink", "", "");
					if sRecord ~= "" then
						local nodeComp = DB.findNode(sRecord);
						DB.setOwner(nodeComp, DB.getOwner(nodeChar));
					end
				end
			else
				return;
			end
		else
			return;
		end
	else
		return;
	end
end