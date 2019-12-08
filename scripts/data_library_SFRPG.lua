--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
-- RECORD TYPE FORMAT
-- 		["recordtype"] = { 
-- 			aDataMap = <table of strings>, (required)
-- 			aDisplayIcon = <table of 2 strings>, (required)
--
--			bExport = <bool>, (optional)
--			nExport = <number>, (optional; overriden by bExport)
--			bExportNoReadOnly = <bool>, (optional; overrides bExport)
--			sExportPath = <string>, (optional)
--			bExportListSkip = <bool>, (optional)
--			sExportListDisplayClass = <string>, (optional)
--
-- 			bHidden = <bool>, (optional)
-- 			bID = <bool>, (optional)
--			bNoCategories = <bool>, (optional)
--
-- 			sListDisplayClass = <string>, (optional)
-- 			sRecordDisplayClass = <string>, (optional)
--			aRecordDisplayCLasses = <table of strings>, (optional; overrides sRecordDisplayClass)
--			fRecordDisplayClass = <function>, (optional; overrides sRecordDisplayClass)
--			fGetLink = <function>, (optional)
--
--			aGMListButtons = <table of template names>, (optional)
--			aPlayerListButtons = <table of template names>, (optional)
--
--			aCustomFilters = <table of custom filter table records>, (optional)
-- 		},
--

-- FIELDS ADDED FROM STRING DATA
-- 		sDisplayText = Interface.getString(library_recordtype_label_ .. sRecordType)
-- 		sEmptyNameText = Interface.getString(library_recordtype_empty_ .. sRecordType)
-- FIELDS ADDED FROM STRING DATA (only when bID set)
-- 		sEmptyUnidentifiedNameText = Interface.getString(library_recordtype_empty_nonid_ .. sRecordType)
--

-- RECORD TYPE LEGEND
--		aDataMap = Required. Table of strings. defining the valid data paths for records of this type
--			NOTE: For bExport/nExport, that number of data paths from the beginning of the data map list will be used as the source for exporting 
--				and the target data paths will be the same in the module. (i.e. default campaign data paths, editable).
--				The next nExport data paths in the data map list will be used as the export target data paths for read-only data paths for the 
--				matching source data path.
--			EX: { "item", "armor", "weapon", "reference.items", "reference.armors", "reference.weapons" } with a nExport of 3 would mean that
--				the "item", "armor" and "weapon" data paths would be exported to the matching "item", "armor" and "weapon" data paths in the module by default.
--				If the reference data path option is selected, then "item", "armor" and "weapon" data paths would be exported to 
--				"reference.items", "reference.armors", and "reference.weapons", respectively.
--		aDisplayIcon = Required. Table of strings. Provides icon resource names for sidebar/library buttons for this record type (normal and pressed icon resources)
--
--		bExport = Optional. Same as nExport = 1. Boolean indicating whether record should be exportable in the library export window for the record type.
--		nExport = Optional. Overriden by bExport. Number indicating number of data paths which are exportable in the library export window for the record type.
--			NOTE: See aDataMap for bExport/nExport are handled for target campaign data paths vs. reference data paths (editable vs. read-only)
--		bExportNoReadOnly = Optional. Similar to bExport. Boolean indicating whether record should be exportable in the library export window for the record type, but read only option in export is ignored.
--		sExportPath = Optional. When exporting records to a module, use this alternate data path when storing into a module, instead of the base data path for this record.
--		sExportListDisplayClass = Optional. When exporting records, the list link created for records to be accessed from the library will use this display class. (Default is reference_list)
--		bExportListSkip = Optional. When exporting records, a list link is normally created for the records to be accessed from the library. This option skips creation of the list and link.
--
--		bHidden = Optional. Boolean indicating whether record should be displayed in library, and sidebar options.
-- 		bID = Optional. Boolean indicating whether record is identifiable or not (currently only items and images)
--		bNoCategories = Optional. Disable display and usage of category information.
--		sEditMode = Optional. Valid values are "play" or "none".  If "play" specified, then both players and GMs can add/remove records of this record type. Note, players can only remove records they have created. If "none" specified, then neither player nor GM can add/remove records. If not specified, then only GM can add/remove records.
--			NOTE: The character selection dialog handles this in the custom character selection window class historically, so does not use this option.
--
--		sListDisplayClass = Optional. String. Class to use when displaying this record in a list. If not defined, a default class will be used.
--		sRecordDisplayClass = Optional. String. Class to use when displaying this record in detail. (Defaults to record type key string) 
--		aRecordDisplayClasses = Optional. Table of strings. List of valid display classes for records of this type. Use fRecordDisplayClass to specify which one to use for a given path.
--		fRecordDisplayClass = Optional. Function. Function called when requesting to display this record in detail.
--		fGetLink = Optional. Function. Function called to determine window class and data path to use when pressing or dragging sidebar button.
--
--		aGMListButtons = Optional. Table of template names. A list of control templates created and added to the master list window for this record type in GM mode.
--		aPlayerListButtons = Optional. Table of template names. A list of control templates created and added to the master list window for this record type in Player mode.
--
--		aCustomFilters = Optional. Table of custom filter table records.  Key = Label string to display for filter; 
--			Filter table record format is:
--				sField = Required. String. Child data node that contains data to use to build filter value list; and to apply filter to.
--				fGetValue = Optional. Function. Returns string or table of strings containing filter value(s) for the record passed as parameter to the function.
--				sType = Optional. String. Valid values are: "boolean", "number".  
--					NOTE: If no type specified, string is assumed. If empty string value returned, then the string resource (library_recordtype_filter_empty) will be used for display if available.
--					NOTE 2: For boolean type, these string resources will be used for labels (library_recordtype_filter_yes, library_recordtype_filter_no).
--
--		sDisplayText = Required. String Resource. Text displayed in library and tooltips to identify record type textually.
--		sEmptyNameText = Optional. String Resource. Text displayed in name field of record list and detail classes, when name is empty.
--		sEmptyUnidentifiedNameText = Optional. String Resource. Text displayed in nonid_name field of record list and detail classes, when nonid_name is empty. Only used if bID flag set.
--

