--[[ notes
    also when players leave then remove them from this data
]]

-- Settings
local petJumpSpeed = 5
local followDistance = 5

local PetSystem = {
    ["PetsEquipped"] = {}
}

-- Services
local RStorage = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables
local RE = RStorage:WaitForChild("RemoteEvent")

-- Main Function that handles all the pets animations
function PetSystem.Init()
    -- Considering using Heartbeat method instead of renderstepped gotta run a test later
    RS.RenderStepped:Connect(function(deltaTime)
        -- update all players pets
        
        for _,player in pairs(PetSystem["PetsEquipped"]) do
            -- make sure player is still in game
            if Players:FindFirstChild(player.Name) then
                AnimatePets(player)

            end
        end

    end)
end

-- function connected from button
function PetSystem.EquipPet(pet)
    RE:FireServer({
        ["ModuleScript"] = "PetSystemS", 
        ["Function"] = "EquipPet", 
        ["Pet"] = pet
    })

end

function PetSystem.UpdatePlayerPets(args)
    local player = args["Player"]
    local petsEquipped = args["PetsEquipped"]

    PetSystem["PetsEquipped"][player] = petsEquipped
end

-- Helper Functions
function AnimatePets(player)
    for _, pet in pairs(PetSystem["PetsEquipped"][player]) do
        local followPosition = getFollowPosition(player, pet)
        local jumpHeight = updateJump()

        pet.PrimaryPart.Position = followPosition + Vector3.new(0, jumpHeight, 0)
    end
end

function getFollowPosition(player, pet)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPosition = player.Character.HumanoidRootPart.Position
        local followPosition = playerPosition - player.Character.HumanoidRootPart.CFrame.LookVector * followDistance
        return followPosition
    end
    return pet.PrimaryPart.Position  -- Fallback to current position if no player character
end

function updateJump()
    -- Using a sine wave to create a jumping effect
    local jumpHeight = math.abs(math.sin(tick() * petJumpSpeed)) * 2  -- Dynamic height calculation

    return jumpHeight
end


return PetSystem

