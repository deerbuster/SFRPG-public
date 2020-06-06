
if UPDATE FIXES AND CHANGES (REV 2.1.0)
--[ADDED] Character Operations Manual Requirments
--[UPDATE] Updated Class record Special Features updating. Disabled Update All function, Class records now update when record is opened.
--[BUG] Fixed Features not updating. (I.E Envoy Improvisions).
--[MOD] Operatives Freeskills can now be manually turned on and off via the skills edit screen.

-------To FIX BEFORE Release-------------


Verify PC Leveling works for all classes
Fix PC Tabs
end

if UPDATE FIXES AND CHANGES (REV 2.0.0)
	--[Enhancement] Merged Ship Combat Extension into main code. 
end

if UPDATE FIXES AND CHANGES (REV 1.2.7)
	--[Fixed] Script Error for Creating a new Class (sClass in Class Manager)
	--[Fixed] DR:10/magic will now be bypassed if damage type has magic (2d10 S,magic).
	--[Fixed] Blinded effect adding additional -2.
end
if UPDATE FIXES AND CHANGES (REV 1.2.6)
--[Fixed] Fixed that upgrade slots were not properly accounted for in item forge
--[Fixed] Fixed console error when creating a new Class record
end

if UPDATE FIXES AND CHANGES (REV 1.2.5)
--[ADDED] Requirements for Character Operations Manual added to system.
--[BUG FIX] Fixed script error when using Archtypes button from Class window.
--[Enhancment] FGU TTF font tags to migrate to Noto Sans in order to support extended character sets.
--[BUG FIX] Fixed RESIST not working.
--[BUG FIX] Fixed non-lethal damage reporting correct.
--[BUG FIX] Fixed Status reporting when final damage was non-lethal.
--[BUG FIX] Fixed Effect AC now adds correct (AC:2,ranged and AC:2,melee)
--[ADDED] Added Effect EAC and KAC now adds to EAC or KAC Attack (KAC:2 or EAC:2)
end
if UPDATE FIXES AND CHANGES (REV 1.2.4)
--(L)[Enhancement] Modifier buttons now show tooltips and correct cover types per CRB
--(L)[BUG FIX] Added missing labels for add ability action menu
--(L)[BUG FIX] Fixed Action Effect label and duration fields garbled with large text
--(L)[BUG FIX] Removed 50 use limit from weapon charges
--(R)[Enhancement] (Class Record)Feature and Special Feature tabs can now Drag-n-Drop to copy record
--(L)[BUG FIX] Fixed that DR types were not applied to PC
--(L)[BUG FIX] Fixed that nonlethal damage stabilizes (and keeps dying status)
--(L)[BUG FIX] Fixed RP didn't decrement at end of turn if dying at start of turn
--(L)[BUG FIX] Fixed RP decremented at exactly 1/2 total HP on second damage per turn
--(L)[BUG FIX] Fixed intermittent problem with fatigue > SP
--(L)[Enhancement] Added Nonlethal damage type to modifiers
--(L)[BUG FIX] Fixed that modifier labels were not showing up on white background

--COM Code Disabled
end


if UPDATE FIXES AND CHANGES (REV 1.2.3b)
--[HOT FIX] Fixed a recursive error when opening a action.
end

if UPDATE FIXES AND CHANGES (REV 1.2.3a)
--[HOT FIX] Fixed Character select and Release issue.
end
if UPDATE FIXES AND CHANGES (REV 1.2.3)
--(L)[BUG FIX] Able to heal more stamina points than you lost
--(L)[Enhancement] Companion changes added to character log.
--(L)[BUG FIX] Effects damage dice not doubling on critical.
--(L)[BUG FIX] Companion name not showing up when rolling skills or abilities
--(L)[BUG FIX] Encumbered and Overburdened effects now work for Abiltities and Skills.  Still not 100% on Def effects.
--(L)[Enhancement] Duplicate Feat checks added
--(L)[Enhancement] Toughness Feat now adds stamina mod on add and level up.  Drop and re-add Toughness to get initial add.
--(L)[BUG FIX] RP Calc now has a minimum of 1 per level
--(L)[BUG FIX] Companion ownership changed on character select
--(R)[BUG FIX] Fixed srcipt error when dropping parcel to inventory sheet.

