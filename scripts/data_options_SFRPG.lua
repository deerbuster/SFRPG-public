--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	registerOptions();
	OptionsManager.setOptionDefault("DDCL", "desktopdecal_sfrpg_logo");
end

function registerOptions()
	OptionsManager.registerOption2("RMMT", true, "option_header_client", "option_label_RMMT", "option_entry_cycler",
		{ labels = "option_val_on|option_val_multi", values = "on|multi", baselabel = "option_val_off", baseval = "off", default = "multi" });

	OptionsManager.registerOption2("SHRR", false, "option_header_game", "option_label_SHRR", "option_entry_cycler",
		{ labels = "option_val_on|option_val_pc", values = "on|pc", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("PSMN", false, "option_header_game", "option_label_PSMN", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });

	OptionsManager.registerOption2("INIT", false, "option_header_combat", "option_label_INIT", "option_entry_cycler",
		{ labels = "option_val_on|option_val_group", values = "on|group", baselabel = "option_val_off", baseval = "off", default = "group" });
	OptionsManager.registerOption2("ANPC", false, "option_header_combat", "option_label_ANPC", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("BARC", false, "option_header_combat", "option_label_BARC", "option_entry_cycler",
		{ labels = "option_val_tiered", values = "tiered", baselabel = "option_val_standard", baseval = "", default = "" });
	OptionsManager.registerOption2("SHPC", false, "option_header_combat", "option_label_SHPC", "option_entry_cycler",
		{ labels = "option_val_detailed|option_val_status", values = "detailed|status", baselabel = "option_val_off", baseval = "off", default = "detailed" });
	OptionsManager.registerOption2("SHNPC", false, "option_header_combat", "option_label_SHNPC", "option_entry_cycler",
		{ labels = "option_val_detailed|option_val_status", values = "detailed|status", baselabel = "option_val_off", baseval = "off", default = "status" });

	OptionsManager.registerOption2("HRIR", false, "option_header_houserule", "option_label_HRIR", "option_entry_cycler",
		{ labels = "option_val_on", values = "on", baselabel = "option_val_off", baseval = "off", default = "off" });
	OptionsManager.registerOption2("HRST", false, "option_header_houserule", "option_label_HRST", "option_entry_cycler",
		{ labels = "option_val_all|option_val_friendly", values = "all|on", baselabel = "option_val_off", baseval = "off", default = "on" });
	OptionsManager.registerOption2("HRFC", false, "option_header_houserule", "option_label_HRFC", "option_entry_cycler",
		{ labels = "option_val_fumbleandcrit|option_val_fumble|option_val_crit", values = "both|fumble|criticalhit", baselabel = "option_val_off", baseval = "", default = "" });

	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_logo", "desktopdecal_sfrpg_logo", true);
	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_sf1", "desktopdecal_sfrpg_sf1", true);
	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_sf2", "desktopdecal_sfrpg_sf2", true);
	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_sf3", "desktopdecal_sfrpg_sf3", true);
	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_sf4", "desktopdecal_sfrpg_sf4", true);
	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_sf5", "desktopdecal_sfrpg_sf5", true);
	OptionsManager.addOptionValue("DDCL", "option_val_SFRPG_sf6", "desktopdecal_sfrpg_sf6", true);
end
