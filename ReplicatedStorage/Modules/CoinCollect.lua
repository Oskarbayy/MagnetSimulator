local CoinCollect = {}

--
local CollectionService = game:GetService("CollectionService")
local RStorage = game:GetService("ReplicatedStorage")

local plr = game.Players.LocalPlayer

--
local RE = RStorage:WaitForChild("RemoteEvent")

function CoinCollect.Init()
    -- Start periodically checking for coins within range
    local char = plr.Character or plr.CharacterAdded:Wait()

    plr.CharacterAdded:Connect(function(character)
        char = character
    end)

    local params = createParam()
    local radius = 10

    while task.wait(.1) do
        if char and char:FindFirstChild("HumanoidRootPart") then
            local coins = workspace:GetPartBoundsInRadius(char.HumanoidRootPart.Position, radius, params)
            
            if #coins > 0 then
                RE:FireServer({["ModuleScript"] = "CoinHandler", ["Function"] = "Collect", ["Coins"] = coins})
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