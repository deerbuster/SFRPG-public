--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

-- Abilities (database names)
abilities = {
	"strength",
	"dexterity",
	"constitution",
	"intelligence",
	"wisdom",
	"charisma"
};
abilitiesshort = {
	"Str",
	"Dex",
	"Con",
	"Int",
	"Wis",
	"Cha"
};
ability_ltos = {
	["strength"] = "STR",
	["dexterity"] = "DEX",
	["constitution"] = "CON",
	["intelligence"] = "INT",
	["wisdom"] = "WIS",
	["charisma"] = "CHA"
};

ability_stol = {
	["STR"] = "strength",
	["DEX"] = "dexterity",
	["CON"] = "constitution",
	["INT"] = "intelligence",
	["WIS"] = "wisdom",
	["CHA"] = "charisma",
	["Str"] = "strength",
	["Dex"] = "dexterity",
	["Con"] = "constitution",
	["Int"] = "intelligence",
	["Wis"] = "wisdom",
	["Cha"] = "charisma",
};

-- Saves
save_ltos = {
	["fortitude"] = "FORT",
	["reflex"] = "REF",
	["will"] = "WILL"
};

save_stol = {
	["FORT"] = "fortitude",
	["REF"] = "reflex",
	["WILL"] = "will"
};

-- Values for wound comparison
healthstatusfull = "healthy";
healthstatushalf = "bloodied";
healthstatuswounded = "wounded";
healthstatusfull = "healthy";
healthstatushalf = "moderate";
healthstatuswounded = "critical";

-- Values for alignment comparison
alignment_lawchaos = {
	["lawful"] = 1,
	["chaotic"] = 3,
	["lg"] = 1,
	["ln"] = 1,
	["le"] = 1,
	["cg"] = 3,
	["cn"] = 3,
	["ce"] = 3,
};
alignment_goodevil = {
	["good"] = 1,
	["evil"] = 3,
	["lg"] = 1,
	["le"] = 3,
	["ng"] = 1,
	["ne"] = 3,
	["cg"] = 1,
	["ce"] = 3,
};
alignment_neutral = "n";

-- Values for size comparison
creaturesize = {
	["fine"] = -4,
	["diminutive"] = -3,
	["tiny"] = -2,
	["small"] = -1,
	["medium"] = 0,
	["large"] = 1,
	["huge"] = 2,
	["gargantuan"] = 3,
	["colossal"] = 4,
	["f"] = -4,
	["d"] = -3,
	["t"] = -2,
	["s"] = -1,
	["m"] = 0,
	["l"] = 1,
	["h"] = 2,
	["g"] = 3,
	["c"] = 4,
};

-- Values for creature type comparison
creaturedefaulttype = "humanoid";
creaturehalftype = "half-";
creaturehalftypesubrace = "human";
creaturetype = {
	"aberration",
	"animal",
	"companion",
	"construct",
	"dragon",
	"fey",
	"giant",
	"humanoid",
	"magical beast",
	"monstrous humanoid",
	"ooze",
	"outsider",
	"plant",
	"undead",
	"vermin",
};
creaturesubtype = {
	"aeon",
	"agathion",
	"air",
	"angel",
	"aquatic",
	"archon",
	"augmented",
	"chaotic",
	"cold",
	"demon",
	"devil",
	"earth",
	"evil",
	"extraplanar",
	"fire",
	"good",
	"incorporeal",
	"lawful",
	"living construct",
	"native",
	"psionic",
	"shapechanger",
	"swarm",
	"water",
	"dwarf", -- Humanoid subtypes
	"elf",
	"gnoll",
	"gnome",
	"goblinoid",
	"halfling",
	"human",
	"orc",
	"reptilian",
};

-- Values supported in effect conditionals
conditionaltags = {
	};

-- Conditions supported in effect conditionals and for token widgets
conditions = {
	"asleep",
	"bleeding",
	"blinded",
	"broken",
	"burning",
	"confused",
	"cowering",
	"dazed",
	"dazzled",
	"dead",
	"deafened",
	"dying",
	"encumbered",
	"entangled",
	"exhausted",
	"fascinated",
	"fatigued",
	"flat-footed",
	"frightened",
	"grappled",
	"helpless",
	"invisible",
	"nauseated",
	"off-kilter",
	"off-target",
	"overburdened",
	"panicked",
	"paralyzed",
	"pinned",
	"prone",
	"shaken",
	"sickened",
	"stable",
	"staggered",
	"stunned",
	"unconscious"

};

-- Bonus/penalty effect types for token widgets
bonuscomps = {
	"INIT",
	"ABIL",
	"AC",
	"ATK",
	"CMB",
	"CMD",
	"DMG",
	"DMGS",
	"HEAL",
	"SAVE",
	"SKILL",
	"STR",
	"CON",
	"DEX",
	"INT",
	"WIS",
	"CHA",
	"FORT",
	"REF",
	"WILL"
};

-- Condition effect types for token widgets
condcomps = {
	["asleep"] = "cond_asleep",
	["bleeding"] = "cond_bleeding",
	["blinded"] = "cond_blinded",
	["broken"] = "cond_broken",
	["burning"] = "cond_burning",
	["confused"] = "cond_confused",
	["cowering"] = "cond_cowering",
	["dazed"] = "cond_dazed",
	["dazzled"] = "cond_dazzled",
	["dead"] = "cond_dead",
	["deafened"] = "cond_deafened",
	["dying"] = "cond_dying",
	["encumbered"] = "cond_encumbered",
	["entangled"] = "cond_entangled",
	["exhausted"] = "cond_exhausted",
	["fascinated"] = "cond_fascinated",
	["fatigued"] = "cond_fatigued",
	["flatfooted"] = "cond_flatfooted",
	["frightened"] = "cond_frightened",
	["grappled"] = "cond_grappled",
	["helpless"] = "cond_helpless",
	["invisible"] = "conf_invisible",
	["nauseated"] = "cond_nauseated",
	["offkilter"] = "cond_offkilter",
	["offtarget"] = "cond_offtarget",
	["overburdened"] = "cond_overburdened",
	["panicked"] = "cond_panicked",
	["paralyzed"] = "cond_paralyzed",
	["pinned"] = "cond_pinned",
	["prone"] = "cond_prone",
	["shaken"] = "cond_shaken",
	["stable"] = "cond_stable",
	["staggered"] = "cond_staggered",
	["stunned"] = "cond_stunned",
	["unconscious"] = "cond_unconscious"
};

