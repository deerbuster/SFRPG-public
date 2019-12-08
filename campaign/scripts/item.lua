-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onStateChanged();
	onNameUpdated();

	sTitle = "Item";
	if getDatabaseNode().getChild("type") ~= nil and getDatabaseNode().getChild("type").getValue() ~= "" then
		if getDatabaseNode().getChild("subtype") ~= nil and getDatabaseNode().getChild("subtype").getValue() ~= "" then
			sTitle = getDatabaseNode().getChild("type").getValue() .. " (" .. getDatabaseNode().getChild("subtype").getValue() .. ")";
		else
			sTitle = getDatabaseNode().getChild("type").getValue();
		end
	end
	
	if header.subwindow then
		header.subwindow.update(sTitle);
	end
end

function onLockChanged()
	onStateChanged();
end

function onIDChanged()
	onStateChanged();
	onNameUpdated();
end

function onStateChanged()
	sTitle = "Item";
	if main.subwindow and main.subwindow.type ~= nil and main.subwindow.type ~= "" then				
		if main.subwindow.subtype ~= nil and main.subwindow.subtype ~= "" then
			sTitle = main.subwindow.type.getValue() .. " (" .. main.subwindow.subtype.getValue() .. ")";
		else
			sTitle = main.subwindow.type.getValue();
		end
	end
	
	if header.subwindow then
		header.subwindow.update(sTitle);
	end
	if main.subwindow then
		main.subwindow.update();
	end
	if other.subwindow then
		other.subwindow.update();
	end
end

function onNameUpdated()
	local nodeRecord = getDatabaseNode();
	local bID = LibraryData.getIDState("item", nodeRecord, true);
	
	local sTooltip = "";
	if bID then
		sTooltip = DB.getValue(nodeRecord, "name", "");
		if sTooltip == "" then
			sTooltip = Interface.getString("library_recordtype_empty_item")
		end
	else
		sTooltip = DB.getValue(nodeRecord, "nonid_name", "");
		if sTooltip == "" then
			sTooltip = Interface.getString("library_recordtype_empty_nonid_item")
		end
	end
	setTooltipText(sTooltip);
end




