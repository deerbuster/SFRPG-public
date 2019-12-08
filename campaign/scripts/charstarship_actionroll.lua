-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--


local sSkill;
				
function onInit()

	
end

function action(draginfo)
	
	local sMsg = Interface.getString("charstarship_message_notimplemented");
	ChatManager.SystemMessage(sMsg, true);
	
	
--	if sSkill then
--		local nodeChar = window.getDatabaseNode();
--		local rActor = ActorManager.getActor("pc", nodeChar);
--		local nValue = CharManager.getSkillValue(rActor, sSkill);
--		ActionSkill.performRoll(draginfo, rActor, sSkill, nValue);
--	end
end

function onButtonPress()
	action();
end

function onDragStart(button, x, y, draginfo)
	action(draginfo);
	return true;
end