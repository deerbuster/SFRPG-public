-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
end

function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;
	end
	
	return self[sControl].update(bReadOnly, bForceHide);
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());

	local sType = DB.getValue(getDatabaseNode(), "type", "");

	if bReadOnly then
		updateControl("size", bReadOnly, true);
		updateControl("frame", bReadOnly, true);
	else
		updateControl("size", bReadOnly);
		updateControl("frame", bReadOnly);
	end
	
	updateControl("speed", bReadOnly);
	updateControl("maneuverability", bReadOnly);
	updateControl("drift", bReadOnly);
	updateControl("ac", bReadOnly);
	updateControl("tl", bReadOnly);
	updateControl("dt", bReadOnly);
	updateControl("ct", bReadOnly);
	updateControl("frameexpansionbays", bReadOnly);
	updateControl("mounts", bReadOnly);
	updateControl("mincrew", bReadOnly);
	updateControl("maxcrew", bReadOnly);
	updateControl("cost", bReadOnly);
	
	updateControl("shields", bReadOnly);
	updateControl("attacks", bReadOnly);
	updateControl("powercore", bReadOnly);
	updateControl("driftengine", bReadOnly);
	updateControl("systems", bReadOnly);
	updateControl("expansionbays", bReadOnly);
	updateControl("modifiers", bReadOnly);
	updateControl("complement", bReadOnly);
	updateControl("crew", bReadOnly);
	
	
end
