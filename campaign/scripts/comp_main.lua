-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode(), "abilities.*.base"), "onUpdate", onBonusChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "abilities.*.mod"), "onUpdate", onBonusChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "attackbonus.*.misc"), "onUpdate", onAttackChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "saves.*.base"), "onUpdate", onSavesChanged);
	DB.addHandler(DB.getPath(getDatabaseNode(), "level"), "onUpdate", update);
	update();
	onHealthChanged();	
end
function onClose()	
	DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities.*.base"), "onUpdate", onBonusChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities.*.mod"), "onUpdate", onBonusChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "attackbonus.*.misc"), "onUpdate", onAttackChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "saves.*.base"), "onUpdate", onSavesChanged);
	DB.removeHandler(DB.getPath(getDatabaseNode(), "level"), "onUpdate", update);
end

function onDrop(x, y, draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = getDatabaseNode();		
		if StringManager.contains({"race"}, sClass) then
			CharManager.addInfoDB(getDatabaseNode(), sClass, sRecord);					
		end
		update();
		return true;
	end
	
end

function onHealthChanged()
	-- Set HP Current Display. System still uses the wounds for Calulations.
	local nodeChar = getDatabaseNode();
	local nHpMax = DB.getValue(nodeChar, "hp.total", 0);						
	local nWounds = DB.getValue(nodeChar, "hp.wounds", 0);	
	local nHpCurrent = nHpMax - nWounds;
	if nHpCurrent < 0 then
		nHpCurrent = 0;
	end	
	DB.setValue(nodeChar, "hp.current", "number", nHpCurrent);						
	local sColorWounds = ActorManager2.getWoundColor("pc", getDatabaseNode());
	wounds.setColor(sColorWounds);	
end


--SFRPGAbility Score Editor

function onBonusChanged()
	local nodeChar = getDatabaseNode();	
	aStats = DB.getChildren(nodeChar, "abilities");
	
	for _,nodeStat in pairs (aStats) do
		local nScore = 0;
		local nBase = DB.getValue(nodeStat, "base", 0);
		local nMod = DB.getValue(nodeStat, "mod", 0);		
			nScore = nBase + nMod;
			DB.setValue(nodeStat, "score", "number", nScore);
	end
end

function onSavesChanged()
	local nodeChar = getDatabaseNode();	
	aStats = DB.getChildren(nodeChar, "saves");
	
	for _,nodeStat in pairs (aStats) do
		local nScore = 0;
		local nBase = DB.getValue(nodeStat, "base", 0);
		local nMisc = DB.getValue(nodeStat, "misc", 0);
		local nTemp = DB.getValue(nodeStat, "temporary", 0);
		
			nScore = nBase + nMisc + nTemp;
			DB.setValue(nodeStat, "total", "number", nScore);
	end
end

function onAttackChanged()
	local nodeChar = getDatabaseNode();	
	local nLevel = DB.getValue(nodeChar, "level", 0);
		CharManager.handleMeleeAttacks(nodeChar,nLevel);
end

function update()
    local nodeChar = getDatabaseNode();
	nReach = DB.getValue(nodeChar, "reach", 0);
	if nReach == 0 then
		reach.setVisible(false);
	else
		reach.setVisible(true);
	end
	
	updateControl("senses",true);
	updateControl("aura",true);
	updateControl("defensiveabilities",true);
	
	
	updateControl("speedspecial",true);
	updateControl("melee",true);
	updateControl("ranged",true);
	updateControl("space",true);
	updateControl("reach",true);
	updateControl("offensiveabilities",true);
	updateControl("reachnote",true);
	updateControl("spelllikeabilities",true);
	updateControl("skills",true);
	specialabilities_iedit.setVisible(false);
	
end
-- NOTE: If not using special hide on empty fields, then just set read only state.
function updateControl(sControl, bReadOnly, bForceHide)
	if not self[sControl] then
		return false;		
	end	
	if self[sControl].update then
		if bForceHide == nil then 
			bForceHide = false;
		end
		return self[sControl].update(bReadOnly, bForceHide);
	end
	self[sControl].setReadOnly(bReadOnly);
	return true;
end