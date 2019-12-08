--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
    registerMenuItem(Interface.getString("menu_addweapon"), "insert", 3);
    registerMenuItem(Interface.getString("menu_addabilityclass"), "insert", 5);

    updateAbility();
    update();
    local node = getDatabaseNode();
    DB.addHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);
  --  DB.addHandler(DB.getPath(node, "abilityset"), "onChildUpdate", updateAbility);
  --  DB.addHandler(DB.getPath(node, "rp.current"), "onUpdate", updateAbility);
--DB.addHandler(DB.getPath(node, "skilllist"), "onChildUpdate", updateAbility);
--DB.addHandler(DB.getPath(node, "actionabilities"), "onChildUpdate", updateAbility);
--DB.addHandler(DB.getPath(node, "abilityclasslist"), "onChildUpdate", updateAbility);
end

function onClose()
    local node = getDatabaseNode();

    DB.removeHandler(DB.getPath(node, "weaponlist"), "onChildUpdate", updateAbility);

  --  DB.removeHandler(DB.getPath(node, "abilityset"), "onChildUpdate", updateAbility);
 --   DB.removeHandler(DB.getPath(node, "rp.current"), "onUpdate", updateAbility);
--DB.removeHandler(DB.getPath(node, "skilllist"), "onChildUpdate", updateAbility);
--DB.removeHandler(DB.getPath(node, "actionabilities"), "onChildUpdate", updateAbility);
--DB.removeHandler(DB.getPath(node, "abilityclasslist"), "onChildUpdate", updateAbility);

end

function onMenuSelection(selection)
    if selection == 3 then
        addWeapon();
    elseif selection == 4 then
        addAbility();
    elseif selection == 5 then
        addAbilityClass();
    end
end

function addWeapon()
	DB.setValue(getDatabaseNode(), "abilitymode", "string", "preparation");
    local w = weaponlist.createWindow();
    if w then
        w.name.setFocus();
    end
end

--function addAbility()
--	local w = abilities.createWindow();
--	if w then
--		w.name.setFocus();
--	end
--end

function addAbilityClass()

    local w = abilityclasslist.createWindow();
    if w then
        w.activatedetail.setValue(1);
        w.label.setFocus();
        DB.setValue(getDatabaseNode(), "abilitymode", "string", "preparation");
    end
end

local bUpdateLock = false;
function updateAbility()
    if bUpdateLock then
        return;
    end
    bUpdateLock = true;
    for _,v in pairs(weaponlist.getWindows()) do
        v.onDataChanged();
    end
    for _,v in pairs(weaponlist.getWindows()) do
        v.onDataChanged();
    end
    bUpdateLock = false;
    local nodeParent = getDatabaseNode();

    local nRP = DB.getValue(nodeParent, "rp.current", 0);
    for _,w in pairs(abilityclasslist.getWindows()) do		
       -- w.points.setValue(nRP);
		AbilityManager.useResolve();        
       --		for _,class in pairs(abilityclasslist.getWindows()) do
        --			nodeClass = class.levels.getDatabaseNode();
        --			for _,level in pairs (nodeClass.getChildren()) do
        --				for _,ability in pairs (level.abilities.getChildren()) do
        --				Debug.chat(w)
        --				end
        --			end
        --		end
    end

end

function update()
    weaponlist.update();
    abilityclasslist.update();
end

function getEditMode()
    return (parentcontrol.window.actions_iedit.getValue() == 1);
end

