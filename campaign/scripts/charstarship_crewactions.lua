-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()

end


function addMoveAction(sName, sText)
	
	name.setValue(sName);
	text.setVisible(true);
	text.setValue(sText);
	type.setValue("move");
	
end

function addAttackAction(nodeCharStarship, sName, nWeapons, nAttackMod, sArc)
	name.setValue(sName);
	type.setValue("attack");
	local nIndex = 1;
	
	if nWeapons == -1 then
		nWeapons = 4;
	end
	
	for i=1,nWeapons do	
		local weaponCntrl = weapon1;
		local weaponDamageCntrl = weapondamage1;	
		local modCntrl = attackmod1;
		local actionCntrl = attackaction1;
		
		if nIndex == 2 then
			weaponCntrl = weapon2;
			weaponDamageCntrl = weapondamage2;	
			modCntrl = attackmod2;
			actionCntrl = attackaction2;
		elseif nIndex == 3 then
			weaponCntrl = weapon3;
			weaponDamageCntrl = weapondamage3;		
			modCntrl = attackmod3;
			actionCntrl = attackaction3;
		elseif nIndex == 4 then
			weaponCntrl = weapon4;
			weaponDamageCntrl = weapondamage4;		
			modCntrl = attackmod4;
			actionCntrl = attackaction4;
		end	
		
		local sWeaponLabels = "";
		local sWeaponValues = "";
		local nWeaponIndex = 1;
		if sArc == "" then
			sArc = "forward";
		end
		local aWeaponNames = CharStarshipManager.getWeaponNames(nodeCharStarship, sArc);
		for x=1, #aWeaponNames do
			if x ~= 1 then
				if aWeaponNames[x]:len() >= 20 then
					sWeaponLabels = aWeaponNames[x]:sub(1,20) .. "|" .. sWeaponLabels;
				else
					sWeaponLabels = aWeaponNames[x] .. "|" .. sWeaponLabels;
				end
				
				sWeaponValues = aWeaponNames[x] .. "|" .. sWeaponValues;
			end
		end
		local defaultVal = aWeaponNames[1]:lower();		
		local defaultLabel = aWeaponNames[1];		
		weaponCntrl.setVisible(true);
		weaponCntrl.initialize(sWeaponLabels, sWeaponValues, defaultLabel, defaultVal);
		weaponCntrl.update();
--		weaponCntrl.setStringValue(defaultVal);
				
		weaponDamageCntrl.setVisible(true);
	
	
		modCntrl.setVisible(true);
		modCntrl.setValue(nAttackMod);

		actionCntrl.setVisible(true);
	
		nIndex = nIndex + 1;
	end
end

function addSkillAction(sName, sSkill, sBaseDC, nTierMod)

	name.setValue(sName);
	type.setValue("skill");
	
	local aSkills = StringManager.split(sSkill, "|");
	local nIndex = 1;
	for k,v in pairs(aSkills) do

		local skillCntrl = skill1;
		local pcSkillBonus = pcskillbonus1;
		local dcCntrl = skilldc1;
		local actionCntrl = action1;

		if nIndex == 2 then
			skillCntrl = skill2;
			pcSkillBonus = pcskillbonus2;	
			dcCntrl = skilldc2;
			actionCntrl = action2;
		elseif nIndex == 3 then
			skillCntrl = skill3;
			pcSkillBonus = pcskillbonus3;		
			dcCntrl = skilldc3;
			actionCntrl = action3;
		elseif nIndex == 4 then
			skillCntrl = skill4;
			pcSkillBonus = pcskillbonus4;		
			dcCntrl = skilldc4;
			actionCntrl = action4;
		end	
		
		skillCntrl.setVisible(true);
		if v == "any" then
			local newskills = "";
			local defaultval = DataCommon.psskilldata[1];
			local i = 1;
			for _,skill in pairs(DataCommon.psskilldata) do
				if i ~= 1 then
					newskills = newskills .. "|" .. skill;
				end
				i = i + 1;
			end
			newskills = newskills:sub(2, newskills:len());
			
			skillCntrl.initialize(newskills, newskills:lower(), defaultval);
			skillCntrl.setFrame("fieldlight", 7,5,7,5);
		else
			skillCntrl.initialize(sSkill, sSkill:lower());
			skillCntrl.setStringValue(v:lower());
			skillCntrl.setEnabled(false);
			skillCntrl.setStateFrame("hover", nil);
		end
		skillCntrl.update();

		pcSkillBonus.setVisible(true);
		
		local sClass, sNodePCID = windowlist.window.link.getValue();
		local rActor = {};
		rActor.sType = "pc";
		rActor.sName = DB.getValue(nodePC, "name", "");
		rActor.sCreatureNode = sNodePCID;
		
		local nSkillValue, bUntrained = CharManager.getSkillValue(rActor, v);
		pcSkillBonus.setValue(nSkillValue);
		
		local aDC = StringManager.split(sBaseDC, "|");
		dcCntrl.setVisible(true);
		dcCntrl.setValue(tonumber(aDC[nIndex]) + nTierMod);
		
		actionCntrl.setVisible(true);
		
		nIndex = nIndex + 1;
	end
end

