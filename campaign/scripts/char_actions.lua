--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
--function onInit()
--	updateAbilityCounters();
--end

function onDisplayChanged()
    if not minisheet then
        for _,v in pairs(actions.subwindow.abilityclasslist.getWindows()) do
            v.onDisplayChanged();
        end
    end
end

function onModeChanged()
    updateAbilityCounters();
end

function updateAbilityCounters()
    if minisheet then
        weaponlist.onModeChanged();
    else
        actions.subwindow.weaponlist.onModeChanged();
        actions.subwindow.abilityclasslist.onModeChanged();
    end

end