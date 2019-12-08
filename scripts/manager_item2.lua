--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	PartyLootManager.setItemCostField("price");
end
-- Handle Companion Inventory Drop
function handleAnyDrop(vTarget, draginfo)
	local sDragType = draginfo.getType();
	if not User.isHost() then
		local sTargetType = getItemSourceType(vTarget);	
		if sTargetType == "item" then
			return false;
		elseif sTargetType == "treasureparcels" then
			return false;
		elseif sTargetType == "partysheet" then
			if sDragType ~= "shortcut" then
				return false;
			end
			local sClass, sRecord = draginfo.getShortcutData();
			if not LibraryData.isRecordDisplayClass("item", sClass) or not LibraryData.isRecordDisplayClass("itemtemplate", sClass) then
				return false;
			end
			local sSourceType = getItemSourceType(sRecord);
			if sSourceType ~= "charsheet" then
				return false;
			end
		elseif sTargetType == "charsheet" or "companionsheet" then
			if not DB.isOwner(vTarget) then
				return false;
			end
		end
	end

	if sDragType == "number" then
		handleString(vTarget, draginfo.getDescription(), draginfo.getNumberData());
		return true;

	elseif sDragType == "string" then
		handleString(vTarget, draginfo.getStringData());
		return true;

	elseif sDragType == "shortcut" then
		local sClass,sRecord = draginfo.getShortcutData();	
		if LibraryData.isRecordDisplayClass("item", sClass) or LibraryData.isRecordDisplayClass("itemtemplate", sClass) then
			
			local bTransferAll = false;
			local sSourceType = getItemSourceType(sRecord);	
			local sTargetType = getItemSourceType(vTarget);
			if StringManager.contains({"charsheet", "companionsheet", "partysheet"}, sSourceType) and StringManager.contains({"charsheet","companionsheet", "partysheet"}, sTargetType) then
				bTransferAll = Input.isShiftPressed();
			end

			handleItem(vTarget, nil, sClass, sRecord, bTransferAll);
			return true;
		elseif sClass == "treasureparcel" then
			ItemManager.handleParcel(vTarget, sRecord);
			return true;
		end
	end
	
	return false;
end
function getItemSourceType(vNode)
	return UtilityManager.getRootNodeName(vNode);
end
function handleItem(vTargetRecord, sTargetList, sClass, sRecord, bTransferAll)
	local nodeTargetRecord = nil;
	if type(vTargetRecord) == "databasenode" then
		nodeTargetRecord = vTargetRecord;
	elseif type(vTargetRecord) == "string" then
		nodeTargetRecord = DB.findNode(vTargetRecord);		
	end
	if not nodeTargetRecord then
		return;
	end
	
	if not sTargetList then
		local sTargetRecordType = getItemSourceType(nodeTargetRecord);
		if sTargetRecordType == "charsheet" or sTargetRecordType == "companionsheet" then
			sTargetList = "inventorylist";
			if ItemManager2 and ItemManager2.getCharItemListPath then
				sTargetList = ItemManager2.getCharItemListPath(vTargetRecord, sClass);
			end
		elseif sTargetRecordType == "treasureparcels" then
			sTargetList = "itemlist";
		elseif sTargetRecordType == "partysheet" then
			sTargetList = "treasureparcelitemlist";
		elseif sTargetRecordType == "item" then
			sTargetList = "";
		end
		if not sTargetList then
			return;
		end
	end
	sendItemTransfer(nodeTargetRecord.getPath(), sTargetList, sClass, sRecord, bTransferAll);
end
function sendItemTransfer (sTargetRecord, sTargetList, sClass, sRecord, bTransferAll)
	--for _,fHandler in ipairs(aCustomTransferNotifyHandlers) do
	--	if fHandler(DB.getPath(sTargetRecord, sTargetList), sClass, sRecord, bTransferAll) then
	--		return;
	--	end
	--end

	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_TRANSFERITEM;
	
	msgOOB.sTarget = sTargetRecord;
	msgOOB.sTargetList = sTargetList;
	msgOOB.sClass = sClass;
	msgOOB.sRecord = sRecord;
	if bTransferAll then
		msgOOB.sTransferAll = "true";
	end

	if not User.isHost() then
		local sSourceRecordType = getItemSourceType(sRecord);
		local sTargetRecordType = getItemSourceType(sTargetRecord);
		if not StringManager.contains({"partysheet", "charsheet"}, sSourceRecordType) and StringManager.contains({"charsheet", "companionsheet"}, sTargetRecordType) then
			ItemManager.handleItemTransfer(msgOOB);
			return;
		end
	else
		ItemManager.handleItemTransfer(msgOOB);
	end

	Comm.deliverOOBMessage(msgOOB, "");
end

--End Handle Companion Inventory Drop

function isArmor(vRecord)
	local bIsArmor = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end

	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	local sSubtypeLower = StringManager.trim(DB.getValue(nodeItem, "subtype", "")):lower();

	if (sTypeLower == "armor") then
		bIsArmor = true;
	elseif StringManager.contains({"shield", "shields"}, sTypeLower) then
		bIsArmor = true;
		sTypeLower = "armor";
		sSubtypeLower = "shield";
	elseif StringManager.contains({"armor template"}, sTypeLower) then
		bIsArmor = true;
		sTypeLower = "armor template";
		sSubtypeLower = "upgrade";
	end
	if sSubtypeLower == "shields" then
		sSubtypeLower = "shield";
	end

	return bIsArmor, sTypeLower, sSubtypeLower;
