-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	registerMenuItem(Interface.getString("list_menu_createitem"), "insert", 5);
	
	constructDefaultSkills();
	CharManager.updateSkillPoints(window.getDatabaseNode());

	local nodeChar = getDatabaseNode().getParent();
	DB.addHandler(DB.getPath(nodeChar, "abilities"), "onChildUpdate", onStatUpdate);
	DB.addHandler(DB.getPath(nodeChar, "skilllist"), "onChildUpdate", update);
	DB.addHandler(DB.getPath(nodeChar, "skilllist"), "onChildAdded", onSkillDataUpdate);
	DB.addHandler(DB.getPath(nodeChar, "skilllist"), "onChildDeleted", onSkillDataUpdate);
end

function onClose()
	local nodeChar = getDatabaseNode().getParent();
	DB.removeHandler(DB.getPath(nodeChar, "abilities"), "onChildUpdate", onStatUpdate);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist"), "onChildUpdate", update);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist"), "onChildAdded", onSkillDataUpdate);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist"), "onChildDeleted", onSkillDataUpdate);
end

function onSkillDataUpdate()
	CharManager.updateSkillPoints(window.getDatabaseNode());
end

function onListChanged()
	update();
end

function update()
	local nodeChar = getDatabaseNode().getParent();
	local bEditMode = (window.skills_iedit.getValue() == 1);
	local bOperative = false;
	window.idelete_header.setVisible(bEditMode);
	window.freeskillpoints.setVisible(false);
	window.free_label.setVisible(false);
	--Set Labels according to Edit Mode
	window.misc_label.setVisible(not bEditMode);
	window.stat_label.setVisible(not bEditMode);
	window.ranks_label.setVisible(not bEditMode);

	window.miscmod_label.setVisible(bEditMode);
	window.divmod_label.setVisible(bEditMode);
	window.enhmod_label.setVisible(bEditMode);
	window.insmod_label.setVisible(bEditMode);
	window.lukmod_label.setVisible(bEditMode);
	window.mormod_label.setVisible(bEditMode);
	window.racmod_label.setVisible(bEditMode);

	for _,class in pairs(DB.getChildren(nodeChar, "classes")) do
			if DB.getValue(class, "name", "") == "Operative" then
			window.freeskillpoints.setVisible(true);
			window.free_label.setVisible(true);
			end
	end

	for _,w in ipairs(getWindows()) do
		local bAllowDelete = w.isCustom();
		w.stat.setVisible(not bEditMode);
		w.statname.setVisible(not bEditMode);
		w.ranks.setVisible(not bEditMode);
		w.showonminisheet.setVisible(not bEditMode);
		w.state.setVisible(not bEditMode);
		w.ranks.setVisible(not bEditMode);
		w.shortcut.setVisible(not bEditMode);
		w.total.setVisible(not bEditMode);

--Set Bonus Type Visibility
		w.miscmod.setVisible(bEditMode);
		w.divinemod.setVisible(bEditMode);
		w.enhancementmod.setVisible(bEditMode);
		w.insightmod.setVisible(bEditMode);
		w.luckmod.setVisible(bEditMode);
		w.moralemod.setVisible(bEditMode);
		w.racialmod.setVisible(bEditMode);
		if w.freeskill.getValue() == 1 then
			w.freeranks.setVisible(not bEditMode);
		else
			w.freeranks.setVisible(false);
		end
		if not bAllowDelete then
			local sLabel = w.label.getValue();
			local rSkill = DataCommon.skilldata[sLabel];
			if rSkill and rSkill.sublabeling then
				bAllowDelete = true;
			end
		end

		if bAllowDelete then
			w.idelete_spacer.setVisible(false);
			w.idelete.setVisibility(bEditMode);
		else
			w.idelete_spacer.setVisible(bEditMode);
			w.idelete.setVisibility(false);
		end
		local sLabel = w.label.getValue();
		local rSkill = DataCommon.skilldata[sLabel];

		local bTrainedOnly = (rSkill and rSkill.trainedonly);
		--local bTrainedOnly = (rSkill.trainedonly);
		local nRanks = w.ranks.getValue();
		local nFreeRanks = w.freeranks.getValue();
	--	--Debug.chat("Ranks", nRanks + nFreeRanks)
		if (nRanks + nFreeRanks) ~= 0 then
			--w.total.setColor(nil);
			w.total.setBackColor(nil);
		end
		if bTrainedOnly == 1 and (nRanks + nFreeRanks) == 0 then
			--w.total.setColor("BB0000");
			w.total.setBackColor("DA7D7D");
		end
		--Update Total Skill Bonus
		nMiscTotal = w.miscmod.getValue() + w.divinemod.getValue() + w.enhancementmod.getValue() + w.insightmod.getValue() + w.luckmod.getValue() + w.moralemod.getValue() + w.racialmod.getValue();
		w.misc.setValue(nMiscTotal);
	end

end

function onStatUpdate()
	for _,w in pairs(getWindows()) do
		w.onStatUpdate();
	end
end

function addEntry(bFocus)
	local w = createWindow();
	w.setCustom(true);
	if bFocus and w then
		w.label.setFocus();
	end
	return w;
end

function onMenuSelection(item)
	if item == 5 then
		addEntry(true);
	end
end

-- Create default skill selection
function constructDefaultSkills()
	local aSystemSkills = DataCommon.skilldata;

	-- Create missing entries for all known skills
	local entrymap = {};
	for _,w in pairs(getWindows()) do
		local sLabel = w.label.getValue();

		local t = aSystemSkills[sLabel];
		if t and not t.sublabeling then
			if not entrymap[sLabel] then
				entrymap[sLabel] = { w };
			else
				table.insert(entrymap[sLabel], w);
			end
		end
	end

	-- Set properties and create missing entries for all known skills
	for k, t in pairs(DataCommon.skilldata) do
		if not t.sublabeling then
			local matches = entrymap[k];

			if not matches then
				local w = createWindow();
				if w then
					w.label.setValue(k);
					if t.stat then
						w.statname.setStringValue(t.stat);
					else
						w.statname.setStringValue("");
					end
					if t.trainedonly then
						w.showonminisheet.setValue(0);
					end
					matches = { w };
				end
			end
		end
	end

	-- Set properties for all skills
	for _,w in pairs(getWindows()) do
		w.updateWindow();
	end
end

function addNewInstance(sLabel)
	local rSkill = DataCommon.skilldata[sLabel];
	if rSkill and rSkill.sublabeling then
		local w = createWindow();
		w.label.setValue(sLabel);
		w.statname.setStringValue(rSkill.stat);
		w.updateWindow();
		w.sublabel.setFocus();
		onListChanged();
	else
		local w = createWindow();
		w.label.setValue(sLabel);
		w.updateWindow();
		w.sublabel.setFocus();
		onListChanged();
	end
end
