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
		
	local bWeapon, sTypeLower, sSubtypeLower = ItemManager2.isWeapon(nodeRecord);
	local bArmor = ItemManager2.isArmor(nodeRecord);
	
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
		
	local bSection2 = false;
	if updateControl("type", bReadOnly, true) then bSection2 = true; end
	if updateControl("subtype", bReadOnly, true) then bSection2 = true; end
	if updateControl("level", bReadOnly, true) then bSection2 = true; end
	if updateControl("bonus", bReadOnly, true) then bSectio2 = true; end

	local bSection3 = false;
	if updateControl("price", bReadOnly, true) then bSection3 = true; end
	if updateControl("bulk", bReadOnly, true) then bSection3 = true; end
	
	local bSection4 = false;
	if updateControl("slots", bReadOnly, bArmor) then bSection4 = true; end
	if updateControl("armortype", bReadOnly, bArmor) then bSection4 = true; end
	
	divider.setVisible(bSection1 and bSection2);
	divider2.setVisible((bSection1 or bSection2) and bSection3);
	divider3.setVisible((bSection1 or bSection2 or bSection3) and bSection4);
end
