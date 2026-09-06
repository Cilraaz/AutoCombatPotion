local L = LibStub("AceLocale-3.0"):GetLocale("AutoCombatPotion")
local addonName, acp = ...

---@class Frame
acp.settingsFrame = CreateFrame("Frame")
local ICON_SIZE = 50
local PADDING_CATERGORY = 60
local PADDING = 30
local PADDING_HORIZONTAL = 200
local classButtons = {}
local prioFrames = {}
local prioTextures = {}
local prioFramesCounter = 0
local firstIcon = nil
local positionx = 0
local currentPrioTitle = nil
local lastStaticElement = nil
local potionSelector = nil

function acp.settingsFrame:updateConfig(option, value)
	if acp.options[option] ~= nil then
		acp.options[option] = value -- Update in-memory
		AutoCombatPotionDB[option] = value       -- Persist to DB
	else
		print(L["Invalid option: "] .. tostring(option))
	end
	-- Rebuild the macro and update priority frame
	acp.updateCombatPots()
	acp.updateMacro()
	self:updatePrio()
end

function acp.settingsFrame:OnEvent(event, addOnName)
	if addOnName == "AutoCombatPotion" then
		if event == "ADDON_LOADED" then
			AutoCombatPotionDB = AutoCombatPotionDB or CopyTable(acp.defaults)
			if AutoCombatPotionDB.preferredPotion == nil then
				print(L["The Settings of AutoCombatPotion were reset due to breaking changes."])
				AutoCombatPotionDB = CopyTable(acp.defaults)
			end
			self:InitializeOptions()
		end
	end
	if event == "PLAYER_LOGIN" then
		acp.updateCombatPots()
		acp.updateMacro()
		self:updatePrio()
	end
end

acp.settingsFrame:RegisterEvent("PLAYER_LOGIN")
acp.settingsFrame:RegisterEvent("ADDON_LOADED")
acp.settingsFrame:SetScript("OnEvent", acp.settingsFrame.OnEvent)

function acp.settingsFrame:createPrioFrame(id, iconTexture, positionx, isSpell, isTinker)
	local icon = CreateFrame("Frame", nil, self.content, UIParent)
	icon:SetFrameStrata("MEDIUM")
	icon:SetWidth(ICON_SIZE)
	icon:SetHeight(ICON_SIZE)
	icon:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(icon, "ANCHOR_TOPRIGHT")
		if isSpell == true then
			GameTooltip:SetSpellByID(id)
		elseif isTinker then
			GameTooltip:SetInventoryItem("player", id)
		else
			GameTooltip:SetItemByID(id)
		end
		GameTooltip:Show()
	end)
	icon:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	local texture = icon:CreateTexture(nil, "BACKGROUND")
	texture:SetTexture(iconTexture)
	texture:SetAllPoints(icon)
	---@diagnostic disable-next-line: inject-field
	icon.texture = texture

	if firstIcon == nil then
		icon:SetPoint("TOPLEFT", potionSelector, "BOTTOMLEFT", 0, -PADDING * 2)
		firstIcon = icon
	else
		icon:SetPoint("TOPLEFT", firstIcon, positionx, 0)
	end
	icon:Show()
	table.insert(prioFrames, icon)
	table.insert(prioTextures, texture)
	prioFramesCounter = prioFramesCounter + 1
	return icon
end

function acp.settingsFrame:updatePrio()
	local spellCounter = 0
	local itemCounter = 0

	for i, frame in pairs(prioFrames) do
		frame:Hide()
	end

	-- Add items to priority frames
	if acp.itemIdList and next(acp.itemIdList) ~= nil then
		for i, id in ipairs(acp.itemIdList) do
			local entry
			local iconTexture
			local isTinker = false

			local _, _, _, _, _, _, _, _, _, tmpTexture = C_Item.GetItemInfo(id)
			entry = id
			iconTexture = tmpTexture

			local currentFrame = prioFrames[i + spellCounter]
			local currentTexture = prioTextures[i + spellCounter]

			if currentFrame ~= nil then
				currentFrame:SetScript("OnEnter", nil)
				currentFrame:SetScript("OnLeave", nil)
				currentFrame:HookScript("OnEnter", function(_, btn, down)
					GameTooltip:SetOwner(currentFrame, "ANCHOR_TOPRIGHT")
					if isTinker then
						GameTooltip:SetInventoryItem("player", acp.tinkerSlot)
					else
						GameTooltip:SetItemByID(id)
					end
					GameTooltip:Show()
				end)
				currentFrame:HookScript("OnLeave", function(_, btn, down)
					GameTooltip:Hide()
				end)
				currentTexture:SetTexture(iconTexture)
				currentTexture:SetAllPoints(currentFrame)
				currentFrame.texture = currentTexture
				currentFrame:Show()
			else
				self:createPrioFrame(entry, iconTexture, positionx, false, isTinker)
				positionx = positionx + (ICON_SIZE + (ICON_SIZE / 2))
			end
			itemCounter = itemCounter + 1
		end
	end
