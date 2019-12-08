-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()	
	if User.isHost() then
		DB.addHandler(DB.getPath(getDatabaseNode(), "ac.pilot"), "onUpdate", onACChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "ac.armor"), "onUpdate", onACChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "ac.size"), "onUpdate", onACChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "ac.misc"), "onUpdate", onACChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "tl.pilot"), "onUpdate", onTLChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "tl.countermeasures"), "onUpdate", onTLChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "tl.size"), "onUpdate", onTLChanged);
		DB.addHandler(DB.getPath(getDatabaseNode(), "tl.misc"), "onUpdate", onTLChanged);
		onACChanged();
		onTLChanged();
	end
end

function onClose()
	if User.isHost() then
		DB.removeHandler(DB.getPath(getDatabaseNode(), "ac.pilot"), "onUpdate", onACChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "ac.armor"), "onUpdate", onACChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "ac.size"), "onUpdate", onACChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "ac.misc"), "onUpdate", onACChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "tl.pilot"), "onUpdate", onTLChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "tl.countermeasures"), "onUpdate", onTLChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "tl.size"), "onUpdate", onTLChanged);
		DB.removeHandler(DB.getPath(getDatabaseNode(), "tl.misc"), "onUpdate", onTLChanged);
	end	
end

function onACChanged()
	if User.isHost() then
		local nPilotMod = DB.getValue(getDatabaseNode(), "ac.pilot", 0);
		local nArmorMod = DB.getValue(getDatabaseNode(), "ac.armor", 0);
		local nSizeMod = DB.getValue(getDatabaseNode(), "ac.size", 0);
		local nMiscMod = DB.getValue(getDatabaseNode(), "ac.misc", 0);	
		DB.setValue(getDatabaseNode(), "ac.total", "number", 10 + nPilotMod + nArmorMod + nSizeMod + nMiscMod);
	end
end

function onTLChanged()
	if User.isHost() then
		local nPilotMod = DB.getValue(getDatabaseNode(), "tl.pilot", 0);
		local nCMMod = DB.getValue(getDatabaseNode(), "tl.countermeasures", 0);
		local nSizeMod = DB.getValue(getDatabaseNode(), "tl.size", 0);
		local nMiscMod = DB.getValue(getDatabaseNode(), "tl.misc", 0);
		DB.setValue(getDatabaseNode(), "tl.total", "number", 10 + nPilotMod + nCMMod + nSizeMod + nMiscMod);	
	end
end
	


