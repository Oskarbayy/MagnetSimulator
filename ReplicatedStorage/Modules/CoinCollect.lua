local CoinCollect = {}

--
local CollectionService = game:GetService("CollectionService")
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = RStorage:WaitForChild("Modules")

local PlayerData = require(Modules.PlayerData)

--
local plr = game.Players.LocalPlayer

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")

-- Properties
local cooldown = 0.1;


function CoinCollect.Init()
    -- Start periodically checking for coins within range
    local char = plr.Character or plr.CharacterAdded:Wait()

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
            end
        end
    end

end

function createParam()
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Whitelist
    local coins = CollectionService:GetTagged("Coin")
    params.FilterDescendantsInstances = coins
    return params
end

return CoinCollect