end

local function SelectPreferredPot(selectedPot)
	print("Newly selected pot: " .. selectedPot)
end

function acp.settingsFrame:InitializeOptions()
	-- Create the main panel inside the Interface Options container
	self.panel = CreateFrame("Frame", addonName, InterfaceOptionsFramePanelContainer)
	self.panel.name = addonName

	-- Register with Interface Options
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(self.panel)
	else
		local category = Settings.RegisterCanvasLayoutCategory(self.panel, addonName)
		Settings.RegisterAddOnCategory(category)
		self.panel.categoryID = category:GetID() -- for OpenToCategory use
	end

	-- inset frame to provide some padding
	self.content = CreateFrame("Frame", nil, self.panel)
	self.content:SetPoint("TOPLEFT", self.panel, "TOPLEFT", 16, -16)
	self.content:SetPoint("BOTTOMRIGHT", self.panel, "BOTTOMRIGHT", -16, 16)

	-- title
	local title = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	title:SetPoint("TOP", 0, 0)
	title:SetText(L["Auto Combat Potion Settings"])

	-- subtitle
	local subtitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subtitle:SetPoint("TOPLEFT", 0, -40)
	subtitle:SetText(L["Configure the behavior of the addon."])

	-- behavior title
	local behaviorTitle = self.content:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
	behaviorTitle:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -30)
	behaviorTitle:SetText(L["Addon Behavior"])

	-------------  Stop Casting  -------------	
	local stopCastButton = CreateFrame("CheckButton", nil, self.content, "InterfaceOptionsCheckButtonTemplate")
	stopCastButton:SetPoint("TOPLEFT", behaviorTitle, 0, -PADDING)
	stopCastButton.Text:SetText(L["Include /stopcasting in the macro"])
	stopCastButton:HookScript("OnClick", function(_, btn, down)
		acp.settingsFrame:updateConfig("stopCast", stopCastButton:GetChecked())
	end)
	stopCastButton:HookScript("OnEnter", function(_, btn, down)
		GameTooltip:SetOwner(stopCastButton, "ANCHOR_TOPRIGHT")
		GameTooltip:SetText(L["Useful for casters."])
		GameTooltip:Show()
	end)
	stopCastButton:HookScript("OnLeave", function(_, btn, down)
		GameTooltip:Hide()
	end)
	stopCastButton:SetChecked(AutoCombatPotionDB.stopCast)
	lastStaticElement = stopCastButton


	-------------  ITEMS  -------------
	local itemsTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	itemsTitle:SetPoint("TOPLEFT", lastStaticElement, 0, -PADDING_CATERGORY)
	itemsTitle:SetText(L["Items"])

	-- Dropdown Menu for Preferred Combat Potion
	potionSelector = CreateFrame("Frame", "ACP_POTION_SELECTOR", self.content, "UIDropDownMenuTemplate")
	local updateSetting = function(self)
		UIDropDownMenu_SetSelectedID(potionSelector, self:GetID())
		local selected = UIDropDownMenu_GetText(potionSelector)
		AutoCombatPotionDB.preferredPotion = selected
		if selected == L["Potion of Recklessness"] then
			AutoCombatPotionDB.recklessPotion = true
			AutoCombatPotionDB.rampantPotion = false
			AutoCombatPotionDB.lightsPotentialPotion = false
			AutoCombatPotionDB.zealotryPotion = false
		elseif selected == L["Draught of Rampant Abandon"] then
			AutoCombatPotionDB.rampantPotion = true
			AutoCombatPotionDB.recklessPotion = false
			AutoCombatPotionDB.lightsPotentialPotion = false
			AutoCombatPotionDB.zealotryPotion = false
		elseif selected == L["Light's Potential"] then
			AutoCombatPotionDB.lightsPotentialPotion = true
			AutoCombatPotionDB.recklessPotion = false
			AutoCombatPotionDB.rampantPotion = false
			AutoCombatPotionDB.zealotryPotion = false
		elseif selected == L["Potion of Zealotry"] then
			AutoCombatPotionDB.zealotryPotion = true
			AutoCombatPotionDB.recklessPotion = false
			AutoCombatPotionDB.rampantPotion = false
			AutoCombatPotionDB.lightsPotentialPotion = false
		end
		acp.MakeMacro()
	end

	local potionSelectorTitle = potionSelector:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	potionSelectorTitle:SetPoint("TOPLEFT", itemsTitle, 0, -PADDING)
	potionSelectorTitle:SetJustifyH("LEFT")
	potionSelectorTitle:SetText(L["Choose Your Preferred Potion"])

	-- Initialize the dropdown menu
	potionSelector:SetPoint("TOPLEFT", potionSelectorTitle, 0, -PADDING+10)
	lastStaticElement = potionSelector

	local function initDropdown(Self, Level)
		local Info = UIDropDownMenu_CreateInfo()
		Info.text = L["Potion of Recklessness"]
		Info.value = L["Potion of Recklessness"]
		Info.func = updateSetting
		UIDropDownMenu_AddButton(Info, Level)
		Info = UIDropDownMenu_CreateInfo()
		Info.text = L["Draught of Rampant Abandon"]
		Info.value = L["Draught of Rampant Abandon"]
		Info.func = updateSetting
		UIDropDownMenu_AddButton(Info, Level)
		Info = UIDropDownMenu_CreateInfo()
		Info.text = L["Light's Potential"]
		Info.value = L["Light's Potential"]
		Info.func = updateSetting
		UIDropDownMenu_AddButton(Info, Level)
		Info = UIDropDownMenu_CreateInfo()
		Info.text = L["Potion of Zealotry"]
		Info.value = L["Potion of Zealotry"]
		Info.func = updateSetting
		UIDropDownMenu_AddButton(Info, Level)
	end

	UIDropDownMenu_Initialize(potionSelector, initDropdown)
	UIDropDownMenu_SetSelectedValue(potionSelector, AutoCombatPotionDB.preferredPotion)
	UIDropDownMenu_JustifyText(potionSelector, "LEFT")


	-------------  CURRENT PRIORITY  -------------
	currentPrioTitle = self.content:CreateFontString("ARTWORK", nil, "GameFontNormalHuge")
	currentPrioTitle:SetPoint("TOPLEFT", potionSelector, 0, -PADDING_CATERGORY)
	currentPrioTitle:SetText(L["Current Priority"])


	-------------  RESET BUTTON  -------------
	local btn = CreateFrame("Button", nil, self.content, "UIPanelButtonTemplate")
	btn:SetPoint("BOTTOMLEFT", 2, 3)
	btn:SetText(L["Reset to Default"])
	btn:SetWidth(120)
	btn:SetScript("OnClick", function()
		AutoCombatPotionDB = CopyTable(acp.defaults)
		acp.updateCombatPots()
		acp.updateMacro()
		self:updatePrio()
		print(L["Reset successful!"])
	end)
end

SLASH_ACPOTION1 = "/acpotion"
SLASH_ACPOTION2 = "/autocombatpotion"

SlashCmdList.ACPOTION = function(msg, editBox)
	-- Check if the message contains "debug"
	if msg and msg:trim():lower() == "debug" then
		acp.debug = not acp.debug
		print("|cffb48ef9AutoCombatPotion:|r Debug mode is now " .. (acp.debug and "enabled" or "disabled"))
		return
	end

	-- Reset DB
	if msg and msg:trim():lower() == "reset" then
		AutoCombatPotionDB = CopyTable(acp.defaults)
		print("|cffb48ef9AutoCombatPotion:|r " .. L["Reset successful!"])
		return
	end

	-- Open settings if no "debug" keyword was passed
	if InterfaceOptions_AddCategory then
		InterfaceOptionsFrame_OpenToCategory(addonName)
	else
		local settingsCategoryID = _G[addonName].categoryID
		Settings.OpenToCategory(settingsCategoryID)
	end
end