-- Other visible effect types for token widgets
othercomps = {
	["CONC"] = "cond_conceal",
	["TCONC"] = "cond_conceal",
	["COVER"] = "cond_cover",
	["SCOVER"] = "cond_cover",
	["NLVL"] = "cond_nlvl",
	["IMMUNE"] = "cond_immune",
	["RESIST"] = "cond_resist",
	["VULN"] = "cond_vuln",
	["REGEN"] = "cond_regen",
	["FHEAL"] = "cond_fheal",
	["DMGO"] = "cond_ongoing"
};

-- Effect components which can be targeted
targetableeffectcomps = {
	"CONC",
	"TCONC",
	"COVER",
	"SCOVER",
	"AC",
	"CMD",
	"SAVE",
	"ATK",
	"CMB",
	"DMG",
	"IMMUNE",
	"VULN",
	"RESIST"
};

connectors = {
	"and",
	"or"
};

-- Range types supported
rangetypes = {
	"melee",
	"ranged"
};
ammotypes ={
	"charges",
	"petrol",
	"rounds",
	"round",
	"shells",
	"arrows",
	"arrow",
	"grenades",
	"missle",
	"mini-rockets",
	"flare",
	"darts",
	"drawn",
};
-- Damage types supported
energytypes = {
	"acid",
	"cold",
	"electricity",
	"fire",
	"sonic",
	"force",
	"positive",
	"negative"
};

immunetypes = {
	"acid",
	"cold",
	"electricity",
	"fire",
	"sonic",
	"nonlethal",
	"critical",
	"charm",
	"poison",
	"sleep",
	"sleep effects",
	"paralysis",
	"petrification",
	"polymorph",
	"stunning",
	"fear",
	"bleed",
	"disease",
	"death effects",
	"flat-footed",
	"mind-affecting",
	"mind-affecting effects",
	"necromancy",
	"vacuum",
	"unflankable",
	"nonlethal",
	"radiation",
	"sight-based attacks",
	"visual effects",
	"illusions",
};

dmgtypes_ltos = {
	["acid"] = "A",
	["cold"] = "C",
	["electricity"] = "E",
	["fire"] = "F",
	["sonic"] = "So",
	["bludgeoning"] = "B",
	["piercing"] = "P",
	["slashing"] = "S",
	["nonlethal"] = "NL",
};

dmgtypes_stol = {
	["A"] = "acid",
	["C"] = "cold",
	["E"] = "electricity",
	["F"] = "fire",
	["So"] = "sonic",
	["B"] = "bludgeoning",
	["P"] = "piercing",
	["S"] = "slashing",
	["NL"] = "nonlethal",
	["A "] = "acid",
	["C "] = "cold",
	["E "] = "electricity",
	["F "] = "fire",
	["So "] = "sonic",
	["B "] = "bludgeoning",
	["P "] = "piercing",
	["S "] = "slashing",
	["NL "] = "nonlethal",
};

dmgtypes = {
	"acid",  		-- ENERGY DAMAGE TYPES
	"cold",
	"electricity",
	"fire",
	"sonic",
	"force",  		-- OTHER SPELL DAMAGE TYPES
	"positive",
	"negative",
	"nonlethal",
	"adamantine", 	-- WEAPON PROPERTY DAMAGE TYPES
	"bludgeoning",
	"cold iron",
	"epic",
	"magic",
	"piercing",
	"silver",
	"slashing",
	"chaotic",		-- ALIGNMENT DAMAGE TYPES
	"evil",
	"good",
	"lawful",

};

specialdmgtypes = {
	"nonlethal",
	"spell",
	"critical",
	"precision",
};

-- Bonus types supported in power descriptions
bonustypes = {
	"alchemical",
	"armor",
	"circumstance",
	"competence",
	"deflection",
	"dodge",
	"enhancement",
	"insight",
	"luck",
	"morale",
	"natural",
	"profane",
	"racial",
	"resistance",
	"sacred",
	"shield",
	"size",
	"trait",
};

stackablebonustypes = {
	"circumstance",
	"dodge"
};

-- Armor class bonus types
-- (Map text types to internal types)
actypes = {
	["dex"] = "dex",
	["armor"] = "armor",
	["shield"] = "shield",
	["natural"] = "natural",
	["dodge"] = "dodge",
	["deflection"] = "deflection",
	["size"] = "size",
};
acarmormatch = {
	"padded",
	"padded armor",
	"padded barding",
	"leather",
	"leather armor",
	"leather barding",
	"studded leather",
	"studded leather armor",
	"studded leather barding",
	"chain shirt",
	"chain shirt barding",
	"hide",
	"hide armor",
	"hide barding",
	"scale mail",
	"scale mail barding",
	"chainmail",
	"chainmail barding",
	"breastplate",
	"breastplate barding",
	"splint mail",
	"splint mail barding",
	"banded mail",
	"banded mail barding",
	"half-plate",
	"half-plate armor",
	"half-plate barding",
	"full plate",
	"full plate armor",
	"full plate barding",
	"plate barding",
	"bracers of armor",
	"mithral chain shirt",
};
acshieldmatch = {
	"buckler",
	"light shield",
	"light wooden shield",
	"light steel shield",
	"heavy shield",
	"heavy wooden shield",
	"heavy steel shield",
	"tower shield",
};
acdeflectionmatch = {
	"ring of protection"
};

-- Spell effects supported in spell descriptions
spelleffects = {
	"blinded",
	"confused",
	"cowering",
	"dazed",
	"dazzled",
	"deafened",
	"entangled",
	"exhausted",
	"fascinated",
	"frightened",
	"helpless",
	"invisible",
	"panicked",
	"paralyzed",
	"shaken",
	"sickened",
	"slowed",
	"stunned",
	"unconscious",
	"flat-footed",
	"off-kilter",
	"off-target",
	"prone",
	"grappled",
	"staggered"

};
abilityeffects = {
	"blinded",
	"confused",
	"cowering",
	"dazed",
	"dazzled",
	"deafened",
	"entangled",
	"exhausted",
	"fascinated",
	"frightened",
	"helpless",
	"invisible",
	"panicked",
	"paralyzed",
	"shaken",
	"sickened",
	"slowed",
	"stunned",
	"unconscious",
	"flat-footed",
	"off-kilter",
	"off-target",
	"prone",
	"grappled",
	"staggered"

};

