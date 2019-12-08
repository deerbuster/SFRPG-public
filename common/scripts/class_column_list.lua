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
		elseif w.name then
			w.name.setReadOnly(bReadOnly);
		end
		w.idelete.setVisibility(bEditMode);
	end
	return bLocalShow;
end
function upDateBaseFeatures(nodeClass, nodeTarget)
	--Setup
	local nodeTarget= DB.createChild(nodeClass, "features"); 
	local sClass = DB.getValue(nodeClass, "name", "");
	local nodeFeatures = nodeClass.getParent().getParent();
	local sNodeName = nodeFeatures.getNodeName();
	sNode = StringManager.split(sNodeName, "@","");	
	local node = DB.getPath(nodeFeatures, "classfeature." .. sClass:lower());	
	local aFeatures = DB.getChildrenGlobal(node);
	
	aTarget = DB.getChildren(nodeTarget, "");	
	for _,k in pairs (aFeatures) do
	local bFound = false;
	local sAName = DB.getValue(k, "name", "");
	local sFeatureAbility = DB.getValue(k, "feature","");	
	local nALevel = DB.getValue(k, "level", 0);		
	for _,f in pairs (aTarget) do
		sBName = DB.getValue(f, "name", "");
		nBLevel = DB.getValue(f, "level", 0);		
			if sAName == sBName and nALevel == nBLevel then
				bFound = true;
			end
	end		
	if not bFound then	
		local vNew = nodeTarget.createChild();
		local nLevel = DB.getValue(k, "level", 0);
		DB.copyNode(k, vNew);
		DB.setValue(vNew, "name", "string", sAName);
		DB.setValue(vNew, "level", "number", nLevel);	
		DB.setValue(vNew, "locked", "number", 1);			
	end	
		upDateFeatureAbilities(nodeClass)
end	
	
end
function upDateFeatureAbilities(nodeClass)	
	--Setup
	local nodeBase = nodeClass.getParent().getParent();
	local sClass = DB.getValue(nodeClass, "name", "");		
	local sNodeName = nodeBase.getNodeName();
	sNode = StringManager.split(sNodeName, "@","");	
	local node = DB.getPath(nodeBase, "classfeatureability." .. sClass:lower());	
	local aAbilities = DB.getChildrenGlobal(node); 
	
	local aClassFeatures = DB.getChildren(nodeClass, "features");  
	for _,f in pairs (aClassFeatures) do	
		local nodeTarget = DB.createChild(f, "abilities");
		local sFName = DB.getValue(f, "name","");
		local nFLevel = DB.getValue(f, "level", 0);
		for _,a in pairs (aAbilities) do
			local sAName = DB.getValue(a, "name","");
			local nALevel = DB.getValue(a, "level", 0);
			local sAFeatureType = DB.getValue(a, "feature", "");
			local aFeatureAbilityList = DB.getChildren(f, "abilities"); 
			local bFound = false;
			if sAFeatureType == sFName and nALevel <= nFLevel then
				for _,FAL in pairs (aFeatureAbilityList) do
					if DB.getValue(FAL, "name", "") == sAName then
						bFound = true;
					end
				end
				if not bFound then	
					local vNew = nodeTarget.createChild();					
					DB.copyNode(a, vNew);
					DB.setValue(vNew, "name", "string", sAName);
					DB.setValue(vNew, "level", "number", nALevel);	
					DB.setValue(vNew, "locked", "number", 1);			
				end	
			end			
		end
	end
end
function upDateBaseSpecialFeatures(nodeClass)	
	--Setup
	local nodeTarget= DB.createChild(nodeClass, "specialfeatures"); 
	local sClass = DB.getValue(nodeClass, "name", "");
	local nodeFeatures = nodeClass.getParent().getParent();
	local sNodeName = nodeFeatures.getNodeName();
	sNode = StringManager.split(sNodeName, "@","");	
	local node = DB.getPath(nodeFeatures, "classspecialfeature." .. sClass:lower());	
	local aFeatures = DB.getChildrenGlobal(node);
	
	aTarget = DB.getChildren(nodeTarget, "");
	for _,k in pairs (aFeatures) do
	local bFound = false;
	local sAName = DB.getValue(k, "name", "");
	local sFeatureAbility = DB.getValue(k, "feature","");	
	local nALevel = DB.getValue(k, "level", 0);		
		for _,f in pairs (aTarget) do
			sBName = DB.getValue(f, "name", "");
			nBLevel = DB.getValue(f, "level", 0);		
				if sAName == sBName and nALevel == nBLevel then
					bFound = true;
				end
		end	
	end
	if not bFound then
		for _,k in pairs (aFeatures) do
			local sListName = DB.getValue(k, "name", "");
			local nLevel = DB.getValue(k, "level", 0);
			local vNew = nodeTarget.createChild();		
				DB.copyNode(k, vNew);
				DB.setValue(vNew, "name", "string", sListName);
				DB.setValue(vNew, "level", "number", nLevel);	
				DB.setValue(vNew, "locked", "number", 1);
		end	
	end
end