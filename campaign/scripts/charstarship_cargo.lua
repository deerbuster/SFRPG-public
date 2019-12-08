-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	onEncumbranceChanged();
	DB.addHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", onStrengthChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.load"), "onUpdate", onLoadChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.strmod"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.stradj"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.encpower"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.encother"), "onUpdate", onEncumbranceChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", onSizeChanged);
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", onStrengthChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", onSizeChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.load"), "onUpdate", onLoadChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.strmod"), "onUpdate", onEncumbranceChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.stradj"), "onUpdate", onEncumbranceChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.encpower"), "onUpdate", onEncumbranceChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.encother"), "onUpdate", onEncumbranceChanged);
end

function onStrengthChanged()
	onEncumbranceChanged();
end

function onSizeChanged()
	onEncumbranceChanged();
end
function onLoadChanged()
	onEncumbranceChanged();
end

function onEncumbranceChanged()
	local nodeChar = getDatabaseNode();	
	
	local nEncStr = DB.getValue(nodeChar, "encumbrance.stradj", 0);
	local nCharStr = DB.getValue(nodeChar, "abilities.strength.score", 10);
	local nStrArmor = DB.getValue(nodeChar, "encumbrance.encpower", 0);
	local nStrOther = DB.getValue(nodeChar, "encumbrance.encother", 0);
	
	if nStrArmor > 0 then
		nStrength = (nStrArmor + nStrOther);
	else	
		nStrength = ((nCharStr + nEncStr)+ nStrOther);	
	end
		
	
	local nLight = math.floor( nStrength / 2);
	local nMedium = nStrength;
	local nHeavy = nStrength + 1;	
	
		DB.setValue(nodeChar, "encumbrance.lightload", "number", nLight);
		DB.setValue(nodeChar, "encumbrance.mediumload", "number", nMedium);
		DB.setValue(nodeChar, "encumbrance.heavyload", "number", nHeavy);
		DB.setValue(nodeChar, "encumbrance.strmodtemp", "number", nEncStr);
		
	local nEncLoad = DB.getValue(nodeChar, "encumbrance.load", 0);
	local nEncStat = 0;
	local nLight = math.floor( nStrength / 2);
	local nMedium = nStrength;
	local nHeavy = nStrength + 1;
	
	
	if nEncLoad >= nHeavy then
		nEncStat = 3;
		DB.setValue(nodeChar, "encumbrance.encstat", "number",nEncStat);
	elseif nEncLoad <= nMedium and  nEncLoad > nLight then
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