-- NPC damage properties
weapondmgtypes = {
	["axe"] = "slashing",
	["battleaxe"] = "slashing",
	["bolas"] = "bludgeoning,nonlethal",
	["chain"] = "piercing",
	["club"] = "bludgeoning",
	["crossbow"] = "piercing",
	["dagger"] = "piercing,slashing",
	["dart"] = "piercing",
	["falchion"] = "slashing",
	["flail"] = "bludgeoning",
	["glaive"] = "slashing",
	["greataxe"] = "slashing",
	["greatclub"] = "bludgeoning",
	["greatsword"] = "slashing",
	["guisarme"] = "slashing",
	["halberd"] = "piercing,slashing",
	["hammer"] = "bludgeoning",
	["handaxe"] = "slashing",
	["javelin"] = "piercing",
	["kama"] = "slashing",
	["kukri"] = "slashing",
	["lance"] = "piercing",
	["longbow"] = "piercing",
	["longspear"] = "piercing",
	["longsword"] = "slashing",
	["mace"] = "bludgeoning",
	["morningstar"] = "bludgeoning,piercing",
	["nunchaku"] = "bludgeoning",
	["pick"] = "piercing",
	["quarterstaff"] = "bludgeoning",
	["ranseur"] = "piercing",
	["rapier"] = "piercing",
	["sai"] = "bludgeoning",
	["sap"] = "bludgeoning,nonlethal",
	["scimitar"] = "slashing",
	["scythe"] = "piercing,slashing",
	["shortbow"] = "piercing",
	["shortspear"] = "piercing",
	["shuriken"] = "piercing",
	["siangham"] = "piercing",
	["sickle"] = "slashing",
	["sling"] = "bludgeoning",
	["spear"] = "piercing",
	["sword"] = {["short"] = "piercing", ["*"] = "slashing"},
	["trident"] = "piercing",
	["urgrosh"] = "piercing,slashing",
	["waraxe"] = "slashing",
	["warhammer"] = "bludgeoning",
	["whip"] = "slashing",

}

naturaldmgtypes = {
	["arm"] = "bludgeoning",
	["bite"] = "piercing,slashing,bludgeoning",
	["butt"] = "bludgeoning",
	["claw"] =  "piercing,slashing",
	["foreclaw"] =  "piercing,slashing",
	["gore"] = "piercing",
	["hoof"] = "bludgeoning",
	["hoove"] = "bludgeoning",
	["horn"] = "piercing",
	["pincer"] = "bludgeoning",
	["quill"] = "piercing",
	["ram"] = "bludgeoning",
	["rock"] = "bludgeoning",
	["slam"] = "bludgeoning",
	["snake"] = "piercing,slashing,bludgeoning",
	["spike"] = "piercing",
	["stamp"] = "bludgeoning",
	["sting"] = "piercing",
	["swarm"] = "piercing,slashing,bludgeoning",
	["tail"] = "bludgeoning",
	["talon"] =  "piercing,slashing",
	["tendril"] = "bludgeoning",
	["tentacle"] = "bludgeoning",
	["wing"] = "bludgeoning",
}

-- Skill properties
sensesdata = {
	["Perception"] = {
		stat = "wisdom"
	},
	["Sense Motive"] = {
		stat = "wisdom"
	},
}

skilldata = {
	["Acrobatics"] = {
		stat = "dexterity",
		armorcheckmultiplier = 1,
		trainedonly = 0
	},
	["Athletics"] = {
		stat = "strength",
		armorcheckmultiplier = 1,
		trainedonly = 0
	},
	["Bluff"] = {
		stat = "charisma",
		trainedonly = 0
	},
	["Computers"] = {
		stat = "intelligence",
		trainedonly = 1
	},
	["Culture"] = {
		stat = "intelligence",
		trainedonly = 1
	},
	["Diplomacy"] = {
		stat = "charisma",
		trainedonly = 0
	},
	["Disguise"] = {
		stat = "charisma",
		trainedonly = 0
	},
	["Engineering"] = {
		stat = "intelligence",
		trainedonly = 1
	},
	["Intimidate"] = {
		stat = "charisma",
		trainedonly = 0
	},
	["Life Science"] = {
		stat = "intelligence",
		trainedonly = 1
	},
	["Medicine"] = {
		stat = "intelligence",
		trainedonly = 1
	},
	["Mysticism"] = {
		stat = "wisdom",
		trainedonly = 1
	},
	["Perception"] = {
		stat = "wisdom",
		trainedonly = 0
	},
	["Physical Science"] = {
		stat = "intelligence",
		trainedonly = 1
	},
	["Piloting"] = {
		stat = "dexterity",
		trainedonly = 0
	},
	["Sense Motive"] = {
		stat = "wisdom",
		trainedonly = 0
	},
	["Sleight of Hand"] = {
		stat = "dexterity",
		armorcheckmultiplier = 1,
		trainedonly = 1
	},
	["Stealth"] = {
		stat = "dexterity",
		armorcheckmultiplier = 1,
		trainedonly = 0
	},
	["Survival"] = {
		stat = "wisdom",
		trainedonly = 0
	}
}

-- Coin labels
--currency = { "PP", "GP", "SP", "CP" };
currency = { "CR","UBP" };

-- Party sheet drop down list data
psabilitydata = {
	"Strength",
	"Dexterity",
	"Constitution",
	"Intelligence",
	"Wisdom",
	"Charisma"
};

pssavedata = {
	"Fortitude",
	"Reflex",
	"Will"
};

psskilldata = {
	"Acrobatics",
	"Athletics",
	"Bluff",
	"Computers",
	"Culture",
	"Diplomacy",
	"Disguise Self",
	"Engineering",
	"Forgery",
	"Intimidate",
	"Life Science",
	"Medicine",
	"Mysticism",
	"Perception",
	"Physical Science",
	"Piloting",
	"Profession (CHA)",
	"Profession (INT)",
	"Profession (WIS)",
	"Sense Motive",
	"Sleight of Hand",
	"Stealth",
	"Survival"
};