end

function isWeapon(vRecord)
	local bIsWeapon = false;

	local nodeItem;
	if type(vRecord) == "string" then
		nodeItem = DB.findNode(vRecord);
	elseif type(vRecord) == "databasenode" then
		nodeItem = vRecord;
	end
	if not nodeItem then
		return false, "", "";
	end

	local sTypeLower = StringManager.trim(DB.getValue(nodeItem, "type", "")):lower();
	local sSubtypeLower = StringManager.trim(DB.getValue(nodeItem, "subtype", "")):lower();

	if sClass == "item" then
		if ((sTypeLower == "weapon") and (sSubtypeLower ~= "ammunition")) or (sSubtypeLower == "weapon fusion") then
			bIsWeapon = true;
		end
	end

	return bIsWeapon, sTypeLower, sSubtypeLower;
end

function addItemToList2(sClass, nodeSource, nodeTarget)
	if LibraryData.isRecordDisplayClass("item", sClass) or LibraryData.isRecordDisplayClass("itemtemplate", sClass) then
		DB.copyNode(nodeSource, nodeTarget);
		DB.setValue(nodeTarget, "isidentified", "number", 1);
		return true;
	end

	return false;
end

function onEncumbranceChanged(nodeChar)

	local nEncStr = DB.getValue(nodeChar, "encumbrance.stradj", 0);
	local nCharStr = DB.getValue(nodeChar, "abilities.strength.score", 10);
	local nStrArmor = DB.getValue(nodeChar, "encumbrance.encpower", 0);
	local nStrOther = DB.getValue(nodeChar, "encumbrance.encother", 0);

	if nStrArmor > 0 then
		nStrength = (nStrArmor + nStrOther);
	else
		nStrength = ((nCharStr + nEncStr)+ nStrOther);
	end


	local nEncStr = 0;
	for _,vNode in pairs(DB.getChildren(nodeChar, "inventorylist")) do
		if DB.getValue(vNode, "carried", 0) == 2 then
			nItemEncStr = DB.getValue(vNode, "strength_enc", 0);
			nEncStr = nEncStr + nItemEncStr;
		end
	end

	local nLight = math.floor(nStrength + nEncStr) / 2;

	local nMedium = nStrength + nEncStr;
	local nHeavy = (nMedium + 1);


	DB.setValue(nodeChar, "encumbrance.lightload", "number", math.floor(nLight));
	DB.setValue(nodeChar, "encumbrance.mediumload", "number", nMedium);
	DB.setValue(nodeChar, "encumbrance.heavyload", "number", nHeavy);
	DB.setValue(nodeChar, "encumbrance.strmodtemp", "number", nEncStr);

	local nEncLoad = DB.getValue(nodeChar, "encumbrance.load", 0);
	local nEncStat = 0;
	--local nLight = math.floor( nStrength / 2)+ nEncStr;
	--local nLight = math.floor(nStrength + nEncStr) / 2;
	--local nMedium = nStrength + nEncStr;
	--local nHeavy = (nStrength + 1)+ nEncStr;

	if nEncLoad >= nHeavy then
		nEncStat = 3;
		DB.setValue(nodeChar, "encumbrance.encstat", "number",nEncStat);
	elseif nEncLoad < nHeavy and  nEncLoad > nLight then
		nEncStat = 2;
		DB.setValue(nodeChar, "encumbrance.encstat", "number",nEncStat);
	--elseif nEncLoad <= nMedium and  nEncLoad > nLight then
	--nEncStat = 2;
	elseif nEncLoad <= nLight then
		nEncStat = 1;
		DB.setValue(nodeChar, "encumbrance.encstat", "number",nEncStat);
	end

	if nEncStat == 3 then
		DB.setValue(nodeChar, "encumbrance.state", "string", "Overburdened");
	--local sEncRank = "Overburdened"
	--local sFormat = Interface.getString("message_encumbrance_changed");
	--local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", ""),sEncRank);
	--ChatManager.SystemMessage(sMsg);
	elseif nEncStat == 2 then

		DB.setValue(nodeChar, "encumbrance.state", "string", "Encumbered");
	--local sEncRank = "Encumbered"
	--local sFormat = Interface.getString("message_encumbrance_changed");
	--local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", ""),sEncRank);
	--ChatManager.SystemMessage(sMsg);
	elseif nEncStat == 1 then

		DB.setValue(nodeChar, "encumbrance.state", "string", "Unencumbered");
	--local sEncRank = "Unencumbered"
	--local sFormat = Interface.getString("message_encumbrance_changed");
	-- local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", ""),sEncRank);
	--ChatManager.SystemMessage(sMsg);
	end
	-- if (sEncRankOriginal ~= sEncRank ) then
	--      local sFormat = Interface.getString("message_encumbrance_changed");
	--      local sMsg = string.format(sFormat, DB.getValue(nodeChar, "name", ""),sEncRank,nBaseEnc);
	--      ChatManager.SystemMessage(sMsg);
	--    end
end
