local GPH = {
    Players = {}
} -- GamepassHandler

-- Services
local Marketplace = game:GetService("MarketplaceService")
local SStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

-- Modules
local sModules = SStorage:WaitForChild("Modules")

local Gamepasses = require(sModules.Gamepasses)

--
function GPH.Init()
    -- some players might have joined before initialization
    for _, player in pairs (Players:GetPlayers()) do
        GPH.CheckGamepasses(player)
    end

    Players.PlayerAdded:Connect(function(player)
        GPH.CheckGamepasses(player)
    end)

    -- remove the player from Gamepass cache
    Players.PlayerRemoving:Connect(function(player)
        GPH.Players[player] = nil
    end)
end

--
function GPH.CheckGamepasses(player)
    GPH.Player = {}

    for gamepass, passID in pairs(Gamepasses) do
        local hasPass = false

        local success, message = pcall(function()
            hasPass = Marketplace:UserOwnsGamePassAsync(player.UserId, passID)
        end)

        if not success then
            warn("Error while checking if player has pass: ".. tostring(message))
            hasPass = false
        end

        GPH.Player[gamepass] = hasPass
    end
end

return GPH