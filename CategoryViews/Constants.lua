if not Syndicator then
  return
end

Baganator.CategoryViews.Constants = {
  ProtectedCategories = { "default_other", "default_special_empty" },
  EmptySlotsCategory = "default_special_empty",
  DividerName = "----",
  DividerLabel = "——————",
  SectionEnd = "__end",
  MinWidth = 400,

  GroupingState = {
    SplitStack = 1,
    NoGroupForced = 2,
  },

  RedisplaySettings = {
    Baganator.Config.Options.CATEGORY_HORIZONTAL_SPACING,
    Baganator.Config.Options.CATEGORY_DISPLAY_ORDER,
    Baganator.Config.Options.CUSTOM_CATEGORIES,
    Baganator.Config.Options.CATEGORY_HIDDEN,
    Baganator.Config.Options.CATEGORY_ITEM_GROUPING,
    Baganator.Config.Options.CATEGORY_SECTION_TOGGLED,
    Baganator.Config.Options.CATEGORY_MODIFICATIONS,
  },
}

local notJunk = "&~" .. SYNDICATOR_L_KEYWORD_JUNK
--Baganator.Constants.DefaultCategories
if Baganator.Constants.IsEra then
  Baganator.CategoryViews.Constants.DefaultCategories = {
    {
      key = "hearthstone",
      name = BAGANATOR_L_CATEGORY_HEARTHSTONE,
      search = BAGANATOR_L_CATEGORY_HEARTHSTONE:lower(),
      searchPriority = 200,
    },
    {
      key = "consumable",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Consumable),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Consumable):lower(),
    },
    {
      key = "reagent",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Reagent),
      search = "#" .. SYNDICATOR_L_KEYWORD_REAGENT,
      searchPriority = 100,
    },
    {
      key = "auto_equipment_sets",
      name = BAGANATOR_L_CATEGORY_EQUIPMENT_SETS_AUTO,
      auto = "equipment_sets",
      searchPriority = 200,
    },
    {
      key = "weapon",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Weapon),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Weapon):lower(),
    },
    {
      key = "armor",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Armor),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Armor):lower() .. "&#" .. SYNDICATOR_L_KEYWORD_GEAR,
    },
    {
      key = "quiver",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Quiver),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Quiver),
    },
    {
      key = "container",
      name = BAGANATOR_L_CATEGORY_BAG,
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Container):lower(),
    },
    {
      key = "tradegoods",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Tradegoods),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Tradegoods):lower(),
    },
    {
      key = "recipe",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Recipe),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Recipe):lower(),
    },
    {
      key = "questitem",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Questitem),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Questitem):lower(),
    },
    {
      key = "key",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Key),
      -- Only era uses the KEYRING keyword as only era has a keyring bag
      search = "#" .. SYNDICATOR_L_KEYWORD_KEYRING or C_Item.GetItemClassInfo(Enum.ItemClass.Key):lower(),
      searchPriority = 165,
    },
    {
      key = "miscellaneous",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Miscellaneous),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Miscellaneous):lower(),
    },
    {
      key = "other",
      name = BAGANATOR_L_CATEGORY_OTHER,
      search = "",
      searchPriority = 0,
    },
    {
      key = "junk",
      name = BAGANATOR_L_CATEGORY_JUNK,
      search = "#" .. SYNDICATOR_L_KEYWORD_JUNK,
      searchPriority = 180,
    },
  }

elseif Baganator.Constants.IsClassic then -- Cata
  Baganator.CategoryViews.Constants.DefaultCategories = {
    {
      key = "hearthstone",
      name = BAGANATOR_L_CATEGORY_HEARTHSTONE,
      search = BAGANATOR_L_CATEGORY_HEARTHSTONE:lower(),
      searchPriority = 200,
    },
    {
      key = "consumable",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Consumable),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Consumable):lower(),
    },
    {
      key = "reagent",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Reagent),
      search = "#" .. SYNDICATOR_L_KEYWORD_REAGENT,
      searchPriority = 100,
    },
    {
      key = "auto_equipment_sets",
      name = BAGANATOR_L_CATEGORY_EQUIPMENT_SETS_AUTO,
      auto = "equipment_sets",
      searchPriority = 200,
    },
    {
      key = "weapon",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Weapon),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Weapon):lower(),
    },
    {
      key = "armor",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Armor),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Armor):lower() .. "&#" .. SYNDICATOR_L_KEYWORD_GEAR,
    },
    {
      key = "gem",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Gem),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Gem):lower(),
    },
    {
      key = "container",
      name = BAGANATOR_L_CATEGORY_BAG,
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Container):lower(),
    },
    {
      key = "tradegoods",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Tradegoods),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Tradegoods):lower(),
    },
    {
      key = "recipe",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Recipe),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Recipe):lower(),
    },
    {
      key = "questitem",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Questitem),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Questitem):lower(),
    },
    {
      key = "key",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Key),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Key):lower(),
      searchPriority = 165,
    },
    {
      key = "miscellaneous",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Miscellaneous),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Miscellaneous):lower() .. "&~#" .. SYNDICATOR_L_KEYWORD_BATTLE_PET,
    },
    {
      key = "battlepet",
      name = TOOLTIP_BATTLE_PET,
      search = "#" .. SYNDICATOR_L_KEYWORD_BATTLE_PET,
      searchPriority = 140,
    },
    {
      key = "other",
      name = BAGANATOR_L_CATEGORY_OTHER,
      search = "",
      searchPriority = 0,
    },
    {
      key = "junk",
      name = BAGANATOR_L_CATEGORY_JUNK,
      search = "#" .. SYNDICATOR_L_KEYWORD_JUNK,
      searchPriority = 180,
    },
  }
