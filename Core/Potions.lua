local addonName, acp = ...

-- lua locals
local tinsert = table.insert

-- TWW Combat Potions
acp.temperedPotionR3 = acp.Item.new(212265, "Tempered Potion")
acp.temperedPotionR2 = acp.Item.new(212264, "Tempered Potion")
acp.temperedPotionR1 = acp.Item.new(212263, "Tempered Potion")
acp.fleetingTemperedPotionR3 = acp.Item.new(212971, "Fleeting Tempered Potion")
acp.fleetingTemperedPotionR2 = acp.Item.new(212970, "Fleeting Tempered Potion")
acp.fleetingTemperedPotionR1 = acp.Item.new(212969, "Fleeting Tempered Potion")
acp.unwaveringFocusPotionR3 = acp.Item.new(212259, "Potion of Unwavering Focus")
acp.unwaveringFocusPotionR2 = acp.Item.new(212258, "Potion of Unwavering Focus")
acp.unwaveringFocusPotionR1 = acp.Item.new(212257, "Potion of Unwavering Focus")
acp.fleetingUnwaveringFocusPotionR3 = acp.Item.new(212965, "Fleeting Potion of Unwavering Focus")
acp.fleetingUnwaveringFocusPotionR2 = acp.Item.new(212964, "Fleeting Potion of Unwavering Focus")
acp.fleetingUnwaveringFocusPotionR1 = acp.Item.new(212963, "Fleeting Potion of Unwavering Focus")
acp.frontlinePotionR3 = acp.Item.new(212262, "Frontline Potion")
acp.frontlinePotionR2 = acp.Item.new(212261, "Frontline Potion")
acp.frontlinePotionR1 = acp.Item.new(212260, "Frontline Potion")
acp.fleetingFrontlinePotionR3 = acp.Item.new(212968, "Fleeting Frontline Potion")
acp.fleetingFrontlinePotionR2 = acp.Item.new(212967, "Fleeting Frontline Potion")
acp.fleetingFrontlinePotionR1 = acp.Item.new(212966, "Fleeting Frontline Potion")


function RemoveFromList(list, itemToRemove)
  for i = #list, 1, -1 do
    if list[i] == itemToRemove then
      table.remove(list, i)
    end
  end
end

function acp.getPreferredPots()
  local temperedPots = {
    acp.fleetingTemperedPotionR3,
    acp.fleetingTemperedPotionR2,
    acp.fleetingTemperedPotionR1,
    acp.temperedPotionR3,
    acp.temperedPotionR2,
    acp.temperedPotionR1
  }
  local unwaveringPots = {
    acp.fleetingUnwaveringFocusPotionR3,
    acp.fleetingUnwaveringFocusPotionR2,
    acp.fleetingUnwaveringFocusPotionR1,
    acp.unwaveringFocusPotionR3,
    acp.unwaveringFocusPotionR2,
    acp.unwaveringFocusPotionR1
  }
  local frontlinePots = {
    acp.fleetingFrontlinePotionR3,
    acp.fleetingFrontlinePotionR2,
    acp.fleetingFrontlinePotionR1,
    acp.frontlinePotionR3,
    acp.frontlinePotionR2,
    acp.frontlinePotionR1
  }
  local pots = {}
  if AutoCombatPotionDB.frontlinePotion then
    for _, v in pairs(frontlinePots) do
      tinsert(pots, v)
    end
    for _, v in pairs(temperedPots) do
      tinsert(pots, v)
    end
    for _, v in pairs(unwaveringPots) do
      tinsert(pots, v)
    end
  elseif AutoCombatPotionDB.unwaveringFocusPotion then
    for _, v in pairs(unwaveringPots) do
      tinsert(pots, v)
    end
    for _, v in pairs(temperedPots) do
      tinsert(pots, v)
    end
    for _, v in pairs(frontlinePots) do
      tinsert(pots, v)
    end
  else
    for _, v in pairs(temperedPots) do
      tinsert(pots, v)
    end
    for _, v in pairs(unwaveringPots) do
      tinsert(pots, v)
    end
    for _, v in pairs(frontlinePots) do
      tinsert(pots, v)
    end
  end
  return pots
end
