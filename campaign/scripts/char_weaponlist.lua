-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);

	onModeChanged();
end

function onListChanged()
	DB.removeHandler(DB.getPath(getDatabaseNode()), "onChildAdded", onChildAdded);

	update();
end

function onChildAdded()
	onModeChanged();
	update();
end

function onModeChanged()					
	if not minisheet then	
		local bPrepModeSpells = (DB.getValue(window.getDatabaseNode(), "abilitymode", "") == "preparation");
			for _,w in ipairs(getWindows()) do			
				w.carried.setVisible(bPrepModeSpells);
			end				
	end
	
	applyFilter();
end

function update()
	if minisheet then
		return;
	end

	local bEditMode = window.getEditMode();
	for _,w in pairs(getWindows()) do
		w.idelete.setVisibility(bEditMode);
	end
end

function addEntry(bFocus)
	local w = createWindow();
	if bFocus and w then
		w.name.setFocus();
	end
	return w;
end

function onDrop(x, y, draginfo)
	return CharManager.onActionDrop(draginfo, window.getDatabaseNode());
end

function onFilter(w)
	if minisheet then
		if (w.carried.getValue() < 2) then
			return false;
		end
	else
		if (DB.getValue(window.getDatabaseNode(), "abilitymode", "") == "combat") and (w.carried.getValue() < 2) then
			return false;
		end
		if (DB.getValue(window.getDatabaseNode(), "abilitymode", "") == "") and (w.carried.getValue() < 2) then
			return false;
		end
	end
	
	return true;
end
