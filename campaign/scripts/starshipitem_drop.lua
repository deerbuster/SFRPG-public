-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onDrop(x, y, draginfo)
	local sDragType = draginfo.getType();
	if sDragType ~= "shortcut" then
		return false;
	end
	
	local sDropClass, sDropNodeName = draginfo.getShortcutData();
	if not StringManager.contains({"starshipitem"}, sDropClass) then
		return true;
	end
	
	local nodeSource = draginfo.getDatabaseNode();
	local nodeTarget = window.getDatabaseNode();
		
	local sSourceType = DB.getValue(nodeSource, "type", "");
	local sTargetType = DB.getValue(nodeTarget, "type", "");
	
	local sSourceName = DB.getValue(nodeSource, "name", "");
	sSourceName = string.gsub(sSourceName, " %(" .. sSourceType .. "%)", "");

	local sTargetName = DB.getValue(nodeTarget, "name", "");
	sTargetName = string.gsub(sTargetName, " %(" .. sTargetType .. "%)", "");
	
	if sSourceType == sTargetType and StringManager.contains({ "Weapon", "Shield" }, sSourceType) then
		
		if sSourceName ~= "" then
			local sName = sSourceName .. " (" .. DB.getValue(nodeTarget, "name", "") .. ")";
			DB.setValue(nodeTarget, "name", "string", sName);
		end
			
		DB.setValue(nodeTarget, "type", "string", DB.getValue(nodeSource, "type", ""));
		DB.setValue(nodeTarget, "subtype", "string", DB.getValue(nodeSource, "subtype", ""));
		DB.setValue(nodeTarget, "pcu", "number", DB.getValue(nodeSource, "subtype", 0));
		local sCost = StringManager.combine(" ", DB.getValue(nodeSource, "cost", ""), DB.getValue(nodeTarget, "cost", ""));
		DB.setValue(nodeTarget, "cost", "string", sCost);
			
		if sSourceType == "Weapon" then
			DB.setValue(nodeTarget, "category", "string", DB.getValue(nodeSource, "category", ""));
			DB.setValue(nodeTarget, "range", "string", DB.getValue(nodeSource, "range", ""));
			DB.setValue(nodeTarget, "speed", "number", DB.getValue(nodeSource, "speed", 0));
			DB.setValue(nodeTarget, "damage", "string", DB.getValue(nodeSource, "damage", ""));
			DB.setValue(nodeTarget, "specialproperties", "string", DB.getValue(nodeSource, "specialproperties", ""));
		elseif sSourceType == "Shield" then
			DB.setValue(nodeTarget, "totalsp", "number", DB.getValue(nodeSource, "totalsp", 0));
			DB.setValue(nodeTarget, "regen", "string", DB.getValue(nodeSource, "regen", ""));
			DB.setValue(nodeTarget, "properties", "string", DB.getValue(nodeSource, "properties", ""));
		else
			DB.setValue(nodeTarget, "size", "string", DB.getValue(nodeSource, "size", ""));
			DB.setValue(nodeTarget, "speed", "number", DB.getValue(nodeSource, "speed", 0));
			DB.setValue(nodeTarget, "pilotmod", "number", DB.getValue(nodeSource, "pilotmod", 0));
			local nSourceBonus = DB.getValue(nodeSource, "bonus", 0);
			local nTargetBonus = DB.getValue(nodeTarget, "bonus", 0);
			DB.setValue(nodeTarget, "bonus", "number", nSourceBonus + nTargetBonus);
			local nSourceBonusAC = DB.getValue(nodeSource, "bonusac", 0);
			local nTargetBonusAC = DB.getValue(nodeTarget, "bonusac", 0);
			DB.setValue(nodeTarget, "bonusac", "number", nSourceBonusAC + nTargetBonusAC);
			local nSourceBonusTL = DB.getValue(nodeSource, "bonustl", 0);
			local nTargetBonusTL = DB.getValue(nodeTarget, "bonustl", 0);
			DB.setValue(nodeTarget, "bonustl", "number", nSourceBonusTL + nTargetBonusTL);
			DB.setValue(nodeTarget, "nodes", "number", DB.getValue(nodeSource, "nodes", 0));
			DB.setValue(nodeTarget, "special", "string", DB.getValue(nodeSource, "special", ""));
			DB.setValue(nodeTarget, "enginerating", "string", DB.getValue(nodeSource, "enginerating", ""));
			DB.setValue(nodeTarget, "minpcu", "string", DB.getValue(nodeSource, "minpcu", ""));
			DB.setValue(nodeTarget, "maxsize", "string", DB.getValue(nodeSource, "maxsize", ""));
			DB.setValue(nodeTarget, "range", "string", DB.getValue(nodeSource, "range", ""));
			DB.setValue(nodeTarget, "modifier", "string", DB.getValue(nodeSource, "modifier", ""));		
		end
		
	end

	return true;
end
