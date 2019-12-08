local list_lookup = {
    ["featlist"] = "Feat",
    ["proficiencylist"] = "Proficiency",
    ["specialabilitylist"] = "Class Ability",
    ["themeabilitylist"] = "Theme Ability",
    ["traitlist"] = "Racial Trait",
    ["languagelist"] = "Language",
    ["boonlist"] = "Boon",
    ["auglist"] = "Augmentation",
    ["upgradelist"] = "Upgrade",  
};

LOG_ACTION_ADD = "ADD";
LOG_ACTION_ADJUST = "ADJUST";
LOG_ACTION_REMOVE = "REMOVE";

function LogMessage(nodeChar,sAction, sRecord, sValue)
  local nLevel = DB.getValue(nodeChar, "level", 0)

  local nodeTargetList = DB.getValue(nodeChar,"loglist");
  if not nodeTargetList then
    nodeTargetList = nodeChar.createChild("loglist");
    if not nodeTargetList then
      return false;
    end
  end
  local nodeEntry = nodeTargetList.createChild();
  DB.setValue(nodeEntry,"record_added","string", sRecord);
  DB.setValue(nodeEntry,"action_added","string", sAction);
  DB.setValue(nodeEntry,"value_added","string", sValue);
  DB.setValue(nodeEntry,"level_added","number", nLevel);
end

function onListAdd(sourceNode)
  local nodeChar = sourceNode.getParent().getParent();
  local sList = sourceNode.getParent().getName();
  local sName = DB.getValue(sourceNode, "name", "", "");
  local sClass = list_lookup[sList];

  LogMessage(nodeChar,LOG_ACTION_ADD, sClass, sName);
end

function onDelete(sourceNode)
  local nodeChar = sourceNode.getParent().getParent();
  local sList = sourceNode.getParent().getName();
  local sName = DB.getValue(sourceNode, "name", "", "");
  local sClass = list_lookup[sList];

  LogMessage(nodeChar,LOG_ACTION_REMOVE, sClass, sName);
end