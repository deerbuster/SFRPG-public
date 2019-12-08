-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if isReadOnly() then
		self.update(true);
	else
		local node = getDatabaseNode();
		if not node or node.isReadOnly() then
			self.update(true);
		end
	end
end

function isEmpty()
	return (getWindowCount() == 0);
end

function update(bReadOnly, bForceHide)
	local bLocalShow;
	if bForceHide then
		bLocalShow = false;
	else
		bLocalShow = true;
		if bReadOnly and not nohide and isEmpty() then
			bLocalShow = false;
		end
	end
	
	setVisible(bLocalShow);
	setReadOnly(bReadOnly);

	local sListName = getName();
	if window[sListName .. "_header"] then
		window[sListName .. "_header"].setVisible(bLocalShow);
	end
	
	local bEditMode = false;
	if window[sListName .. "_iedit"] then
		if bReadOnly then
			window[sListName .. "_iedit"].setValue(0);
			window[sListName .. "_iedit"].setVisible(false);
		else
			window[sListName .. "_iedit"].setVisible(true);
			bEditMode = (window[sListName .. "_iedit"].getValue() ~= 0);
		end
	end

	for _,w in ipairs(getWindows()) do
		if w.update then
			w.update(bReadOnly);
		end
		w.idelete.setVisibility(bEditMode);
	end
	
	return bLocalShow;
end

function addEntry()
	return createWindow();
end
