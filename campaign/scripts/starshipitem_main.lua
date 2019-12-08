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
	local bID, bOptionID = LibraryData.getIDState("starshipitem", nodeRecord);
	
	local sType = type.getValue();
	local sSubType = subtype.getValue();

	local bShield = (sType == "Starship Shield");
	local bWeapon = (sType == "Starship Weapon");
	
	local bSection1 = false;
	if bOptionID and User.isHost() then
		if updateControl("nonid_name", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonid_name", false);
	end
	if bOptionID and (User.isHost() or not bID) then
		if updateControl("nonidentified", bReadOnly, true) then bSection1 = true; end;
	else
		updateControl("nonidentified", false);
	end
	
	updateControl("pcu", bReadOnly, bID);
	updateControl("cost", bReadOnly, bID);

	local bSection2 = false;
	local bSection3 = false;
	local bSection4 = false;
    
	--Item
	if not bShield and not bWeapon then
		if updateControl("type", bReadOnly, bID) then bSection2 = true; end
		if updateControl("subtype", bReadOnly, bID) then bSection2 = true; end
		if updateControl("category", bReadOnly, bID) then bSection2 = true; end
		if updateControl("size", bReadOnly, bID) then bSection2 = true; end
		if updateControl("speed", bReadOnly, bID) then bSection2 = true; end
		if updateControl("pilotmod", bReadOnly, bID) then bSection2 = true; end
		if updateControl("bonus", bReadOnly, bID) then bSection2 = true; end
		if updateControl("bonusac", bReadOnly, bID) then bSection2 = true; end
		if updateControl("bonustl", bReadOnly, bID) then bSection2 = true; end
		if updateControl("nodes", bReadOnly, bID) then bSection2 = true; end
		if updateControl("special", bReadOnly, bID) then bSection2 = true; end
		if updateControl("enginerating", bReadOnly, bID) then bSection2 = true; end
		if updateControl("mincpu", bReadOnly, bID) then bSection2 = true; end
		if updateControl("maxsize", bReadOnly, bID) then bSection2 = true; end
		if updateControl("range", bReadOnly, bID) then bSection2 = true; end
		if updateControl("modifier", bReadOnly, bID) then bSection2 = true; end
	elseif bShield and not bWeapon then
		-- Shields
		if updateControl("totalsp", bReadOnly, bID and bShield) then bSection3 = true; end
		if updateControl("regen", bReadOnly, bID and bShield) then bSection3 = true; end
	elseif not bShield and bWeapon then
		-- Weapons
		if updateControl("range", bReadOnly, bID and bWeapon) then bSection4 = true; end
		if updateControl("speed", bReadOnly, bID and bWeapon) then bSection4 = true; end
		if updateControl("damage", bReadOnly, bID and bWeapon) then bSection4 = true; end
		if updateControl("specialproperties", bReadOnly, bID and bWeapon) then bSection4 = true; end
	end
	
	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 and bSection2) and bSection3);
	divider3.setVisible((bSection1 and bSection2) and (bSection3 or bSection4));
	
end
