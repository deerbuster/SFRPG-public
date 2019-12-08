-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

--
-- CHARACTER SHEET DROPS
--
nodePendingWeaponDrop = nil;
nodePendingCrewDrop = nil;

OOB_MSGTYPE_DROPRECORD = "droprecord";
OOB_MSGTYPE_ISSTARSHIPCAPTAIN = "starshipcaptain";

function onInit()
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_DROPRECORD, handleAddInfoDB);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_ISSTARSHIPCAPTAIN, handleIsStarshipCaptain);
end

function logBuild(nodeCharStarship, sType, sEntryTxt, nCost)
	if DB.isOwner(nodeCharStarship) then
		if sEntryTxt == "" and sType == "" then
			return;
		end;

		local bpSummaryListNode = DB.createChild(nodeCharStarship, "build.summary");

		if sType ~= "expansionbay" and sType ~= "weapon" then
			removeBuildEntry(nodeCharStarship, bpSummaryListNode, sType);
		end

		local nodeEntry = DB.createChild(bpSummaryListNode);
		local entryNode = DB.createChild(nodeEntry, "entry", "string");
		local costNode = DB.createChild(nodeEntry, "cost", "number");
		local typeNode = DB.createChild(nodeEntry, "type", "string");
		entryNode.setValue(sEntryTxt);
		costNode.setValue(nCost);
		typeNode.setValue(sType);
	end
end
function logPCU(nodeCharStarship, sType, sEntryTxt, nCost)	
	if DB.isOwner(nodeCharStarship) then
		local pcuSummaryListNode = DB.createChild(nodeCharStarship, "pcu.summary");
		
		if sType == "thrusters" and containsBuildEntry(pcuSummaryListNode, sType) then
			removeBuildEntry(nodeCharStarship, pcuSummaryListNode, sType);
		elseif sType == "" and containsBuildEntry(pcuSummaryListNode, sType) then
			removeBuildEntry(nodeCharStarship, pcuSummaryListNode, sType);
		end
			
		local nodeEntry = DB.createChild(pcuSummaryListNode);
		local entryNode = DB.createChild(nodeEntry, "entry", "string");
		local costNode = DB.createChild(nodeEntry, "cost", "number");
		local typeNode = DB.createChild(nodeEntry, "type", "string");
		entryNode.setValue(sEntryTxt);
		costNode.setValue(nCost);
		typeNode.setValue(sType);
	end
end

function addSystem(nodeCharStarship, sClass, sRecord)
	if DB.isOwner(nodeCharStarship) then
		local systemsNode = DB.getChild(nodeCharStarship, "systems");
		local nodeSource = resolveRefNode(sRecord);
		
		-- Basic validation of source data node
		if not nodeSource then
			return;
		end

		local sSrcName = DB.getValue(nodeSource, "name", "");
		local newEntryNode = DB.createChild(systemsNode);
		if newEntryNode ~= nil then
			DB.copyNode(nodeSource, newEntryNode);
		end
	end
end
function addExpBay(nodeCharStarship, sClass, sRecord)
	if DB.isOwner(nodeCharStarship) then
		
		local expBaysNode = DB.getChild(nodeCharStarship, "expansionbays");
		local nodeSource = resolveRefNode(sRecord);
		
		-- Basic validation of source data node
		if not nodeSource then
			return;
		end		
--		

		local sSrcName = DB.getValue(nodeSource, "name", "");
		local newEntryNode = DB.createChild(expBaysNode);
		
		if newEntryNode ~= nil then
			DB.copyNode(nodeSource, newEntryNode);			
		end
	end
end

function removeBuildEntry(nodeCharStarship, targetListNode, sType)
	if DB.isOwner(nodeCharStarship) then
		for _,v in pairs(targetListNode.getChildren()) do
			if DB.getValue(v, "type", "") == sType then
				v.delete();
			end
		end
	end
	return true;