function getCRGroupedList(v)
	local nOutput = v
	if v > 0 then
		if v < 0.14 then
			nOutput = "1/8"
		elseif v < 0.2 then
			nOutput = "1/6"
		elseif v < 0.3 then
			nOutput = "1/4"
		elseif v < 0.4 then
			nOutput = "1/3"
		elseif v < 1 then
			nOutput = "1/2"
		end
	end
	return tostring(nOutput)
end

function getCRGroup(v)
	local nOutput = v
	if v > 0 then
		if v < 0.14 then
			nOutput = 0.125
		elseif v < 0.2 then
			nOutput = 0.166
		elseif v < 0.3 then
			nOutput = 0.25
		elseif v < 0.4 then
			nOutput = 0.33
		elseif v < 1 then
			nOutput = 0.5
		end
	end
	return tostring(nOutput)
end

function getNPCCRValue(vNode)
	return getCRGroup(DB.getValue(vNode, "cr", 0))
end

function getTypeGroup(v)
	local sOutput = ""
	local sCreatureType = StringManager.trim(v):lower()
	for _, sListCreatureType in ipairs(DataCommon.creaturetype) do
		if sCreatureType:match(sListCreatureType) then
			sOutput = StringManager.capitalize(sListCreatureType)
			break
		end
	end
	return sOutput
end

function getNPCTypeValue(vNode)
	return getTypeGroup(DB.getValue(vNode, "type", ""))
end

function getRaceTypeValue(vNode)
	return getRaceTypeGroup(DB.getValue(vNode, "racetype", ""))
end
function getRaceTypeGroup(v)
	local sOutput = ""
	local sRaceType = StringManager.trim(v):lower()
	for _, sListRaceType in ipairs(DataCommon.racetype) do
		if sRaceType:match(sListRaceType) then
			sOutput = StringManager.capitalize(sListRaceType)
			break
		end
	end
	return sOutput
end

function getItemIsIdentified(vRecord, vDefault)
	return LibraryData.getIDState("item", vRecord, true)
end

function isItemIdentifiable(vNode)
	local sBasePath,
		sSecondPath = UtilityManager.getDataBaseNodePathSplit(vNode)
	if sBasePath == "reference" then
		return false
	end
	return true
end

function getSpellSchoolValue(vNode)
	local v = StringManager.trim(DB.getValue(vNode, "school", ""))
	local sType = v:match("^%w+")
	if sType then
		v = StringManager.trim(sType)
	end
	v = StringManager.capitalize(v)
	return v
end

function getSpellLevelValue(vNode)
	return DB.getValue(vNode, "level", "") .. ""
end

function getSpellSourceValue(vNode)
	return DB.getValue(vNode, "source", "") .. ""
end

