-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onLockChanged();
	
	sTitle = "STARSHIP";
	updateTitle(sTitle);
end

function updateTitle(sTitle)
	local node = getDatabaseNode();
	local sNewTitle = "";
	if node.getChild("size") ~= nil and node.getChild("size").getValue() ~= "" then
		sNewTitle = string.upper(getDatabaseNode().getChild("size").getValue());
	end
	if node.getChild("type") ~= nil and node.getChild("type").getValue() ~= "" then
		sNewTitle = sNewTitle .. " " .. string.upper(node.getChild("type").getValue());
	end
	if node.getChild("frame") ~= nil and node.getChild("frame").getValue() ~= "" then
		sNewTitle = sNewTitle .. " " .. string.upper(node.getChild("frame").getValue());
	end
	sNewTitle = sNewTitle .. " (" .. sTitle .. ")";
	if header.subwindow then
		header.subwindow.update(sNewTitle);
	end
end


function onLockChanged()
	StateChanged();
end

function StateChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if main.subwindow then
		main.subwindow.update();
	end
	
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	
	text.setReadOnly(bReadOnly);
end
