local _, addonTable = ...
local function SetupBackpackView()
  local backpackView
  local allBackpackViews = {
    single = CreateFrame("Frame", "Baganator_SingleViewBackpackViewFrame", UIParent, "BaganatorSingleViewBackpackViewTemplate"),
    category = CreateFrame("Frame", "Baganator_CategoryViewBackpackViewFrame", UIParent, "BaganatorCategoryViewBackpackViewTemplate"),
  }

  function addonTable.ViewManagement.GetBackpackFrame()
    return backpackView
  end

  backpackView = allBackpackViews[addonTable.Config.Get(addonTable.Config.Options.VIEW_TYPE)]

  local bagButtons = {}

  local UpdateButtons
  if addonTable.Constants.IsClassic then
    UpdateButtons = function()
      for _, b in ipairs(bagButtons) do
        b:SetChecked(backpackView:IsVisible())
      end
    end
  else
    UpdateButtons = function()
      for _, b in ipairs(bagButtons) do
        b.SlotHighlightTexture:SetShown(backpackView:IsVisible())
      end
    end
  end

  local function SetPositions()
    for _, backpackView in pairs(allBackpackViews) do
      backpackView:ClearAllPoints()
      backpackView:SetPoint(unpack(addonTable.Config.Get(addonTable.Config.Options.MAIN_VIEW_POSITION)))
    end
  end

  local function ResetPositions()
    addonTable.Config.ResetOne(addonTable.Config.Options.MAIN_VIEW_POSITION)
    SetPositions()
  end

  local success = pcall(SetPositions) -- work around broken values
  if not success then
    ResetPositions()
  end

  for _, backpackView in pairs(allBackpackViews) do
    table.insert(UISpecialFrames, backpackView:GetName())

    backpackView:HookScript("OnHide", function()
      UpdateButtons()
    end)
  end

  addonTable.CallbackRegistry:RegisterCallback("ResetFramePositions", function()
    ResetPositions()
  end)

  local lastToggleTime = 0
  local function ToggleBackpackView()
    if GetTime() == lastToggleTime then
      return
    end
    backpackView:SetShown(not backpackView:IsShown())
    if backpackView:IsVisible() then
      backpackView:UpdateForCharacter(Syndicator.API.GetCurrentCharacter(), true)
    end
    lastToggleTime = GetTime()
    UpdateButtons()
  end

  addonTable.CallbackRegistry:RegisterCallback("BagShow",  function(_, characterName)
    characterName = characterName or Syndicator.API.GetCurrentCharacter()
    backpackView:Show()
    backpackView:UpdateForCharacter(characterName, characterName == backpackView.liveCharacter)
    UpdateButtons()
  end)

  addonTable.CallbackRegistry:RegisterCallback("BagHide",  function(_)
    backpackView:Hide()
    UpdateButtons()
  end)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.VIEW_TYPE then
      local isShown = backpackView:IsShown()
      backpackView:Hide()
      backpackView = allBackpackViews[addonTable.Config.Get(settingName)]
      if isShown then
        addonTable.CallbackRegistry:TriggerEvent("BagShow")
      end
      addonTable.CallbackRegistry:TriggerEvent("BackpackFrameChanged", backpackView)
    elseif settingName == addonTable.Config.Options.MAIN_VIEW_POSITION then
      SetPositions()
    end
  end)

  --Handled by OpenClose.lua
  --[[hooksecurefunc("OpenAllBags", function()
    backpackView:Show()
    backpackView:UpdateForCharacter(Syndicator.API.GetCurrentCharacter(), true)
  end)

  hooksecurefunc("CloseAllBags", function()
    backpackView:Hide()
  end)]]

  -- Backpack button
  table.insert(bagButtons, MainMenuBarBackpackButton)
  -- Bags 1-4, hookscript so that changing bags remains
  for i = 0, 3 do
    table.insert(bagButtons, _G["CharacterBag" .. i .. "Slot"])
  end
  -- Reagent bag
  if CharacterReagentBag0Slot then
    table.insert(bagButtons, CharacterReagentBag0Slot)
  end
  -- Keyring bag
  if KeyRingButton then
    table.insert(bagButtons, KeyRingButton)
  end
  for _, b in ipairs(bagButtons) do
    b:HookScript("OnClick", ToggleBackpackView)
  end

  hooksecurefunc("ToggleBackpack", function()
    local stack = debugstack()
    -- Check to ensure we're not opening when OpenClose.lua will handle the
    -- auto-open and auto-close
    if stack:match("OpenAllBags") or stack:match("CloseAllBags") then
      return
    end
    ToggleBackpackView()
  end)

  ToggleAllBags = ToggleBackpackView
