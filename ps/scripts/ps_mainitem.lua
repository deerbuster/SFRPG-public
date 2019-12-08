-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	cmd.setVisible(true);
	onHealthChanged();
end

function onHealthChanged()
	local nHP = math.max(hptotal.getValue(), 0);
	local nTempHP = math.max(hptemp.getValue(), 0);
	local nWounds = math.max(wounds.getValue(), 0);
	local nNonlethal = math.max(nonlethal.getValue(), 0);
	
	
	
	local nPercentWounded = 0;
	local nPercentNonlethal = 0;
	
	
	if nHP > 0 then
		nPercentWounded = nWounds / (nHP + nTempHP);
		nPercentNonlethal = (nWounds + nNonlethal) / (nHP + nTempHP);
	end	
	--For HP
	local sColor; 
	if nPercentWounded <= 1 and nPercentNonlethal > 1 then
		sColor = ActorManager2.COLOR_HEALTH_UNCONSCIOUS;
	elseif nPercentWounded == 1 or nPercentNonlethal == 1 then
		sColor = ColorManager.COLOR_HEALTH_SIMPLE_BLOODIED;
	else
		sColor = ColorManager.getHealthColor(nPercentNonlethal, true);
	end
	hpbar.updateBackColor(sColor);
	
	hpbar.setMax(nHP + nTempHP);
	hpbar.setValue(nHP + nTempHP - nWounds);	
	
	local sText = "HP: " .. (nHP - nWounds);
	if nTempHP > 0 then
		sText = sText .. " (+" .. nTempHP .. ")";
	end
	sText = sText .. " / " .. nHP;
	if nTempHP > 0 then
		sText = sText .. " (+" .. nTempHP .. ")";
	end
	hpbar.updateText(sText);
	
	
	-- Stamina
	local sColorSta;
	local nPercentSta = 0;
	local nStaMax = math.max(sptotal.getValue(), 0);
	local nFatique = math.max(fatique.getValue(), 0);
	
	if nStaMax > 0 then
		nPercentSta = nFatique / nStaMax;

	end
	if nPercentSta <= 1 then		
		sColorSta = ColorManager.getHealthColor(nPercentSta, true);
	end
	shpbar.updateBackColor(sColorSta);
	
	shpbar.setMax(nStaMax);
	shpbar.setValue(nStaMax - nFatique);
	
	local sTextSta = "SP: " .. (nStaMax - nFatique);
	sTextSta = sTextSta .. " / " .. nStaMax;
	shpbar.updateText(sTextSta);
end
