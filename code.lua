local L = LibStub("AceLocale-3.0"):GetLocale("AutoCombatPotion")
local addonName, acp = ...
local macroName = L["AutoCombatPotion"]

-- Configuration options
-- Use in-memory options as AutoCombatPotionDB updates are not persisted instantly.
-- We'll also use lazy initialization to prevent early access issues.
setmetatable(acp, {
  __index = function(t, k)
    if k == "options" then
      t.options = {
        stopCast = AutoCombatPotionDB.stopCast or false,
        temperedPotion = AutoCombatPotionDB.temperedPotion or false,
        unwaveringFocusPotion = AutoCombatPotionDB.unwaveringFocusPotion or false,
        frontlinePotion = AutoCombatPotionDB.frontlinePotion or false,
        preferredPotion = AutoCombatPotionDB.preferredPotion or L["Tempered Potion"],
      }
      if not t.options.temperedPotion and not t.options.unwaveringFocusPotion and not t.options.frontlinePotion then
        t.options.temperedPotion = true
        AutoCombatPotionDB.temperedPotion = true
      end
      return t.options
    end
  end
})

acp.debug = false
acp.tinkerSlot = nil

local itemsMacroString = ''
local macroStr = ''
local resetType = "combat"
local bagUpdates = false -- debounce watcher for BAG_UPDATE events
local debounceTime = 3   -- seconds
local combatRetry = 0    -- number of combat retries

-- MegaMacro addon compatibility
local megaMacro = {
  name = "MegaMacro", -- the addon name
  retries = 0,        -- number of loaded checks to prevent infinite loop
  checked = false,    -- did we check for the addon?
  installed = false,  -- is the addon installed?
  loaded = false,     -- is the addon loaded?
}

local function log(message)
  if acp.debug then
    print("|cffb48ef9AutoCombatPotion:|r " .. message)
  end
end

local function addPreferredCombatPotIfAvailable()
  log("Updating preferred pot counts...")
  local pots = acp.getPreferredPots()
  for i, value in ipairs(pots) do
    log("Item: " .. tostring(value.getId()) .. " Count: " .. tostring(value.getCount()))
    if value.getCount() > 0 then
      table.insert(acp.itemIdList, value.getId())
      --we break because all Pots share a cd so we only want the highest priority one
      break;
    end
  end
end


function acp.updateCombatPots()
  acp.itemIdList = {}

  -- Priority 1: Add Preferred Combat Pots if available
  addPreferredCombatPotIfAvailable()
end

local function createMacroIfMissing()
  -- dont create macro if MegaMacro is installed and loaded
  if megaMacro.installed and megaMacro.loaded then
    return
  end
  local name = GetMacroInfo(macroName)
  if name == nil then
    CreateMacro(macroName, "INV_Misc_QuestionMark")
  end
end

local function buildItemMacroString()
  if next(acp.itemIdList) ~= nil then
    for i, name in ipairs(acp.itemIdList) do
      local entry
      -- Check if the entry starts with "slot:" and extract the slot number
      if type(name) == "string" and name:match("^slot:") then
        entry = name:sub(6)               -- Extract everything after "slot:"
      else
        entry = "item:" .. tostring(name) -- Default to item ID formatting
      end
      -- Add the entry to the macro string
      if i == 1 then
        itemsMacroString = entry
      else
        itemsMacroString = itemsMacroString .. ", " .. entry
      end
    end
  end
end

local function UpdateMegaMacro(newCode)
  for _, macro in pairs(MegaMacroGlobalData.Macros) do
    if macro.DisplayName == macroName then
      MegaMacro.UpdateCode(macro, newCode)
      log("MegaMacro updated with: " .. newCode)
      return
    end
  end
  print(
    "|cffff0000AutoCombatPotion Error:|r Missing global 'AutoCombatPotion' macro in MegaMacro. Please create it then reload your game.")
end

local function checkMegaMacroAddon()
  -- MegaMacro is only available for retail
  if not isRetail then
    megaMacro.checked = true
    return
  end

  -- is MegaMacro installed?
  local name = C_AddOns.GetAddOnInfo(megaMacro.name)
  if not name then
    megaMacro.installed = false
    megaMacro.checked = true
    return
  end

  megaMacro.installed = true

  -- is the addon loaded?
  if C_AddOns.IsAddOnLoaded(megaMacro.name) then
    megaMacro.loaded = true
    megaMacro.checked = true
    return
  end

  -- Retry loading if not yet loaded
  if megaMacro.retries < 3 then
    megaMacro.retries = megaMacro.retries + 1
    C_Timer.After(debounceTime, checkMegaMacroAddon)
  else
    megaMacro.checked = true
  end
