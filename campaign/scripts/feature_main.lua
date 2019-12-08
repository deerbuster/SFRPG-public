-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()	
	update();
end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
end

function VisDataCleared()
	update();
end

function InvisDataAdded()
	update();
end

function update()
	local nodeRecord = getDatabaseNode();
	local sNodeName = nodeRecord.getNodeName();	
	local aNodeName = StringManager.split(sNodeName, "@","");
	local sType = aNodeName[1];
	aType = StringManager.split(sType, ".","");
	if aType[2] == "classfeature" then
		ClassManager.upDateFeatureAbilities(nodeRecord);
	end
	
	local bReadOnly = WindowManager.getReadOnlyState(nodeRecord);	
	local bAbilities = (abilities.getWindowCount() > 0);		
	updateControl("abilities", bReadOnly, bAbilities);	
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