--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

local m_sType = nil;

function onInit()
    registerMenuItem(Interface.getString("menu_deletespellaction"), "deletepointer", 4);
    registerMenuItem(Interface.getString("list_menu_deleteconfirm"), "deletepointer", 4, 3);

    local sNode = getDatabaseNode().getNodeName();
    local node = getDatabaseNode();
    local nodeChar = getDatabaseNode().getParent().getParent().getParent().getParent().getParent().getParent().getParent().getParent();
    DB.addHandler(sNode, "onChildAdded", onDataChanged);
    DB.addHandler(sNode, "onChildUpdate", onDataChanged);
    DB.addHandler(sNode, "onUpdate", updateViews);
    DB.addHandler(DB.getPath(nodeChar, "skilllist.*.total"), "onUpdate", updateViews);

    onDataChanged();
    updateViews();
end

function onClose()
    local sNode = getDatabaseNode().getNodeName();
    local node = getDatabaseNode();
    local nodeChar = getDatabaseNode().getParent().getParent().getParent().getParent().getParent().getParent().getParent().
        DB.removeHandler(sNode, "onChildAdded", onDataChanged);
    DB.removeHandler(sNode, "onChildUpdate", onDataChanged);
    DB.removeHandler(sNode, "onUpdate", updateViews);
	DB.removeHandler(DB.getPath(nodeChar, "skilllist.*.total"), "onUpdate", updateViews);
end

function onMenuSelection(selection, subselection)
    if selection == 4 and subselection == 3 then
        getDatabaseNode().delete();
    end
end

--local bDataChangedLock = false;
function onDataChanged()
    local bDataChangedLock = false;
    if bDataChangedLock then
        return;
    end
    bDataChangedLock = true;
    if not m_sType then
        local sType = DB.getValue(getDatabaseNode(), "type");
        if (sType or "") ~= "" then
            createDisplay(sType);
            m_sType = sType;
        end
    end
    if m_sType then
        updateViews();
    end
    bDataChangedLock = false;
end


function highlight(bState)
    if bState then
        setFrame("rowshade");
    else
        setFrame(nil);
    end
end

function createDisplay(sType)
    if sType == "cast" then
        createControl("ability_action_castbutton", "castbutton");
        createControl("ability_action_castlabel", "castlabel");
        createControl("ability_action_attackbutton", "attackbutton");
        createControl("ability_action_attackviewlabel", "attackviewlabel");
        createControl("ability_action_attackview", "attackview");
        createControl("ability_action_rpviewlabel", "rpviewlabel");
        createControl("ability_action_rpview", "rpcost");
        createControl("ability_action_savebutton", "savebutton");
        createControl("ability_action_saveviewlabel", "saveviewlabel");
        createControl("ability_action_saveview", "saveview");
        createControl("ability_action_castdetailbutton", "castdetail");
    elseif sType == "damage" then
        createControl("ability_action_damagebutton", "damagebutton");
        createControl("ability_action_damagelabel", "damagelabel");
        createControl("ability_action_damageview", "damageview");
        createControl("ability_action_damagedetailbutton", "damagedetail");
    elseif sType == "heal" then
        createControl("ability_action_healbutton", "healbutton");
        createControl("ability_action_heallabel", "heallabel");
        createControl("ability_action_healview", "healview");
        createControl("ability_action_healtypelabel", "healtypelabel");
        createControl("ability_action_healtype", "healtype");
        createControl("ability_action_healdetailbutton", "healdetail");
    elseif sType == "effect" then
        createControl("ability_action_effectbutton", "effectbutton");
        createControl("ability_action_effecttargeting", "targeting");
        createControl("ability_action_effectapply", "apply");
        createControl("ability_action_effectlabel", "label");
        createControl("ability_action_effectdurationview", "durationview");
        createControl("ability_action_effectdetailbutton", "effectdetail");
    end
end

function updateViews()
    if m_sType == "cast" then
        onCastChanged();
    elseif m_sType == "damage" then
        onDamageChanged();
    elseif m_sType == "heal" then
        onHealChanged();
    elseif m_sType == "effect" then
        onEffectChanged();
    end
end

function onCastChanged()
    local node = getDatabaseNode();
    local sAttack = AbilityManager.getActionAttackText(node);
    attackview.setValue(sAttack);
    local sSave = AbilityManager.getActionSaveText(node);
    saveview.setValue(sSave);
end

function onDamageChanged()
    local sDamage = AbilityManager.getActionDamageText(getDatabaseNode());
    damageview.setValue(sDamage);

end

function onHealChanged()
    local sHeal = AbilityManager.getActionHealText(getDatabaseNode());
    healview.setValue(sHeal);
end

function onEffectChanged()
    local sDuration = AbilityManager.getActionEffectDurationText(getDatabaseNode());
    durationview.setValue(sDuration);
end