end
function resetBuild(nodeCharStarship)
	if DB.isOwner(nodeCharStarship) then
		local bpSummaryListNode = DB.getChild(nodeCharStarship, "build.summary", nil);
		if bpSummaryListNode ~= nil then
			for _,v in pairs(bpSummaryListNode.getChildren()) do
				v.delete();
			end
		end
		local bpMountListNode = DB.getChild(nodeCharStarship, "mounts", nil);
		if bpMountListNode ~= nil then
			for _,v in pairs(bpMountListNode.getChildren()) do
				v.delete();
			end
		end
		local pcuSummaryListNode = DB.getChild(nodeCharStarship, "pcu.summary", nil);
		if pcuSummaryListNode ~= nil then
			for _,v in pairs(pcuSummaryListNode.getChildren()) do
				v.delete();
			end
		end
		local systemsSummaryListNode = DB.getChild(nodeCharStarship, "systems", nil);
		if systemsSummaryListNode ~= nil then
			for _,v in pairs(systemsSummaryListNode.getChildren()) do
				v.delete();
			end
		end
		local expbaysSummaryListNode = DB.getChild(nodeCharStarship, "expansionbays", nil);
		if expbaysSummaryListNode ~= nil then
			for _,v in pairs(expbaysSummaryListNode.getChildren()) do
				v.delete();
			end
		end
		
		aNodeEntries = DB.getChildren(nodeCharStarship, "", nil);	
		for _,v in pairs(aNodeEntries) do
		sName = v.getName();
		sType = v.getType();		
			if sType == "node" then
				aSubNodeEntries = DB.getChildren(v, "", nil);			
					for _,k in pairs(aSubNodeEntries) do
						sSubName = k.getName();
						sSubType = k.getType();		
						sPath = sName .. "." .. sSubName;						
						if sSubType == "number" then
							DB.setValue(nodeCharStarship, sPath, "number", 0);
						elseif	sSubType == "string" then
							DB.setValue(nodeCharStarship, sPath, "string", "");
						elseif sSubType == "windowreference" then
							DB.setValue(nodeCharStarship, sPath, "windowreference", "");
						else
						end
					end		
			elseif sType == "number" then
					DB.setValue(nodeCharStarship, sName, "number", 0);
			elseif	sType == "string" and sName ~= "name" then
					DB.setValue(nodeCharStarship, sName,"string", "");
			elseif sType == "windowreference" then
					DB.setValue(nodeCharStarship, sName,"windowreference", "");
			elseif sType == "token" then
					DB.setValue(nodeCharStarship, sName,"token", "");
			end		
			
		end
		
		local sResetFormat = Interface.getString("charstarship_message_starshipbuildreset");
		local sResetMsg = string.format(sResetFormat, DB.getValue(nodeCharStarship, "name", ""));
		totalCurrentBuildPoints(nodeCharStarship);
		
		ChatManager.Message(sResetMsg, true);
	end
	return true;
end

function totalCurrentBuildPoints(nodeCharStarship)
	if DB.isOwner(nodeCharStarship) then
		local bpSummaryListNode = DB.getChild(nodeCharStarship, "build.summary", nil);
		local nCurrentTotal = 0;
		if bpSummaryListNode ~= nil then
			for _,v in pairs(bpSummaryListNode.getChildren()) do
				nCurrentTotal = nCurrentTotal + DB.getValue(v, "cost", 0);
			end
		end
		DB.setValue(nodeCharStarship, "build.bpcurrent", "number", nCurrentTotal);
	end
end
function totalCurrentPCUPoints(nodeCharStarship)
	if DB.isOwner(nodeCharStarship) then
		local pcuSummaryListNode = DB.getChild(nodeCharStarship, "pcu.summary", nil);
		local nCurrentTotal = 0;
		if pcuSummaryListNode ~= nil then
			for _,v in pairs(pcuSummaryListNode.getChildren()) do
				nCurrentTotal = nCurrentTotal + DB.getValue(v, "cost", 0);
			end
		end
		DB.setValue(nodeCharStarship, "pcu.current", "number", nCurrentTotal);
	end
	return true;
end

