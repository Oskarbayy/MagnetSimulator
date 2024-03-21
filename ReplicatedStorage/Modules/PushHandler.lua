local PushHandler = {}

-- 
local RStorage = game:GetService("ReplicatedStorage")

-- 
local Modules = RStorage:WaitForChild("Modules")

local PlayerData = require(Modules.PlayerData)

-- 
local RE = RStorage:WaitForChild("RemoteEvent")
--
local plr = game.Players.LocalPlayer

function PushHandler.Init()

    while task.wait(.25) do
        local char = plr.Character

        if char and char:FindFirstChild("HumanoidRootPart") and PlayerData.PVP and PlayerData.Equipped then

            local players = getPlayersInRadius(char.HumanoidRootPart.Position, PlayerData.Equipped.Range)

            if #players > 0 then
                RE:FireServer({
                    ["ModuleScript"] = "PushHandlerS",
                    ["Function"] = "Push",
                    ["Players"] = players,
                })
            end
        end
    end

end

function getPlayersInRadius(centerPoint, radius)
    local partsInRadius = workspace:GetPartBoundsInRadius(centerPoint, radius)
    local playersFound = {}
    local uniquePlayers = {}

    -- Filter parts to find those that are part of a player's character
    for _, part in ipairs(partsInRadius) do
        local player = game.Players:GetPlayerFromCharacter(part.Parent)
        if player and not playersFound[player.UserId] then
            playersFound[player.UserId] = true
            table.insert(uniquePlayers, player)
        end
    end

    return uniquePlayers
end

return PushHandler