end

local function SetupBankView()
  local bankView
  local allBankViews = {
    single = CreateFrame("Frame", "Baganator_SingleViewBankViewFrame", UIParent, "BaganatorSingleViewBankViewTemplate"),
    category = CreateFrame("Frame", "Baganator_CategoryViewBankViewFrame", UIParent, "BaganatorCategoryViewBankViewTemplate"),
  }

  bankView = allBankViews[addonTable.Config.Get(addonTable.Config.Options.VIEW_TYPE)]

  FrameUtil.RegisterFrameForEvents(bankView, {
    "BANKFRAME_OPENED",
    "BANKFRAME_CLOSED",
  })

  for _, bankView in pairs(allBankViews) do
    table.insert(UISpecialFrames, bankView:GetName())
  end

  local function SetPositions()
    for key, bankView in pairs(allBankViews) do
      bankView:ClearAllPoints()
      bankView:SetPoint(unpack(addonTable.Config.Get(addonTable.Config.Options.BANK_ONLY_VIEW_POSITION)))
    end
  end

  local function ResetPositions()
    addonTable.Config.ResetOne(addonTable.Config.Options.BANK_ONLY_VIEW_POSITION)
    SetPositions()
  end

  local success = pcall(SetPositions) -- work around broken values
  if not success then
    ResetPositions()
  end

  addonTable.CallbackRegistry:RegisterCallback("ResetFramePositions", function()
    ResetPositions()
  end)

  addonTable.CallbackRegistry:RegisterCallback("BankToggle", function(_, characterName)
    characterName = characterName or Syndicator.API.GetCurrentCharacter()
    bankView:SetShown(characterName ~= bankView.Character.lastCharacter or not bankView:IsShown())
    bankView:UpdateViewToCharacter(characterName)
  end)

  addonTable.CallbackRegistry:RegisterCallback("BankShow", function(_, entity, subView)
    if type(entity) == "string" or entity == nil then -- Character bank
      local characterName = entity or Syndicator.API.GetCurrentCharacter()
      bankView:Show()
      bankView:UpdateViewToCharacter(characterName)
    elseif type(entity) == "number" then -- Warband bank
      subView = subView or 1
      bankView:Show()
      bankView:UpdateViewToWarband(entity, subView)
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("BankHide", function(_, characterName)
    bankView:Hide()
  end)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged", function(_, settingName)
    if settingName == addonTable.Config.Options.VIEW_TYPE then
      bankView:Hide()
      FrameUtil.UnregisterFrameForEvents(bankView, {
        "BANKFRAME_OPENED",
        "BANKFRAME_CLOSED",
      })
      bankView = allBankViews[addonTable.Config.Get(settingName)]
      FrameUtil.RegisterFrameForEvents(bankView, {
        "BANKFRAME_OPENED",
        "BANKFRAME_CLOSED",
      })
    elseif settingName == addonTable.Config.Options.BANK_ONLY_VIEW_POSITION then
      SetPositions()
    end
  end)
end

local function SetupGuildView()
  local guildView = CreateFrame("Frame", "Baganator_SingleViewGuildViewFrame", UIParent, "BaganatorSingleViewGuildViewTemplate")
  guildView:SetClampedToScreen(true)
  guildView:SetUserPlaced(false)

  table.insert(UISpecialFrames, guildView:GetName())

  local function SetPositions()
    guildView:HideInfoDialogs()
    guildView:ClearAllPoints()
    guildView:SetPoint(unpack(addonTable.Config.Get(addonTable.Config.Options.GUILD_VIEW_POSITION)))
  end

  local function ResetPositions()
    addonTable.Config.ResetOne(addonTable.Config.Options.GUILD_VIEW_POSITION)
    addonTable.Config.ResetOne(addonTable.Config.Options.GUILD_VIEW_DIALOG_POSITION)
    SetPositions()
  end

  local success = pcall(SetPositions) -- work around broken values
  if not success then
    ResetPositions()
  end

  addonTable.CallbackRegistry:RegisterCallback("ResetFramePositions", function()
    ResetPositions()
  end)

  addonTable.CallbackRegistry:RegisterCallback("GuildToggle", function(_, guildName)
    local guildName = guildName or Syndicator.API.GetCurrentGuild()
    guildView:SetShown(guildName ~= guildView.lastGuild or not guildView:IsShown())
    guildView:UpdateForGuild(guildName, Syndicator.API.GetCurrentGuild() == guildName and C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.GuildBanker))
  end)

  addonTable.CallbackRegistry:RegisterCallback("GuildShow",  function(_, guildName, tabIndex)
    guildName = guildName or Syndicator.API.GetCurrentGuild()
    guildView:Show()
    if tabIndex ~= nil then
      guildView:SetCurrentTab(tabIndex)
    end
    guildView:UpdateForGuild(
      guildName,
      guildName == Syndicator.API.GetCurrentGuild() and C_PlayerInteractionManager.IsInteractingWithNpcOfType(Enum.PlayerInteractionType.GuildBanker)
    )
  end)

  addonTable.CallbackRegistry:RegisterCallback("GuildHide",  function(_, ...)
    guildView:Hide()
  end)
