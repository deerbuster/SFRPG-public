--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
    DB.addHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", onChange);
    DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.load"), "onUpdate", onChange);
    DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.strmod"), "onUpdate", onChange);
    DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.stradj"), "onUpdate", onChange);
    DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.encpower"), "onUpdate", onChange);
    DB.addHandler(DB.getPath(getDatabaseNode(), "encumbrance.encother"), "onUpdate", onChange);
    DB.addHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", onChange);
    onChange();
    local nodeChar = getDatabaseNode();
    local bAndroid = false;
    local CharRace = DB.getValue(nodeChar,"race",""):lower();

    if CharRace == "android" then
        bAndroid = true;
    end
    androidframe.setVisible(bAndroid);
    android_upgrade_label.setVisible(bAndroid);
    upgrade.setVisible(bAndroid);
end

function onClose()
    DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", onChange);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", onChange);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.load"), "onUpdate", onChange);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.strmod"), "onUpdate", onChange);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.stradj"), "onUpdate", onChange);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.encpower"), "onUpdate", onChange);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "encumbrance.encother"), "onUpdate", onChange);
end

function onChange()
    local nodeChar = getDatabaseNode();
    ItemManager2.onEncumbranceChanged(nodeChar);
end