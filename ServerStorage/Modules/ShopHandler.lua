local ShopHandler = {}

--
local RStorage = game:GetService("ReplicatedStorage")
local SStorage = game:GetService("ServerStorage")
local HttpService = game:GetService("HttpService")

-- Modules
local sModules = SStorage:WaitForChild("Modules")
local cModules = RStorage:WaitForChild("Modules")


local DH = require(sModules.DataHandler)
local MagnetsInfo = require(cModules.Magnets)

-- Use remotefunction for this
function ShopHandler.BuyItem(plr, args)
    local coins = DH.GetData(plr, "Coins")
    local item = args["Item"] -- is just string example: "Rusted Magnet"

    if not MagnetsInfo[item] then
        return {["Status"] = false, ["Message"] = "Magnet doesn't exist!"}
    end
    
    local itemInfo = MagnetsInfo[item]
    local price = itemInfo.price

    if coins >= price then
        -- can afford the item

        -- deduct coins
        DH.AddData(plr, "Coins", -price)

        -- add item to inventory
        local inventory = DH.GetData(plr, "Inventory")
        inventory[item] = itemInfo -- this way i can actually change upgrade level and durability values in realtime
        inventory[item].ID = HttpService:GenerateGUID(false)
        DH.SetData(plr, "Inventory", inventory)

        return {["Status"] = true, ["Message"] = "Successfully bought item!"}
    end

    return {["Status"] = false, ["Message"] = "You do not have enough coins!"}
end


return ShopHandler