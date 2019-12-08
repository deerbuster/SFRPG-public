--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local bShow = true;

function setFilter(bFilter)
    bShow = bFilter;
end

function getFilter()
    return bShow;
end

function onInit()

    if not windowlist.isReadOnly() then
        registerMenuItem(Interface.getString("menu_deleteability"), "delete", 6);
        registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "delete", 6, 7);
        registerMenuItem(Interface.getString("menu_addabilityaction"), "pointer", 3);
        registerMenuItem(Interface.getString("menu_addabilitycast"), "radial_sword", 3, 2);
        registerMenuItem(Interface.getString("menu_addabilitydamage"), "radial_damage", 3, 3);
        registerMenuItem(Interface.getString("menu_addabilityheal"), "radial_heal", 3, 4);
        registerMenuItem(Interface.getString("menu_addspelleffect"), "radial_effect", 3, 5);
        registerMenuItem(Interface.getString("menu_reparseability"), "textlist", 4);
    end

    -- Check to see if we should automatically parse ability text
    local nodeAbility = getDatabaseNode();
    local nParse = DB.getValue(nodeAbility, "parse", 0);
    if nParse == 1 then
        DB.setValue(nodeAbility, "parse", "number", 0);
        AbilityManager.parseAbility(nodeAbility);
    end

    onDisplayChanged();
    onModeChanged()
end


function update(bEditMode)
    if minisheet then
        return;
    end

    idelete.setVisibility(bEditMode);
end

function onDisplayChanged()
    if minisheet then
        return;
    end

    sDisplayMode = DB.getValue(getDatabaseNode(), ".......abilitydisplaymode", "");
    if sDisplayMode == "action" then
        header.subwindow.shortdescription.setVisible(false);
        header.subwindow.actionsmini.setVisible(true);
    else
        header.subwindow.shortdescription.setVisible(true);
        header.subwindow.actionsmini.setVisible(false);
    end
end
function onModeChanged()
    if not minisheet then
        sAbilityMode = DB.getValue(getDatabaseNode(), ".......abilitymode", "");
        if sAbilityMode == "preparation" then
            header.subwindow.usespacer.setVisible(true);
            header.subwindow.usesperday.setVisible(true);
            header.subwindow.counter.setVisible(false);
        else
            header.subwindow.usespacer.setVisible(false);
            header.subwindow.usesperday.setVisible(false);
            header.subwindow.counter.setVisible(true);
        end
    end

    --applyFilter();
end


function onHover(bOver)
    if minisheet then
        if bOver then
            setFrame("rowshade");
        else
            setFrame(nil);
        end
    end
end

function createAction(sType)
    local nodeSpell = getDatabaseNode();
    if nodeSpell then
        local nodeActions = nodeSpell.createChild("actions");
        if nodeActions then
            local nodeAction = nodeActions.createChild();
            if nodeAction then
                DB.setValue(nodeAction, "type", "string", sType);
            end
        end
    end
end

function onMenuSelection(selection, subselection)
    if selection == 6 and subselection == 7 then
        getDatabaseNode().delete();
    elseif selection == 4 then
        AbilityManager.parseAbility(getDatabaseNode());
        activatedetail.setValue(1);
    elseif selection == 3 then
        if subselection == 2 then
            createAction("cast");
            activatedetail.setValue(1);
        elseif subselection == 3 then
            createAction("damage");
            activatedetail.setValue(1);
        elseif subselection == 4 then
            createAction("heal");
            activatedetail.setValue(1);
        elseif subselection == 5 then
            createAction("effect");
            activatedetail.setValue(1);
        end
    end
end

function toggleDetail()
    local status = (activatedetail.getValue() == 1);

    actions.setVisible(status);
end

function getDescription()
    local nodeAbility = getDatabaseNode();

    local s = DB.getValue(nodeAbility, "name", "");

    local sShort = DB.getValue(nodeAbility, "shortdescription", "");
    if sShort ~= "" then
        s = s .. " - " .. sShort;
    end

    return s;
end

function activatePower()
    --Debug.chat("ActivatePower")
    local nodeSpell = getDatabaseNode();
    if nodeSpell then
        ChatManager.Message(getDescription(), true, ActorManager.getActor("", nodeSpell.getChild(".......")));
    end
end

