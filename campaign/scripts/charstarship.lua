-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()	
	registerMenuItem(Interface.getString("menu_resetbuild"), "rotateccw", 8);
	
	DB.addHandler(DB.getPath(getDatabaseNode(), "tier"), "onUpdate", onTierStatusChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "build.bpmax"), "onUpdate", onMaxBPChanged);
	DB.createChild(DB.getPath(getDatabaseNode(), "build.summary"));
	DB.addHandler(DB.getPath(getDatabaseNode(), "build.summary"), "onChildUpdate", onCurrentBPChanged);
	
	onShare();
	
	onTierStatusChanged();
	onCurrentBPChanged();
	onMaxBPChanged();
	
	local sName = DB.getValue(getDatabaseNode(), "name", "");
	local nTier = DB.getValue(getDatabaseNode(), "tier", 0);
	local sFrame = DB.getValue(getDatabaseNode(), "frame", "");
	
	if sName == "" and nTier == 0 and sFrame == "" then
		showHelp();
	end
	
end

function onShare()
	if User.isHost() then
		for _,v in pairs(User.getActiveUsers()) do
			DB.addHolder(getDatabaseNode(), v, false);
		end
		
		if crew.subwindow then
			for _,v in pairs(crew.subwindow.crewlist.getWindows()) do
				local sClass, sNodeID = v.link.getValue();
				sNodeID = sNodeID:gsub("charsheet.", "");
				local sUserName = User.getIdentityOwner(sNodeID);
				if sUserName ~= nil then
					v.getDatabaseNode().addHolder(sUserName, true);	
				end
			end
		end
	end
end
function onHover(state)
	if state then
		local sName = DB.getValue(getDatabaseNode(), "name", "");
		local nTier = DB.getValue(getDatabaseNode(), "tier", 0);
		local sFrame = DB.getValue(getDatabaseNode(), "frame", "");
	
		if sName == "" and nTier == 0 and sFrame == "" then
			showHelp();
		end
	end
end
function onMenuSelection(selection, subselection)
	if selection == 8 then
		local wChoice= Interface.openWindow("charstarship_dialog_resetbuild", "");
		wChoice.initialize(getDatabaseNode());
	end
	return true;
end
function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		if StringManager.contains({"starship", "starshipitem", "charsheet" }, sClass) then
			CharStarshipManager.handleAddInfoDB(User.getIdentityOwner(User.getCurrentIdentity()), sClass, sRecord, getDatabaseNode());
		end
	end
	return true;	
end
function onClose()
	if User.isHost() then
		DB.removeHandler(DB.getPath(getDatabaseNode(), "tier"), "onUpdate", onTierStatusChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "build.bpmax"), "onUpdate", onMaxBPChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "build.summary"), "onChildUpdate", onCurrentBPChanged);
	end
end

-- 
-- Custom Handlers
--
function onMaxBPChanged()
	bpcurrent.updateColor();
end
function onCurrentBPChanged()
	CharStarshipManager.totalCurrentBuildPoints(getDatabaseNode());
end
function onTierStatusChanged()
	-- Set Build Points
	local nodeCharStarship = getDatabaseNode();
	local nTier = DB.getValue(nodeCharStarship, "tier", 0.25);
	local sTier = nTier .. "";	
	if nTier > 0 and nTier < 0.25 then
		sTier = "1/4";
	elseif nTier > 0.25 and nTier < 0.33 then
		sTier = "1/3";
	elseif nTier > 0.33 and nTier < 0.6 then
		sTier = "1/2";
	end
		
	local nBP = DataCommon.starshiptier[sTier].bp;
	DB.setValue(nodeCharStarship, "build.bpmax", "number", nBP);
end

-- 
-- DIALOGS
--
function showHelp()
	local wChoice= Interface.openWindow("charstarship_dialog_newbuild", "");
	wChoice.initialize(getDatabaseNode());	
end



