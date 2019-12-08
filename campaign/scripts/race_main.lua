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
	local node = getDatabaseNode()	
	local sTypeRecord = DB.getValue(node, "racetype", "");
		
	local sClass = getClass();	
	-- Update labels based on system being played and NPC type
	if sClass == "race_pc_stats" then
		local bSection1 = false;
		if summary.update(bReadOnly) then bSection1 = true; end
		local bSection2 = false;
			if size.update(bReadOnly) then bSection2 = true; end
			if type.update(bReadOnly) then bSection2 = true; end
			if subtype.update(bReadOnly) then bSection2 = true; end
			if hp.update(bReadOnly) then bSection2 = true; end
				
			divider.setVisible(bSection1 and bSection2);

			abilitymods.update(bReadOnly);	
			traits.update(bReadOnly);
		
	elseif sClass == "race_comp_stats" then
		sFort = DB.getValue(node, "fort", "");
		sRef = DB.getValue(node, "ref", "");
		sWill = DB.getValue(node, "will", "");
		sSaves = ("FORT: " .. sFort .. ", REF: " .. sRef .. ", WILL: " .. sWill);
		DB.setValue(node, "saves", "string", sSaves);
		local bSection1 = false;
		if summary.update(bReadOnly) then bSection1 = true; end
		local bSection2 = false;
			if subtype.update(bReadOnly) then bSection2 = true; end		
			divider.setVisible(bSection1 and bSection2);
			
			updateControl("size", bReadOnly);
			updateControl("level", bReadOnly);
			updateControl("levelrange", bReadOnly);
			updateControl("type", bReadOnly);
			updateControl("senses", bReadOnly);
			updateControl("aura", bReadOnly);
			updateControl("speed", bReadOnly);
			updateControl("melee", bReadOnly);
			updateControl("ranged", bReadOnly);
			updateControl("space", bReadOnly);
			updateControl("reach", bReadOnly);
			updateControl("reachnote", bReadOnly);
			updateControl("skills", bReadOnly);
			updateControl("defensiveabilities", bReadOnly);			
			updateControl("offensiveabilities", bReadOnly);
			updateControl("spelllikeabilities", bReadOnly);
			updateControl("saves", bReadOnly);
			
			abilitymods.update(bReadOnly);	
			fort.setVisible(not bReadOnly);
			ref.setVisible(not bReadOnly);
			will.setVisible(not bReadOnly);
			fort_label.setVisible(not bReadOnly);
			ref_label.setVisible(not bReadOnly);
			will_label.setVisible(not bReadOnly);
			saves_label.setVisible(bReadOnly);
			saves.setVisible(bReadOnly);
			specialabilities_iedit.setVisible(not bReadOnly)
			--specialabilities.update(bReadOnly);
			
		
	end
end
-- function update()
	-- local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());		local sTypeRecord = window.racetype.getValue();		
				
-- local bSection1 = false;
	-- if summary.update(bReadOnly) then bSection1 = true; end
				
	-- local bSection2 = false;
		-- if size.update(bReadOnly) then bSection2 = true; end
		-- if type.update(bReadOnly) then bSection2 = true; end
		-- if subtype.update(bReadOnly) then bSection2 = true; end
		-- if hp.update(bReadOnly) then bSection2 = true; end
				
		-- divider.setVisible(bSection1 and bSection2);

		-- abilitymods.update(bReadOnly);	
		-- traits.update(bReadOnly);
-- end