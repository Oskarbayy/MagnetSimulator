local Magnets = {
    ["Rusted Magnet"] = {
        Range = 10, 
        Price = 0,
        Effectiveness = 1, 
        Durability = 100,
        SpecialAbility = nil,
        UsingAbility = false,
        UsedAbilityTick = tick(),
        UpgradeCost = 50,
        UpgradeLevel = 1,
        Rarity = "Common",
        RankRequirement = 1,
        Image = "",
        AssetName = "RustedMagnetModel"
    },

    ["Average Magnet"] = {
        Range = 15, 
        Price = 100,
        Effectiveness = 1, 
        Durability = 100,
        SpecialAbility = nil,
        UsingAbility = false,
        UsedAbilityTick = tick(),
        UpgradeCost = 50,
        UpgradeLevel = 1,
        Rarity = "Common",
        RankRequirement = 1,
        Image = "",
        AssetName = "AverageMagnetModel"
    },

    ["Skibidi Magnet"] = {
        Range = 20, 
        Price = 1000,
        Effectiveness = 10, 
        Durability = 100,
        SpecialAbility = "Black Hole",
        UsingAbility = false,
        UsedAbilityTick = tick(),
        UpgradeCost = 50,
        UpgradeLevel = 1,
        Rarity = "Uncommon",
        RankRequirement = 1,
        Image = "",
        AssetName = "SkibidiMagnetModel"
    },
}

return Magnets