aRecordOverrides = {
	-- CoreRPG overrides
	["image"] = {
		aDataMap = {"image", "reference.imagedata", "reference.image"}
	},
	["npc"] = {
		aDataMap = {"npc", "reference.npc", "reference.trap"},
		aGMListButtons = {"button_npc_letter", "button_npc_cr", "button_npc_type", "button_npc_trap"},
		aCustomFilters = {
			["CR"] = {sField = "cr", sType = "number", fGetValue = getNPCCRValue},
			["Type"] = {sField = "type", fGetValue = getNPCTypeValue},
			["Record"] = {sField = "npctype"}
		}
	},
	["item"] = {
		fIsIdentifiable = isItemIdentifiable,
		aDataMap = {"item", "reference.armor", "reference.augmentation", "reference.computer", "reference.item", "reference.magicitem", "reference.weapon"},
		aGMListButtons = {"button_item_armor", "button_item_weapons", "button_item_templates"},
		aPlayerListButtons = {"button_item_armor", "button_item_weapons", "button_item_templates"},
		aCustomFilters = {
			["1-Type"] = {sField = "type"},
			["2-SubType"] = {sField = "subtype"},
			["3-Category"] = {sField = "category"},
			["4-Hands"] = {sField = "hands"}
		}
	},
	["vehicle"] = {
		aDataMap = {"vehicle", "reference.vehicle"}
	},
	["charsheet"] = {
		sExportPath = "pregencharsheet",
		sExportListClass = "pregencharselect",
		aDataMap = {"charsheet"},
		aDisplayIcon = {"button_characters", "button_characters_down"},
		fGetLink = getCharListLink
		-- sRecordDisplayClass = "charsheet",
	},
	-- New record types
	["archetype"] = {
		bExport = true,
		bHidden = false,
		aDataMap = {"archetype", "reference.archetype"},
		aDisplayIcon = {"button_archetypes", "button_archetypes_down"}
	},
	["boon"] = {
		bExport = true,
		aDataMap = {"boon", "reference.boon"},
		aDisplayIcon = {"button_boons", "button_boons_down"}
	},
	["charstarshipsheet"] = {
		bExport = true,
		sEditMode = "play",
		aDataMap = {"charstarshipsheet"},
		fToggleIndex = toggleCharRecordIndex,
		aDisplayIcon = {"button_charstarships", "button_charstarships_down"}
	},

	["companionsheet"] = {
		bExport = true,
		--sEditMode = "play",
		bHidden = true,		
		aDataMap = {"companionsheet", "reference.companionsheet"},
		fToggleIndex = toggleCharRecordIndex
		--sRecordDisplayClass = "companionsheet",
	},
	["class"] = {
		bExport = true,
		aDataMap = {"class", "reference.class"},
		aDisplayIcon = {"button_classes", "button_classes_down"},
		aGMListButtons = {"button_update_class", "button_archetypes"},
		aPlayerListButtons = {"button_archetypes"}
	},
	["feat"] = {
		bExport = true,
		aDataMap = {"feat", "reference.feat"},
		aDisplayIcon = {"button_feats", "button_feats_down"}
	},
	["itemtemplate"] = {
		bExport = true,
		bHidden = true,
		aDataMap = {"itemtemplate", "reference.itemtemplate"},
		aDisplayIcon = {"button_items", "button_items_down"},
		aGMListButtons = {"button_forge_item"},
		aCustomFilters = {
			["Type"] = {sField = "type"}
		}
	},
	["race"] = {
		bExport = true,		
		aDataMap = {"race", "reference.race"},
		aDisplayIcon = {"button_races", "button_races_down"},
		aGMListButtons = {"button_companion_letter"},
		aPlayerListButtons = {"button_companion_letter"},
		--sExportPath = {"reference.race"},
		---aDisplayIcon = {"button_races", "button_races_down"},		
		---aGMListButtons = {"button_companion_letter"},
		---aPlayerListButtons = {"button_companion_letter"},
		
		--aGMListButtons = {"button_race_letter", "button_companion_letter"},
		--aPlayerListButtons = {"button_race_letter", "button_companion_letter"},

		aCustomFilters = {
			["Type"] = {sField = "type"},
			["Race Type"] = {sField = "racetype"},			
		}
	},
	["companionsheet"] = {
		bExport = true,
		--sEditMode = "play",
		bHidden = true,		
		aDataMap = {"companionsheet", "reference.companionsheet"},
		fToggleIndex = toggleCharRecordIndex
		--sRecordDisplayClass = "companionsheet",
	},
	["skill"] = {
		bExport = true,
		aDataMap = {"skill", "reference.skill"},
		aDisplayIcon = {"button_skills", "button_skills_down"}
	},
	["spell"] = {
		bExport = true,
		aDataMap = {"spell", "reference.spell"},
		aDisplayIcon = {"button_spells", "button_spells_down"},
		sRecordDisplayClass = "spelldesc",
		aGMListButtons = {"button_spell_class", "button_spell_school", "button_spell_level"},
		aPlayerListButtons = {"button_spell_class", "button_spell_school", "button_spell_level"},
		aCustomFilters = {
			["Class"] = {sField = "source", fGetValue = getSpellSourceValue},
			["School"] = {sField = "school", fGetValue = getSpellSchoolValue},
			["Level"] = {sField = "level", fGetValue = getSpellLevelValue}
		}
	},
	["starship"] = {
		bExport = true,
		aDataMap = {"starship", "reference.starship"},
		aDisplayIcon = {"button_starships", "button_starships_down"},
		aCustomFilters = {
			["Type"] = {sField = "type"}
		}
	},
	["starshipitem"] = {
		bExport = true,
		bID = true,
		aDataMap = {"starshipitem", "reference.starshipitem", "reference.starshipshield", "reference.starshipweapon"},
		aDisplayIcon = {"button_starshipitems", "button_starshipitems_down"},
		sListDisplayClass = "masterindexitem_id",
		fIsIdentifiable = isItemIdentifiable,
		aGMListButtons = {"button_starshipitem_shields", "button_starshipitem_weapons"},
		aPlayerListButtons = {"button_starshipitem_shields", "button_starshipitem_weapons"},
		aCustomFilters = {
			["Type"] = {sField = "type"},
			["SubType"] = {sField = "subtype"},
			["Category"] = {sField = "category"}
		}
	},
	["theme"] = {
		bExport = true,
		aDataMap = {"theme", "reference.theme"},
		aDisplayIcon = {"button_themes", "button_themes_down"},
		sRecordDisplayClass = "theme"
	},
	["classfeature"] = {
		bExport = true,
		aDataMap = {"classfeature"},
		aDisplayIcon = {"button_features", "button_features_down"},
		sRecordDisplayClass = "class_feature",
		aCustomFilters = {
			["Class"] = {sField = "class"},
			["Feature"] = {sField = "feature"},
			["Level"] = {sField = "level"}
		}
	},
	["classspecialfeature"] = {
		bExport = true,
		aDataMap = {"classspecialfeature"},
		aDisplayIcon = {"button_specialfeatures", "button_specialfeatures_down"},
		sRecordDisplayClass = "class_feature",
		aCustomFilters = {
			["Class"] = {sField = "class"},
			["Feature"] = {sField = "feature"},
			["Level"] = {sField = "level"}
		}
	}
}

