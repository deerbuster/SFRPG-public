--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
    registerMenuItem(Interface.getString("menu_addspellclass"), "insert", 5);

    updateAbility();
    update();
    local node = getDatabaseNode();
    DB.addHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);
end

function onClose()
    local node = getDatabaseNode();
    DB.removeHandler(DB.getPath(node, "spellset"), "onChildUpdate", updateAbility);
end

function onMenuSelection(selection)
    if selection == 5 then
        addSpellClass();
    end
end

function addSpellClass()
    local w = spellclasslist.createWindow();
    if w then
        w.activatedetail.setValue(1);
        w.label.setFocus();
        DB.setValue(getDatabaseNode(), "spellmode", "string", "standard");
    end
end

local bUpdateLock = false;
function updateAbility()
    if bUpdateLock then
        return;
    end
    bUpdateLock = true;
    for _,v in pairs(spellclasslist.getWindows()) do
        v.onStatUpdate();
    end
    bUpdateLock = false;
end

function update()
    spellclasslist.update();
end

function getEditMode()
    return (parentcontrol.window.actions_iedit.getValue() == 1);
end
