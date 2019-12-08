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

    updateLabel(nLevel);

    if not windowlist.isReadOnly() then
        registerMenuItem(Interface.getString("menu_addspell"), "insert", 5);
    end
end

function update(bEditMode)
    if minisheet then
        return;
    end

    ability_iadd.setVisible(bEditMode);
    for _,w in ipairs(abilities.getWindows()) do
        w.update(bEditMode);
    end
end

function setFilter(bFilter)
    bShow = bFilter;
end

function getFilter()
    return bShow;
end

function updateLabel(nLevel)
--	local sLabel = "[LEVEL " .. nLevel .. "]";
--	label.setValue(sLabel);
end

function onAbilityCounterUpdate()
    windowlist.window.onAbilityCounterUpdate();
end

function onMenuSelection(selection, subselection)
    if selection == 5 then
        abilities.addEntry(true);
    end
end

function onClickDown(button, x, y)
    return true;
end

function onClickRelease(button, x, y)
    if DB.getChildCount(abilities.getDatabaseNode(), "") == 0 then
        abilities.addEntry(true);
        return true;
    end

    abilities.setVisible(not abilities.isVisible());
    return true;
end
