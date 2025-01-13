local L = LibStub("AceLocale-3.0"):GetLocale("AutoCombatPotion")
local addonName, acp = ...

acp.defaults = {
    stopCast = false,
    preferredPotion = L["Tempered Potion"],
    temperedPotion = true,
    unwaveringFocusPotion = false,
    frontlinePotion = false,
}


--[[function acp.dbContains(id)
    local found = false
    for _, v in pairs(AutoCombatPotionDB.activatedSpells) do
        if v == id then
            found = true
        end
    end
    return found
end

function acp.removeFromDB(id)
    local backup = {}
    if ham.dbContains(id) then
        for _, v in pairs(AutoCombatPotionDB.activatedSpells) do
            if v ~= id then
                table.insert(backup, v)
            end
        end
    end

    AutoCombatPotionDB.activatedSpells = CopyTable(backup)
end

function acp.insertIntoDB(id)
    table.insert(AutoCombatPotionDB.activatedSpells, id)
end]]
