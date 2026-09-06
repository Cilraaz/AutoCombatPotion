local addonName, acp = ...

-- lua locals
local tinsert = table.insert

-- Midnight Combat Potions
acp.fleetingRampantAbandonR1 = acp.Item.new(245911, "Fleeting Draught of Rampant Abandon")
acp.fleetingRampantAbandonR2 = acp.Item.new(245910, "Fleeting Draught of Rampant Abandon")
acp.draughtOfRampantAbandonR1 = acp.Item.new(241293, "Draught of Rampant Abandon")
acp.draughtOfRampantAbandonR2 = acp.Item.new(241292, "Draught of Rampant Abandon")
acp.fleetingLightsPotentialR1 = acp.Item.new(245897, "Fleeting Light's Potential")
acp.fleetingLightsPotentialR2 = acp.Item.new(245898, "Fleeting Light's Potential")
acp.lightsPotentialR1 = acp.Item.new(241309, "Light's Potential")
acp.lightsPotentialR2 = acp.Item.new(241308, "Light's Potential")
acp.fleetingRecklessnessR1 = acp.Item.new(245903, "Fleeting Potion of Recklessness")
acp.fleetingRecklessnessR2 = acp.Item.new(245902, "Fleeting Potion of Recklessness")
acp.potionOfRecklessnessR1 = acp.Item.new(241289, "Potion of Recklessness")
acp.potionOfRecklessnessR2 = acp.Item.new(241288, "Potion of Recklessness")
acp.fleetingZealotryR1 = acp.Item.new(245900, "Fleeting Potion of Zealotry")
acp.fleetingZealotryR2 = acp.Item.new(245901, "Fleeting Potion of Zealotry")
acp.potionOfZealotryR1 = acp.Item.new(241297, "Potion of Zealotry")
acp.potionOfZealotryR2 = acp.Item.new(241296, "Potion of Zealotry")
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
  local rampantPots = {
    acp.fleetingRampantAbandonR2,
    acp.fleetingRampantAbandonR1,
    acp.draughtOfRampantAbandonR2,
    acp.draughtOfRampantAbandonR1,
  }
  local lightsPotentialPots = {
    acp.fleetingLightsPotentialR2,
    acp.fleetingLightsPotentialR1,
    acp.lightsPotentialR2,
    acp.lightsPotentialR1,
  }
  local recklessnessPots = {
    acp.fleetingRecklessnessR2,
    acp.fleetingRecklessnessR1,
    acp.potionOfRecklessnessR2,
    acp.potionOfRecklessnessR1,
  }
  local zealotryPots = {
    acp.fleetingZealotryR2,
    acp.fleetingZealotryR1,
    acp.potionOfZealotryR2,
    acp.potionOfZealotryR1,
  }
  local pots = {}
  if AutoCombatPotionDB.rampantPotion then
    for _, v in ipairs(rampantPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(recklessnessPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(lightsPotentialPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(zealotryPots) do
      tinsert(pots, v)
    end
  elseif AutoCombatPotionDB.lightsPotentialPotion then
    for _, v in ipairs(lightsPotentialPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(recklessnessPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(rampantPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(zealotryPots) do
      tinsert(pots, v)
    end
  elseif AutoCombatPotionDB.zealotryPotion then
    for _, v in ipairs(zealotryPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(recklessnessPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(rampantPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(lightsPotentialPots) do
      tinsert(pots, v)
    end
  else
    for _, v in ipairs(recklessnessPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(rampantPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(lightsPotentialPots) do
      tinsert(pots, v)
    end
    for _, v in ipairs(zealotryPots) do
      tinsert(pots, v)
    end
  end
  return pots
end