end

function acp.updateMacro()
  if next(acp.itemIdList) == nil then
    macroStr = "#showtooltip"
    if acp.options.stopCast then
      macroStr = macroStr .. "\n /stopcasting \n"
    end
  else
    resetType = "combat"
    buildItemMacroString()
    macroStr = "#showtooltip \n"
    if acp.options.stopCast then
      macroStr = macroStr .. "/stopcasting \n"
    end
    macroStr = macroStr .. "/castsequence reset=" .. resetType .. " "
    if itemsMacroString ~= "" then
      macroStr = macroStr .. itemsMacroString
    end
  end

  if not megaMacro.checked then
    log("MegaMacro not checked. Retrying.")
    checkMegaMacroAddon()
    return
  end

  if megaMacro.installed and megaMacro.loaded then
    UpdateMegaMacro(macroStr)
    return
  end

  log('MegaMacro not in use. Creating default macro.')
  createMacroIfMissing()

  -- Use pcall to suppress LUA errors
  local success, err = pcall(function()
    EditMacro(macroName, macroName, nil, macroStr)
  end)
  if success then
    log('Macro updated.')
  end
end

function acp.MakeMacro()
  -- dont attempt to create macro until MegaMacro addon is checked
  if not megaMacro.checked then
    log("MegaMacro not checked or loaded. Retrying.")
    checkMegaMacroAddon()
    return
  end

  -- retry if player is still in combat
  if InCombatLockdown() then
    if combatRetry < 4 then
      combatRetry = combatRetry + 1
      log("Player in combat. Retry attempt: " .. combatRetry)
      C_Timer.After(0.5, acp.MakeMacro)
    else
      log("Failed to update macro after 4 attempts.")
    end
    return
  end

  -- safe to update macro
  combatRetry = 0
  acp.updateCombatPots()
  acp.updateMacro()
  acp.settingsFrame:updatePrio()
end

-- debounce handler for BAG_UPDATE events which can fire very rapidly
local function onBagUpdate()
  if bagUpdates then
    return
  end
  log("event: BAG_UPDATE")
  bagUpdates = true
  C_Timer.After(debounceTime, function()
    acp.MakeMacro()
    bagUpdates = false
  end)
end

local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("ADDON_LOADED")
updateFrame:RegisterEvent("BAG_UPDATE")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
updateFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
if isClassic == false then
  updateFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
end
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
updateFrame:RegisterEvent("UNIT_PET")
updateFrame:SetScript("OnEvent", function(self, event, arg1, ...)
  -- when addon is loaded
  if event == "ADDON_LOADED" and arg1 == addonName then
    updateFrame:UnregisterEvent("ADDON_LOADED")
    log("event: ADDON_LOADED")
    acp.MakeMacro()
    return
  end
  -- player is in combat, do nothing
  if InCombatLockdown() then
    return
  end
  -- bag update events
  if event == "BAG_UPDATE" then
    onBagUpdate()
    -- on loading/reloading
  elseif event == "UNIT_PET" then
    log("event: UNIT_PET")
    acp.MakeMacro()
    -- when pet is called
  elseif event == "PLAYER_ENTERING_WORLD" then
    log("event: PLAYER_ENTERING_WORLD")
    acp.MakeMacro()
    -- on exiting combat
  elseif event == "PLAYER_REGEN_ENABLED" then
    log("event: PLAYER_REGEN_ENABLED")
    -- Wait a second after combat ends to update the macro
    -- as the UI may still be cleaning up a protected state.
    C_Timer.After(0.5, acp.MakeMacro)
    -- when talents change and classic is false
  elseif isClassic == false and event == "TRAIT_CONFIG_UPDATED" then
    log("event: TRAIT_CONFIG_UPDATED")
    acp.MakeMacro()
    -- when player changes equipment
  elseif event == "PLAYER_EQUIPMENT_CHANGED" then
    log("event: PLAYER_EQUIPMENT_CHANGED")
    acp.MakeMacro()
  end
end)