aDefaultSidebarState = {
	["gm"] = "story,battle,image,item,npc,quest,starship,starshipitem,vehicle,table,treasureparcel,note,charsheet,charstarshipsheet",
	["play"] = "boon,charsheet,charstarshipsheet,item,starship,starshipitem,vehicle,story,npc,image,note",
	["create"] = "charsheet,class,race,theme,archetype,feat,skill,spell,item,,charstarshipsheet,starship,starshipitem,vehicle,boon"
}

aListViews = {
	["archetype"] = {
		["archetype"] = {
			sTitleRes = "archetype_grouped_title_archetypes",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "race_grouped_label_name", nWidth = 200}
			},
			aFilters = {},
			aGroups = {},
			aGroupValueOrder = {}
		}
	},
	["boon"] = {
		["boon"] = {
			sTitleRes = "boon_grouped_title_boons",
			aColumns = {},
			aFilters = {},
			aGroups = {},
			aGroupValueOrder = {}
		}
	},
	["class"] = {
		["class"] = {
			sTitleRes = "class_grouped_title_classes",
			aColumns = {},
			aFilters = {},
			aGroups = {},
			aGroupValueOrder = {}
		}
	},
	["npc"] = {
		["byletter"] = {
			sTitleRes = "npc_grouped_title_byletter",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "npc_grouped_label_name", nWidth = 250},
				{sName = "npctype", sType = "string", sHeadingRes = "npc_grouped_label_type", sTooltipRe = "npc_grouped_tooltip_type", bCentered = false},
				{sName = "cr", sType = "number", sHeadingRes = "npc_grouped_label_cr", sTooltipRe = "npc_grouped_tooltip_cr", bCentered = true}
			},
			aFilters = {},
			aGroups = {{sDBField = "name", nLength = 1}},
			aGroupValueOrder = {}
		},
		["bycr"] = {
			sTitleRes = "npc_grouped_title_bycr",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "npc_grouped_label_name", nWidth = 250},
				{sName = "npctype", sType = "string", sHeadingRes = "npc_grouped_label_type", sTooltipRe = "npc_grouped_tooltip_type", bCentered = false},
				{sName = "cr", sType = "number", sHeadingRes = "npc_grouped_label_cr", sTooltipRe = "npc_grouped_tooltip_cr", bCentered = true}
			},
			aFilters = {},
			aGroups = {{sDBField = "cr", sPrefix = "CR", sCustom = "npc_cr"}},
			aGroupValueOrder = {
				"CR 0",
				"CR 1/8",
				"CR 1/6",
				"CR 1/4",
				"CR 1/3",
				"CR 1/2",
				"CR 1",
				"CR 2",
				"CR 3",
				"CR 4",
				"CR 5",
				"CR 6",
				"CR 7",
				"CR 8",
				"CR 9"
			}
		},
		["bytype"] = {
			sTitleRes = "npc_grouped_title_bytype",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "npc_grouped_label_name", nWidth = 250},
				{sName = "npctype", sType = "string", sHeadingRes = "npc_grouped_label_type", sTooltipRe = "npc_grouped_tooltip_type", bCentered = false},
				{sName = "cr", sType = "number", sHeadingRes = "npc_grouped_label_cr", sTooltipRe = "npc_grouped_tooltip_cr", bCentered = true}
			},
			aFilters = {},
			aGroups = {{sDBField = "type"}},
			aGroupValueOrder = {}
		},
		["trap"] = {
			sTitleRes = "npc_grouped_title_traps",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "npc_grouped_label_name", nWidth = 250},
				{sName = "npctype", sType = "string", sHeadingRes = "npc_grouped_label_type", sTooltipRe = "npc_grouped_tooltip_type", bCentered = false},
				{sName = "cr", sType = "number", sHeadingRes = "npc_grouped_label_cr", sTooltipRe = "npc_grouped_tooltip_cr", bCentered = true}
			},
			aFilters = {
				{sDBField = "npctype", vFilterValue = "Trap"},
				{sCustom = "item_isidentified"}
			},
			aGroups = {{sDBField = "type"}},
			aGroupValueOrder = {}
		}
	},
	["item"] = {
		["augmentation"] = {
			sTitleRes = "item_grouped_title_augmentations",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "item_grouped_label_level",
					sTooltipRes = "item_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{sName = "price", sType = "string", sHeadingRes = "item_grouped_label_price", sTooltipRes = "item_grouped_label_price", nWidth = 50},
				{
					sName = "system",
					sType = "string",
					sHeadingRes = "item_grouped_label_system",
					sTooltipRes = "item_grouped_label_system",
					nWidth = 100,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Augmentation"},
				{sCustom = "item_isidentified"}
			},
			aGroups = {{sDBField = "subtype"}},
			aGroupValueOrder = {"BioTech", "Cybernetics", "Personal Upgrade"}
		},
		["armor"] = {
			sTitleRes = "item_grouped_title_armor",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "item_grouped_label_level",
					sTooltipRes = "item_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{sName = "price", sType = "string", sHeadingRes = "item_grouped_label_price", sTooltipRes = "item_grouped_label_price", nWidth = 50},
				{
					sName = "eacbonus",
					sType = "number",
					sHeadingRes = "item_grouped_label_eac",
					sTooltipRes = "item_grouped_tooltip_eac",
					nWidth = 30,
					bCentered = true
				},
				{
					sName = "kacbonus",
					sType = "number",
					sHeadingRes = "item_grouped_label_kac",
					sTooltipRes = "item_grouped_tooltip_kac",
					nWidth = 30,
					bCentered = true
				},
				{
					sName = "maxdexbonus",
					sType = "string",
					sHeadingRes = "item_grouped_label_maxdexbonus",
					sTooltipRes = "item_grouped_tooltip_maxdexbonus",
					bCentered = true
				},
				{
					sName = "acpenalty",
					sType = "number",
					sHeadingRes = "item_grouped_label_acpenalty",
					sTooltipRes = "item_grouped_tooltip_acpenalty",
					bCentered = true
				},
				{
					sName = "upgradeslots",
					sType = "number",
					sHeadingRes = "item_grouped_label_upgradeslots",
					sTooltipRes = "item_grouped_label_upgradeslots",
					bCentered = true
				},
				{
					sName = "bulk",
					sType = "string",
					sHeadingRes = "item_grouped_label_bulk",
					sTooltipRes = "item_grouped_label_bulk",
					nWidth = 30,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Armor"},
				{sCustom = "item_isidentified"}
			},
			aGroups = {{sDBField = "subtype"}},
			aGroupValueOrder = {"Light", "Heavy", "Powered", "Upgrade"}
		},
		["computer"] = {
			sTitleRes = "item_grouped_title_computers",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth = 200},
				{sName = "price", sType = "string", sHeadingRes = "item_grouped_label_price", sTooltipRes = "item_grouped_label_price", nWidth = 100}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Computer"},
				{sCustom = "item_isidentified"}
			},
			aGroups = {{sDBField = "subtype"}},
			aGroupValueOrder = {}
		},
		["weapon"] = {
			sTitleRes = "item_grouped_title_weapons",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "item_grouped_label_level",
					sTooltipRes = "item_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{sName = "price", sType = "string", sHeadingRes = "item_grouped_label_price", sTooltipRes = "item_grouped_label_price", nWidth = 50},
				{sName = "damage", sType = "string", sHeadingRes = "item_grouped_label_damage", nWidth = 60, bCentered = true},
				{sName = "critical", sType = "string", sHeadingRes = "item_grouped_label_critical", nWidth = 60, bCentered = true},
				{
					sName = "range",
					sType = "string",
					sHeadingRes = "item_grouped_label_range",
					sTooltipRes = "item_grouped_tooltip_range",
					nWidth = 60,
					bCentered = true
				},
				{
					sName = "capacity",
					sType = "string",
					sHeadingRes = "item_grouped_label_capacity",
					sTooltipRes = "item_grouped_label_capacity",
					nWidth = 60,
					bCentered = true
				},
				{
					sName = "usage",
					sType = "string",
					sHeadingRes = "item_grouped_label_charges",
					sTooltipRes = "item_grouped_label_capacity",
					nWidth = 60,
					bCentered = true
				},
				{
					sName = "bulk",
					sType = "string",
					sHeadingRes = "item_grouped_label_bulk",
					sTooltipRes = "item_grouped_label_bulk",
					nWidth = 30,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Weapon"},
				{sCustom = "item_isidentified"}
			},
			aGroups = {{sDBField = "subtype"}, {sDBField = "category"}},
			aGroupValueOrder = {"Melee Basic", "Melee Advanced", "Small Arms", "Long Arms"}
		},
		["item"] = {
			sTitleRes = "item_grouped_title_items",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "item_grouped_label_level",
					sTooltipRes = "item_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{sName = "price", sType = "string", sHeadingRes = "item_grouped_label_price", sTooltipRes = "item_grouped_label_price", nWidth = 100},
				{
					sName = "bulk",
					sType = "string",
					sHeadingRes = "item_grouped_label_bulk",
					sTooltipRes = "item_grouped_label_bulk",
					nWidth = 100,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Item"},
				{sCustom = "item_isidentified"}
			},
			aGroups = {{sDBField = "subtype"}, {sDBField = "category"}},
			aGroupValueOrder = {}
		}
	},
	["itemtemplate"] = {
		["itemtemplate"] = {
			sTitleRes = "itemtemplate_grouped_title_itemtemplates",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "item_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "item_grouped_label_level",
					sTooltipRes = "item_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{sName = "price", sType = "string", sHeadingRes = "item_grouped_label_price", sTooltipRes = "item_grouped_label_price", nWidth = 50},
				{
					sName = "bulk",
					sType = "string",
					sHeadingRes = "item_grouped_label_bulk",
					sTooltipRes = "item_grouped_label_bulk",
					nWidth = 100,
					bCentered = true
				}
			},
			aFilters = {},
			aGroups = {{sDBField = "type"}, {sDBField = "subtype"}},
			aGroupValueOrder = {}
		}
	},
	["race"] = {
		["race"] = {
			sTitleRes = "race_grouped_title_race",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "race_grouped_label_name", nWidth = 200},
				{sName = "racetype",
					sType = "string",
					sHeadingRes = "race_grouped_label_type",
					sTooltipRes = "race_grouped_label_type",
					nWidth = 100,
					bCentered = true
				},
				{sName = "subtype",
					sType = "string",
					sHeadingRes = "race_grouped_label_subtype",
					sTooltipRes = "race_grouped_label_subtype",
					nWidth = 100,
					bCentered = true
				},
				{sName = "size",
					sType = "string",
					sHeadingRes = "race_grouped_label_size",
					sTooltipRes = "race_grouped_label_size",
					nWidth = 60,
					bCentered = true
				}
			},
			aFilters = {},
			aGroups = {{sDBField = "rule"}},
			aGroupValueOrder = {}
		},
		["byletter"] = {
			sTitleRes = "race_groupedtitle_letter",
			aColumns = {
				{sName = "name",
					sType = "string",
					sHeadingRes = "race_grouped_label_name",
					nWidth = 100},
				{sName = "type",
					sType = "string",
					sHeadingRes = "race_grouped_label_type",
					sTooltipRes = "race_grouped_label_type",
					nWidth = 75,
					bCentered = true
				},
				{sName = "hp",
					sType = "number",
					sHeadingRes = "race_grouped_label_hp",
					sTooltipRes = "race_grouped_label_hp",
					nWidth = 25,
					bCentered = true},
				{sName = "abilitymodifiers.str.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_str",
					sTooltipRes = "race_grouped_label_str",
					nWidth = 25,
					bCentered = true
				},
				{sName = "abilitymodifiers.dex.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_dex",
					sTooltipRes = "race_grouped_label_dex",
					nWidth = 25,
					bCentered = true
				},
				{sName = "abilitymodifiers.con.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_con",
					sTooltipRes = "race_grouped_label_con",
					nWidth = 25,
					bCentered = true
				},
				{sName = "abilitymodifiers.int.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_int",
					sTooltipRes = "race_grouped_label_int",
					nWidth = 25,
					bCentered = true
				},
				{sName = "abilitymodifiers.wis.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_wis",
					sTooltipRes = "race_grouped_label_wis",
					nWidth = 25,
					bCentered = true
				},
				{sName = "abilitymodifiers.cha.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_cha",
					sTooltipRes = "race_grouped_label_cha",
					nWidth = 25,
					bCentered = true
				},
				{sName = "abilitymodifiers.toany1ability.mod",
					sType = "number",
					sHeadingRes = "race_grouped_label_any",
					sTooltipRes = "race_grouped_label_any",
					nWidth = 30,
					bCentered = true
				},
				{sName = "size",
					sType = "string",
					sHeadingRes = "race_grouped_label_size",
					sTooltipRes = "race_grouped_label_size",
					nWidth = 60,
					bCentered = true
				}
			},			
			aFilters = {
				{sDBField = "racetype", vFilterValue = "PC"}
			},
			aGroups = {{sDBField = "type"}},
			aGroupValueOrder = {}
		},
		["bycompanion"] = {
			sTitleRes = "race_groupedtitle_companion",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "race_grouped_label_name", nWidth = 100},
				{
					sName = "size",
					sType = "string",
					sHeadingRes = "race_grouped_label_size",
					sTooltipRes = "race_grouped_label_size",
					nWidth = 60,
					bCentered = true
				},
				{
					sName = "levelrange",
					sType = "string",
					sHeadingRes = "race_grouped_label_levelrange",
					sTooltipRes = "race_grouped_label_levelrange",
					nWidth = 75,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "racetype", vFilterValue = "Companion"}
			},
			aGroups = {{sDBField = "type"}},
			aGroupValueOrder = {}
		}
	},
	["skill"] = {
		["skill"] = {
			sTitleRes = "skill_grouped_title_skills",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "skill_grouped_label_name", nWidth = 200}
			},
			aFilters = {},
			aGroups = {{sDBField = "ability"}},
			aGroupValueOrder = {"STR", "DEX", "CON", "INT", "WIS", "CHA"}
		}
	},
	["spell"] = {
		["byclass"] = {
			sTitleRes = "spell_grouped_title_spellsbyclass",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "spell_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "spell_grouped_label_level",
					sTooltipRes = "spell_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{
					sName = "school",
					sType = "string",
					sHeadingRes = "spell_grouped_label_school",
					sTooltipRes = "spell_grouped_label_school",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "summary",
					sType = "formattedtext",
					sHeadingRes = "spell_grouped_label_summary",
					sTooltipRes = "spell_grouped_label_summary",
					nWidth = 300,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "sort", vFilterValue = "1"}
			},
			aGroups = {{sDBField = "source"}},
			aGroupValueOrder = {"Mystic", "Technomancer", "Mystic, Technomancer", "Special"}
		},
		["byschool"] = {
			sTitleRes = "spell_grouped_title_spellsbyschool",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "spell_grouped_label_name", nWidth = 200},
				{
					sName = "level",
					sType = "number",
					sHeadingRes = "spell_grouped_label_level",
					sTooltipRes = "spell_grouped_label_level",
					nSortOrder = 1,
					bCentered = true
				},
				{
					sName = "source",
					sType = "string",
					sHeadingRes = "spell_grouped_label_class",
					sTooltipRes = "spell_grouped_label_class",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "summary",
					sType = "formattedtext",
					sHeadingRes = "spell_grouped_label_summary",
					sTooltipRes = "spell_grouped_label_summary",
					nWidth = 300,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "sort", vFilterValue = "1"}
			},
			aGroups = {{sDBField = "school"}},
			aGroupValueOrder = {"Abjuration", "Conjuration", "Divination", "Enchantment", "Evocation", "Illusion", "Necromancy", "Transmutation"}
		},
		["bylevel"] = {
			sTitleRes = "spell_grouped_title_spellsbylevel",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "spell_grouped_label_name", nWidth = 200},
				{
					sName = "source",
					sType = "string",
					sHeadingRes = "spell_grouped_label_class",
					sTooltipRes = "spell_grouped_label_class",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "school",
					sType = "string",
					sHeadingRes = "spell_grouped_label_school",
					sTooltipRes = "spell_grouped_label_school",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "summary",
					sType = "formattedtext",
					sHeadingRes = "spell_grouped_label_summary",
					sTooltipRes = "spell_grouped_label_summary",
					nWidth = 300,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "sort", vFilterValue = "1"}
			},
			aGroups = {{sDBField = "level"}},
			aGroupValueOrder = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
		}
	},
	["starshipitem"] = {
		["starshipitem"] = {
			sTitleRes = "starshipitem_grouped_title_starshipitems",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "starshipitem_grouped_label_name", nWidth = 200},
				{
					sName = "pcu",
					sType = "number",
					sHeadingRes = "starshipitem_grouped_label_pcu",
					sTooltipRes = "starshipitem_grouped_label_pcu",
					nWidth = 75,
					bCentered = true
				},
				{
					sName = "cost",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_cost",
					sTooltipRes = "starshipitem_grouped_label_cost",
					nWidth = 100,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Starship Item"}
			},
			aGroups = {{sDBField = "subtype"}},
			aGroupValueOrder = {}
		},
		["starshipshield"] = {
			sTitleRes = "starshipitem_grouped_title_starshipshields",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "starshipitem_grouped_label_name", nWidth = 200},
				{
					sName = "totalsp",
					sType = "number",
					sHeadingRes = "starshipitem_grouped_label_totalsp",
					sTooltipRes = "starshipitem_grouped_label_totalsp",
					nWidth = 75,
					bCentered = true
				},
				{
					sName = "regen",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_regen",
					sTooltipRes = "starshipitem_grouped_label_regen",
					nWidth = 75,
					bCentered = true
				},
				{
					sName = "pcu",
					sType = "number",
					sHeadingRes = "starshipitem_grouped_label_pcu",
					sTooltipRes = "starshipitem_grouped_label_pcu",
					nWidth = 75,
					bCentered = true
				},
				{
					sName = "cost",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_cost",
					sTooltipRes = "starshipitem_grouped_label_cost",
					nWidth = 100,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Starship Shield"}
			},
			aGroups = {{sDBField = "subtype"}},
			aGroupValueOrder = {"BASIC", "MEDIUM", "HEAVY", "SUPERIOR"}
		},
		["starshipweapon"] = {
			sTitleRes = "starshipitem_grouped_title_starshipweapons",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "starshipitem_grouped_label_name", nWidth = 200},
				{
					sName = "category",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_category",
					sTooltipRes = "starshipitem_grouped_label_category",
					nSortOrder = 1,
					nWidth = 100
				},
				{
					sName = "range",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_range",
					sTooltipRes = "starshipitem_grouped_label_range",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "speed",
					sType = "number",
					sHeadingRes = "starshipitem_grouped_label_speed",
					sTooltipRes = "starshipitem_grouped_label_speed",
					nWidth = 75,
					bCentered = true
				},
				{
					sName = "damage",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_damage",
					sTooltipRes = "starshipitem_grouped_label_damage",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "pcu",
					sType = "number",
					sHeadingRes = "starshipitem_grouped_label_pcu",
					sTooltipRes = "starshipitem_grouped_label_pcu",
					nWidth = 75,
					bCentered = true
				},
				{
					sName = "cost",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_cost",
					sTooltipRes = "starshipitem_grouped_label_cost",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "specialproperties",
					sType = "string",
					sHeadingRes = "starshipitem_grouped_label_sprop",
					sTooltipRes = "starshipitem_grouped_label_sprop",
					nWidth = 100,
					bCentered = true
				}
			},
			aFilters = {
				{sDBField = "type", vFilterValue = "Starship Weapon"}
			},
			aGroups = {{sDBField = "subtype"}},
			aGroupValueOrder = {"LIGHT", "HEAVY ", "CAPITAL"}
		}
	},
	["starship"] = {
		["starship"] = {
			sTitleRes = "starship_grouped_title_starships",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "skill_grouped_label_name",
					nWidth = 200},
				{sName = "tier", sType = "number", sHeadingRes = "starship_grouped_label_tier",
					sTooltipRes = "starship_grouped_label_tier", nWidth = 75},
				{sName = "size", sType = "string", sHeadingRes = "starship_grouped_label_size",
					sTooltipRes = "starship_grouped_label_size", nWidth = 100},
				{sName = "frame", sType = "string", sHeadingRes = "starship_grouped_label_frame",
					sTooltipRes = "starship_grouped_label_frame", nWidth = 100},
				{sName = "mounts", sType = "string", sHeadingRes = "starship_grouped_label_mounts",
					sTooltipRes = "starship_grouped_label_mounts", nWidth = 100},
				{
					sName = "expansionbays",
					sType = "string",
					sHeadingRes = "starship_grouped_label_expbays",
					sTooltipRes = "starship_grouped_label_expbays",
					nWidth = 100
				},
				{sName = "mincrew", sType = "number", sHeadingRes = "starship_grouped_label_mincrew",
					sTooltipRes = "starship_grouped_label_mincrew", nWidth = 75},
				{sName = "maxcrew", sType = "number", sHeadingRes = "starship_grouped_label_maxcrew",
					sTooltipRes = "starship_grouped_label_maxcrew", nWidth = 75}
			},
			aFilters = {},
			aGroups = {{sDBField = "type"}},
			aGroupValueOrder = {"FRAME", "EOXIAN", "KASATHIAN", "PACT WORLD", "SHIRREN", "VESKARIUM", "CUSTOM"}
		}
	},
	["table"] = {
		["table"] = {
			sTitleRes = "table_grouped_title_tables",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "table_grouped_label_name", nWidth = 200}
			},
			aFilters = {},
			aGroups = {},
			aGroupValueOrder = {}
		}
	},
	["theme"] = {
		["theme"] = {
			sTitleRes = "theme_grouped_title_themes",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "theme_grouped_label_name", nWidth = 200}
			},
			aFilters = {},
			aGroups = {},
			aGroupValueOrder = {}
		}
	},
	["vehicle"] = {
		["vehicle"] = {
			sTitleRes = "vehicle_grouped_title_vehicles",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "vehicle_grouped_label_name", nWidth = 200},
				{sName = "level", sType = "number", sHeadingRes = "vehicle_grouped_label_type", sTooltipRe = "npc_grouped_tooltip_type", bCentered = false},
				{sName = "price", sType = "string", sHeadingRes = "vehicle_grouped_label_price", sTooltipRe = "vehicle_grouped_label_price", bCentered = true},
				{
					sName = "size",
					sType = "string",
					sHeadingRes = "vehicle_grouped_label_size",
					sTooltipRe = "vehicle_grouped_label_size",
					nWidth = 100,
					bCentered = true
				},
				{
					sName = "speed",
					sType = "string",
					sHeadingRes = "vehicle_grouped_label_speed",
					sTooltipRe = "vehicle_grouped_label_speed",
					nWidth = 100,
					bCentered = true
				},
				{sName = "eac", sType = "number", sHeadingRes = "vehicle_grouped_label_eac", sTooltipRe = "vehicle_grouped_label_eac", bCentered = true},
				{sName = "kac", sType = "number", sHeadingRes = "vehicle_grouped_label_kac", sTooltipRe = "vehicle_grouped_label_kac", bCentered = true},
				{sName = "hp", sType = "number", sHeadingRes = "vehicle_grouped_label_hp", sTooltipRe = "vehicle_grouped_label_hp", bCentered = true}
			},
			aFilters = {},
			aGroups = {{sDBField = "type"}},
			aGroupValueOrder = {"Air", "Air and Land", "Air and Sea", "Land", "Land and Air", "Land and Sea", "Sea", "Sea and Land", "Sea and Air"}
		}
	},
	["companion"] = {
		["byowner"] = {
			sTitleRes = "race_grouped_title_comp",
			aColumns = {
				{sName = "name", sType = "string", sHeadingRes = "race_grouped_label_name", nWidth = 200},
				--{sName = "holder",sType = "string",sHeadingRes = "race_grouped_label_holder",nWidth = 200},
				--{sName = "owner",sType = "string",sHeadingRes = "race_grouped_label_owner",nWidth = 200},				
			},
			aFilters = {},
			aGroups = {},
			aGroupValueOrder = { }
		},
	},
}

function onInit()
	LibraryData.setCustomFilterHandler("item_isidentified", getItemIsIdentified)
	LibraryData.setCustomGroupOutputHandler("npc_cr", getCRGroupedList)
	LibraryData.setCustomGroupOutputHandler("npc_type", getTypeGroup)
	
	
	for kDefSidebar, vDefSidebar in pairs(aDefaultSidebarState) do
		DesktopManager.setDefaultSidebarState(kDefSidebar, vDefSidebar)
	end
	for kRecordType, vRecordType in pairs(aRecordOverrides) do
		LibraryData.overrideRecordTypeInfo(kRecordType, vRecordType)
	end
	for kRecordType, vRecordListViews in pairs(aListViews) do
		for kListView, vListView in pairs(vRecordListViews) do
			LibraryData.setListView(kRecordType, kListView, vListView)
		end
	end
end
