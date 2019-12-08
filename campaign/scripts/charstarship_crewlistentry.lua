-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	-- Acquire token reference, if any
	linkToken();
	-- Set up the PC links
	onLinkChanged();
	
	
end

function linkToken()
	local imageinstance = token.populateFromImageNode(tokenrefnode.getValue(), tokenrefid.getValue());
	if imageinstance then
		TokenManager.linkToken(getDatabaseNode(), imageinstance);
	end
end

function onLinkChanged()
	-- If a PC, then set up the links to the char sheet
	local sClass, sRecord = link.getValue();
	if sClass == "charsheet" then
		linkPCFields();
		name.setLine(false);
	end
end

function linkPCFields()
	local nodeChar = link.getTargetDatabaseNode();
	if nodeChar then
		name.setLink(nodeChar.createChild("name", "string"), true);
		
	end
end

function buildRoleActions(sCrewRole)

	if not getDatabaseNode().isOwner() then
		return;
	end
	
	for _,aAction in pairs(DataCommon.starshipcrewactions[sCrewRole:lower()]) do
		local wndAction = actions.createWindow("." .. aAction.name:lower());
		local aActions = StringManager.split(aAction.action, "|");
		local nodeCharStarship = windowlist.window.getDatabaseNode();
		for k, v in pairs(aActions) do
			if v == "skill" then
				wndAction.addSkillAction(aAction.name, aAction.skills, aAction.basedc, math.floor(aAction.tiermod * DB.getValue(nodeCharStarship, "tier", 0)));
			elseif v == "attack" then
				wndAction.addAttackAction(nodeCharStarship, aAction.name, aAction.weapons, aAction.attackmod, arc.getStringValue());
			elseif v == "move" then
				wndAction.addMoveAction(aAction.name, aAction.text);
			end
		end
	end		

	for _,aMinorAction in pairs(DataCommon.starshipcrewminoractions) do
		local wndMinorAction = minoractions.createWindow("." .. aMinorAction.name:lower());
		local nodeCharStarship = windowlist.window.getDatabaseNode();
		if aMinorAction.action == "skill" then
			wndMinorAction.addSkillAction(aMinorAction.name, aMinorAction.skills, aMinorAction.basedc, math.floor(aMinorAction.tiermod * DB.getValue(nodeCharStarship, "tier", 0)));
		elseif aMinorAction.action == "attack" then
			wndMinorAction.addAttackAction(nodeCharStarship, aMinorAction.name, aMinorAction.weapons, aMinorAction.attackmod, arc.getStringValue());
		elseif aMinorAction.action == "move" then
			wndMinorAction.addMoveAction(aMinorAction.name, aMinorAction.text);
		end
	end
	
end

function updateActionHeaders(sCrewRole)
	if sCrewRole == "Gunner" then
		label1.setValue("ACTION");
		label2.setValue("WEAPON");
		label3.setValue("BONUS");
		label4.setValue("ATK");
		label5.setValue("");
	else
		label1.setValue("ACTION");
		label2.setValue("SKILL ");
		label3.setValue("BONUS");
		label4.setValue("DC");
		label5.setValue("CHK");
	end
end

function initializeWeaponArcs()
	local aWeaponArcs = CharStarshipManager.getStarshipWeaponArcs(windowlist.window.getDatabaseNode());
	local sWeaponArcLabels = "";
	local sWeaponArcValues = "";
	local nWeaponIndex = 1;
	local aArcs = {};
	if aWeaponArcs["forward"] then
		table.insert(aArcs, "Forward");
	end
	if aWeaponArcs["aft"] then
		table.insert(aArcs, "Aft");
	end
	if aWeaponArcs["starboard"] then
		table.insert(aArcs, "Starboard");
	end
	if aWeaponArcs["port"] then
		table.insert(aArcs, "Port");
	end
	if aWeaponArcs["turret"] then
		table.insert(aArcs, "Turret");
	end						
	
	for x=1, #aArcs do
		if x ~= 1 then
			sWeaponArcLabels = aArcs[x] .. "|" .. sWeaponArcLabels;
			sWeaponArcValues = aArcs[x]:lower() .. "|" .. sWeaponArcValues;
		end
	end
	
	local defaultVal = aArcs[1]:lower();		
	local defaultLabel = aArcs[1];		
	arc.initialize(sWeaponArcLabels, sWeaponArcValues, defaultLabel, defaultVal);
	arc.update();
--	arc.setStringValue(defaultVal);
end