-- Item Data
itemsizetoacmod = {
	["colossal"] = -8,
	["gargantuan"] = -4,
	["huge"] = -2,
	["large"] = -1,
	["medium"] = 0,
	["small"] = 1,
	["tiny"] = 2,
	["diminutive"] = 4,
	["fine"] = 8,
};

-- Starship Data
starshiptier = {
	["0"] = {bp = "0", hp="0"},
	["1/4"] = {bp = "25", hp="0"},
	["1/3"] = {bp = "30", hp="0"},
	["1/2"] = {bp = "40", hp="0"},
	["1"] = {bp = "55", hp="0"},
	["2"] = {bp = "75", hp="0"},
	["3"] = {bp = "95", hp="0"},
	["4"] = {bp = "115", hp="1"},
	["5"] = {bp = "135", hp="0"},
	["6"] = {bp = "155", hp="0"},
	["7"] = {bp = "180", hp="0"},
	["8"] = {bp = "205", hp="1"},
	["9"] = {bp = "230", hp="0"},
	["10"] = {bp = "270", hp="0"},
	["11"] = {bp = "310", hp="0"},
	["12"] = {bp = "350", hp="1"},
	["13"] = {bp = "400", hp="0"},
	["14"] = {bp = "450", hp="0"},
	["15"] = {bp = "500", hp="0"},
	["16"] = {bp = "600", hp="1"},
	["17"] = {bp = "700", hp="0"},
	["18"] = {bp = "800", hp="0"},
	["19"] = {bp = "900", hp="0"},
	["20"] = {bp = "1000", hp="1"},
};

starshipscale = {
	["tiny"] = { minlength="20", maxlength="60", minweight="3", maxweight="20", actlmod="2" },
	["small"] = { minlength="60", maxlength="120", minweight="20", maxweight="40", actlmod="1" },
	["medium"] = { minlength="120", maxlength="300", minweight="40", maxweight="150", actlmod="0" },
	["large"] = { minlength="300", maxlength="800", minweight="150", maxweight="420", actlmod="-1" },
	["huge"] = { minlength="800", maxlength="2000", minweight="420", maxweight="1200", actlmod="-2" },
	["gargantuan"] = { minlength="2000", maxlength="15000", minweight="1200", maxweight="8000", actlmod="-4" },
	["colossal"] = { minlength="15000", maxlength="99999", minweight="8000", maxweight="99999", actlmod="-8" },
};

starshipsizes = {
	["—"] = 99,
	["-"] = 99,
	["tiny"] = 1,
	["small"] = 2,
	["medium"] = 3,
	["large"] = 4,
	["huge"] = 5,
	["gargantuan"] = 6,
	["colossal"] = 7,
}

starshiproles = {
	"Captain",
	"Engineer",
	"Gunner",
	"Pilot",
	"Science Officer"
};

starshipcrewactiontitles = {
	["skill"] = { "Name", "Skill", "Bonus", "DC", "Roll" },
	["attack"] = { "Name", "Weapon", "Attack Mod", "Roll" },
	["move"] = { "Name" }
};

starshipcrewactions = {
	["captain"] = { { name = "Demand", action = "skill", skills = "Intimidate", basedc = "15", tiermod = 1.5 },
		{ name = "Encourage", action = "skill", skills = "Diplomacy|any", basedc = "15|10", tiermod = 0 },
		{ name = "Taunt", action = "skill", skills = "Bluff|Intimidate", basedc = "15|15", tiermod = 1.5 },
		{ name = "Orders", action = "skill", skills = "Computers|Engineering|Gunnery|Piloting", basedc = "15|15|15|15", tiermod = 1.5 },
		{ name = "Moving Speech", action = "skill", skills = "Diplomacy", basedc = "20", tiermod = 1.5 } },
	["engineer"] = { { name = "Divert", action = "skill", skills = "Engineering", basedc = "10", tiermod = 1.5 },
		{ name = "Hold It Together", action = "skill", skills = "Engineering", basedc = "15", tiermod = 1.5 },
		{ name = "Patch", action = "skill", skills = "Engineering", basedc = "10|15|20", tiermod = 1.5 },
		{ name = "Overpower", action = "skill", skills = "Engineering", basedc = "15", tiermod = 1.5 },
		{ name = "Quick Fix", action = "skill", skills = "Engineering", basedc = "20", tiermod = 1.5 } },
	["gunner"] = { { name = "Fire At Will", action = "attack", weapons = 2, attackmod = -4 },
		{ name = "Shoot", action = "attack", weapons = 1, attackmod = 0 },
		{ name = "Broadside", action = "attack", weapons = -1, attackmod = -2 },
		{ name = "Precise Targeting", action = "attack", weapons = 1, attackmod = 0 } },
	["pilot"] = { { name = "Fly", action = "move", text="Move action." },
		{	name = "Maneuver", action = "skill", skills = "Piloting", basedc = "15", tiermod = 1.5 },
		{	name = "Back Off (Stunt)", action = "skill", text="Move action.", skills = "Piloting", basedc = "10", tiermod = 1.5 },
		{	name = "Barrel Roll (Stunt)", action = "skill", skills = "Piloting", basedc = "10", tiermod = 1.5 },
		{	name = "Evade (Stunt)", action = "skill", skills = "Piloting", basedc = "10", tiermod = 1.5 },
		{	name = "Flip & Burn (Stunt)", action = "skill", skills = "Piloting", basedc = "15", tiermod = 1.5 },
		{	name = "Flyby (Stunt)", action = "skill", skills = "Piloting", basedc = "15", tiermod = 1.5 },
		{	name = "Slide (Stunt)", action = "skill", skills = "Piloting", basedc = "10", tiermod = 1.5 },
		{	name = "Full Power", action = "move" , text="Move action." },
		{ name = "Audacious Gambit", action = "skill", skills = "Piloting", basedc = "15", tiermod = 1.5 } },
	["science officer"] = { { name = "Balance", action = "skill", skills = "Computers", basedc = "10", tiermod = 1.5 },
		{ name = "Scan", action = "skill", skills = "Computers", basedc = "5", tiermod = 1.5 },
		{ name = "Target", action = "skill", skills = "Computers", basedc = "5", tiermod = 1.5 },
		{ name = "Lock On", action = "skill", skills = "Computers", basedc = "5", tiermod = 1.5 },
		{ name = "Improve CM", action = "skill", skills = "Computers", basedc = "5", tiermod = 1.5 } }
};

