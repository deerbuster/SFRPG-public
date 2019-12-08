-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	sTitle = "Starship Item";
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
	
	sTitle = "Starship Item";
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
	
	if other.subwindow then
		other.subwindow.update();
	end
	
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if other.subwindow then
		other.subwindow.description.setReadOnly(bReadOnly);
	end
		  
end