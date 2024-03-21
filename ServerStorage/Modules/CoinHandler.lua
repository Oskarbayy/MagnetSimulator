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
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local sModules = SStorage:WaitForChild("Modules")
local cModules = RStorage:WaitForChild("Modules")
local Coin =  require(sModules.Coin)
local DH = require(sModules.DataHandler)
local Abilities = require(cModules.Abilities)
local CollectionService = game:GetService("CollectionService")

-- 
local RE = RStorage:WaitForChild("RemoteEvent")

-- Properties
local Coins = {}
local cooldown = 0
local lastTick = tick()

-- Define start and end points for effectiveness and their corresponding cooldowns
local start_effectiveness = 1
local end_effectiveness = 10
local start_cooldown = 1
local end_cooldown = 0.05

-- Calculate the slope of the line for linear interpolation
local slope = (end_cooldown - start_cooldown) / (end_effectiveness - start_effectiveness)

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
    local count = 0
    for _, coin in pairs(coinsToCollect) do
        if count >= equipped.Effectiveness then
            -- if you have collected 'effectiveness' coins then its the limit
            break
        end

        local distance = calcDistance(plr, coin)
        
        if range >= distance then
            local thread = coroutine.create(CollectCoin)
            coroutine.resume(thread, plr, coin)

            status = true
        end

        count = count + 1
    end

    if status then
        local effectiveness = equipped.Effectiveness
        local cooldown = start_cooldown + slope * (effectiveness - start_effectiveness)
        
        cooldown = math.max(math.min(cooldown, start_cooldown), end_cooldown)
        
        lastTick = tick()
        return cooldown
    end

    return nil
end

function CoinHandler.UseAbility(plr)
    local data = DH.GetData(plr)
    local ability = data.Equipped.SpecialAbility

    if ability and tick() - data.Equipped.UsedAbilityTick >= Abilities[ability].Cooldown then
        -- ready to collect ability 
        local char = plr.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        data.Equipped.UsingAbility = true
        data.Equipped.UsedAbilityTick = tick()

        if ability == "Black Hole" then
            local params = createParam()

            local coins = workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position, Abilities[ability].RangeMultiplier, params)

            for _, coin in pairs(coins) do
                local thread = coroutine.create(CollectCoin)
                coroutine.resume(thread, plr, coin)
            end
        end
    end
end

-- Private Functions --
function CollectCoin(plr, coin)
    local char = plr.Character or plr.CharacterAdded:Wait()

    if not char:FindFirstChild("HumanoidRootPart") then; return; end

    local startPos = coin.Position
    local targetPos = char.PrimaryPart.Position
    -- Generate a random control position for each movement
    local controlPos = getRandomControlPos(startPos, targetPos)

    RE:FireAllClients({
        ["ModuleScript"] = "CoinCollect", 
        ["Function"] = "CollectAnimation", 
        ["TargetPlayer"] = plr, 
        ["Coin"] = coin, 
        ["ControlPosition"] = controlPos
    })

    task.wait(1)
    DH.AddData(plr, "Coins", 1)
    coin:Destroy()
end

function createParam()
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    local coins = CollectionService:GetTagged("Coin")
    params.FilterDescendantsInstances = coins
    return params
end


function getRandomControlPos(startPos, targetPos)
    local direction = (targetPos - startPos).Unit  -- Direction from start to target
    local distance = (targetPos - startPos).Magnitude  -- Distance from start to target
    
    -- Base the deviation on the distance, adjusting these factors as needed
    local lateralDeviationFactor = 0.3  -- Controls lateral deviation
    local verticalDeviationFactor = 0.5  -- Controls vertical deviation
    local forwardDeviationFactor = 0.5  -- Controls forward/backward deviation
    
    -- Calculate maximum lateral, vertical, and forward deviations based on distance
    local maxLateralDeviation = distance * lateralDeviationFactor
    local maxVerticalDeviation = distance * verticalDeviationFactor
    local maxForwardDeviation = distance * forwardDeviationFactor  -- New
    
    -- Randomize deviations within the calculated ranges
    local lateralDeviation = math.random(-maxLateralDeviation, maxLateralDeviation)
    local verticalDeviation = math.random(0, maxVerticalDeviation)  -- Keeping it positive to avoid going downwards
    local forwardDeviation = math.random(-maxForwardDeviation, maxForwardDeviation)  -- New: Allows deviation forward and backward
    
    -- Calculate the control point's position
    -- For lateral deviation, we need to find a vector perpendicular to the direction of movement
    local right = Vector3.new(-direction.Z, 0, direction.X)  -- Assuming Y is up, this gives a perpendicular vector in the XZ plane
    local controlPos = (startPos + targetPos) / 2  -- Start with the midpoint
    controlPos = controlPos + right * lateralDeviation  -- Apply lateral deviation
    controlPos = controlPos + Vector3.new(0, verticalDeviation, 0)  -- Apply vertical deviation
    controlPos = controlPos + direction * forwardDeviation  -- Apply forward/backward deviation

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