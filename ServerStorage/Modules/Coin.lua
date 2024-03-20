local ServerStorage = game:GetService("ServerStorage")
local CollectionService = game:GetService("CollectionService")
local Coin = {}

-- Constructor
function Coin.Create()
    local coinModel = ServerStorage.Models.Coin

    local coinObj = coinModel:Clone()
    coinObj.Parent = workspace.Coins

    CollectionService:AddTag(coinObj, "Coin")

    return coinObj
end

return Coin