starshipcrewminoractions = {
	[1] = { name = "Glide", action = "move", text="Move action." },
	[2] = { name = "Snap Shot", action = "attack", weapons = 1, attackmod = -2 }
};


-- PC/NPC Class properties

class_stol = {
	["brb"] = "barbarian",
	["brd"] = "bard",
	["clr"] = "cleric",
	["drd"] = "druid",
	["ftr"] = "fighter",
	["mnk"] = "monk",
	["pal"] = "paladin",
	["rgr"] = "ranger",
	["rog"] = "rogue",
	["sor"] = "sorcerer",
	["wiz"] = "wizard",
};

-- Basic class values (not display values)
classes = {
	"operative",
	"envoy",
	"mechanic",
	"mystic",
	"solarian",
	"soldier",
	"technomancer",
	"drone (combat)",
	"drone (hover)",
	"drone (stealth)",
	"biohacker",
	"vanguard",
	"witchwarper",
};

classdata = {
	-- Starfinder Core [fort/ref/will/] good=2 bad =0  BAB Slow = 0,1,1,2   Med = 0,1,2,3   Fast = 1
	["operative"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 8, classhp = 6, classstamina = 6, keyability = "dexterity",
		specialability = "true" ,skills = "Acrobatics (Dex), Medicine (Int), Athletics (Str), Perception (Wis), Bluff (Cha), Piloting (Dex), Computers (Int), Culture (Int), Sense Motive (Wis), Disguise (Cha), Sleight of Hand (Dex), Engineering (Int), Stealth (Dex), Intimidate (Cha), Survival (Wis)",
	},
	["envoy"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 8, classhp = 6, classstamina = 6, keyability = "charisma",
		specialability = "false" ,skills = "Acrobatics (Dex), Intimidate (Cha), Athletics (Str), Medicine (Int), Bluff (Cha), Perception (Wis), Computers (Int), Piloting (Dex), Culture (Int), Profession (Cha), Profession (Int), Profession (Wis), Diplomacy (Cha), Sense Motive (Wis), Disguise (Cha), Sleight of Hand (Dex), Engineering (Int), Stealth (Dex)",
	},
	["mechanic"] = {
		hd = "d6", bab = "medium", fort = "good", ref = "good", will = "bad", skillranks = 4, classhp = 6, classstamina = 6, keyability = "intelligence",
		specialability = "true" ,skills = "Athletics (Str), Perception (Wis), Computers (Int), Physical Science (Int), Engineering (Int), Piloting (Dex), Medicine (Int), Profession (Cha), Profession (Int), Profession (Wis)"
	},
	["mystic"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 6, classhp = 6, classstamina = 6, keyability = "wisdom",
		specialability = "false" ,skills = "Bluff (Cha), Medicine (Int), Culture (Int), Mysticism (Wis), Diplomacy (Cha), Perception (Wis), Disguise (Cha), Profession (Cha), Profession (Int), Profession (Wis), Intimidate (Cha), Sense Motive (Wis,) Life Science (Int), Survival (Wis)",
	},
	["solarian"] = {
		hd = "d6", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 4, classhp = 7, classstamina = 7, keyability = "charisma",
		specialability = "true" ,skills = "Acrobatics (Dex), Perception (Wis), Athletics (Str), Physical Science (Int), Diplomacy (Cha), Profession (Cha), Profession (Int), Profession (Wis), Intimidate (Cha), Sense Motive (Wis), Mysticism (Wis), Stealth (Dex)",
	},
	["soldier"] = {
		hd = "d6", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 4, classhp = 7, classstamina = 7, keyability = "strength",
		specialability = "true" ,skills = "Acrobatics (Dex), Medicine (Int), Athletics (Str), Piloting (Dex), Engineering (Int), Profession (Cha, Int, or Wis), Intimidate (Cha), Survival (Wis)",
	},
	["technomancer"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 4, classhp = 5, classstamina = 5, keyability = "intelligence",
		specialability = "false" ,skills = "Computers (Int), Physical Science (Int), Engineering (Int), Piloting (Dex), Life Science (Int), Profession (Cha, Int, or Wis), Mysticism (Wis), Sleight of Hand (Dex)",
	},
	["drone (combat)"] = {
		hd = "d10", bab = "drone", fort = "dgood", ref = "dbad", will = "dbad", skillranks = 0, classhp = 10, classstamina = 0, keyability = "base",
		specialability = "false" ,skills = "",
	},
	["drone (hover)"] = {
		hd = "d10", bab = "drone", fort = "dbad", ref = "dgood", will = "dbad", skillranks = 0, classhp = 10, classstamina = 0, keyability = "base",
		specialability = "false" ,skills = "Acrobatics (Dex)",
	},
	["drone (stealth)"] = {
		hd = "d10", bab = "drone", fort = "dbad", ref = "dgood", will = "dbad", skillranks = 0, classhp = 10, classstamina = 0, keyability = "base",
		specialability = "false" ,skills = "Stealth (Dex)",
	},
	--Character Operations Manual
	["biohacker"] = {
		hd = "d6", bab = "medium", fort = "good", ref = "bad", will = "bad", skillranks = 6, classhp = 6, classstamina = 6, keyability = "intelligence",
		specialability = "true" ,skills = "Bluff (Cha), Medicine (Int),Computers (Int), Perception (Wis), Culture (Int), Physical Science (Int),Diplomacy (Cha), Profession (Cha), Profession (Int), Profession (Wis), Engineering (Int), Sense Motive (Wis), Life Science (Int), Sleight of Hand (Dex)",
	},
	["vanguard"] = {
		hd = "d6", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 6, classhp = 8, classstamina = 8, keyability = "constitution",
		specialability = "true" ,skills = "Acrobatics (Dex), Medicine (Int), Athletics (Str), Mysticism (Wis),Culture (Int), Perception (Wis), Diplomacy (Cha), Physical Science (Int), Intimidate (Cha), Profession (Cha), Profession (Int), Profession (Wis), Life Science (Int), Survival (Wis)",
	},
	["witchwarper"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 4, classhp = 5, classstamina = 5, keyability = "charisma",
		specialability = "true" ,skills = "Acrobatics (Dex), Intimidate (Cha), Bluff (Cha), Mysticism (Wis), Culture (Int), Profession (Cha), Profession (Int), Profession (Wis), Diplomacy (Cha), Physical Science (Int)",
	},
	-- Core
	["barbarian"] = {
		hd = "d12", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Jump (Str), Listen (Wis), Ride (Dex), Survival (Wis), and Swim (Str)",
	},
	["bard"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "good", will = "good", skillranks = 6,
		skills = "Appraise (Int), Balance (Dex), Bluff (Cha), Climb (Str), Concentration (Con), Craft (Int), Decipher Script (Int), Diplomacy (Cha), Disguise (Cha), Escape Artist (Dex), Gather Information (Cha), Hide (Dex), Jump (Str), Knowledge (all skills, taken individually) (Int), Listen (Wis), Move Silently (Dex), Perform (Cha), Profession (Wis), Sense Motive (Wis), Sleight of Hand (Dex), Speak Language (None), Spellcraft (Int), Swim (Str), Tumble (Dex), and Use Magic Device (Cha)",
	},
	["cleric"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = " Concentration (Con), Craft (Int), Diplomacy (Cha), Heal (Wis), Knowledge (arcana) (Int), Knowledge (history) (Int), Knowledge (religion) (Int), Knowledge (the planes) (Int), Profession (Wis), and Spellcraft (Int)",
	},
	["druid"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 4,
		skills = "Concentration (Con), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Knowledge (nature) (Int), Listen (Wis), Profession (Wis), Ride (Dex), Spellcraft (Int), Spot (Wis), Survival (Wis), and Swim (Str)",
	},
	["fighter"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Intimidate (Cha), Jump (Str), Ride (Dex), and Swim (Str)",
	},
	["monk"] = {
		hd = "d8", bab = "medium", fort = "good", ref = "good", will = "good", skillranks = 4,
		skills = "Balance (Dex), Climb (Str), Concentration (Con), Craft (Int), Diplomacy (Cha), Escape Artist (Dex), Hide (Dex), Jump (Str), Knowledge (arcana) (Int), Knowledge (religion) (Int), Listen (Wis), Move Silently (Dex), Perform (Cha), Profession (Wis), Sense Motive (Wis), Spot (Wis), Swim (Str), and Tumble (Dex)",
	},
	["paladin"] = {
		hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Knowledge (nobility and royalty) (Int), Knowledge (religion) (Int), Profession (Wis), Ride (Dex), and Sense Motive (Wis)",
	},
	["ranger"] = {
		hd = "d8", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 6,
		skills = "Climb (Str), Concentration (Con), Craft (Int), Handle Animal (Cha), Heal (Wis), Hide (Dex), Jump (Str), Knowledge (dungeoneering) (Int), Knowledge (geography) (Int), Knowledge (nature) (Int), Listen (Wis), Move Silently (Dex), Profession (Wis), Ride (Dex), Search (Int), Spot (Wis), Survival (Wis), Swim (Str), and Use Rope (Dex)",
	},
	["rogue"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 8,
		skills = "Appraise (Int), Balance (Dex), Bluff (Cha), Climb (Str), Craft (Int), Decipher Script (Int), Diplomacy (Cha), Disable Device (Int), Disguise (Cha), Escape Artist (Dex), Forgery (Int), Gather Information (Cha), Hide (Dex), Intimidate (Cha), Jump (Str), Knowledge (local) (Int), Listen (Wis), Move Silently (Dex), Open Lock (Dex), Perform (Cha), Profession (Wis), Search (Int), Sense Motive (Wis), Sleight of Hand (Dex), Spot (Wis), Swim (Str), Tumble (Dex), Use Magic Device (Cha), and Use Rope (Dex)",
	},
	["sorcerer"] = {
		hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Bluff (Cha), Concentration (Con), Craft (Int), Knowledge (arcana) (Int), Profession (Wis), and Spellcraft (Int)",
	},
	["wizard"] = {
		hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Decipher Script (Int), Knowledge (all skills, taken individually) (Int), Profession (Wis), and Spellcraft (Int)",
	},
	-- NPC
	["adept"] = {
		hd = "d6", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Handle Animal (Cha), Heal (Wis), Knowledge (all skills taken individually) (Int), Profession (Wis), Spellcraft (Int), and Survival (Wis)",
	},
	["aristocrat"] = {
		hd = "d8", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 4,
		skills = "Appraise (Int), Bluff (Cha), Diplomacy (Cha), Disguise (Cha), Forgery (Int), Gather Information (Cha), Handle Animal (Cha), Intimidate (Cha), Knowledge (all skills taken individually) (Int), Listen (Wis), Perform (Cha), Ride (Dex), Sense Motive (Wis), Speak Language (None), Spot (Wis), Swim (Str), and Survival (Wis)",
	},
	["commoner"] = {
		hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Craft (Int), Handle Animal (Cha), Jump (Str), Listen (Wis), Profession (Wis), Ride (Dex), Spot (Wis), Swim (Str), and Use Rope (Dex)",
	},
	["expert"] = {
		hd = "d6", bab = "medium", fort = "bad", ref = "bad", will = "good", skillranks = 6,
		skills = "Any 10",
	},
	["warrior"] = {
		hd = "d8", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Climb (Str), Handle Animal (Cha), Intimidate (Cha), Jump (Str), Ride (Dex), and Swim (Str)",
	},
	-- Prestige
	["arcane archer"] = {
		bPrestige = true, hd = "d8", bab = "fast", fort = "good", ref = "good", will = "bad", skillranks = 4,
		skills = "Craft (Int), Hide (Dex). Listen (Wis), Move Silently (Dex), Ride (Dex), Spot (Wis), Survival (Wis), and Use Rope (Dex)",
	},
	["arcane trickster"] = {
		bPrestige = true, hd = "d4", bab = "slow", fort = "bad", ref = "good", will = "good", skillranks = 4,
		skills = "Appraise (Int), Balance (Dex), Bluff (Cha), Climb (Str), Concentration (Con), Craft (Int), Decipher Script (Int), Diplomacy (Cha), Disable Device (Int), Disguise (Cha), Escape Artist (Dex), Gather Information (Cha), Hide (Dex), Jump (Str), Knowledge (all skills taken individually) (Int), Listen (Wis), Move Silently (Dex), Open Lock (Dex), Profession (Wis), Search (Int), Sense Motive (Wis), Sleight of Hand (Dex), Speak Language (None), Spellcraft (Int), Spot (Wis), Swim (Str), Tumble (Dex), and Use Rope (Dex)",
	},
	["archmage"] = {
		bPrestige = true, hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (alchemy) (Int), Knowledge (all skills taken individually) (Int), Profession (Wis), Search (Int), and Spellcraft (Int)",
	},
	["assassin"] = {
		bPrestige = true, hd = "d6", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 4,
		skills = "Balance (Dex), Bluff (Cha), Climb (Str), Craft (Int), Decipher Script (Int), Diplomacy (Cha), Disable Device (Int), Disguise (Cha), Escape Artist (Dex), Forgery (Int), Gather Information (Cha), Hide (Dex), Intimidate (Cha), Jump (Str), Listen (Wis), Move Silently (Dex), Open Lock (Dex), Search (Int), Sense Motive (Wis), Sleight of Hand (Dex), Spot (Wis), Swim (Str), Tumble (Dex), Use Magic Device (Cha), and Use Rope (Dex)",
	},
	["blackguard"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Diplomacy (Cha), Handle Animal (Cha), Heal (Wis), Hide (Dex), Intimidate (Cha), Knowledge (religion) (Int), Profession (Wis), and Ride (Dex)",
	},
	["dragon disciple"] = {
		bPrestige = true, hd = "d12", bab = "medium", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Diplomacy (Cha), Escape Artist (Dex), Gather Information (Cha), Knowledge (all skills, taken individually) (Int), Listen (Wis), Profession (Wis), Search (Int), Speak Language (None), Spellcraft (Int), and Spot (Wis)",
	},
	["duelist"] = {
		bPrestige = true, hd = "d10", bab = "fast", fort = "bad", ref = "good", will = "bad", skillranks = 4,
		skills = "Balance (Dex), Bluff (Cha), Escape Artist (Dex), Jump (Str), Listen (Wis), Perform (Cha), Sense Motive (Wis), Spot (Wis), and Tumble (Dex)",
	},
	["dwarven defender"] = {
		bPrestige = true, hd = "d12", bab = "fast", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Craft (Int), Listen (Wis), Sense Motive (Wis), and Spot (Wis)",
	},
	["eldritch knight"] = {
		bPrestige = true, hd = "d6", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Decipher Script (Int), Jump (Str), Knowledge (arcana) (Int), Knowledge (nobility and royalty) (Int), Ride (Dex), Sense Motive (Wis), Spellcraft (Int), and Swim (Str)",
	},
	["hierophant"] = {
		bPrestige = true, hd = "d8", bab = "slow", fort = "good", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Diplomacy (Cha), Heal (Wis), Knowledge (arcana) (Int), Knowledge (religion) (Int), Profession (Wis), and Spellcraft (Int)",
	},
	["horizon walker"] = {
		bPrestige = true, hd = "d8", bab = "fast", fort = "good", ref = "bad", will = "bad", skillranks = 4,
		skills = "Balance (Dex), Climb (Str), Diplomacy (Cha), Handle Animal (Cha), Hide (Dex), Knowledge (geography) (Int), Listen (Wis), Move Silently (Dex), Profession (Wis), Ride (Dex), Speak Language (None), Spot (Wis), and Survival (Wis)",
	},
	["loremaster"] = {
		bPrestige = true, hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 4,
		skills = "Appraise (Int), Concentration (Con), Craft (alchemy) (Int), Decipher Script (Int), Gather Information (Cha), Handle Animal (Cha), Heal (Wis), Knowledge (all skills taken individually) (Int), Perform (Cha), Profession (Wis), Speak Language (None), Spellcraft (Int), and Use Magic Device (Cha)",
	},
	["mystic theurge"] = {
		bPrestige = true, hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Decipher Script (Int), Knowledge (arcana) (Int), Knowledge (religion) (Int), Profession (Wis), Sense Motive (Wis), and Spellcraft (Int)",
	},
	["shadowdancer"] = {
		bPrestige = true, hd = "d8", bab = "medium", fort = "bad", ref = "good", will = "bad", skillranks = 6,
		skills = "Balance (Dex), Bluff (Cha), Decipher Script (Int), Diplomacy (Cha), Disguise (Cha), Escape Artist (Dex), Hide (Dex), Jump (Str), Listen (Wis), Move Silently (Dex), Perform (Cha), Profession (Wis), Search (Int), Sleight of Hand (Dex), Spot (Wis), Tumble (Dex), and Use Rope (Dex)",
	},
	["thaumaturgist"] = {
		bPrestige = true, hd = "d4", bab = "slow", fort = "bad", ref = "bad", will = "good", skillranks = 2,
		skills = "Concentration (Con), Craft (Int), Diplomacy (Cha), Knowledge (religion) (Int), Knowledge (the planes) (Int), Profession (Wis), Sense Motive (Wis), Speak Language (None), and Spellcraft (Int)",
	};


	-- Race Data
	racedata = {
		--Starfionder Core
		["android"] = {racehp = "4"},
		["human"] = {racehp = "4"},
		["kasatha"] = {racehp = "4"},
		["lashunta"] = {racehp = "4"},
		["lashunta (korasha)"] = {racehp = "4"},
		["lashunta (damaya)"] = {racehp = "4"},
		["shirren"] = {racehp = "6"},
		["vesk"] = {racehp = "6"},
		["ysoki"] = {racehp = "2"},
		["dwarf"] = {racehp = "6"},
		["elf"] = {racehp = "4"},
		["gnome"] = {racehp = "4"},
		["gnome (feychild)"] = {racehp = "4"},
		["gnome (bleaching)"] = {racehp = "4"},
		["half-elf"] = {racehp = "4"},
		["half-orc"] = {racehp = "6"},
		["halfling"] = {racehp = "2"},
	};



};

