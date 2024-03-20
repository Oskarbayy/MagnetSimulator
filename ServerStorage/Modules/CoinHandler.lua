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
local cooldown = 0
local lastTick = tick()

-- Public Functions --
function CoinHandler.Init()
    local thread = coroutine.create(SpawnLoop)
    coroutine.resume(thread)

end

-- maybe use a remotefunction and return true / false to make client animations based on return
function CoinHandler.Collect(plr, args)
    -- Check cooldown
    if not (tick() - lastTick >= cooldown) then; return nil; end

    local equipped = DH.GetData(plr, "Equipped")
    if not equipped then; return nil; end

    local coinsToCollect = args["Coins"]

    local range = DH.GetData(plr, "Range")
    local status = false

    -- Server Check
    for _, coin in pairs(coinsToCollect) do
        local distance = calcDistance(plr, coin)
        
        if range >= distance then
            local thread = coroutine.create(CollectCoin)
            coroutine.resume(thread, plr, coin)

            status = true
        end
    end

    if status then
        cooldown = 1/(math.random(equipped.Effectiveness*100-25, equipped.Effectiveness*100+25)/100)
        lastTick = tick()
        return cooldown
    end

    return nil
end

-- Private Functions --
function CollectCoin(plr, coin)
    local char = plr.Character or plr.CharacterAdded:Wait()

    if not char:FindFirstChild("HumanoidRootPart") then; return; end

    local startPos = coin.Position
    local targetPos = char.PrimaryPart.Position
    -- Generate a random control position for each movement
    local controlPos = getRandomControlPos(startPos, targetPos)

    local t = 0
    local speed = 0.01 -- Adjust for timing

    local connection; connection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        -- if char dies or somehow isnt loaded then we dont do the animation
        -- and just skip to the collect part.
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            DH.AddData(plr, "Coins", 1)
            coin:Destroy()
            connection:Disconnect()
        end

        
        local targetPos = char.PrimaryPart.Position

        t += speed * deltaTime
        if t > 1 then t = 1 end -- Clamp t to 1 to avoid overshooting

        local newPos = getBezierPoint(t, startPos, controlPos, targetPos)
        coin.Position = newPos

        if t == 1 then
            -- reached targetPos
            -- Give coins via DataHandler
            DH.AddData(plr, "Coins", 1)
            coin:Destroy()
            connection:Disconnect()
        end
    end)
end

function getBezierPoint(t, start, control, target)
    return (1 - t) ^ 2 * start + 2 * (1 - t) * t * control + t ^ 2 * target
end


function getRandomControlPos(startPos, targetPos)
    local direction = (targetPos - startPos).Unit  -- Direction from start to target
    local distance = (targetPos - startPos).Magnitude  -- Distance from start to target
    
    -- Base the deviation on the distance, adjusting these factors as needed
    local lateralDeviationFactor = 0.3  -- Controls lateral deviation
    local verticalDeviationFactor = 0.5  -- Controls vertical deviation
    
    -- Calculate maximum lateral and vertical deviations based on distance
    local maxLateralDeviation = distance * lateralDeviationFactor
    local maxVerticalDeviation = distance * verticalDeviationFactor

    -- Randomize deviations within the calculated ranges
    local lateralDeviation = math.random(-maxLateralDeviation, maxLateralDeviation)
    local verticalDeviation = math.random(0, maxVerticalDeviation)  -- Keeping it positive to avoid going downwards
    
    -- Calculate the control point's position
    -- For lateral deviation, we need to find a vector perpendicular to the direction of movement
    local right = Vector3.new(-direction.Z, 0, direction.X)  -- Assuming Y is up, this gives a perpendicular vector in the XZ plane
    local controlPos = (startPos + targetPos) / 2  -- Start with the midpoint
    controlPos = controlPos + right * lateralDeviation  -- Apply lateral deviation
    controlPos = controlPos + Vector3.new(0, verticalDeviation, 0)  -- Apply vertical deviation

    return controlPos
end

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