--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
    onEncumbranceChanged();
    DB.addHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", onStrengthChanged);
    DB.addHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", onSizeChanged);
end

function onClose()
    DB.removeHandler(DB.getPath(getDatabaseNode(), "abilities.strength.score"), "onUpdate", onStrengthChanged);
    DB.removeHandler(DB.getPath(getDatabaseNode(), "size"), "onUpdate", onSizeChanged);
end

function onStrengthChanged()
    onEncumbranceChanged();
end

function onSizeChanged()
    onEncumbranceChanged();
end

function onEncumbranceChanged()
    local nodeChar = getDatabaseNode();

    local nHeavy = 0;
    local nStrength = DB.getValue(nodeChar, "abilities.strength.score", 10);
    if nStrength > 0 then
        if nStrength <= 10 then
            nHeavy = nStrength * 10;
        elseif nStrength == 11 then
            nHeavy = 115;
        elseif nStrength == 12 then
            nHeavy = 130;
        elseif nStrength == 13 then
            nHeavy = 150;
        elseif nStrength == 14 then
            nHeavy = 175;
        elseif nStrength == 15 then
            nHeavy = 200;
        elseif nStrength == 16 then
            nHeavy = 230;
        elseif nStrength == 17 then
            nHeavy = 260;
        elseif nStrength == 18 then
            nHeavy = 300;
        elseif nStrength == 19 then
            nHeavy = 350;
        else
            if (nStrength % 10) == 0 then
                nHeavy = 400;
            elseif (nStrength % 10) == 1 then
                nHeavy = 460;
            elseif (nStrength % 10) == 2 then
                nHeavy = 520;
            elseif (nStrength % 10) == 3 then
                nHeavy = 600;
            elseif (nStrength % 10) == 4 then
                nHeavy = 700;
            elseif (nStrength % 10) == 5 then
                nHeavy = 800;
            elseif (nStrength % 10) == 6 then
                nHeavy = 920;
            elseif (nStrength % 10) == 7 then
                nHeavy = 1040;
            elseif (nStrength % 10) == 8 then
                nHeavy = 1200;
            elseif (nStrength % 10) == 9 then
                nHeavy = 1400;
            end
            local nExp = math.max(math.floor((nStrength - 20) / 10), 0);
            nHeavy = nHeavy * (4^nExp);
        end
    end

    local nSize = ActorManager2.getSize(ActorManager.getActor("pc", nodeChar));
    if (nSize == -4) then
        nHeavy = math.floor(nHeavy / 8);
    elseif (nSize == -3) then
        nHeavy = math.floor(nHeavy / 4);
    elseif (nSize == -2) then
        nHeavy = math.floor(nHeavy / 2);
    elseif (nSize == -1) then
        nHeavy = math.floor((nHeavy / 4) * 3);
    elseif (nSize == 1) then
        nHeavy = nHeavy * 2;
    elseif (nSize == 2) then
        nHeavy = nHeavy * 4;
    elseif (nSize == 3) then
        nHeavy = nHeavy * 8;
    elseif (nSize == 4) then
        nHeavy = nHeavy * 16;
    end

    local nLight = math.floor(nHeavy / 3);
    local nMedium = math.floor ((nHeavy / 3) * 2);
    local nLiftOver = nHeavy;
    local nLiftOff = nHeavy * 2;
    local nPushDrag = nHeavy * 5;

    DB.setValue(nodeChar, "encumbrance.lightload", "number", nLight);
    DB.setValue(nodeChar, "encumbrance.mediumload", "number", nMedium);
    DB.setValue(nodeChar, "encumbrance.heavyload", "number", nHeavy);
    DB.setValue(nodeChar, "encumbrance.liftoverhead", "number", nLiftOver);
    DB.setValue(nodeChar, "encumbrance.liftoffground", "number", nLiftOff);
    DB.setValue(nodeChar, "encumbrance.pushordrag", "number", nPushDrag);
end
