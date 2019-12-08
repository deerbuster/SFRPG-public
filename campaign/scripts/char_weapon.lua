-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("menu_deleteweapon"), "delete", 4);
	registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 4, 3);
	
	local sNode = getDatabaseNode().getNodeName();
	DB.addHandler(sNode, "onChildUpdate", onDataChanged);
	onDataChanged();
end

function onMenuSelection(selection, subselection)
	if selection == 4 and subselection == 3 then
		local node = getDatabaseNode();
		if node then
			node.delete();
		else
			close();
		end
	end
end

function onClose()
	local sNode = getDatabaseNode().getNodeName();
	DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
end

local m_sClass = "";
local m_sRecord = "";
function onLinkChanged()
	local node = getDatabaseNode();
	local sClass, sRecord = DB.getValue(node, "shortcut", "", "");
	if sClass ~= m_sClass or sRecord ~= m_sRecord then
		m_sClass = sClass;
		m_sRecord = sRecord;
		
		local sInvList = DB.getPath(DB.getChild(node, "..."), "inventorylist") .. ".";
		if sRecord:sub(1, #sInvList) == sInvList then
			carried.setLink(DB.findNode(DB.getPath(sRecord, "carried")));
		end
	end
end

function onDataChanged()
	onLinkChanged();
	onDamageChanged();	
	local nodeWeapon = getDatabaseNode();
	local bRanged = (type.getValue() == 1);	
	
	label_range.setVisible(bRanged);
	rangeincrement.setVisible(bRanged);
	label_ammo.setVisible(bRanged);
	uses.setVisible(bRanged);
	ammocounter.setVisible(bRanged);
	
	
	local sSpecial = DB.getValue(nodeWeapon, "special",""):lower();	
	if string.find(sSpecial, "unwieldy") then
		bNoFull = true
	elseif string.find(sSpecial, "explode") then
		bNoFull = true
	elseif string.find(sSpecial, "thrown") and bRanged then
		bNoFull = true
	else
		bNoFull = false
	end	
	if bNoFull then
	attacks.setVisible(false);
	attackicons.setVisible(false);
	attack1.setVisible(false);
	attack2.setVisible(false);
	attack3.setVisible(false);
	attack4.setVisible(false);
	end
	local sSpecial = DB.getValue(nodeWeapon, "special",""):lower();	
	if string.find(sSpecial, "powered") then
	label_ammo.setVisible(true);
	uses.setVisible(true);
	ammocounter.setVisible(true);
	end
end

function onDamageChanged()
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")
	local rActor = ActorManager.getActor("pc", nodeChar);
	
	local aDamage = {};
	local aDamageNodes = UtilityManager.getSortedTable(DB.getChildren(nodeWeapon, "damagelist"));
	for _,v in ipairs(aDamageNodes) do
		local aDice = DB.getValue(v, "dice", {});
		local nMod = DB.getValue(v, "bonus", 0);

		local sAbility = DB.getValue(v, "stat", "");
		if sAbility ~= "" then
			local nMult = DB.getValue(v, "statmult", 1);
			local nMax = DB.getValue(v, "statmax", 0);
			local nAbilityBonus = ActorManager2.getAbilityBonus(rActor, sAbility);
			if nMax > 0 then
				nAbilityBonus = math.min(nAbilityBonus, nMax);
			end
			if nAbilityBonus > 0 and nMult ~= 1 then
				nAbilityBonus = math.floor(nMult * nAbilityBonus);
			end
			nMod = nMod + nAbilityBonus;
		end
		
		if #aDice > 0 or nMod ~= 0 then
			local sDamage = StringManager.convertDiceToString(DB.getValue(v, "dice", {}), nMod);
			local sType = DB.getValue(v, "type", "");
			if sType ~= "" then
				sDamage = sDamage .. " " .. sType;
			end
			table.insert(aDamage, sDamage);
		end
	end

	damageview.setValue(table.concat(aDamage, "\n+ "));
end

function onDamageAction(draginfo)
	local rActor, rDamage = CharManager.getWeaponDamageRollStructures(getDatabaseNode());
	
	ActionDamage.performRoll(draginfo, rActor, rDamage);
	return true;
end

function onReloadAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")
	local rActor, rAttack = CharManager.getWeaponAttackRollStructures(nodeWeapon);						
	local nAmmo = DB.getValue(nodeWeapon, "ammo",0);
	local nUses = DB.getValue(nodeWeapon, "uses",0);	
		if nAmmo > 0 then
			if nUses == 1 then
				ChatManager.Message(Interface.getString("char_message_ammodrawn"), true, rActor);
				DB.setValue(nodeWeapon, "ammo", "number", 0);
			else
				ChatManager.Message(Interface.getString("char_message_reloadammo"), true, rActor);
				DB.setValue(nodeWeapon, "ammo", "number", 0);
			end
		else 
			ChatManager.Message(Interface.getString("char_message_ammofull"), true, rActor);
		end
	return true;
end