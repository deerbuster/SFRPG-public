-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

function onInit()
	if User.isHost() then
		if GameSystem.currencies then
			if coins.getWindowCount() == 0 then
				local nCoinTypes = #(GameSystem.currencies);
				for i = 1, #(GameSystem.currencies) do
					local w = coins.createWindow();
					w.description.setValue(GameSystem.currencies[i]);
				end
			end
		end
		
		PartyLootManager.rebuild();
	else
		OptionsManager.registerCallback("PSIN", onOptionChanged);
		onOptionChanged();
	end
end

function onClose()
	if not User.isHost() then
		OptionsManager.unregisterCallback("PSIN", onOptionChanged);
	end
end

function onOptionChanged()
	local bOptPSIN = OptionsManager.isOption("PSIN", "on");

	label_coin_main.setVisible(bOptPSIN);
	label_coin_count.setVisible(bOptPSIN);
	label_coin_name.setVisible(bOptPSIN);
	label_coin_carried.setVisible(bOptPSIN);
	coinlist.setVisible(bOptPSIN);
	
	label_inv_main.setVisible(bOptPSIN);
	label_inv_count.setVisible(bOptPSIN);
	label_inv_name.setVisible(bOptPSIN);
	label_inv_carried.setVisible(bOptPSIN);
	itemlist.setVisible(bOptPSIN);
	
	if bOptPSIN then
		coins.setAnchor("bottom", "", "center", "absolute", "-20");
		items.setAnchor("bottom", "", "center", "absolute", "-20");
	else
		coins.setAnchor("bottom", "", "bottom", "absolute", "-30");
		items.setAnchor("bottom", "", "bottom", "absolute", "-30");
	end
end

function onDrop(x, y, draginfo)
	return ItemManager2.handleAnyDrop("partysheet", draginfo);
end

