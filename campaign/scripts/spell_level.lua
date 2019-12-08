-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local bShow = true;

function onInit()
	local node = getDatabaseNode();
	if not node then
		return;
	end
	
	local nLevel = tonumber(string.sub(node.getName(), 6)) or 0;
	DB.setValue(node, "level", "number", nLevel);

	updateLabel();
	
	if not windowlist.isReadOnly() then
		registerMenuItem(Interface.getString("menu_addspell"), "insert", 5);
	end
end

function update(bEditMode)
	if minisheet then
		return;
	end
	
	spells_iadd.setVisible(bEditMode);
	for _,w in ipairs(spells.getWindows()) do
		w.update(bEditMode);
	nodeSpell = w.getDatabaseNode();

	sSpellName = DB.getValue(nodeSpell, "name", "");
	sSave = DB.getValue(nodeSpell, "save", "");
	sSaveThrow = DB.getValue(nodeSpell, "savingthrow","");
		if sSave == "" then
			DB.setValue(nodeSpell, "save", "string", sSaveThrow);
		end
	
	end
end

function setFilter(bFilter)
	bShow = bFilter;
end

function getFilter()
	return bShow;
end

function updateLabel()

	local sLabel = "Level " .. DB.getValue(getDatabaseNode(), "level", 0);
	
	label.setValue(sLabel);
end
	
function onSpellCounterUpdate()
	windowlist.window.onSpellCounterUpdate();
end

function onMenuSelection(selection, subselection)
	if selection == 5 then
		spells.addEntry(true);
	end
end

function onClickDown(button, x, y)
	return true;
end

function onClickRelease(button, x, y)
	if DB.getChildCount(spells.getDatabaseNode(), "") == 0 then
		spells.addEntry(true);
		return true;
	end

	spells.setVisible(not spells.isVisible());
	return true;
end
