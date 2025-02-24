local _, addonTable = ...
local addonName, addonTable = ...

BaganatorCategoryViewBackpackViewMixin = CreateFromMixins(BaganatorItemViewCommonBackpackViewMixin)

function BaganatorCategoryViewBackpackViewMixin:OnLoad()
  BaganatorItemViewCommonBackpackViewMixin.OnLoad(self)

  self.Layouts = {}
  self.LiveLayouts = {}
  self.CachedLayouts = {}

  self.liveEmptySlotsPool = addonTable.ItemViewCommon.GetLiveItemButtonPool(self)
  for i = 1, #Syndicator.Constants.AllBagIndexes do
    self.liveEmptySlotsPool:Acquire()
  end
  self.liveEmptySlotsPool:ReleaseAll()

  self:RegisterEvent("CURSOR_CHANGED")

  self.labelsPool = CreateFramePool("Button", self, "BaganatorCategoryViewsCategoryButtonTemplate")
  self.sectionButtonPool = addonTable.CategoryViews.GetSectionButtonPool(self)
  self.dividerPool = CreateFramePool("Button", self, "BaganatorBagDividerTemplate")

  self.recentItems = {}

  addonTable.CallbackRegistry:RegisterCallback("ContentRefreshRequired",  function()
    self.MultiSearch:ResetCaches()
    for _, layout in ipairs(self.Layouts) do
      layout:RequestContentRefresh()
    end
    if self:IsVisible() and self.lastCharacter ~= nil then
      self:UpdateForCharacter(self.lastCharacter, self.isLive)
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("SettingChanged",  function(_, settingName)
    if not self.lastCharacter then
      return
    end
    if tIndexOf(addonTable.CategoryViews.Constants.RedisplaySettings, settingName) ~= nil then
      self.searchToApply = true
      if self:IsVisible() then
        self:UpdateForCharacter(self.lastCharacter, self.isLive)
      end
    elseif settingName == addonTable.Config.Options.SORT_METHOD then
      for _, layout in ipairs(self.Layouts) do
        layout:InformSettingChanged(settingName)
      end
      if self:IsVisible() then
        self:UpdateForCharacter(self.lastCharacter, self.isLive)
      end
    elseif settingName == addonTable.Config.Options.JUNK_PLUGIN then
      self.MultiSearch:ResetCaches()
      if self:IsVisible() then
        self:UpdateForCharacter(self.lastCharacter, self.isLive)
      end
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("CategoryAddItemStart", function(_, fromCategory, itemID, itemLink, addedDirectly)
    self.addToCategoryMode = fromCategory
    self.addedToFromCategory = addedDirectly == true
    if self:IsVisible() then
      self:UpdateForCharacter(self.lastCharacter, self.isLive)
    end
  end)

  self.AllButtons = {}
  tAppendAll(self.AllButtons, self.TopButtons)
  tAppendAll(self.AllButtons, self.AllFixedButtons)

  addonTable.AddBagTransferActivationCallback(function()
    self:UpdateTransferButton()
    local oldState = self.splitStacksDueToTransfer
    self.splitStacksDueToTransfer = false
    for _, info in ipairs(addonTable.BagTransfers) do
      if info.condition() then
        self.splitStacksDueToTransfer = true
      end
    end
    if oldState ~= self.splitStacksDueToTransfer and self:IsVisible() then
      self:UpdateForCharacter(self.lastCharacter, self.isLive)
    end
  end)

  self.notShown = {}
end

function BaganatorCategoryViewBackpackViewMixin:NotifyBagUpdate(updatedBags)
end

function BaganatorCategoryViewBackpackViewMixin:OnEvent(eventName)
  if eventName == "CURSOR_CHANGED" and self.addToCategoryMode and not C_Cursor.GetCursorItem() then
    self.addToCategoryMode = nil
    if self:IsVisible() then
      self:UpdateForCharacter(self.lastCharacter, self.isLive)
    end
  end
end

function BaganatorCategoryViewBackpackViewMixin:OnShow()
  BaganatorItemViewCommonBackpackViewMixin.OnShow(self)
  addonTable.NewItems:ClearNewItemsForTimeout()
end

-- Clear new item status on items that are hidden as part of a stack
function BaganatorCategoryViewBackpackViewMixin:OnHide()
  BaganatorItemViewCommonBackpackViewMixin.OnHide(self)
  for _, item in ipairs(self.notShown) do
    addonTable.NewItems:ClearNewItem(item.bagID, item.slotID)
  end
end

function BaganatorCategoryViewBackpackViewMixin:ApplySearch(text)
  if not self:IsVisible() then
    return
  end
  self.searchToApply = false

  for _, layout in ipairs(self.Layouts) do
    if layout:IsVisible() then
      layout:ApplySearch(text)
    end
  end
end

function BaganatorCategoryViewBackpackViewMixin:GetSearchMatches()
  local matches = {}
  for _, layouts in ipairs(self.LiveLayouts) do
    tAppendAll(matches, layouts.SearchMonitor:GetMatches())
  end
  return matches
end

function BaganatorCategoryViewBackpackViewMixin:TransferCategory(associatedSearch)
  if not self.isLive or not associatedSearch then
    return
  end

  self:Transfer(true, function() return self.results[associatedSearch].all end)
end

function BaganatorCategoryViewBackpackViewMixin:UpdateForCharacter(character, isLive)
  local start = debugprofilestop()
  BaganatorItemViewCommonBackpackViewMixin.UpdateForCharacter(self, character, isLive)

  if self.isLive then
    addonTable.NewItems:ImportNewItems(true)
  end

  local sideSpacing, topSpacing = 13, 14
  if addonTable.Config.Get(addonTable.Config.Options.REDUCE_SPACING) then
    sideSpacing = 8
    topSpacing = 7
  end

  self.isGrouping = addonTable.Config.Get(addonTable.Config.Options.CATEGORY_ITEM_GROUPING) and not self.splitStacksDueToTransfer

  if self.addToCategoryMode and C_Cursor.GetCursorItem() == nil then
    self.addToCategoryMode = false
  end

  local characterData = Syndicator.API.GetCharacter(character)
  local bagTypes = addonTable.CategoryViews.Utilities.GetBagTypes(characterData, "bags", Syndicator.Constants.AllBagIndexes)
  addonTable.CategoryViews.LayoutContainers(self, characterData.bags, "bags", bagTypes, Syndicator.Constants.AllBagIndexes, sideSpacing, topSpacing, function(maxWidth, maxHeight)
    self:SetSize(
      math.max(addonTable.CategoryViews.Constants.MinWidth, maxWidth + sideSpacing * 2 + addonTable.Constants.ButtonFrameOffset - 2),
      maxHeight + 75 + topSpacing / 2
    )

    local searchText = self.SearchWidget.SearchBox:GetText()
    if self.searchToApply then
      self:ApplySearch(searchText)
    end

    self:HideExtraTabs()

    if addonTable.Config.Get(addonTable.Config.Options.DEBUG_TIMERS) then
      print("-- updateforcharacter backpack", debugprofilestop() - start)
    end

    self:UpdateAllButtons()

    addonTable.CallbackRegistry:TriggerEvent("ViewComplete")
  end)
end
