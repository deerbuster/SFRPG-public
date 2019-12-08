-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local FORGE_PATH_BASE_ITEMS = "forge.items";
local FORGE_PATH_TEMPLATES = "forge.templates";

local RARITY_UNKNOWN = 1;
local RARITY_COMMON = 2;
local RARITY_UNCOMMON = 3;
local RARITY_RARE = 4;
local RARITY_VERY_RARE = 5;
local RARITY_LEGENDARY = 6;

local items = {};
local templates = {};

function reset()
	DB.deleteChildren(FORGE_PATH_BASE_ITEMS);
	DB.deleteChildren(FORGE_PATH_TEMPLATES);
end

function addBaseItem(sClass, sRecord)
	local nodeSource = DB.findNode(sRecord);
	if nodeSource then
		local nodeTarget = DB.createChild(FORGE_PATH_BASE_ITEMS);
		copyNode = DB.copyNode(nodeSource, nodeTarget);
		DB.setValue(nodeTarget, "locked", "number", 1);
		DB.setValue(nodeTarget, "refclass", "string", sClass);
	end
end

function addTemplate(sClass, sRecord)
	local nodeSource = DB.findNode(sRecord);
	
	if nodeSource then
		local nodeTarget = DB.createChild(FORGE_PATH_TEMPLATES);
		copyNode = DB.copyNode(nodeSource, nodeTarget);
		DB.setValue(nodeTarget, "locked", "number", 1);
		DB.setValue(nodeTarget, "refclass", "string", sClass);
	end
end

