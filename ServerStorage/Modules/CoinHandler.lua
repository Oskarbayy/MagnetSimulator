-- Settings --
local SpawnArea = workspace.SpawnArea
local Density = 10 -- studs^2 per coin

local hotspots = {
    {
    position = SpawnArea.Position,
    radius = 50
    }

}

--
local CoinHandler = {}

-- Services
local SStorage = game:GetService("ServerStorage")

-- Modules
local sModules = SStorage:WaitForChild("Modules")
local Coin =  require(sModules.Coin)
local DH = require(sModules.DataHandler)

-- Properties
local Coins = {}

-- Public Functions --
function CoinHandler.Init()
    local thread = coroutine.create(SpawnLoop)
    coroutine.resume(thread)

end

-- maybe use a remotefunction and return true / false to make client animations based on return
function CoinHandler.Collect(plr, args)
    local coinsToCollect = args["Coins"]

    local range = DH.GetData(plr, "Range")

    -- Server Check
    for _, coin in pairs(coinsToCollect) do
        local distance = calcDistance(plr, coin)
        
        if range >= distance then
            coin:Destroy()

            -- Give coins via DataHandler
            DH.AddData(plr, "Coins", 1)
        end
    end
end

-- Private Functions --
function SpawnLoop()
    -- First spawn all the coins
    local AmountOfCoins = CalcCoinAmount()

    for i = 1, AmountOfCoins do
        local coinObj = Coin.Create()
        coinObj.PrimaryPart.Position = GetSpawnPosition()
        
        table.insert(Coins, coinObj)
    end

    -- Start the continuous spawning of coins

end

function CalcCoinAmount()
    local area = SpawnArea.Size.X * SpawnArea.Size.Z
    local coinAmount = area / Density  -- Density Formula: Mass = Volume / Density

    return coinAmount
end

function GetSpawnPosition()
    -- Generate random pos
    local x = SpawnArea.Position.X + math.random(-SpawnArea.Size.X/2, SpawnArea.Size.X/2)
    local z = SpawnArea.Position.Z + math.random(-SpawnArea.Size.Z/2, SpawnArea.Size.Z/2)

    local posCheck = Vector3.new(x, 0, z)

    for _, hotspot in pairs(hotspots) do
        if shouldSpawnCoinAtPosition(posCheck, hotspot) then
            return posCheck
        end
    end
    return GetSpawnPosition() -- Try another pos if none was suitable
end

function shouldSpawnCoinAtPosition(position, hotspot)
    local distanceFromCenter = (position - hotspot.position).magnitude
    local spawnProbability = calcSpawnProb(distanceFromCenter, hotspot.radius)

    -- Randomly decide to spawn based on calculated probability
    return math.random() < spawnProbability
end

function calcSpawnProb(distanceFromCenter, radius)
    local maxProbability = 1  -- 100% probability at the center
    local minProbability = 0.05  -- 5% probability at the edge

    if distanceFromCenter >= radius then
        return 0.03  -- Outside the hotspot
    else
        -- Linearly interpolate probability based on distance
        local probability = maxProbability - ((distanceFromCenter / radius) * (maxProbability - minProbability))
        return probability
    end
end
--

function calcDistance(plr, coin)
    local char = plr.Character

    if char and char.PrimaryPart then
        return (char.PrimaryPart.Position-coin.PrimaryPart.Position).Magnitude
    end

    return math.huge
end

return CoinHandler