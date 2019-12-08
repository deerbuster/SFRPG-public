-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if not isReadOnly() then
		registerMenuItem(Interface.getString("menu_addability"), "insert", 6);
	end
end

function onMenuSelection(selection)
	if selection == 6 then
		addEntry(true);
	end
end

local bCounting = false;
function onListChanged()
	if not bCounting then
		bCounting = true;
		onAbilityCounterUpdate();
		bCounting = false;
	end
	
	window.windowlist.window.windowlist.update();
end

function update()
	if minisheet then
		return;
	end
	
	if bInit then
		local bEditMode = window.getEditMode();
		for _,w in ipairs(getWindows()) do
			w.update(bEditMode);
		end
	end
end

function onAbilityCounterUpdate()
	window.onAbilityCounterUpdate();
end

function addEntry(bFocus)
	local w = createWindow();
	
	-- Set the default points value
	local nodeParent = getDatabaseNode().getParent();
	if nodeParent then
		--local nCost = tonumber(string.sub(nodeParent.getName(), -1)) or 0;		
		DB.setValue(w.getDatabaseNode(), "cost", "number", 0);
	end
	
	-- Set the focus to the name if requested.
	if bFocus and w then			
		w.header.subwindow.name.setFocus();
	end
	
	return w;
end

function onEnter()
	if Input.isShiftPressed() then
		addEntry(true);
		return true;
	end
	
	return false;
end

function onFilter(w)
	return w.getFilter();
end

function onDrop(x, y, draginfo)
	-- Do not process message; pass it directly to level list
	return false;
end
