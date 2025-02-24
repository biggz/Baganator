local _, addonTable = ...
local function MigrateFormat()
  if addonTable.Config.Get(addonTable.Config.Options.CATEGORY_MIGRATION) == 0 then
    local customCategories = addonTable.Config.Get(addonTable.Config.Options.CUSTOM_CATEGORIES)
    local categoryMods = addonTable.Config.Get(addonTable.Config.Options.CATEGORY_MODIFICATIONS)
    for key, categoryDetails in pairs(customCategories) do
      categoryMods[key] = { addedItems = categoryDetails.addedItems }
      categoryDetails.addedItems = nil
    end
    addonTable.Config.Set(addonTable.Config.Options.CATEGORY_MIGRATION, 1)
  end
end

local function SetupCategories()
  local alreadyAdded = addonTable.Config.Get(addonTable.Config.Options.AUTOMATIC_CATEGORIES_ADDED)
  local displayOrder = addonTable.Config.Get(addonTable.Config.Options.CATEGORY_DISPLAY_ORDER)
  for index, category in ipairs(addonTable.CategoryViews.Constants.DefaultCategories) do
    if not alreadyAdded[category.source] and not category.doNotAdd then
      if index > #displayOrder then
        table.insert(displayOrder, category.source)
      else
        table.insert(displayOrder, index, category.source)
      end
      alreadyAdded[category.source] = true
    end
  end

  local customCategories = addonTable.Config.Get(addonTable.Config.Options.CUSTOM_CATEGORIES)
  if #displayOrder > 0 then
    for i = #displayOrder, 1, -1 do
      local source = displayOrder[i]
      local category = addonTable.CategoryViews.Constants.SourceToCategory[source] or customCategories[source]
      if not category and source ~= addonTable.CategoryViews.Constants.DividerName and not source:match("^_") then
        table.remove(displayOrder, i)
      end
    end
  end
  for _, source in ipairs(addonTable.CategoryViews.Constants.ProtectedCategories) do
    if tIndexOf(displayOrder, source) == nil then
      table.insert(displayOrder, source)
    end
  end

  -- Trigger settings changed event
  addonTable.Config.Set(addonTable.Config.Options.AUTOMATIC_CATEGORIES_ADDED, CopyTable(alreadyAdded))
  addonTable.Config.Set(addonTable.Config.Options.CATEGORY_DISPLAY_ORDER, CopyTable(displayOrder))
end

local function SetupAddRemoveItems()
  local activeItemID, activeItemLink

  local previousCategory

  addonTable.CallbackRegistry:RegisterCallback("CategoryAddItemStart", function(_, fromCategory, itemID, itemLink)
    activeItemID, activeItemLink = itemID, itemLink
    previousCategory = fromCategory
  end)

  -- Remove the item from its current category and add it to the new one
  addonTable.CallbackRegistry:RegisterCallback("CategoryAddItemEnd", function(_, toCategory)
    local categoryMods = addonTable.Config.Get(addonTable.Config.Options.CATEGORY_MODIFICATIONS)
    local details = addonTable.CategoryViews.Utilities.GetAddedItemData(activeItemID, activeItemLink)
    if categoryMods[previousCategory] and categoryMods[previousCategory].addedItems then
      local oldIndex = FindInTableIf(categoryMods[previousCategory].addedItems, function(alt)
        return alt.itemID == details.itemID and alt.petID == details.petID
      end)
      if oldIndex then
        table.remove(categoryMods[previousCategory].addedItems, oldIndex)
        if #categoryMods[previousCategory].addedItems == 0 then
          categoryMods[previousCategory].addedItems = nil
        end
      end
    end

    -- Either the target doesn't exist or this is a remove from category request
    if not toCategory then
      return
    end

    if not categoryMods[toCategory] then
      categoryMods[toCategory] = {}
    end

    categoryMods[toCategory].addedItems = categoryMods[toCategory].addedItems or {}

    local existingIndex = FindInTableIf(categoryMods[toCategory].addedItems, function(alt)
      return alt.itemID == details.itemID and alt.petID == details.petID
    end)
    if existingIndex then
      return
    end
    table.insert(categoryMods[toCategory].addedItems, details)
  end)
end

function addonTable.CategoryViews.Initialize()
  MigrateFormat()

  SetupCategories()

  addonTable.CallbackRegistry:RegisterCallback("ResetCategoryOrder", function()
    -- Avoid the settings changed event firing
    table.wipe(addonTable.Config.Get(addonTable.Config.Options.AUTOMATIC_CATEGORIES_ADDED))
    table.wipe(addonTable.Config.Get(addonTable.Config.Options.CATEGORY_DISPLAY_ORDER))

    SetupCategories()
  end)

  SetupAddRemoveItems()
end