function forgeItem(winForge) 
	if winForge == nil then
		return;
	end
	
	-- Reset status
	winForge.status.setValue("");
	
	-- Cache item and template nodes
	items = {};
	for _,v in pairs(DB.getChildren(FORGE_PATH_BASE_ITEMS)) do
		table.insert(items, v);
	end
	templates = {};
	for _,v in pairs(DB.getChildren(FORGE_PATH_TEMPLATES)) do
		table.insert(templates, v);
	end
	
	-- Validate forging data
	if ((#items ~= 0) and (#templates ~= 0)) or (#templates >= 2) then
		if isCompatible() then
			createForgedItem();
			winForge.statusicon.setStringValue("ok");
			winForge.status.setValue(Interface.getString("forge_item_message_success"));
		else
			winForge.statusicon.setStringValue("error");
			winForge.status.setValue(Interface.getString("forge_item_message_incompatible"));
		end	
	else 
		winForge.statusicon.setStringValue("error");
		winForge.status.setValue(Interface.getString("forge_item_message_missing"));
	end
	
end

function getDisplayType(node)
	local sIcon = "";
	
	local sTypeLower = DB.getValue(node, "type", ""):lower();
	local sSubTypeLower = DB.getValue(node, "subtype", ""):lower();
	local sSchoolLower = DB.getValue(node, "school", ""):lower();
	
	if StringManager.contains({"powered armor template"}, sTypeLower) then
			sIcon = "poweredarmoruprade";
	elseif StringManager.contains({"powered armor"}, sTypeLower) then
			sIcon = "poweredarmor";
	elseif StringManager.contains({"armor template"}, sTypeLower) then
			sIcon = "armoruprade";
	elseif StringManager.contains({"armor"}, sTypeLower) then
			sIcon = "armor";
	elseif StringManager.contains({"magic item template"}, sTypeLower) then
		sIcon = "magicitem";
	elseif StringManager.contains({"serum"}, sSubTypeLower) then
		sIcon = "serum";
	elseif StringManager.contains({"spell"}, sSubTypeLower) then
		sIcon = "spellgem";
	elseif StringManager.contains({"hybrid item template"}, sTypeLower) then
		sIcon = "hybriditem";
	elseif sSchoolLower ~= nil and sSchoolLower ~= "" then
		sIcon = "spell";
	elseif StringManager.contains({"starship template"}, sTypeLower) then
		sIcon = "starshipuprade";
	elseif StringManager.contains({"starship"}, sTypeLower) then
		sIcon = "starship";
	elseif StringManager.contains({"vehicle template"}, sTypeLower) then
		sIcon = "vehicleuprade";
	elseif StringManager.contains({"vehicle"}, sTypeLower) then
		sIcon = "vehicle";
	elseif StringManager.contains({"weapon template"}, sTypeLower) then
		sIcon = "weaponupgrade";
	elseif StringManager.contains({"weapon"}, sTypeLower) then
		sIcon = "weapon";
	end
		
	return sIcon;
end

function getCompatibilityType(node)
	local sTypeLower = DB.getValue(node, "type", ""):lower();
	local sSubTypeLower = DB.getValue(node, "subtype", ""):lower();
	local sSchoolLower = DB.getValue(node, "school", ""):lower();
	local sType = "";	
	if StringManager.contains({"armor"}, sTypeLower) or StringManager.contains({"armor template"}, sTypeLower) then
		sType =  "armor";
	elseif StringManager.contains({"powered armor"}, sTypeLower) then
		sType =  "poweredarmor";
	elseif StringManager.contains({"magic"}, sTypeLower) or StringManager.contains({"magic item"}, sSubTypeLower) or sSchoolLower ~= "" then
		sType =  "magicitem";
	elseif StringManager.contains({"starship"}, sTypeLower) or StringManager.contains({"starship template"}, sTypeLower) then
		sType =  "starship";
	elseif StringManager.contains({"vehicle"}, sTypeLower) or StringManager.contains({"vehicle template"}, sTypeLower) then
		sType =  "vehicle";
	elseif StringManager.contains({"weapon"}, sTypeLower) or StringManager.contains({"weapon template"}, sTypeLower) then
		sType =  "weapon";
	end
	
	return sType;
end

function isCompatible()
	local sCompatibilityType = nil;
	
	-- Check to make sure templates are all the same type
	for _,v in ipairs(templates) do
		local sTemplateCompatibilityType = getCompatibilityType(v);
		
		
		if sCompatibilityType then
			if (sCompatibilityType ~= sTemplateCompatibilityType) then
				return false;
			end
		else
			sCompatibilityType = sTemplateCompatibilityType;
		end
	end
	if not sCompatibilityType then
		return false;
	end
	
	
	-- Check to make sure items are compatible type to the templates
	for _,v in ipairs(items) do
		if sCompatibilityType ~= getCompatibilityType(v) then
			return false;
		end
	end
	
	return true;
end

function createForgedItem()
	if (#templates == 0) or ((#items == 0) and (#templates < 2)) then
		return;
	end

	-- Make sure we have at least one base item, or make the first template into a base item
	local bAllTemplates = false;
	if #items == 0 then
		bAllTemplates = true;
		table.insert(items, templates[1]);
		table.remove(templates, 1);
	end

	-- Cycle through each base item to apply templates
	for _,v in ipairs(items) do
		local rForgedItem = getItemStats(v);
		if bAllTemplates then
			rForgedItem.isTemplate = true;
		end
			
		if StringManager.contains({"armor", "weapon"}, rForgedItem.sType:lower()) then
			rForgedItem.sName = rForgedItem.sName:gsub("%,?%s%+%d+$", "");
		end
		
		for x,y in ipairs(templates) do
			local rTemplate = getItemStats(y);

			local sTemplateNameLower = rTemplate.sName:lower();
			local sTemplateTypeLower = rTemplate.sType:lower();
			local sTemplateSubTypeLower = rTemplate.sSubType:lower();
								
			if sTemplateTypeLower == "armor" or  sTemplateTypeLower == "weapon" then
				rTemplate.sName = rTemplate.sName:gsub("%,?%s%+%d+$", "");
			end
			
			-- Inherit from template when fields empty
			if rForgedItem.sType == "" then
				rForgedItem.sType = rTemplate.sType;
			end
			if rForgedItem.sSubType == "" then	
                rForgedItem.sSubType = rTemplate.sSubType;
			end
		
			if sTemplateTypeLower == "armor template" or sTemplateTypeLower == "weapon template" then
				if sTemplateTypeLower == "weapon template" then
					if (rForgedItem.sDamage or "") == "" then
						rForgedItem.sDamage = rTemplate.sDamage;
					end
					if (rForgedItem.sCritical or "") == "" then
						rForgedItem.sCritical = rTemplate.sCritical;
					end
					if (rForgedItem.sSpecial or "") == "" then
						rForgedItem.sSpecial = rTemplate.sSpecial;
					end
					if (rForgedItem.nCharges or 0) == 0 then
						rForgedItem.nCharges = rTemplate.nCharges;
					end	
				end
				if sTemplateTypeLower == "armor template" then
					rForgedItem.nAC = math.max(rForgedItem.nAC or 0, rTemplate.nAC or 0);
					if (rForgedItem.sDexBonus or "") == "" then
						rForgedItem.sDexBonus = rTemplate.sDexBonus;
					end
					if (rForgedItem.sStealth or "") == "" then
						rForgedItem.sStealth = rTemplate.sStealth;
					end
				end
			
				local aProperties = {};
				if rForgedItem.sProperties and rForgedItem.sProperties ~= "" then
					table.insert(aProperties, rForgedItem.sProperties);
				end
				if rTemplate.sProperties and rTemplate.sProperties ~= "" then
					table.insert(aProperties, rTemplate.sProperties);
				end
				if sTemplateSubTypeLower == "weapon fusion" then
					table.insert(aProperties, rTemplate.sName:lower());	
				end
				rForgedItem.sProperties = table.concat(aProperties, ", ");
			end
		               
			-- Bonus Adjustment
			if StringManager.contains({"armor", "weapon", "rod", "staff", "wand"}, rForgedItem.sType:lower()) then
				rForgedItem.nBonus = (rForgedItem.nBonus or 0) + (rTemplate.nBonus or 0);
			end
			
			-- Name Adjustment
			if rForgedItem.sName == "" then
				rForgedItem.sName = rTemplate.sName;
			else
				-- Calculate new name
				local sNewName = nil;
				if sTemplateTypeLower == "weapon" then
					if sTemplateNameLower:match("weapon") then
						sNewName = rTemplate.sName:gsub("[wW]eapon", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("ammunition") then
						sNewName = rTemplate.sName:gsub("[aA]mmunition", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("arrow") then
						sNewName = rTemplate.sName:gsub("[aA]rrow", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("axe") then
						sNewName = rTemplate.sName:gsub("[aA]xe", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("dagger") then
						sNewName = rTemplate.sName:gsub("[dD]agger", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("hammer") then
						sNewName = rTemplate.sName:gsub("[hH]ammer", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("javelin") then
						sNewName = rTemplate.sName:gsub("[jJ]avelin", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("mace") then
						sNewName = rTemplate.sName:gsub("[mM]ace", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("scimitar") then
						sNewName = rTemplate.sName:gsub("[sS]cimitar", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("sword") then
						sNewName = rTemplate.sName:gsub("[sS]word", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("trident") then
						sNewName = rTemplate.sName:gsub("[tT]rident", rForgedItem.sName, 1);
					end
				elseif sTemplateTypeLower == "armor" then
					if sTemplateNameLower:match("armor") then
						if rForgedItem.sName:lower():match("armor") then
							sNewName = rTemplate.sName:gsub("[aA]rmor", rForgedItem.sName, 1);
						elseif rForgedItem.sName:lower():match("shield") then
							sNewName = rTemplate.sName:gsub("[aA]rmor", rForgedItem.sName, 1);
						else
							if rForgedItem.sSubType:lower() == "shield" then
								sNewName = rTemplate.sName:gsub("[aA]rmor", rForgedItem.sName .. " Shield", 1);
							else
								sNewName = rTemplate.sName:gsub("[aA]rmor", rForgedItem.sName .. " Armor", 1);
							end
						end
					elseif sTemplateNameLower:match("shield") then
						if rForgedItem.sName:lower():match("armor") then
							sNewName = rTemplate.sName:gsub("[sS]hield", rForgedItem.sName, 1);
						elseif rForgedItem.sName:lower():match("shield") then
							sNewName = rTemplate.sName:gsub("[sS]hield", rForgedItem.sName, 1);
						else
							if rForgedItem.sSubType:lower() == "shield" then
								sNewName = rTemplate.sName:gsub("[sS]hield", rForgedItem.sName .. " Shield", 1);
							else
								sNewName = rTemplate.sName:gsub("[sS]hield", rForgedItem.sName .. " Armor", 1);
							end
						end
					end
				elseif sTemplateTypeLower == "potion" then
					if sTemplateNameLower:match("elixir") then
						sNewName = rTemplate.sName:gsub("[eE]lixir", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("oil") then
						sNewName = rTemplate.sName:gsub("[oO]il", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("philter") then
						sNewName = rTemplate.sName:gsub("[pP]hilter", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("potion") then
						sNewName = rTemplate.sName:gsub("[pP]otion", rForgedItem.sName, 1);
					end
				elseif sTemplateTypeLower == "ring" then
					if sTemplateNameLower:match("ring") then
						sNewName = rTemplate.sName:gsub("[rR]ing", rForgedItem.sName, 1);
					end
				elseif StringManager.contains({"rod", "staff", "wand"}, sTemplateTypeLower) then
					if sTemplateNameLower:match("rod") then
						sNewName = rTemplate.sName:gsub("[rR]od", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("staff") then
						sNewName = rTemplate.sName:gsub("[sS]taff", rForgedItem.sName, 1);
					elseif sTemplateNameLower:match("wand") then
						sNewName = rTemplate.sName:gsub("[wW]and", rForgedItem.sName, 1);
					end
				elseif sTemplateTypeLower == "scroll" then
					if sTemplateNameLower:match("scroll") then
						sNewName = rTemplate.sName:gsub("[sS]croll", rForgedItem.sName, 1);
					end
				elseif sTemplateTypeLower == "wondrous item" then
					local nStartOf = rTemplate.sName:find(" [oO]f ");
					if nStartOf then
						sNewName = rForgedItem.sName .. rTemplate.sName:sub(nStartOf);
					end
				end
				if sNewName then
					rForgedItem.sName = sNewName;
					
					local _,nEndOf = rForgedItem.sName:find(" [oO]f ");
					if nEndOf then
						rForgedItem.sName = rForgedItem.sName:sub(1, nEndOf) .. rForgedItem.sName:sub(nEndOf + 1):gsub(" [oO]f ", " and ");
					end
				else
					if not rForgedItem.sName:match(rTemplate.sName) then
						if rTemplate.sName:match(rForgedItem.sName) then
							rForgedItem.sName = rTemplate.sName;
						else
							rForgedItem.sName = rForgedItem.sName .. " [" .. rTemplate.sName .. "]";
						end
					end
				end

				local aParens = {};
				for sParens in rForgedItem.sName:gmatch(" (%[[^%]]+%])") do
					table.insert(aParens, sParens);
				end
				if #aParens > 0 then
					rForgedItem.sName = rForgedItem.sName:gsub(" %[[^%]]+%]", "") .. " " .. table.concat(aParens, " ");
				end
			end
		
			-- Description Adjustment
			if rForgedItem.sDescription == "" then
				rForgedItem.sDescription = rTemplate.sDescription;
			else
				if sTemplateTypeLower == "scroll" then
					if rTemplate.sSpells ~= "" then
						local aSpells = StringManager.split(rTemplate.sSpells, ";", true);
						for _,sSpellEntry in pairs(aSpells) do 
							local sSpellName, sSpellRecord = sSpellEntry:match("(.*),(.*)");
							local sSpellLink = [[<link class="reference_spell" recordname="]] .. sSpellRecord .. [[">Spell: ]] .. sSpellName .. [[</link>]];
							rForgedItem.sDescription = rForgedItem.sDescription:gsub("<h>Description</h>", "<h>Description</h>" .. sSpellLink);
						end
					end
				else
					rForgedItem.sDescription = rForgedItem.sDescription .. "<p><b>" .. rTemplate.sName .. " Notes</b></p>" .. rTemplate.sDescription:gsub("%<h%>Description%<%/h%>", "");
				end
			end
		end
		
		if StringManager.contains({"armor", "weapon", "rod", "staff", "wand"}, rForgedItem.sType:lower()) then
			if rForgedItem.nBonus and rForgedItem.nBonus ~= 0 then
				rForgedItem.sName = rForgedItem.sName .. ", +" .. rForgedItem.nBonus;
			end
		end
		
		-- Now that we've built the item, add it to the campaign
		addForgedItemToCampaign(rForgedItem);		
	end
end

function getItemDescBonus(sDesc)
	local sDescLower = (sDesc or ""):lower();
	
	local sBonus = sDescLower:match("%+(%d+)%sbonus%sto%sattack");
	if not sBonus then
		sBonus = sDescLower:match("%+(%d+)%sbonus%sto%sthe%sattack");
	end
	if not sBonus then
		sBonus = sDescLower:match("%+(%d+)%sbonus%sto%sac");
	end
	
	return tonumber(sBonus) or 0;
end

-- rItemRecord
-- 		sName
-- 		sNonIDName
-- 		sNonIDNotes
--		sType
--		sSubType
--		sCategory
-- 		nLevel;
-- 		sPrice;
-- 		sBulk;
-- 		sItemSize;
--		sDescription;
--		nAC
--		nHardness
--		nHP
--		sDescription
--		nEACBonus
--		nKACBonus
--		nACPenalty
-- 		sDexBonus
-- 		sSpeedAdj
-- 		sStrength
-- 		nStrengthEnc
-- 		sSize
-- 		nUpgradeSlots
-- 		nWeaponSlots
-- 		sHands
-- 		sDamage
-- 		sCritical
-- 		sSpecial
-- 		sRange
-- 		sCapacity
-- 		sUsage
--		nCharges 
-- 		sProperties
--		sSpells;

function getItemStats(node)
	local rItemRecord = {};
		
	rItemRecord.sName = StringManager.trim(DB.getValue(node, "name", ""));
	rItemRecord.sNonIDName = StringManager.trim(DB.getValue(node, "nonid_name", ""));
	rItemRecord.sNonIDNotes = StringManager.trim(DB.getValue(node, "nonid_notes", ""));
	rItemRecord.sType = StringManager.trim(DB.getValue(node, "type", ""));
	rItemRecord.sSubType = StringManager.trim(DB.getValue(node, "subtype", ""));
	rItemRecord.sCategory = StringManager.trim(DB.getValue(node, "category", ""));
	rItemRecord.nLevel = DB.getValue(node, "level", 0);
	rItemRecord.sCategory = DB.getValue(node, "category", "");
	rItemRecord.sPrice = DB.getValue(node, "price", "");
	rItemRecord.sBulk = DB.getValue(node, "bulk", "");
	rItemRecord.sItemSize = DB.getValue(node, "itemsize", "");
	rItemRecord.nAC = DB.getValue(node, "ac", 0);
	rItemRecord.nHardness = DB.getValue(node, "hardness", 0);
	rItemRecord.nHP = DB.getValue(node, "hp", 0);
	rItemRecord.sDescription = DB.getValue(node, "description", "");
	
	local aSpells = {};
	for _,v in pairs(DB.getChildren(node, "spells")) do
		local _, sRecord = DB.getValue(v, "link", "", "");
		table.insert(aSpells, DB.getValue(v, "name", "") .. "," .. sRecord);
	end
	if #aSpells > 0 then
		rItemRecord.sSpells = table.concat(aSpells, ";");
	end

	local sTypeLower = StringManager.trim(rItemRecord.sType:lower());
	if sTypeLower == "armor" then
		rItemRecord.nEACBonus = DB.getValue(node, "eacbonus", 0);
		rItemRecord.nKACBonus = DB.getValue(node, "kacbonus", 0);
		rItemRecord.nACPenaly = DB.getValue(node, "acpenalty", 0);
		rItemRecord.sDexBonus = DB.getValue(node, "maxdexbonus", "");
		rItemRecord.sSpeedAdj = DB.getValue(node, "speedadj", "");
		rItemRecord.sStrength = DB.getValue(node, "strength", "");
		rItemRecord.nStrengthEnc = DB.getValue(node, "strength_enc", 0);
		rItemRecord.sSize = DB.getValue(node, "size", "");
		rItemRecord.nUpgradeSlots = DB.getValue(node, "upgradeslots", 0);
		rItemRecord.nWeaponSlots = DB.getValue(node, "weaponslots", 0);		
	elseif sTypeLower == "weapon" then
		rItemRecord.sHands = DB.getValue(node, "hands", "");
		rItemRecord.sDamage = DB.getValue(node, "damage", "");
		rItemRecord.sCritical = DB.getValue(node, "critical", "");
		rItemRecord.sSpecial = DB.getValue(node, "special", "");
		rItemRecord.sStrength = DB.getValue(node, "strength", "");
		rItemRecord.sRange = DB.getValue(node, "range", "");
		rItemRecord.sUsage = DB.getValue(node, "usage", "");
		rItemRecord.sCapacity = DB.getValue(node, "capacity", "");
		rItemRecord.sUsage = DB.getValue(node, "usage", "");
		rItemRecord.nCharges = DB.getValue(node, "charges", 0);
		rItemRecord.sProperties = DB.getValue(node, "properties", "");
	elseif StringManager.contains({"rod", "staff", "wand"}, sTypeLower) then
		rItemRecord.nBonus = DB.getValue(node, "bonus", 0);
	end
	
	-- Calculate the template bonus from the name and description, and check whether it matches bonus field
	if StringManager.contains({"armor", "weapon", "rod", "staff", "wand"}, sTypeLower) then
		if rItemRecord.nBonus == 0 then
			local nTemplateNameBonus = tonumber(rItemRecord.sName:match("%,?%s%+(%d+)$")) or 0;
			if nTemplateNameBonus ~= 0 then
				rItemRecord.nBonus = nTemplateNameBonus;
			else
				rItemRecord.nBonus = getItemDescBonus(rItemRecord.sDescription);
			end
		end
	end

	return rItemRecord;
end

function addForgedItemToCampaign(rForgedItem)
	local nodeTarget;
	if rForgedItem.isTemplate then
		nodeTarget = DB.createdChild("itemtemplate");
	else
		nodeTarget = DB.createChild("item");
	end
	
	DB.setValue(nodeTarget, "locked", "number", 1);
	DB.setValue(nodeTarget, "name", "string", rForgedItem.sName);
	DB.setValue(nodeTarget, "nonidname", "string", rForgedItem.sNonIDName);
	DB.setValue(nodeTarget, "nonidnotes", "string", rForgedItem.sNonIDNotes);
	DB.setValue(nodeTarget, "type", "string", rForgedItem.sType);
	DB.setValue(nodeTarget, "subtype", "string", rForgedItem.sSubType);
	DB.setValue(nodeTarget, "level", "number", rForgedItem.nLevel);
	DB.setValue(nodeTarget, "bulk", "string", rForgedItem.sBulk);
	DB.setValue(nodeTarget, "price", "string", rForgedItem.sPrice);
	DB.setValue(nodeTarget, "itemsize", "string", rForgedItem.sItemSize);
	DB.setValue(nodeTarget, "ac", "number", rForgedItem.nAC);
	DB.setValue(nodeTarget, "hardness", "number", rForgedItem.nHardness);
	DB.setValue(nodeTarget, "hp", "number", rForgedItem.nHP);
	DB.setValue(nodeTarget, "description", "formattedtext", rForgedItem.sDescription);
	
	local sTypeLower = rForgedItem.sType:lower();
	if sTypeLower == "armor" then
		DB.setValue(nodeTarget, "eacbonus", "number", rForgedItem.nEACBonus);
		DB.setValue(nodeTarget, "kacbonus", "number", rForgedItem.nKACBonus);
		DB.setValue(nodeTarget, "acpenalty", "number", rForgedItem.nACPenalty);
		DB.setValue(nodeTarget, "maxdexbonus", "string", rForgedItem.sDexBonus);
		DB.setValue(nodeTarget, "speedadj", "string", rForgedItem.sSpeedAdj);
		DB.setValue(nodeTarget, "strength", "string", rForgedItem.sStrength);
		DB.setValue(nodeTarget, "strength_enc", "number", rForgedItem.nStrengthEnc);
		DB.setValue(nodeTarget, "size", "string", rForgedItem.sSize);
		DB.setValue(nodeTarget, "upgradeslots", "number", rForgedItem.sUpgradeSlots);
		DB.setValue(nodeTarget, "weaponslots", "number", rForgedItem.sWeaponSlots);
	elseif sTypeLower == "weapon" then
		DB.setValue(nodeTarget, "hands", "string", rForgedItem.sHands);
		DB.setValue(nodeTarget, "damage", "string", rForgedItem.sDamage);
		DB.setValue(nodeTarget, "critical", "string", rForgedItem.sCritical);
		DB.setValue(nodeTarget, "special", "string", rForgedItem.sSpecial);
		DB.setValue(nodeTarget, "range", "string", rForgedItem.sRange);
		DB.setValue(nodeTarget, "capacity", "string", rForgedItem.sCapacity);
		DB.setValue(nodeTarget, "usage", "string", rForgedItem.sUsage);
		DB.setValue(nodeTarget, "charges", "number", rForgedItem.nCharges);
		DB.setValue(nodeTarget, "properties", "string", rForgedItem.sProperties);
	end
	
	if rForgedItem.isTemplate then
		Interface.openWindow("itemtemplate", nodeTarget);
	else
		Interface.openWindow("item", nodeTarget);
	end
end
