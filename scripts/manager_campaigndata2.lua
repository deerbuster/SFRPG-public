--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function handleDrop(sTarget, draginfo)
	if sTarget == "spell" then
		local bAllowEdit = LibraryData.allowEdit(sTarget);
		if bAllowEdit then
			local sRootMapping = LibraryData.getRootMapping(sTarget);
			local sClass, sRecord = draginfo.getShortcutData();
			if ((sClass == "spell") or (sClass == "spell2")) and ((sRootMapping or "") ~= "") then
				local nodeSource = DB.findNode(sRecord);
				local nodeTarget = DB.createChild(sRootMapping);
				DB.copyNode(nodeSource, nodeTarget);
				DB.setValue(nodeTarget, "locked", "number", 1);
				SpellManager.convertSpellDescToFormattedText(nodeTarget);
				return true;
			end
		end
    end

	if not User.isHost() then
		return;
	end
	
	if sTarget == "combattracker" then
		local sClass, sRecord = draginfo.getShortcutData();
		if sClass == "charsheet" then		
			CombatManager2.addPC(draginfo.getDatabaseNode());
			return true;
		elseif sClass == "npc" then
			CombatManager.addNPC(sClass, draginfo.getDatabaseNode());
			return true;
		elseif sClass == "battle" then
			CombatManager.addBattle(draginfo.getDatabaseNode());
            return true;
        elseif sClass == "companionsheet" then
            CombatManager2.addCompanion(draginfo.getDatabaseNode());
            return true;
		end
	end
end

function sanitize(s)
	local sSanitized = StringManager.trim(s:gsub("%s%(.*%)$", ""));
	sSanitized = sSanitized:gsub("[.,-():'’/?+–-]", "_"):gsub("%s", ""):lower();
	return sSanitized
end
