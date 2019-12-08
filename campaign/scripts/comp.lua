-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if User.isHost() then		
		registerMenuItem(Interface.getString("menu_rest"), "lockvisibilityon", 8);
		registerMenuItem(Interface.getString("menu_restshort"), "pointer_cone", 8, 8);
		registerMenuItem(Interface.getString("menu_restovernight"), "pointer_circle", 8, 6);
	end
--		portrait.setVisible(false);
--		localportrait.setVisible(false);
--[[ 	if not minisheet and User.isLocal() then
		portrait.setVisible(false);
		localportrait.setVisible(false);
	end
 ]]	onShare();
end

function onMenuSelection(selection, subselection)
	if selection == 8 then
		local nodeChar = getDatabaseNode();
		
		if subselection == 8 then
			ChatManager.Message(Interface.getString("message_restshort"), true, ActorManager2.getActor("pc", nodeChar));
		elseif subselection == 6 then
			ChatManager.Message(Interface.getString("message_restovernight"), true, ActorManager2.getActor("pc", nodeChar));
			CharManager.rest(nodeChar);
		end
	end
end
function onShare()
	if User.isHost() then
		for _,v in pairs(User.getActiveUsers()) do
			DB.addHolder(getDatabaseNode(), v, false);
		end
		
		-- if notes.subwindow then
			-- for _,v in pairs(crew.subwindow.crewlist.getWindows()) do
				-- local sClass, sNodeID = v.link.getValue();
				-- sNodeID = sNodeID:gsub("charsheet.", "");
				-- local sUserName = User.getIdentityOwner(sNodeID);
				-- if sUserName ~= nil then
					-- v.getDatabaseNode().addHolder(sUserName, true);	
				-- end
			-- end
		-- end
	end
end