feat_proficiencies = {
	["reference.feat.advancedmeleeweaponproficiency"] = "melee, advanced",
	["reference.feat.basicmeleeweaponproficiency"] = "melee, basic",
	["reference.feat.grenadeproficiency"] = "grenade",
	["reference.feat.heavyweaponproficiency"] = "heavy",
	["reference.feat.longarmproficiency"] = "long arms",
	["reference.feat.smallarmproficiency"] = "small arms",
	["reference.feat.sniperweaponproficiency"] = "sniper",

}
xp_per_level = {
    [1] = 0,
    [2] = 1300,
    [3] = 3300,
    [4] = 6000,
    [5] = 10000,
    [6] = 15000,
    [7] = 23000,
    [8] = 34000,
    [9] = 50000,
    [10] = 71000,
    [11] = 105000,
    [12] = 145000,
    [13] = 210000,
    [14] = 295000,
    [15] = 425000,
    [16] = 600000,
    [17] = 850000,
    [18] = 1200000,
    [19] = 1700000,
    [20] = 2400000
};
companiondatalvl = {
	--Starfionder AA3 Pg 143
	[0] = {price = 0, pricenextlvl = 0, hp = 0,atkbonus = 0,damage = "",eac = 0 ,kac = 0,  good = 0, poor = 0,abilitymod = "", skillpoints = 0, skills = "" },
	[1] = {price = 100, pricenextlvl = 400, hp = 10,atkbonus = 2,damage = "1d4+1",eac = 11 ,kac = 14,  good = 4, poor = 1,abilitymod = "2,1", skillpoints = "+5", skills = "Acrobatics, Athletics, Perception, Stealth, Survival" },
	[2] = {price = 500 , pricenextlvl = 700,  hp = 20,atkbonus = 3,damage = "1d4+2",eac = 12,kac = 15,  good = 5, poor = 1,abilitymod = "2,1", skillpoints = "+6",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[3] = {price = 1200 , pricenextlvl = 600,  hp = 30,atkbonus = 4,damage = "1d4+3",eac =13 ,kac = 16,  good = 5, poor = 2,abilitymod = "2,1", skillpoints = "+7",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[4] = {price = 1800 , pricenextlvl = 900,  hp = 40,atkbonus = 5,damage = "1d4+4",eac = 15,kac = 18,  good = 5, poor = 2,abilitymod = "2,1", skillpoints = "+8",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[5] = {price = 2700, pricenextlvl = 2200,  hp = 55,atkbonus = 6,damage = "1d4+5",eac = 16,kac = 19,  good = 7, poor = 3,abilitymod = "2,1", skillpoints = "+9",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[6] = {price = 4900, pricenextlvl = 500,  hp = 65,atkbonus = 7,damage = "1d6+6",eac = 17,kac = 20,  good = 7, poor = 3,abilitymod = "2,1", skillpoints = "+10",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[7] = {price = 5400, pricenextlvl = 3000,  hp = 80,atkbonus = 9,damage = "1d8+7",eac = 19,kac = 22,  good = 8 , poor = 4,abilitymod = "3,2", skillpoints = "+12",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[8] = {price = 8400, pricenextlvl = 3600,  hp = 90,atkbonus = 10,damage = "1d12+8",eac = 20,kac = 23,  good = 8, poor = 4,abilitymod = "3,2", skillpoints = "+13",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[9] = {price = 12000, pricenextlvl = 5000,  hp = 105,atkbonus = 11,damage = "3d4+9",eac = 21,kac = 24,  good = 8, poor = 4,abilitymod = "3,2", skillpoints = "+14",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[10] = {price = 17000, pricenextlvl = 6000,  hp = 120,atkbonus = 13,damage = "2d8+10",eac = 23,kac = 26,  good = 10, poor = 5,abilitymod = "3,2", skillpoints = "+15",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[11] = {price = 23000, pricenextlvl = 8000,  hp = 135,atkbonus = 14,damage = "2d10+11",eac = 23,kac = 26,  good = 10, poor = 6,abilitymod = "3,2", skillpoints = "+16",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[12] = {price = 31000, pricenextlvl = 15000,  hp = 145,atkbonus = 14,damage = "2d12+12",eac = 24,kac = 27,  good = 10, poor = 6,abilitymod = "3,2", skillpoints = "+17",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[13] = {price = 46000, pricenextlvl = 17000,  hp = 160,atkbonus = 16,damage = "6d4+13",eac = 26,kac = 29,  good = 11, poor = 6,abilitymod = "4,3", skillpoints = "+19",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[14] = {price = 63000, pricenextlvl = 31000,  hp = 175,atkbonus = 17,damage = "6d6+14",eac = 27,kac = 30,  good = 11, poor = 6,abilitymod = "4,3", skillpoints = "+20",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[15] = {price = 94000, pricenextlvl = 50000,  hp = 190,atkbonus = 18,damage = "5d8+15",eac = 28,kac = 31,  good = 12, poor = 8,abilitymod = "4,3", skillpoints = "+21",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[16] = {price = 144000, pricenextlvl = 72000,  hp = 205,atkbonus = 19,damage = "6d8+16",eac = 30,kac = 33,  good = 12, poor = 8,abilitymod = "4,3", skillpoints = "+22",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[17] = {price = 216000, pricenextlvl = 109000,  hp = 225,atkbonus = 20,damage = "8d6+17",eac = 31,kac = 34,  good = 12, poor = 8,abilitymod = "4,3", skillpoints = "+23",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[18] = {price = 325000, pricenextlvl = 155000,  hp = 250,atkbonus = 21,damage = "8d8+18",eac = 32,kac = 35,  good = 13, poor = 8,abilitymod = "4,3", skillpoints = "+24",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[19] = {price = 480000, pricenextlvl = 240000,  hp = 275,atkbonus = 23,damage = "9d8+19",eac = 34,kac = 37,  good = 13, poor = 9,abilitymod = "5,4", skillpoints = "+26",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
	[20] = {price = 720000, pricenextlvl = 0,  hp = 300,atkbonus = 23,damage = "13d6+20",eac = 35,kac = 38,  good = 14, poor = 9,abilitymod = "5,4", skillpoints = "+27",skills = "Acrobatics (Dex), Athletics (Str), Perception (Wis), Stealth (Dex), Survival (Wis)",},
};
racetype ={
"",
"pc",
"companion",
};