end

local hidden = CreateFrame("Frame")
hidden:Hide()

local function HideDefaultBackpack()
  --Retail: 1-6 are regular bags
  --Wrath: 1-5 are regular bags, 6 is keyring
  --Era: Doing 1-6 gets the right result even if it hides more frames than
  --needed
  for i = 1, 6 do
    _G["ContainerFrame" .. i]:SetParent(hidden)
  end

  if addonTable.Constants.IsRetail then
    ContainerFrameCombinedBags:SetParent(hidden)

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("VARIABLES_LOADED")
    frame:SetScript("OnEvent", function()
      -- Prevent glitchy tutorial popups that cannot be closed from showing
      -- These would ordinarily be attached to the Blizzard bag frames
      SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HUD_REVAMP_BAG_CHANGES, true)
      SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BAG_SLOTS_AUTHENTICATOR, true)
      SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_MOUNT_EQUIPMENT_SLOT_FRAME, true)
      SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_UPGRADEABLE_ITEM_IN_SLOT, true)
    end)
  end
end

local function HideDefaultBank()
  -- 7 to 13 are bank bags
  for i = 7, 13 do
    _G["ContainerFrame" .. i]:SetParent(hidden)
  end

  BankFrame:SetParent(hidden)
  BankFrame:SetScript("OnHide", nil)
  BankFrame:SetScript("OnShow", nil)
  BankFrame:SetScript("OnEvent", nil)
end

local function SetupCharacterSelect()
  local characterSelect = CreateFrame("Frame", "Baganator_CharacterSelectFrame", UIParent, "BaganatorCharacterSelectTemplate")

  table.insert(UISpecialFrames, characterSelect:GetName())

  local function SetPositions()
    characterSelect:ClearAllPoints()
    -- Fix for setting storing frame instead of just the frame name in previous
    -- versions, also makes the frame snap to the backpack when it is
    -- enabled/disabled
    local setting = addonTable.Config.Get(addonTable.Config.Options.CHARACTER_SELECT_POSITION)
    if type(setting[2]) == "table" or type(setting[2]) == "string" then
      setting[2] = nil
    end
    local anchor = CopyTable(setting)
    if setting[2] == nil then -- Accommodate renamed backpack frames
      anchor[2] = addonTable.ViewManagement.GetBackpackFrame() or UIParent
      setting[2] = anchor[2]:GetName()
    end
    characterSelect:SetPoint(unpack(anchor))
  end

  local function ResetPositions()
    addonTable.Config.ResetOne(addonTable.Config.Options.CHARACTER_SELECT_POSITION)
    SetPositions()
  end

  local success = pcall(SetPositions) -- work around broken values
  if not success then
    ResetPositions()
  end

  addonTable.CallbackRegistry:RegisterCallback("ResetFramePositions", function()
    ResetPositions()
  end)

  addonTable.CallbackRegistry:RegisterCallback("BackpackFrameChanged", function()
    SetPositions()
  end)

  addonTable.CallbackRegistry:RegisterCallback("CharacterSelectToggle", function(_, guildName)
    characterSelect:SetShown(not characterSelect:IsShown())
  end)
end

function addonTable.ViewManagement.Initialize()
  -- Use xpcall to so that if Blizzard reworks a component the rest of the
  -- other component initialisations won't fail

  xpcall(function()
    SetupBackpackView()
    HideDefaultBackpack()
  end, CallErrorHandler)

  xpcall(function()
    SetupBankView()
    HideDefaultBank()
  end, CallErrorHandler)

  xpcall(function()
    local info = C_XMLUtil.GetTemplateInfo("BackpackTokenTemplate")
    local tokenWidth = info and info.width or 50
    BackpackTokenFrame:SetWidth(tokenWidth * 3 + 1) -- Support tracking up to 3 currencies
  end, CallErrorHandler)

  xpcall(function()
    SetupGuildView()
  end, CallErrorHandler)

  SetupCharacterSelect()
end
