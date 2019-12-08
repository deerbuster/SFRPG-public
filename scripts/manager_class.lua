

function onInit()

end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update();
	end
	if main.subwindow then
		main.subwindow.update();
	end
	if features.subwindow then
		main.subwindow.update();
	end
	if specialfeatures.subwindow then
		main.subwindow.update();
	end
	if other.subwindow then
		other.subwindow.update();
	end
end

function upDateAllClasses(aClasses, sCallSource)
	local msg = {font = "msgfont"};

	for _,class in pairs (aClasses) do
		local sClass = DB.getValue(class, "name", ""):lower();

		local bSpecial = DataCommon.classdata[sClass].specialability;
		upDateBaseFeatures(class);
		upDateFeatureAbilities(class);
		if bSpecial then
			upDateBaseSpecialFeatures(class);
		end
	end

	if sCallSource == "button" then
		msg.text = "[Class Features Updated]";
		Comm.deliverChatMessage(msg);
	end
end

function upDateBaseFeatures(nodeClass)
	--Setup
	local nodeTarget= DB.createChild(nodeClass, "features");
	local sClassNodeName = nodeClass.getNodeName();
	local aClassNode = StringManager.split(sClassNodeName, "@","");
	aClassNode = StringManager.split(aClassNode[1], ".","");
	local sClass = aClassNode[3];

	local nodeFeatures = nodeClass.getParent().getParent();
	local sNodeName = nodeFeatures.getNodeName();
	local node = DB.getPath(nodeFeatures, "classfeature." .. sClass:lower());
	local aFeatures = DB.getChildrenGlobal(node);

	local aTarget = DB.getChildren(nodeTarget, "");
	local aNew = aTarget;
	for _,k in pairs (aFeatures) do
		local bFound = false;
		local sAName = DB.getValue(k, "name", "");
		local sFeatureAbility = DB.getValue(k, "feature","");
		local nALevel = DB.getValue(k, "level", 0);
		-- Get Source Book Name
		local sSourceName = k.getNodeName();
		local aSoruceName = StringManager.split(sSourceName, "@","");
		local sSource = aSoruceName[2];
		for _,f in pairs (aTarget) do
			local sBName = DB.getValue(f, "name", "");
			local nBLevel = DB.getValue(f, "level", 0);
			if sAName == sBName and nALevel == nBLevel then
				bFound = true;
			end
		end
		if not bFound then
			local nLevel = DB.getValue(k, "level", 0);
			if nLevel ~= 21 then
				local vNew = nodeTarget.createChild();
				DB.copyNode(k, vNew);
				DB.setValue(vNew, "name", "string", sAName);
				DB.setValue(vNew, "level", "number", nLevel);
				DB.setValue(vNew, "locked", "number", 1);
				DB.setValue(vNew, "source", "string", sSource);
			end
		end
	end
	upDateFeatureAbilities(nodeClass)
end

function upDateFeatureAbilities(nodeClass)
	--Setup
	local nodeBase = nodeClass.getParent().getParent();
	if nodeBase == nil then
		nodeBase = DB.getRoot();
	end
	local sClassNodeName = nodeClass.getNodeName();
	local aClassNode = StringManager.split(sClassNodeName, "@","");
	aClassNode = StringManager.split(aClassNode[1], ".","");
	local sClass = aClassNode[3];
	if sClass == nil then
		sClass = DB.getValue(nodeClass, "class", "");
	end
	local sNodeName = nodeBase.getNodeName();
	local node = DB.getPath(nodeBase, "classfeatureability." .. sClass:lower());
	local aAbilities = DB.getChildrenGlobal(node); -- List all Abilities Global
	local aClassFeatures = DB.getChildren(nodeClass, "features");
	for _,f in pairs (aClassFeatures) do
		local nodeTarget = DB.createChild(f, "abilities");
		local sFName = DB.getValue(f, "name","");
		local nFLevel = DB.getValue(f, "level", 0);
		for _,a in pairs (aAbilities) do
			-- Get Source Book Name
			local sSourceName = a.getNodeName();
			local aSoruceName = StringManager.split(sSourceName, "@","");
			local sSource = aSoruceName[2];
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
					--DB.setValue(vNew, "level", "number", nALevel);
					DB.setValue(vNew, "locked", "number", 1);
				--DB.setValue(vNew, "source", "string", sSource);
				end
			end
		end
	end

end

function upDateBaseSpecialFeatures(nodeClass)
	--Setup
	local nodeTarget= DB.createChild(nodeClass, "specialfeatures");
	local sClassNodeName = nodeClass.getNodeName();
	local aClassNode = StringManager.split(sClassNodeName, "@","");
	local sSource = aClassNode[2];
	aClassNode = StringManager.split(aClassNode[1], ".","");
	local sClass = aClassNode[3];
	local nodeFeatures = nodeClass.getParent().getParent();
	local sNodeName = nodeFeatures.getNodeName();

	local node = DB.getPath(nodeFeatures, "classspecialfeature." .. sClass:lower());
	local aFeatures = DB.getChildrenGlobal(node);

	local aTarget = DB.getChildren(nodeTarget, "");
	for _,k in pairs (aFeatures) do
		-- Get Source Book Name
		local sSourceName = k.getNodeName();
		local aSoruceName = StringManager.split(sSourceName, "@","");
		local sSource = aSoruceName[2];
		local bFound = false;
		local sAName = DB.getValue(k, "name", "");
		local sFeatureAbility = DB.getValue(k, "feature","");
		local nALevel = DB.getValue(k, "level", 0);
		for _,f in pairs (aTarget) do
			local sBName = DB.getValue(f, "name", "");
			local nBLevel = DB.getValue(f, "level", 0);
			if sAName == sBName and nALevel == nBLevel then
				bFound = true;
			end
		end
		if not bFound then
			local sListName = DB.getValue(k, "name", "");
			local nLevel = DB.getValue(k, "level", 0);
			local vNew = nodeTarget.createChild();

			DB.copyNode(k, vNew);
			DB.setValue(vNew, "name", "string", sListName);
			DB.setValue(vNew, "level", "number", nLevel);
			DB.setValue(vNew, "locked", "number", 1);
			DB.setValue(vNew, "source", "string", sSource);
		end
	end
	upDateSpecialFeatureAbilities(nodeClass);
end

function upDateSpecialFeatureAbilities(nodeClass)
	--Setup
	local nodeBase = nodeClass.getParent().getParent();
	local sClassNodeName = nodeClass.getNodeName();
	local aClassNode = StringManager.split(sClassNodeName, "@","");
	local sSource = aClassNode[2];
	aClassNode = StringManager.split(aClassNode[1], ".","");
	local sClass = aClassNode[3];
	local sNodeName = nodeBase.getNodeName();
	local node = DB.getPath(nodeBase, "classspecialfeatureability." .. sClass:lower());

	local aAbilities = DB.getChildrenGlobal(node);
	local aClassFeatures = DB.getChildren(nodeClass, "specialfeatures");

	for _,f in pairs (aClassFeatures) do
		-- Get Source Book Name
		local sSourceName = f.getNodeName();
		local aSoruceName = StringManager.split(sSourceName, "@","");
		local sSource = aSoruceName[2];
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
					DB.setValue(vNew, "source", "string", sSource);
				end
			end
		end
	end
end
