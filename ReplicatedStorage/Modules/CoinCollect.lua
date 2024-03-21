local CoinCollect = {}

--
local CollectionService = game:GetService("CollectionService")
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = RStorage:WaitForChild("Modules")

local PlayerData = require(Modules.PlayerData)
local RadiusHandler = require(Modules.RadiusHandler)

--
local plr = game.Players.LocalPlayer

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")


-- Properties
local cooldown = 0.1;
local char = plr.Character or plr.CharacterAdded:Wait()

function CoinCollect.Init()
    -- Start periodically checking for coins within range
    char = plr.Character or plr.CharacterAdded:Wait()

    -- Connect renderstep radius refreshing
    local thread = coroutine.create(RadiusHandler.Init)
    coroutine.resume(thread)

    plr.CharacterAdded:Connect(function(character)
        char = character
    end)

    local params = createParam()

    while task.wait(cooldown) do
        if char and char:FindFirstChild("HumanoidRootPart") and PlayerData.Data.Equipped then
            local radius = PlayerData.Data.Equipped.Range

            local coins = workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position, radius, params)
            
            if #coins > 0 then
                cooldown = RF:FireServer({["ModuleScript"] = "CoinHandler", ["Function"] = "Collect", ["Coins"] = coins})
                if not cooldown then
                    cooldown = 0.1 -- hopefully wont
                end
            else
                cooldown = 0.1
            end
        end
    end
end

function CoinCollect.CollectAnimation(args)
    local player = args["TargetPlayer"]
    local coin = args["Coin"]
    local controlPos = args["ControlPosition"]

    createCollectionBeam(coin, player)

    local char = player.Character or player.CharacterAdded:Wait()

    if not char:FindFirstChild("HumanoidRootPart") then return end

    local startPos = coin.Position

    local t = 0
    local speed = 1 -- Adjust for timing

    local connection; connection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        -- if char dies or somehow isnt loaded then we dont do the animation
        -- and just skip to the collect part.
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            connection:Disconnect()
        end

        
        local targetPos = char.PrimaryPart.Position

        t += speed * deltaTime
        if t > 1 then t = 1 end -- Clamp t to 1 to avoid overshooting

        local newPos = getBezierPoint(t, startPos, controlPos, targetPos)
        coin.Position = newPos

        if t == 1 then
            connection:Disconnect()
        end
    end)
end

function getBezierPoint(t, start, control, target)
    return (1 - t) ^ 2 * start + 2 * (1 - t) * t * control + t ^ 2 * target
end

function createCollectionBeam(coin, player)
    -- Assuming 'coin' is the part you're collecting and 'player' is the player's character model
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoidRootPart then return end -- Safety check

    -- Create Beam
    local beam = Instance.new("Beam")
    beam.Parent = coin -- Parent the beam to the coin for demonstration; adjust as needed
    
    -- Beam appearance customization
    beam.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
    beam.FaceCamera = true
    beam.LightEmission = 0.7
    beam.LightInfluence = 0.2
    beam.Width0 = 0.1
    beam.Width1 = 0.1
    beam.Attachment0 = Instance.new("Attachment", coin)
    beam.Attachment1 = Instance.new("Attachment", humanoidRootPart)

    -- Optionally, add logic to remove the beam after a certain duration
    delay(1, function() -- Example: Remove after 2 seconds
        beam:Destroy()
    end)
end

function createParam()
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    local coins = CollectionService:GetTagged("Coin")
    params.FilterDescendantsInstances = coins
    return params
end

return CoinCollect