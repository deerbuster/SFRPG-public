-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	update();
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

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local sClass = getClass();
	local nodeNPC = getDatabaseNode();
	
	-- Update labels based on system being played and NPC type
	if sClass == "npc_combat_creature" then
		updateControl("size", bReadOnly, bReadOnly);
		updateControl("type", bReadOnly, bReadOnly);
		updateControl("subtype", bReadOnly, bReadOnly);
		updateControl("race", bReadOnly);
		updateControl("grafts", bReadOnly);
		updateControl("alignment", bReadOnly);	
		updateControl("cr", bReadOnly);	
		updateControl("init", bReadOnly);	
		updateControl("xp", bReadOnly);	
		updateControl("senses", bReadOnly);
		updateControl("aura", bReadOnly);
		--DEFENSE CONTROLS
		updateControl("eac", bReadOnly);
		updateControl("kac", bReadOnly);
		updateControl("hp", bReadOnly);
		updateControl("rp", bReadOnly);
		updateControl("fortitudesave", bReadOnly);
		updateControl("reflexsave", bReadOnly);
		updateControl("willsave", bReadOnly);
		updateControl("defensiveabilities", bReadOnly);
		updateControl("weaknesses", bReadOnly);
		--OFFENSE CONTROLS
		local bShowOffenseHeader = true;
		if not updateControl("speed", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("melee", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("multiatk", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("ranged", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("space", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("reach", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("spacereachnote", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("offensiveabilities", bReadOnly) then bShowOffenseHeader = false; end
		if not updateControl("spelllikeabilities", bReadOnly) then bShowOffenseHeader = false; end
		offense_header.setVisible(bShowOffenseHeader);
		--STATISTICS CONTROLS
		updateControl("strength", bReadOnly);
		updateControl("strength_modtext", bReadOnly);
		updateControl("dexterity", bReadOnly);
		updateControl("dexterity_modtext", bReadOnly);
		updateControl("constitution", bReadOnly);
		updateControl("constitution_modtext", bReadOnly);
		updateControl("intelligence", bReadOnly);
		updateControl("intelligence_modtext", bReadOnly);
		updateControl("wisdom", bReadOnly);
		updateControl("wisdom_modtext", bReadOnly);
		updateControl("charisma", bReadOnly);
		updateControl("charisma_modtext", bReadOnly);
		updateControl("skills", bReadOnly);
		updateControl("feats", bReadOnly);
		updateControl("languages", bReadOnly);
		updateControl("otherabilities", bReadOnly);
		--ECOLOGY CONTROLS
		local bShowEcologyHeader = true;
		if not updateControl("environment", bReadOnly) then bShowEcologyHeader = false; end
		if not updateControl("organization", bReadOnly) then bShowEcologyHeader = false; end
		ecology_header.setVisible(bShowEcologyHeader);
		-- SPECIAL ABILITY LIST
		specialabilities.update(bReadOnly);
		
	elseif sClass == "npc_combat_trap" then
		local bRanged = false;
		updateControl("hp", bReadOnly);
		updateControl("type", bReadOnly, bReadOnly);
		updateControl("perception", bReadOnly);
		updateControl("disable", bReadOnly);
		updateControl("init", bReadOnly);
		updateControl("eac", bReadOnly);
		updateControl("kac", bReadOnly);
		updateControl("goodsave", bReadOnly);
		updateControl("poorsave", bReadOnly);
		updateControl("space", bReadOnly);
		updateControl("reach", bReadOnly);		
		updateControl("attack", bReadOnly);
		updateControl("savedc", bReadOnly);
		updateControl("damage", bReadOnly);
		updateControl("trigger", bReadOnly);
		updateControl("duration", bReadOnly);
		updateControl("reset", bReadOnly);
		updateControl("bypass", bReadOnly);
		updateControl("effect", bReadOnly);
		updateControl("initialeffect", bReadOnly);
		updateControl("secondaryeffect", bReadOnly);
		
	end	
end
