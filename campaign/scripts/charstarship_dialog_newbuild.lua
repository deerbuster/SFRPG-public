-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local node = nil;

function initialize(nodeCharStarship)
	node = nodeCharStarship;
	activateDialog();
end

function activateDialog()
	if node == nil then
		return;
	end
	local sName = DB.getValue(node, "name", "");
	local sMessage = string.format(Interface.getString("charstarship_dialog_newbuild_message"), sName);
	message.setValue(sMessage);
end

function processOK()
	close();
end

function processCancel()
	close();
end
