-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
function onInit()
	updateAbilityCounters()
end
function onDisplayChanged()
	if not minisheet then
		for _,v in pairs(actions.subwindow.abilityclasslist.getWindows()) do
			v.onDisplayChanged();
		end
	end
end

function onModeChanged()	
	updateAbilityCounters;
end

function updateAbilityCounters()

	if minisheet then
		for _,v in pairs(abilityclasslist.getWindows()) do
			v.onAbilityCounterUpdate();
		end
	else
		for _,v in pairs(actions.subwindow.abilitylist.getWindows()) do
			v.onAbilityCounterUpdate();
		end
	end
end

