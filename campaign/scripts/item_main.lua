-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
end

function VisDataCleared()
	update();
end

function InvisDataAdded()
	update();
end

function updateControl(sControl, bReadOnly, bID)
	if not self[sControl] then
		return false;
	end
		
	if not bID then
		return self[sControl].update(bReadOnly, true);
	end
	
	return self[sControl].update(bReadOnly);
end

function update()
	local nodeRecord = getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);
	local bID, bOptionID = LibraryData.getIDState("item", nodeRecord);
	
	local sType = type.getValue();
	local sSubType = subtype.getValue();
	local bArmor = (sType == "Armor");
	local bPoweredArmor = (sSubType == "Powered");
	local bArmorUpgrade = (sSubType == "Upgrade");
	local bAugmentation = (sType == "Augmentation");
	local bPersonalUpgrade = (sSubType == "Personal Upgrade");
	local bConsumable = (sType == "Consumable");
	local bPersonalItem = (sSubType == "Personal");
	local bService = (sType == "Service");
	local bTechItem = (sType == "Tech");
	local bTradeGood = (sType == "Trade");
	local bWeapon = (sType == "Weapon");
	local bWeaponRanged = (sSubType == "Small Arms" or sSubType == "Long Arms" or sSubType == "Grenade" or sSubType == "Heavy" or sSubType == "Special" or sSubType == "Sniper");
	local bAmmunition = (sSubType == "Ammunition");
	local bSolarian = (sSubType == "Solarian Weapon Crystal");
	local bAffliction = (sType == "Poison") or (sType == "Curse") or (sType == "Disease") ;
	
	local bSection1 = false;
	if bOptionID and User.isHost() then
		if updateControl("nonid_name", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonid_name", false);
	end
	if bOptionID and (User.isHost() or not bID) then
		if updateControl("nonid_notes", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonid_notes", bReadOnly, false);
	end

	local bSection2 = false;
	if updateControl("type", bReadOnly, bID) then bSection2 = true; end
	if updateControl("subtype", bReadOnly, bID) then bSection2 = true; end
	if updateControl("category", bReadOnly, bID) then bSection2 = true; end
	if updateControl("level", bReadOnly, bID) then bSection2 = true; end
	
	local bSection3 = false;
	if updateControl("price", bReadOnly, bID) then bSection3 = true; end
	if updateControl("bulk", bReadOnly, bID) then bSection3 = true; end
	if updateControl("itemsize", bReadOnly, bID) then bSection3 = true; end
	if updateControl("ac", bReadOnly, bID) then bSection3 = true; end
	if updateControl("hardness", bReadOnly, bID) then bSection3 = true; end
	if updateControl("hp", bReadOnly, bID) then bSection3 = true; end
	if updateControl("strength_enc", bReadOnly, bID) then bSection3 = true; end
	
	local bSection4 = false;
	-- Armor
    if updateControl("eacbonus", bReadOnly, bID and bArmor and not bArmorUpgrade) then bSection4 = true; end
    if updateControl("kacbonus", bReadOnly, bID and bArmor and not bArmorUpgrade) then bSection4 = true; end
    if updateControl("maxdexbonus", bReadOnly, bID and bArmor and not bArmorUpgrade) then bSection4 = true; end
    if updateControl("acpenalty", bReadOnly, bID and bArmor and not bArmorUpgrade) then bSection4 = true; end
    if updateControl("speedadj", bReadOnly, bID and bArmor and not bArmorUpgrade) then bSection4 = true; end
    if updateControl("upgradeslots", bReadOnly, bID and bArmor and not bArmorUpgrade) then bSection4 = true; end

	-- Powered Armor
	if updateControl("strength", bReadOnly, bID and bArmor and bPoweredArmor) then bSection4 = true; end
    if updateControl("damage", bReadOnly, bID and bArmor and bPoweredArmor) then bSection4 = true; end
    if updateControl("size", bReadOnly, bID and bArmor and bPoweredArmor) then bSection4 = true; end
    if updateControl("capacity", bReadOnly, bID and bArmor and bPoweredArmor) then bSection4 = true; end
	if updateControl("usage", bReadOnly, bID and bArmor and bPoweredArmor) then bSection4 = true; end
    if updateControl("weaponslots", bReadOnly, bID and bArmor and bPoweredArmor) then bSection4 = true; end

	-- Armor Upgrade
	if updateControl("consumedslots", bReadOnly, bID and bArmor and bArmorUpgrade) then bSection4 = true; end
    if updateControl("associatedarmor", bReadOnly, bID and bArmor and bArmorUpgrade) then bSection4 = true; end
    
	-- Weapon
	if updateControl("hands", bReadOnly, bID and bWeapon and not bAmmunition and not bSolarian) then bSection4 = true; end
	if updateControl("damage", bReadOnly, bID and bWeapon and not bAmmunition) then bSection4 = true; end
	if updateControl("critical", bReadOnly, bID and bWeapon and not bAmmunition) then bSection4 = true; end
	if updateControl("usage", bReadOnly, bID and bWeapon and bWeaponRanged) then bSection4 = true; end
	if updateControl("special", bReadOnly, bID and bWeapon and not bSolarian) then bSection4 = true; end
	if updateControl("range", bReadOnly, bID and bWeaponRanged and not bAmmunition) then bSection4 = true; end
	if updateControl("capacity", bReadOnly, bID and bWeaponRanged and not bAmmunition) then bSection4 = true; end
	if updateControl("charges", bReadOnly, bID and bAmmunition) then bSection4 = true; end
	
	-- Augmentations
	if updateControl("system", bReadOnly, bID and (bAugmentation and not bPersonalUpgrade)) then bSection4 = true; end
	if updateControl("abilityscore", bReadOnly, bID and (bAugmentation and bPersonalUpgrade)) then bSection4 = true; end	
	
	local bSection5 = false;
	if updateControl("bonus", bReadOnly, bID and (bWeapon or bArmor)) then bSection5 = true; end
	if updateControl("aura", bReadOnly, bID) then bSection5 = true; end
	if updateControl("cl", bReadOnly, bID) then bSection5 = true; end
	if updateControl("prequisite", bReadOnly, bID) then bSection5 = true; end
	if updateControl("properties", bReadOnly, bID) then bSection5 = true; end
	
	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 or bSection2) and bSection3);
	divider3.setVisible((bSection1 or bSection2 or bSection3) and bSection4);
	divider4.setVisible((bSection1 or bSection2 or bSection3 or bSection4) and bSection5);
	divider5.setVisible((bSection1 or bSection2 or bSection3 or bSection4 or bSection5) and bSection6);
end

function onTypeChanged()
	updateHardness();
	updateHP();
end
function onLevelChanged()
	updateHardness();
	updateHP();
end
function updateHardness()
	if string.lower(type.getValue()) == "armor" or string.lower(type.getValue()) == "weapon" then
		hardness.setValue(5 + (2 * level.getValue()));
	else
		hardness.setValue(5 + level.getValue());
	end
end
function updateHP()
	if string.lower(type.getValue()) == "armor" or string.lower(type.getValue()) == "weapon" then
		hp.setValue(5 + level.getValue());
	else
		hp.setValue(5 + level.getValue());
	end
							
	if level.getValue() >= 15 then
		hp.setValue(hp.getValue() + 30);
	end

end