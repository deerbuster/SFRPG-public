-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if User.isHost() then
		registerMenuItem(Interface.getString("char_menu_ownerclear"), "erase", 4);
		registerMenuItem(string.format(Interface.getString("char_menu_ownergm"), User.getUsername()), "mask", 3);
	end

	local node = getDatabaseNode();
	
	portrait.setIcon("portrait_" .. node.getName() .. "_charlist", true);
	node.onObserverUpdate = updateOwner;
	updateOwner();

	details.setValue(GameSystem.getCharSelectDetailHost(node));
end

function updateOwner()
	local sOwner = getDatabaseNode().getOwner();
	if sOwner then
		owner.setValue(Interface.getString("charselect_label_ownedby") .. " " .. sOwner);
	else
		owner.setValue("");
	end
end

function onMenuSelection(selection)
	if User.isHost() then
        if selection == 4 then
            local node = getDatabaseNode();
            local nodeOwnedComp = DB.getChild(node,"companionlink");
            if nodeOwnedComp then
                local sClass, sRecord = DB.getValue(nodeOwnedComp,"","");
                if sRecord ~= "" then
					local nodeComp = DB.findNode(sRecord);
					nodeComp.removeAllHolders(false);
				end
            end                
			local owner = node.getOwner();
			if owner then
                node.removeHolder(owner);
			end
		end
		
		if selection == 3 then
			local node = getDatabaseNode();
			local owner = node.getOwner();
			if owner then
				node.removeHolder(owner);
			end
			DB.setOwner(node, User.getUsername());
		end
	end
end

function openCharacter()
	Interface.openWindow("charsheet", getDatabaseNode().getNodeName());
end

function dragCharacter(draginfo)
	local nodeWin = getDatabaseNode();
	if nodeWin then
		local sIdentity = nodeWin.getName();

		local sToken = "portrait_" .. sIdentity .. "_token";
		if not Interface.isToken(sToken) then
			sToken = "";
		end
		local sName = DB.getValue(nodeWin, "name", "");
		if sName == "" then
			sName = Interface.getString("library_recordtype_empty_charsheet");
		end

		draginfo.setType("shortcut");
		draginfo.setIcon("portrait_" .. sIdentity .. "_charlist");
		if sToken ~= "" then
			draginfo.setTokenData(sToken);
		end
		draginfo.setShortcutData("charsheet", "charsheet." .. sIdentity);
		draginfo.setDescription(sName);

		if sToken ~= "" then
			local base = draginfo.createBaseData();
			base.setType("token");
			base.setTokenData(sToken);
		end
	end
end