--
-- Configuration handlers
--
function handleAddStarship(sUserName, sClass, sRecord, nodeCharStarship)
	
	if DB.isOwner(nodeCharStarship) then
	
		if User.isHost() then
			if (DB.getOwner(nodeCharStarship) == sUserName) and not (DB.getOwner(nodeCharStarship) == nil and sUserName == nil) then
				return;
			end
		end
		
		-- Variables
		local nodeSource = resolveRefNode(sRecord);
		
		-- Basic validation of source data node
		if not nodeSource and nodeCharStarship then
			return;
		end
		
		-- Conditional check of source record type 
		local sType = DB.getValue(nodeSource, "type", "");
		if sType == "FRAME" then
		
			-- Get Starship max and current BP
			local nBPMax = DB.getValue(nodeCharStarship, "build.bpmax", 0);
			local nBPCurrent = DB.getValue(nodeCharStarship, "build.bpcurrent", 0);
			
			-- Get source node field data
			-- Check Cost against current BP spend and max bp allowance.
			local sStarship = DB.getValue(nodeSource, "name", "");
			local nCost = tonumber(DB.getValue(nodeSource, "cost", ""));
			if nCost + nBPCurrent > nBPMax then
				-- Send warning message
				local sFormat = Interface.getString("charstarship_message_starshipmaxbpwarning");
				local sMsg = string.format(sFormat, sStarship, DB.getValue(nodeCharStarship, "name", "Starship"));			
				ChatManager.SystemMessage(sMsg);
			end		
			local sSize = DB.getValue(nodeSource, "size", "");
			local nACTLMod = tonumber(DataCommon.starshipscale[string.lower(sSize)].actlmod);
			local sMnvr = DB.getValue(nodeSource, "maneuverability", "");
			local nPilotMod = tonumber(string.match(sMnvr, ".*([%-|%+]%d+)%sPiloting.*"));
			local sMounts = DB.getValue(nodeSource, "mounts", "");
			local aMounts = StringManager.split(sMounts, ")", true);
			local nExpBays = DB.getValue(nodeSource, "frameexpansionbays", 0);
			local nMinCrew = DB.getValue(nodeSource, "mincrew", 0);
			local nMaxCrew = DB.getValue(nodeSource, "maxcrew", 0);
			local nHP = DB.getValue(nodeSource, "hp", 0);
			local nCT = DB.getValue(nodeSource, "ct", 0);
			
			-- Set starship frame details
			DB.setValue(nodeCharStarship, "frame", "string", StringManager2.titleCase(sStarship));
			DB.setValue(nodeCharStarship, "framelink", "windowreference", sClass, nodeSource.getNodeName());
			DB.setValue(nodeCharStarship, "size", "string", StringManager2.titleCase(sSize));
			DB.setValue(nodeCharStarship, "ac.size", "number", nACTLMod);
			DB.setValue(nodeCharStarship, "tl.size", "number", nACTLMod);
			DB.setValue(nodeCharStarship, "maneuverability", "string", StringManager2.titleCase(sMnvr));
			DB.setValue(nodeCharStarship, "ac.pilot", "number", DB.getValue(nodeCharStarship, "ac.pilot", 0) + nPilotMod);
			DB.setValue(nodeCharStarship, "tl.pilot", "number", DB.getValue(nodeCharStarship, "tl.pilot", 0) + nPilotMod);
			DB.setValue(nodeCharStarship, "hp.total", "number", nHP);
			DB.setValue(nodeCharStarship, "ct.total", "number", nCT);
			
			-- Log the bp spend
			logBuild(nodeCharStarship, "frame", StringManager2.titleCase(sStarship) .. " (Frame)" , nCost);

			-- Set the build thresholds for the frame
			DB.setValue(nodeCharStarship, "build.mounts", "string", sMounts);
			DB.setValue(nodeCharStarship, "build.expbays", "number", tonumber(nExpBays));
			DB.setValue(nodeCharStarship, "build.mincrew", "number", nMinCrew);
			DB.setValue(nodeCharStarship, "build.maxcrew", "number", nMaxCrew);
			
			DB.setValue(nodeCharStarship, "crewmin", "number", nMinCrew);
			DB.setValue(nodeCharStarship, "crewmax", "number", nMaxCrew);
			
			-- Initialize Ship Crew
			DB.createChild(nodeCharStarship, "crew");
			
			-- Create mountpoint entries 
			local nodeMountsList = DB.createChild(nodeCharStarship, "mounts");
			if nodeMountsList.getChildCount() > 0 then
				DB.deleteChildren(nodeCharStarship, "mounts");
			end		
			for _,v in pairs(aMounts) do
			local aMount = StringManager.split(v, ",");
			local sArc = string.match(string.lower(v), "([forward|aft|turret|port|starboard]+).*");
			
			for __,vMount in pairs(aMount) do
				local nCount, sType = string.match(vMount:lower(), ".*(%d+)%s([light|heavy|capital]+)");
				for i=1,nCount do	
					local nodeEntry = DB.createChild(nodeMountsList);
					local arcNode = DB.createChild(nodeEntry, "arc", "string");
					local typeNode = DB.createChild(nodeEntry, "type", "string");
					arcNode.setValue(sArc);
					typeNode.setValue(sType);
				end
			end
		end
		
			-- Send status message 
			local sAddFormat = Interface.getString("charstarship_message_starshipadd");
			local sAddMsg = string.format(sAddFormat, "Frame", sStarship, DB.getValue(nodeCharStarship, "name", ""));
			ChatManager.Message(sAddMsg, true);
		
		elseif sType ~= "FRAME" then
		
			local sMsg = Interface.getString("charstarship_message_notimplemented");
			ChatManager.SystemMessage(sMsg, true);
			
		end
		
		-- Recalculate total bp spent.
		totalCurrentBuildPoints(nodeCharStarship);
	end
	return true;
