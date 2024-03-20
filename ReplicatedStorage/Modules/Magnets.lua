local Magnets = {
    ["Rusted Magnet"] = {
        Range = 10, 
        Price = 0, -- free
        Effectiveness = 1, 
        -- affects how quickly a magnet can collect coins or the quantity it can collect at once
        Durability = 100,
        SpecialAbility = nil,
        -- temporary boost in range, the ability to attract rare coins, or a magnetic pulse 
        --that collects all coins within range instantly but has a cooldown
        UpgradeCost = 50,
        UpgradeLevel = 1,
        Rarity = "Common",
        LevelRequirement = 1,
        AssetName = "RustedMagnetModel"
    },

    ["Average Magnet"] = {
        Range = 15, 
        Price = 100,
        Effectiveness = 1.5,
        Durability = 100,
        SpecialAbility = nil,
        UpgradeCost = 50,
        UpgradeLevel = 1,
        Rarity = "Common",
        LevelRequirement = 1,
        AssetName = "AverageMagnetModel"
    },

    ["Skibidi Magnet"] = {
        Range = 20, 
        Price = 300,
        Effectiveness = 2,
        Durability = 100,
        SpecialAbility = nil,
        UpgradeCost = 50,
        UpgradeLevel = 1,
        Rarity = "Uncommon",
        LevelRequirement = 5,
        AssetName = "SkibidiMagnetModel"
    },
}

return Magnets