else -- retail
  Baganator.CategoryViews.Constants.DefaultCategories = {
    {
      key = "hearthstone",
      name = BAGANATOR_L_CATEGORY_HEARTHSTONE,
      search = BAGANATOR_L_CATEGORY_HEARTHSTONE:lower(),
      searchPriority = 200,
    },
    {
      key = "potion",
      name = BAGANATOR_L_CATEGORY_POTION,
      search = "#" .. SYNDICATOR_L_KEYWORD_POTION,
      searchPriority = 160,
    },
    {
      key = "food",
      name = BAGANATOR_L_CATEGORY_FOOD,
      search = "#" .. SYNDICATOR_L_KEYWORD_FOOD,
      searchPriority = 160,
    },
    {
      key = "consumable",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Consumable),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Consumable):lower(),
    },
    {
      key = "reagent",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Reagent),
      search = "#" .. SYNDICATOR_L_KEYWORD_REAGENT,
      searchPriority = 100,
    },
    {
      key = "auto_equipment_sets",
      name = BAGANATOR_L_CATEGORY_EQUIPMENT_SETS_AUTO,
      auto = "equipment_sets",
      searchPriority = 200,
    },
    {
      key = "weapon",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Weapon),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Weapon):lower(),
    },
    {
      key = "armor",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Armor),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Armor):lower() .. "&#" .. SYNDICATOR_L_KEYWORD_GEAR,
    },
    {
      key = "gem",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Gem),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Gem):lower(),
    },
    {
      key = "itemenhancement",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.ItemEnhancement),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.ItemEnhancement):lower(),
    },
    {
      key = "container",
      name = BAGANATOR_L_CATEGORY_BAG,
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Container):lower(),
    },
    {
      key = "tradegoods",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Tradegoods),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Tradegoods):lower(),
    },
    {
      key = "profession",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Profession),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Profession):lower(),
    },
    {
      key = "recipe",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Recipe),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Recipe):lower(),
    },
    {
      key = "questitem",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Questitem),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Questitem):lower(),
    },
    {
      key = "key",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Key),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Key):lower(),
      searchPriority = 165,
    },
    {
      key = "miscellaneous",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Miscellaneous),
      search = "#" .. C_Item.GetItemClassInfo(Enum.ItemClass.Miscellaneous):lower(),
    },
    {
      key = "battlepet",
      name = C_Item.GetItemClassInfo(Enum.ItemClass.Battlepet),
      search = "#" .. SYNDICATOR_L_KEYWORD_BATTLE_PET,
      searchPriority = 140,
    },
    {
      key = "toy",
      name = TOY,
      search = "#" .. TOY:lower(),
      searchPriority = 170,
    },
    {
      key = "other",
      name = BAGANATOR_L_CATEGORY_OTHER,
      search = "",
      searchPriority = 0,
    },
    {
      key = "junk",
      name = BAGANATOR_L_CATEGORY_JUNK,
      search = "#" .. SYNDICATOR_L_KEYWORD_JUNK,
      searchPriority = 180,
    },
  }
end

table.insert(Baganator.CategoryViews.Constants.DefaultCategories, {
  key = "auto_inventory_slots",
  name = BAGANATOR_L_CATEGORY_INVENTORY_SLOTS_AUTO,
  auto = "inventory_slots",
  searchPriority = 150,
  doNotAdd = true,
})

table.insert(Baganator.CategoryViews.Constants.DefaultCategories, {
  key = "auto_recents",
  name = BAGANATOR_L_CATEGORY_RECENT_AUTO,
  auto = "recents",
  searchPriority = 600,
  doNotAdd = true,
})

table.insert(Baganator.CategoryViews.Constants.DefaultCategories, {
  key = "special_empty",
  name = BAGANATOR_L_EMPTY,
  emptySlots = true,
  doNotAdd = true,
})

Baganator.CategoryViews.Constants.SourceToCategory = {}
for index, category in ipairs(Baganator.CategoryViews.Constants.DefaultCategories) do
  category.source = "default_" .. category.key
  category.searchPriority = category.searchPriority or 50
  Baganator.CategoryViews.Constants.SourceToCategory[category.source] = category
end