end
function handleAddStarshipItem(sUserName, sClass, sRecord, nodeCharStarship)
	
	if DB.isOwner(nodeCharStarship) then
	
		if User.isHost() then
			if (DB.getOwner(nodeCharStarship) == sUserName) and not (DB.getOwner(nodeCharStarship) == nil and sUserName == nil) then
				return;
			end
		end
	
		-- Variables
		local nodeSource = resolveRefNode(sRecord);
		
		-- Basic validation of source data node
		if not nodeSource then
			return;
		end

		-- Get Starship Size
		local sSize = DB.getValue(nodeCharStarship, "size", "");
		
		-- Get source record field data
		local sSrcName = DB.getValue(nodeSource, "name", "");
		local sSrcType = DB.getValue(nodeSource, "type", "");
		local sSrcSubType = DB.getValue(nodeSource, "subtype", "");
		
		-- ITEMS
		if sSrcType == "Starship Item" then
		
			if not isValidBuild(nodeCharStarship) then
				-- Send error status message
				local sFormat = Interface.getString("charstarship_message_starshipmaxbpwarning");
				local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
			end
			-- Power Core
			if sSrcSubType == "POWER CORE" then
							
				local nSrcPCU = DB.getValue(nodeSource, "pcu", "");
				local sSrcSize = DB.getValue(nodeSource, "size", "");
				local nSrcCost = DB.getValue(nodeSource, "cost", "");
				
				if not isSizeSupported(sSize, sSrcSize) then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshipsizewarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
					return;
				end
				
				DB.setValue(nodeCharStarship, "powercore", "string", StringManager2.titleCase(sSrcName));
				DB.setValue(nodeCharStarship, "powercorelink", "windowreference", sClass, nodeSource.getNodeName());
				DB.setValue(nodeCharStarship, "pcu.total", "number", nSrcPCU);
				
				-- Log the bp spend
				logBuild(nodeCharStarship, "powercore", StringManager2.titleCase(sSrcName) .. " (Power Core)", nSrcCost);

				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Power Core", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);			
			-- THRUSTERS
			elseif sSrcSubType == "THRUSTERS" then
			
				local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
				local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
				
				local nSrcPCU = DB.getValue(nodeSource, "pcu", 0);
				local sSrcSize = DB.getValue(nodeSource, "size", "");
				local nSrcCost = DB.getValue(nodeSource, "cost", 0);
				local nSrcPilotMod = DB.getValue(nodeSource, "pilotmod", 0);
				local nSrcSpeed = DB.getValue(nodeSource, "speed", 0);
				
				if not isSizeSupported(sSize, sSrcSize) then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshipsizewarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
					return;
				end
				if nCurrentPCU + nSrcPCU > nTotalPCU then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshippcuwarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
				end
							
				-- Log the bp spend
				logBuild(nodeCharStarship, "thrusters", StringManager2.titleCase(sSrcName) .. " (Thrusters)", nSrcCost);
				-- Log the pcu spend
				logPCU(nodeCharStarship, "thrusters", StringManager2.titleCase(sSrcName) .. " (Thrusters)", nSrcPCU);
				-- Add the thrusters to the systems list
				addSystem(nodeCharStarship, sClass, sRecord);
				-- Record the speed
				DB.setValue(nodeCharStarship, "speed", "number", nSrcSpeed);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Thrusters", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
				-- Recalculate total pcu.
				totalCurrentPCUPoints(nodeCharStarship);

			-- ARMOR
			elseif sSrcSubType == "ARMOR" then
				
				local sSize = DB.getValue(nodeCharStarship, "size", "");
				
				local sSrcCost = DB.getValue(nodeSource, "cost", "");
				local nSrcBonusAC = DB.getValue(nodeSource, "bonusac", 0);
				local nSrcCost = getCostFromSize(sSize, sSrcCost);
				
				-- Log the bp spend
				logBuild(nodeCharStarship, "armor", StringManager2.titleCase(sSrcName) .. " (Armor)", nSrcCost);
				-- Add the armor to the systems list
				addSystem(nodeCharStarship, sClass, sRecord);
				-- Record the Armor Bonus to AC	
				DB.setValue(nodeCharStarship, "ac.armor", "number", nSrcBonusAC);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Armor", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
			-- COMPUTER
			elseif sSrcSubType == "COMPUTER" then
				local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
				local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
				
				local nSrcPCU = DB.getValue(nodeSource, "pcu", 0);
				local nSrcCost = DB.getValue(nodeSource, "cost", 0);
				
				if nCurrentPCU + nSrcPCU > nTotalPCU then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshippcuwarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);			
				end
				
				-- Log the bp spend
				logBuild(nodeCharStarship, "computer", StringManager2.titleCase(sSrcName) .. " (Computer)", nSrcCost);
				-- Log the pcu spend
				logPCU(nodeCharStarship, "computer", StringManager2.titleCase(sSrcName) .. " (Computer)", nSrcPCU);
				-- Add the computer to the systems list
				addSystem(nodeCharStarship, sClass, sRecord);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Computer", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
				-- Recalculate total pcu.
				totalCurrentPCUPoints(nodeCharStarship);

			-- CREW QUARTERS
			elseif sSrcSubType == "CREW QUARTERS" then
				local nSrcCost = DB.getValue(nodeSource, "cost", 0);
				-- Log the bp spend
				logBuild(nodeCharStarship, "crewquarters", StringManager2.titleCase(sSrcName) .. " (Crew Quarters)", nSrcCost);
				-- Add the crew quarters to the systems list
				addSystem(nodeCharStarship, sClass, sRecord);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Crew Quarters", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);		
			-- DEFENSIVE COUNTERMEASURES
			elseif sSrcSubType == "DEFENSIVE COUNTERMEASURE" then
				local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
				local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
				
				local nSrcPCU = DB.getValue(nodeSource, "pcu", 0);
				local nSrcCost = DB.getValue(nodeSource, "cost", 0);
				local nTLBonus = DB.getValue(nodeSource, "bonustl", 0);
				
				if nCurrentPCU + nSrcPCU > nTotalPCU then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshippcuwarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
				end
				
				-- Log the bp spend
				logBuild(nodeCharStarship, "countermeasure", StringManager2.titleCase(sSrcName) .. " (Def. Countermeasure)", nSrcCost);
				-- Log the pcu spend
				logPCU(nodeCharStarship, "countermeasure", StringManager2.titleCase(sSrcName) .. " (Def. Countermeasure)", nSrcPCU);
				-- Add the computer to the systems list
				addSystem(nodeCharStarship, sClass, sRecord);
				-- Record the bonus to TL
				DB.setValue(nodeCharStarship, "tl.countermeasures", "number", nTLBonus);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Defensive Countermeasures", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
				-- Recalculate total pcu.
				totalCurrentPCUPoints(nodeCharStarship);
			-- DRIFT ENGINE
			elseif sSrcSubType == "DRIFT ENGINE" then
			
				local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
				local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
				
				local nSrcPCU = DB.getValue(nodeSource, "minpcu", 0);
				local sSrcSize = DB.getValue(nodeSource, "maxsize", "");
				local sSrcCost = DB.getValue(nodeSource, "cost", 0);
				local nSrcCost = getCostFromSize(sSize, sSrcCost);
				
				local nEngineRating = DB.getValue(nodeSource, "enginerating", 0);
				
				if not isMaxSizeSupported(sSize, sSrcSize) then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshipsizewarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
					return;
				end
				
				if nCurrentPCU + nSrcPCU > nTotalPCU then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshipapcuwarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
				end
				
				-- Log the bp spend
				logBuild(nodeCharStarship, "driftengine", StringManager2.titleCase(sSrcName) .. " (Drift Engine)", nSrcCost);
				-- Log the pcu spend
				logPCU(nodeCharStarship, "driftengine", StringManager2.titleCase(sSrcName) .. " (Drift Engine)", nSrcPCU);
				-- Add the drift engine 
				DB.setValue(nodeCharStarship, "driftengine", "string", sSrcName);
				DB.setValue(nodeCharStarship, "driftenginelink", "windowreference", sClass, nodeSource.getNodeName());
				-- Record the drift engine rating
				DB.setValue(nodeCharStarship, "driftrating", "number", nEngineRating);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Drift Engine", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
				-- Recalculate total pcu.
				totalCurrentPCUPoints(nodeCharStarship);
					
			-- EXPANSION BAY
			elseif sSrcSubType == "EXPANSION BAY" then
				local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
				local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
				local nExpBays = DB.getValue(nodeCharStarship, "build.expbays", 0);		
				local nodeExpBays = DB.getChild(nodeCharStarship, "expansionbays");
				
				local nSrcPCU = DB.getValue(nodeSource, "pcu", 0);
				local nSrcCost = DB.getValue(nodeSource, "cost", 0);
				
				if nodeExpBays.getChildCount() == nExpBays then					
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshipexpbaywarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
					return;
				end
				if nCurrentPCU + nSrcPCU > nTotalPCU then
					-- Send warning status message
					local sFormat = Interface.getString("charstarship_message_starshippcuwarning");
					local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
					ChatManager.SystemMessage(sMsg);
				end
			
				

				-- Log the bp spend
				logBuild(nodeCharStarship, "expansionbay", StringManager2.titleCase(sSrcName) .. " (Exp.Bay)", nSrcCost);
				-- Log the pcu spend
				logPCU(nodeCharStarship, "expansionbay", StringManager2.titleCase(sSrcName) .. " (Exp.Bay)", nSrcPCU);
				-- Add the expansion bay to the systems list
				addExpBay(nodeCharStarship, sClass, sRecord);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Expansion Bay", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
				-- Recalculate total pcu.
				totalCurrentPCUPoints(nodeCharStarship);

			-- SECURITY
			elseif sSrcSubType == "SECURITY" then
				local sSrcCost = DB.getValue(nodeSource, "cost", "");
				local nSrcCost = 0;
				if string.match(sSrcCost, "(%d+) × size category") then
					nSrcCost = getCostFromSize(sSize, string.match(sSrcCost, "(%d+) × size category"));
				elseif string.match(sSrcCost, "(%d+)") then
					nSrcCost = string.match(sSrcCost, "(%d+)");
				end
							
				-- Log the bp spend
				logBuild(nodeCharStarship, "security", StringManager2.titleCase(sSrcName) .. " (Security)", nSrcCost);
				-- Add the security to the systems list
				addSystem(nodeCharStarship, sClass, sRecord);
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Security", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
			-- SENSORS
			elseif sSrcSubType == "SENSORS" then
				local nSrcCost = DB.getValue(nodeSource, "cost", 0);
				local nSrcMod = DB.getValue(nodeSource, "modifier", 0);
							
				-- Log the bp spend
				logBuild(nodeCharStarship, "sensors", StringManager2.titleCase(sSrcName) .. " (Sensors)", nSrcCost);
				-- Add the sensors
				DB.setValue(nodeCharStarship, "sensors", "string", sSrcName);
				DB.setValue(nodeCharStarship, "sensorslink", "windowreference", sClass, nodeSource.getNodeName());
				-- Record the sensors modifier
				DB.setValue(nodeCharStarship, "sensorsmod", "number", nSrcMod);
						
				-- Send status message
				local sFormat = Interface.getString("charstarship_message_starshipadd");
				local sMsg = string.format(sFormat, "Sensors", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				-- Recalculate total bp spent.
				totalCurrentBuildPoints(nodeCharStarship);
			end
		-- SHIELDS
		elseif sSrcType == "Starship Shield" then
			local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
			local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
			
			local nSrcPCU = DB.getValue(nodeSource, "pcu", 0);
			local nSrcCost = DB.getValue(nodeSource, "cost", 0);
			local nSrcTotalSP = DB.getValue(nodeSource, "totalsp", 0);
			
			if nCurrentPCU + nSrcPCU > nTotalPCU then
				-- Send warning status message
				local sFormat = Interface.getString("charstarship_message_starshippcuwarning");
				local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
			end
			-- Log the bp spend
			logBuild(nodeCharStarship, "shields", StringManager2.titleCase(sSrcName) .. " (Shields)", nSrcCost);
			-- Log the pcu spend
			logPCU(nodeCharStarship, "shields", StringManager2.titleCase(sSrcName) .. " (Shields)", nSrcPCU);
			
			-- Add the shields
			DB.setValue(nodeCharStarship, "shields", "string", sSrcName);
			DB.setValue(nodeCharStarship, "shieldslink", "windowreference", sClass, nodeSource.getNodeName());
			-- Record the shields total sp
			DB.setValue(nodeCharStarship, "shieldssp", "number", nSrcTotalSP);
			-- Assign the shields SP to each arc evenly.
			
			local nLowSP = math.floor(nSrcTotalSP/4);
			local nHighSP = math.ceil(nSrcTotalSP/4);
						
			DB.setValue(nodeCharStarship, "shields_forward", "number", nHighSP);
			DB.setValue(nodeCharStarship, "shields_aft", "number", nHighSP);
			DB.setValue(nodeCharStarship, "shields_port", "number", nLowSP);
			DB.setValue(nodeCharStarship, "shields_starboard", "number", nLowSP);
						
			-- Send status message
			local sFormat = Interface.getString("charstarship_message_starshipadd");
			local sMsg = string.format(sFormat, "Shields", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
			ChatManager.SystemMessage(sMsg);
			-- Recalculate total bp spent.
			totalCurrentBuildPoints(nodeCharStarship);
			-- Recalculate total pcu.
			totalCurrentPCUPoints(nodeCharStarship);
	 
		-- WEAPONS
		elseif sSrcType == "Starship Weapon" then
			local nCurrentPCU = DB.getValue(nodeCharStarship, "pcu.current", 0);
			local nTotalPCU = DB.getValue(nodeCharStarship, "pcu.total", 0);
			
			local nSrcPCU = DB.getValue(nodeSource, "pcu", 0);
			local nSrcCost = DB.getValue(nodeSource, "cost", 0);
					
			if nCurrentPCU + nSrcPCU > nTotalPCU then
				-- Send warning status message
				local sFormat = Interface.getString("charstarship_message_starshippcuwarning");
				local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
			end
			
			if not isWeaponTypeSupported(nodeCharStarship, string.lower(sSrcSubType)) then
				-- Send error status message
				local sFormat = Interface.getString("charstarship_message_starshipweapontypewarning");
				local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", ""));
				ChatManager.SystemMessage(sMsg);
				return;
			end
			-- Log the bp spend
			
			
			logBuild(nodeCharStarship, "weapon", StringManager2.titleCase(sSrcName) .. " (Weapon)", nSrcCost);
			-- Log the pcu spend
			logPCU(nodeCharStarship, "weapon", StringManager2.titleCase(sSrcName) .. " (Weapon)", nSrcPCU);
			
			-- Add the weapon to the systems list
			addSystem(nodeCharStarship, sClass, sRecord);
			nodePendingWeaponDrop = nodeSource;
			
			-- Open dialog for selection of mountpoint
			local aMountPoints = getAvailableMountPoints(nodeCharStarship);
			local wSelect = Interface.openWindow("select_dialog", "");
			local sTitle = Interface.getString("charstarship_dialog_title_selectmountpoint");
			local sMessage = Interface.getString("charstarship_dialog_message_selectmountpoint");
			wSelect.requestSelection(sTitle, sMessage, aMountPoints, CharStarshipManager.onWeaponMountpointSelect, nodeCharStarship, 1);
						
			-- Send status message
			local sFormat = Interface.getString("charstarship_message_starshipadd");
			local sMsg = string.format(sFormat, "Weapon", sSrcName, DB.getValue(nodeCharStarship, "name", ""));
			ChatManager.SystemMessage(sMsg);
			-- Recalculate total bp spent.
			totalCurrentBuildPoints(nodeCharStarship);
			-- Recalculate total pcu.
			totalCurrentPCUPoints(nodeCharStarship);
		end	
	end
	return true;
end
function handleAddCrewMember(sUserName, sClass, sRecord, nodeCharStarship)
	if DB.isOwner(nodeCharStarship) then
	
		if User.isHost() then
			if (DB.getOwner(nodeCharStarship) == sUserName) and not (DB.getOwner(nodeCharStarship) == nil and sUserName == nil) then
				return;
			end
		end
	
		-- Variables
		local nodeSource = resolveRefNode(sRecord);
		
		-- Basic validation of source data node
		if not nodeSource then
			return;
		end

		nodePendingCrewDrop = nodeSource;
		
		local sSrcName = DB.getValue(nodePendingCrewDrop, "name", "");
		local nMaxCrew = DB.getValue(nodeCharStarship, "build.maxcrew", 0);
	 
		if DB.getChildCount(nodeCharStarship, "crew") >= nMaxCrew then
			-- Send warning message
			local sFormat = Interface.getString("charstarship_message_starshipmaxcrewwarning");			
			local sMsg = string.format(sFormat, sSrcName, DB.getValue(nodeCharStarship, "name", "Starship"));			
			ChatManager.SystemMessage(sMsg);
		end		
		
		
		-- Open dialog for selection of crew position
		local aCrewRoles = getAvailableCrewRoles(nodeCharStarship);
		local wSelect = Interface.openWindow("select_dialog", "");
		local sTitle = Interface.getString("charstarship_dialog_title_selectcrewrole");
		
		local sFormat = Interface.getString("charstarship_dialog_message_selectcrewrole");
		local sMsg = string.format(sFormat, sSrcName);
			
		-- local sMessage = Interface.getString("charstarship_dialog_message_selectcrewrole");
		wSelect.requestSelection(sTitle, sMsg, aCrewRoles, CharStarshipManager.onCrewRoleSelect, nodeCharStarship, 1);
		
	end
end

--
-- Dialog Handlers
--
function onWeaponMountpointSelect(aSelection, nodeCharStarship)
	if nodePendingWeaponDrop == nil then
		return;
	end
	
	local mountsListNode = DB.getChild(nodeCharStarship, "mounts");
	for _,sArc in ipairs(aSelection) do
		local bUpdated = false;
		for k,v in pairs(mountsListNode.getChildren()) do
			if DB.getValue(v, "configured", 0) ~= 1 and DB.getValue(v, "arc", 0) == string.lower(sArc) then
				if not bUpdated then
					DB.copyNode(nodePendingWeaponDrop, v);	
					DB.setValue(v, "type", "string", DB.getValue(nodePendingWeaponDrop, "subtype", ""):lower());
					DB.setValue(v, "special", "string", DB.getValue(nodePendingWeaponDrop, "specialproperties", ""));
					DB.setValue(v, "category", "string", string.lower(DB.getValue(nodePendingWeaponDrop, "category", "")));
					DB.setValue(v, "configured", "number", 1);
					bUpdated = true;
				end
			end
		
		end
	end
	nodePendingWeaponDrop = nil;
end
function onCrewRoleSelect(aSelection, nodeCharStarship)
	if nodePendingCrewDrop == nil then
		return;
	end
		
	local crewListNode = DB.getChild(nodeCharStarship, "crew");
	for _,sRole in ipairs(aSelection) do
		local sCrewRole = sRole:gsub("%s", "");
		for k,v in pairs(crewListNode.getChildren()) do
			if v.role and v.role.getValue() == sCrewRole:lower() then
				v.delete();
			end
		end
		
		local entryNode = DB.createChild(crewListNode);	
		local sPCNodeID = nodePendingCrewDrop.getName();
		local sUserName = User.getIdentityOwner(sPCNodeID);
		if sUserName ~= nil then
			entryNode.addHolder(sUserName, true);
		end
		DB.setValue(entryNode, "name", "string", DB.getValue(nodePendingCrewDrop, "name", ""));
		DB.setValue(entryNode, "token", "token", DB.getValue(nodePendingCrewDrop, "token", ""));
		DB.setValue(entryNode, "link", "windowreference", "charsheet", nodePendingCrewDrop.getNodeName());
		DB.setValue(entryNode, "role", "string", sRole);
		DB.setValue(entryNode, "roleclass", "string", "officer");	
		
	end	
	nodePendingCrewDrop = nil;
end

--
-- OOB Message Handlers
--
function handleAddInfoDB(sUserName, sClass, sRecord, nodeCharStarship) 
		
	if not nodeCharStarship then
		return false;
	end
	
	if sClass == "starship" then
		handleAddStarship(sUserName, sClass, sRecord, nodeCharStarship);
	elseif sClass == "starshipitem" then
		handleAddStarshipItem(sUserName, sClass, sRecord, nodeCharStarship);
	elseif sClass == "charsheet" then
		handleAddCrewMember(sUserName, sClass, sRecord, nodeCharStarship);
	else
		return false;
	end
	
	return true;
	
end

--
-- Helper Functions
--
function resolveRefNode(sRecord)
	local nodeSource = DB.findNode(sRecord);
	if not nodeSource then
		local sRecordSansModule = StringManager.split(sRecord, "@")[1];
		nodeSource = DB.findNode(sRecordSansModule .. "@*");
		if not nodeSource then
			ChatManager.SystemMessage(Interface.getString("char_error_missingrecord"));
		end
	end
	return nodeSource;
end
function containsBuildEntry(targetListNode, sType)
	for _,v in pairs(targetListNode.getChildren()) do
		if DB.getValue(v, "type", "") == sType then
			return true;
		end
	end
	return false;
end
function isValidBuild(nodeCharStarship)
	local nBPTotal = DB.getValue(nodeCharStarship, "build.bpmax", 0);
	local nBPCurrent = DB.getValue(nodeCharStarship, "build.bpcurrent", 0);
	return nBPCurrent <= nBPTotal;	
end
function isSizeSupported(sSize, sSrcSize)
--Debug.console(sSize, sSrcSize)
	local aSrcSize = StringManager.split(sSrcSize, ",", true);
	local sSrcExpandedSize = "";
	if aSrcSize ~= nil then
		for _,v in pairs(aSrcSize) do
			if v == "T" then
				sSrcExpandedSize = sSrcExpandedSize .. "Tiny,";
			elseif v == "S" then
				sSrcExpandedSize = sSrcExpandedSize .. "Small,";
			elseif v == "M" then
				sSrcExpandedSize = sSrcExpandedSize .. "Medium,";
			elseif v == "L" then
				sSrcExpandedSize = sSrcExpandedSize .. "Large,";
			elseif v == "H" then
				sSrcExpandedSize = sSrcExpandedSize .. "Huge,";
			elseif v == "G" then
				sSrcExpandedSize = sSrcExpandedSize .. "Gargantuan,";
			elseif v == "C" then
				sSrcExpandedSize = sSrcExpandedSize .. "Small,";
			end
		end
	end
	local aSrcExpandedSize = StringManager.split(sSrcExpandedSize, ",", false);
	local bSupported = false;
	for _,v in pairs(aSrcExpandedSize) do
		if sSize == v then
			bSupported = true;
		end
	end
	return bSupported;		
end
function isMaxSizeSupported(sSize, sSrcSize)
	if DataCommon.starshipsizes[string.lower(sSize)] <= DataCommon.starshipsizes[string.lower(sSrcSize)] then
		return true;
	end
end
function getCostFromSize(sSize, sSrcCost)
	local nMultiplier = tonumber(string.match(sSrcCost, "(%d+)"));
	local nCost = 0;
	if sSize == "Tiny" then
		nCost = 1 * nMultiplier;
	elseif sSize == "Small" then
		nCost = 2 * nMultiplier;
	elseif sSize == "Medium" then
		nCost = 3 * nMultiplier;
	elseif sSize == "Large" then
		nCost = 4 * nMultiplier;
	elseif sSize == "Huge" then
		nCost = 5 * nMultiplier;
	elseif sSize == "Gargantuan" then
		nCost = 6 * nMultiplier;
	elseif sSize == "Colossal" then
		nCost = 7 * nMultiplier;
	end
	return nCost;
end
function getAvailableCrewRoles(nodeCharStarship)
	local crewListNode = DB.getChild(nodeCharStarship, "crew");
	local bCaptain = false;
	local bPilot = false;
	local aRoles = {};
		
	for k, v in pairs(crewListNode.getChildren()) do
		if DB.getValue(v, "role", "") == "Captain" then
			bCaptain = true;
		elseif DB.getValue(v, "role", "") == "Pilot" then
			bPilot = true;
		end
	end
	
	if not bCaptain then
		table.insert(aRoles, "Captain");
	end
	
	if not bPilot then
		table.insert(aRoles, "Pilot");
	end
	
	table.insert(aRoles, "Engineer");
	table.insert(aRoles, "Gunner");
	table.insert(aRoles, "Science Officer");
		
	return aRoles;
end
function getAvailableMountPoints(nodeCharStarship)
	local mountsListNode = DB.getChild(nodeCharStarship, "mounts");
	local aMounts = {};
	for k,v in pairs(mountsListNode.getChildren()) do
		if DB.getValue(v, "configured", 0) == 0 then
			local sTitle = StringManager2.titleCase(DB.getValue(v, "arc", ""));
			table.insert(aMounts, sTitle);
		end
	end
	return aMounts;
end
function isWeaponTypeSupported(nodeCharStarship, sType)
	local mountsListNode = DB.getChild(nodeCharStarship, "mounts");
	for k,v in pairs(mountsListNode.getChildren()) do
		if DB.getValue(v, "configured", 0) == 0 and DB.getValue(v, "type", "") == sType then
			return true;
		end
	end
end
function getWeaponNames(nodeCharStarship, sArc)
	local aWeaponNames = {};
	local nodeMounts = DB.getChild(nodeCharStarship, "mounts");
	for k,v in pairs(nodeMounts.getChildren()) do
		local sVArc = DB.getValue(v, "arc", ""):lower();
		if sVArc == "" then 
			sVArc = "forward";
		end
		if sVArc == sArc:lower() then
			local sWeaponName = DB.getValue(v, "name", "");
			table.insert(aWeaponNames, sWeaponName);
		end
	end
	return aWeaponNames;
end
function getWeaponDamage(nodeCharStarship, sWeaponName)
	
	local nodeMounts = DB.getChild(nodeCharStarship, "mounts");
	for k,v in pairs(nodeMounts.getChildren()) do
		local sWeapon = DB.getValue(v, "name", "");
		if sWeaponName == "" then 
			sWeaponName = sWeapon;
		end
		if sWeapon:lower() == sWeaponName:lower() then
			return DB.getValue(v, "damage", "");
		end
	end
	return "";
end
function getStarshipWeaponArcs(nodeCharStarship)
	local aArcs = {["forward"] = false, ["aft"] = false, ["starboard"] = false, ["port"] = false, ["turret"] = false };
	local mountsListNode = DB.getChild(nodeCharStarship, "mounts");
	
	for k,v in pairs(mountsListNode.getChildren()) do
		aArcs[DB.getValue(v, "arc", "forward")] = true;
	end

	return aArcs;
end
function adjustCurrentPcuValue(nodeCharStarship)

end