end

if UPDATE FIXES AND CHANGES (REV 1.2.2)
--(L)[BUG FIX] Unable to use Signal Basic drift engine
--(R)[Enhancement] Item Templates can now be dropped in both Parcels and Party sheet.
--(R)[Spells] Added Class field in Spell record.(For search by Class).
--(L)[CT Menu] Clear All Init now also resets rounds.
--(R)[Races] Fixed script error when opening a race in client mode.
--(L)ItemTemplates empty lines now hide when record locked.
end

if UPDATE FIXES AND CHANGES (REV 1.2.1)
--(L)[BUG FIX] Unable to increase skill rank after level up
--(L)[BUG FIX] Corrected spelling of Overburdened condition
--[Drones] Fixed key ability issue giving script error.
end
if UPDATE FIXES AND CHANGES (REV 1.2.0)
--[ADDED] Companions system
--[FIXED] RP being spent on all action rolls.
--[FIXED] Inventory: Should be adding 1 bulk per 1000 UPB
--[ADDED] Class level effects now possible (see Effects below)
--[FIXED] Critical attacks Damage not applying on weapon attack for PC.
--[SKILLS] Ranks no longer can go above Characters Level (Characters Level - FreeSkills for Operatives free skills.).
--[CT] CT now shows HP/TEMP HP/WOUNDS/SP/FATIQUE/RP both Host and Client
====NOTES======
Effects
--Can now use [{CLASSNAME}] to obtain the level of a specific class in effects.  This will come more into play as effects handling is improved
----Example: DMG:[SOLDIER]; would add the level of your Soldier class to the amount of damage you do.
CT Update
--PC' will required to be re-dropped in the CT to update the new links in the CT.
Known issues
--Local Mode: has several issues and is currently unreliable
--Local Mode: companion information missing from owned companion sheet
--Action: Ability Actions copied from another sheet only have name and Use Action
--Action: Effects damage dice do not double on critical currently
--Class: Mechanic exocortex does not add weapon and armor proficiency
--Feat: Toughness does not add 1SP/level
end

