-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	TypeChanged();
	onLockChanged();
	onIDChanged();
end

function TypeChanged()
	local nodeRace = getDatabaseNode()
	local sType = DB.getValue(nodeRace, "racetype", "");
	
	if sType == "Companion" then
		tabs.setTab(1, "main_companion", "tab_main");
	else
		tabs.setTab(1, "main_pc", "tab_main");
		if User.isHost() then
			DB.setValue(nodeRace, "racetype", "string", "")
		end
	end
	
	--if header.subwindow then
	--	header.subwindow.updateSummary();
	--end
end

function onLockChanged()	
	StateChanged();
end

function StateChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if main_pc.subwindow then
		main_pc.subwindow.update();
	end
	if main_companion.subwindow then	
		main_companion.subwindow.update();		
	end
	if other.subwindow then
		other.subwindow.update();
	end

	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local dataNode = getDatabaseNode()		
	
	--racetype.setReadOnly(bReadOnly);
	--text.setReadOnly(bReadOnly);
end

function onIDChanged()
	onNameUpdated();	
	if User.isHost() then
		if main_pc.subwindow then
			main_pc.subwindow.update();
		end	
		if main_companion.subwindow then
			main_companion.subwindow.update();
		end
	else
		local bID = LibraryData.getIDState("race", getDatabaseNode(), true);
		tabs.setVisibility(bID);
		racetype.setVisible(bID);
		
	end
end

function onNameUpdated()
	local nodeRecord = getDatabaseNode();
	local bID = LibraryData.getIDState("npc", nodeRecord, true);
	
	local sTooltip = "";
	if bID then
		sTooltip = DB.getValue(nodeRecord, "name", "");
		if sTooltip == "" then
			sTooltip = Interface.getString("library_recordtype_empty_npc")
		end
	else
		sTooltip = DB.getValue(nodeRecord, "nonid_name", "");
		if sTooltip == "" then
			sTooltip = Interface.getString("library_recordtype_empty_nonid_npc")
		end
	end
	setTooltipText(sTooltip);
	if header.subwindow and header.subwindow.link then
		header.subwindow.link.setTooltipText(sTooltip);
	end
end