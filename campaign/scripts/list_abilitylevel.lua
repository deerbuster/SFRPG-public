-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	local node = getDatabaseNode();
	if node then
		node.createChild("level01");
		node.createChild("level02");
		node.createChild("level03");
		node.createChild("level04");
		node.createChild("level05");
		node.createChild("level06");
		node.createChild("level07");
		node.createChild("level08");
		node.createChild("level09");
		node.createChild("level10");
		node.createChild("level11");
		node.createChild("level12");
		node.createChild("level13");
		node.createChild("level14");
		node.createChild("level15");
		node.createChild("level16");
		node.createChild("level17");
		node.createChild("level18");
		node.createChild("level19");
		node.createChild("level20");
	end
end

function onFilter(w)
	return w.getFilter();
end

function addEntry()
	return createWindow();
end

function onDrop(x, y, draginfo)
	if isReadOnly() then
		return false;
	end
	
	local winLevel = getWindowAt(x, y);
	if not winLevel then
		return false;
	end

	-- Draggable ability name to move abilitys
	if draginfo.isType("abilitymove") then
		local node = winLevel.getDatabaseNode();
		if node then
			local nodeSource = draginfo.getDatabaseNode();
			local nodeNew = AbilityManager.addAbility(nodeSource, node.getChild("..."), DB.getValue(node, "level"));
			if nodeNew then
				nodeSource.delete();
				winLevel.abilities.setVisible(true);
				DB.setValue(window.getDatabaseNode().getChild("..."), "abilitymode", "string", "standard");
			end
		end
		
		return true;

	-- ability link with level information (i.e. class ability list)
	elseif draginfo.isType("abilitydescwithlevel") then
		local node = winLevel.getDatabaseNode();
		if node then
			local nodeSource = draginfo.getDatabaseNode();
			local nodeNew = AbilityManager.addAbility(nodeSource, node.getChild("..."), DB.getValue(node, "level"));
			if nodeNew then
				winLevel.abilities.setVisible(true);
				DB.setValue(window.getDatabaseNode().getChild("..."), "abilitymode", "string", "standard");
			end
		end
		
		return true;
	
	-- ability link with no level information
	elseif draginfo.isType("shortcut") then
	
		local sDropClass, sSource = draginfo.getShortcutData();

		if sDropClass == "ability" or sDropClass == "class_feature" or sDropClass == "item" or sDropClass == "feat" or sDropClass == "skilltask" then
			local node = winLevel.getDatabaseNode();

			if node then
				local nodeSource = DB.findNode(sSource);
				
				local nodeNew = AbilityManager.addAbility(nodeSource, node.getChild("..."), DB.getValue(node, "level"));
				if nodeNew then
					winLevel.abilities.setVisible(true);
					DB.setValue(window.getDatabaseNode().getChild("..."), "abilitymode", "string", "standard");
					if sDropClass == "item" then
						local sDesc= DB.getValue(nodeSource, "description","");
						DB.setValue(nodeNew, "text", "formattedtext", sDesc);
						DB.setValue(nodeNew, "class", "string", "Item");
					elseif sDropClass == "feat" then
						local sNormal = "";
						local sBenefit = "";
						local sSpecial = "";
						local sSumm = DB.getValue(nodeSource, "summary","");
						
						local sBenefit = DB.getValue(nodeSource, "benefit","");
						local sSpecial = DB.getValue(nodeSource, "special","");
						local sDesc = "";												
						sDesc = sDesc .. "<p><b>Benefit:</b></p>" .. sBenefit;
						sDesc = sDesc .. "<p><b>Special:</b></p>" .. sSpecial;
					
						DB.setValue(nodeNew, "text", "formattedtext", sDesc);
						DB.setValue(nodeNew, "class", "string", "Feat");
					elseif sDropClass == "skilltask" then
						local sDesc= DB.getValue(nodeSource, "text","");
						DB.setValue(nodeNew, "text", "formattedtext", sDesc);
						DB.setValue(nodeNew, "class", "string", "Skill Task");
					end
					-- Parse Ability details to create actions
						
						if DB.getChildCount(nodeNewAbility, "actions") == 0 then
							AbilityManager.parseAbility(nodeNew);
						end
				end
				
				return true;
			end
		end
	end
end