if UPDATE FIXES AND CHANGES (REV 1.1.0)
--(R)[Action Tab] Added ability to Drop (Items,Feats and Skill Tasks) to the Action Tab as a ability.
--(R)[Skills] Added Misc Bonus calculation per bonus type. (in edit mode).	
--(R)[Prof] Attacks while NON PROF now give a -4 and report {NON-PROF].
--(R)[FULL ATTACK] Full Attacks now look at ammo remaining and adjust the number of allowed attacks if not enough ammo.
--(L)[HEAVY Weapons] -2 to attacks if weapon is too heavy for your STR.
--(L)[Effects] Added that damage will remove Asleep effect and healing will remove bleeding effect
--(L)[Effects] Fixed that Stunned condition was applying flat-footed effect twice
--(L)[Logging] Added character logging to allow for future ability to be able to delete a level correctly.
--(R)[Spells] Put ability to use Spell Like Abilities (can set seperate castable per day for spells Preperation Spell Caster operation)
--(R)[Logging] Stats now added to log.
--(R)[BUG FIX] Race and Theme can no longer be dropped if the already exist.
--(L)[BUG FIX] Ammunition no longer creates entry on Action tab automatically.
--(L)[BUG FIX] Drift engine size validation check now correct
--Switch to semantic versioning (https://semver.org/), starting with version 1.1.0

end
if UPDATE FIXES AND CHANGES (REV 1.0.15a)
-- [Fixed] Profession Skills no longer get console error
--[Fixed] Mixed DAMTYPE Short/Long now convert correct.
--[Fixed] Effect DMGTYPE can now add to short damage type from weapon.
--[Fixed] Fixed damage type "nonlethal" Will now put Uncon/Stable/Prone on the target if the damage that put him at 0 HP was non-lethal.
--[Fixed] Added Uses Per Day (Per Ability) Can set how many times a day when in Prep mode. Standard Mode will have that many bubbles. -- This is Per Ability not Per Section like Spells, so when you check off one use it does not affect the other abilities in that section.
--[Fixed] Sections (Old Level Header) now have a writable Name
--[Fixed] Class Block now only has one Number Box to set the number of sections per Group--With the last two changes the Actions Tab Ability Section is completely user configurable.---# of Groups, # of Sections per Group, as many abilities as you want per Section, Each Ability Configurable Uses per Day if needed. All can be Named what the user wants to name them.
--[Fixed] Effect ABIL: and DEX: CON: ect.. now work correct again.
--[Fixed] Effect SKILL: now works with Ability system.
--[Fixed] Cleaned up how Abilities report to Chat (Much cleaner looking)
--[Fixed] Added Opposed Check option for Ability Checks (When selected the roll will go to chat and the result line will say I.E Check [26] -- [OPPOSED CHECK] -> {tARGET}--This tells the GM that the Ability has a Opposed Check and he can make his Check and pass out the results.
--[FIXED] Ability check using a Skill now adjust correct if the Ability Stat for the Skill has a effect. I.E Ability uses Stealth Skill and the user has the effect DEX:-2.
--[FIXED] Combat Maneuver option for Attack type will now roll attack against the targets CMD (which is set at KAC +8).
--[LIB] Added {Race-Alpha] button to Races List window. (Gives a detailed list of Races (Type/HP/Ability Score Adjustments/Size).--Fixed console error related to this change.
end
if UPDATE FIXES AND CHANGES (REV 1.0.15)
--Updated base.xml to Rev 1.0.15
Ability and Spells Systems
Spell Tab
--[Spells] Added Spells Tab and moved Spells from Action tab to Spells tab. 
---Removed Level 0 from Spells Per Day
--- Added Spells Known Line
---Both Update automatic. (Spells Per Day will update anytime your spell-casting ability stat score changes).
--[LEVEL-0 Spells changes.]
--- Level 0 Spell Bar now reads "Level 0 At-Will"
--- No longer shows a use circle
--- Level 0 Spells will not disappear when used if in "Combat Mode".
Action Tab
  -- Added Ability Group for abilities like Trick Attack ect.
  -- Cast action includes Skill Bonus, and DC Check configurations.
Main System
--[CT] Traps Effect is now a Attack String, also transfers to Atk section on NPC when dropped in CT.
--[Skills] Trained Only Skills with Free Skill Ranks ONLY no longer report (UNTRAINED).
--[Skills] Fixed Operative (Explorer Spec) not listing the Free Skills.
--[Lib] Added Traps button to top of NPC Library.
Starship System
-- [Lib] Fixed filter Type to show Types (I.E. Frame)
end
if QUICK FIX (REV 1.14a)
Main System
--[Spells] Fixed spell parsinf for PC/NPCs 

end
if UPDATE FIXES AND CHANGES (REV 1.0.14)
Main System
--[PC] Fixed Key Ability issues
--[PC] Fixed Resolve calulations when creating a 1st lvl character.
--[PC] Fixed Script error when adding a custom class.

-- [Desktop] Added Cover and FF button to Modifier Stack
-- [Forge] Removed Forge option for Client (until I can get it working right).
-- [CT] Removed Atks and Saves that were added from Creature Traits.

Starship System
-- [PC Ship] Items that don't match the Frame size can no longer be added to ship.
-- [PC Ship] Reset now resets all but the Ship Name.
end
if UPDATE FIXES AND CHANGES (REV 1.0.13)

General Items
-- Fixed Update Suggested Books List in the Starting setup.

Bugs and Fixes
--[Combat] Fixed Weapons with Multi Damage Types- Damage is now handled correct with a damage type I.E- P & C
--[Combat] Fixed Immune/Vuln/Resist/ and DR section works correct with Multi Damage types
--[Char Sheet] Fixed Primary Stat disappears off Class Editor when you Level up.
--[Skills] Fixed  Class Skills for Multi Class incorrect. Class skills now mark correct for Multi Class
--[Skills] Fixed  Operative Free Skill system now works correct (seperate box for Free Skill)
--[Char Sheet] Verified BAB for Multi Class is working correct.

New Added Content
--[Ability Score Editor] Added Ability modifier to the editor. (Shows what the Bonus will be on the Editor window)
end
