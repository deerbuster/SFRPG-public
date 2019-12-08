-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

localdatabasenode = nil;
id = "";
function setData(n, node)
	id = n;
	localdatabasenode = node;
end

function openCharacter()
	if not bRequested then
        User.requestIdentity(id, "charsheet", "name", localdatabasenode, requestResponse);

        bRequested = true;
	end
end

function requestResponse(result, identity)
	if result and identity then
		local msgOOB = {};
		msgOOB.type = "claimcompanion";
		msgOOB.sClaimant = "charsheet."..identity;	
		Comm.deliverOOBMessage(msgOOB, "");
		local colortable = {};
		if CampaignRegistry and CampaignRegistry.colortables and CampaignRegistry.colortables[identity] then
			colortable = CampaignRegistry.colortables[identity];
		end
		
		User.setCurrentIdentityColors(colortable.color or "000000", colortable.blacktext or false);

		windowlist.window.close();
	else
		error.setVisible(true);
	end
end
