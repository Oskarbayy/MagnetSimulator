local RadiusHandler = {
    UsingAbility = false,
    UsedAbilityTick = 0
}

--
local RStorage = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

--
local plr = game.Players.LocalPlayer

--
local Modules = RStorage:WaitForChild("Modules")

local Abilities = require(Modules.Abilities)
local PlayerData = require(Modules.PlayerData)

-- Radius Part
local radiusPart = Instance.new("Part")
radiusPart.Shape = Enum.PartType.Cylinder
radiusPart.Transparency = 1

-- Properties
local radiusColor = Color3.fromRGB(178, 178, 178)

function RadiusHandler.Init()
    local char = plr.Character or plr.CharacterAdded:Wait()

    plr.CharacterAdded:Connect(function(character)
        char = character
    end)

    RS.RenderStepped:Connect(function(deltaTime)
        -- dont do this every iteration only update
        if char and char:FindFirstChild("HumanoidRootPart") and PlayerData.Data.Equipped then

            -- now check if using abilities
            if RadiusHandler.UsingAbility then
                local ability = PlayerData.Data.Equipped.SpecialAbility

                if ability == "Black Hole" then
                    -- do ability animation here, and on the server actual do something
                    local progress = (tick() - RadiusHandler.UsedAbilityTick) / Abilities[ability].Cooldown
                    local abilityProps = Abilities[ability]

                    radiusPart.Color = Color3.fromRGB(255,0,0)

                    math.min(1, progress)

                    -- do animation progress = 0 is animation start progress = 1 is animation done
                    local root = char.HumanoidRootPart

                    local startMultiplier = 1
                    local endMultiplier = abilityProps.RangeMultiplier
                    local currentMultiplier = startMultiplier + (endMultiplier - startMultiplier) * progress
                    
                    radiusPart.Size = Vector3.new(
                        PlayerData.Data.Equipped.Range*currentMultiplier, 
                        .5, 
                        PlayerData.Data.Equipped.Range*currentMultiplier
                    ) -- actual radius

                    radiusPart.Position = Vector3.new(root.Position.X, root.Position.Y-5, root.Position.Z)
                    radiusPart.Transparency = 0.75

                    if progress == 1 then
                        RadiusHandler.UsingAbility = false

                    end
                end
            else
                local root = char.HumanoidRootPart
                radiusPart.Size = Vector3.new(PlayerData.Data.Equipped.Range, .5, PlayerData.Data.Equipped.Range) -- actual radius
                print("Fix the y axis of the radiusPart with raycast?")
                radiusPart.Position = Vector3.new(root.Position.X, root.Position.Y-5, root.Position.Z)
                radiusPart.Color = radiusColor
                radiusPart.Transparency = 0.75
            end
        else
            radiusPart.Transparency = 1
        end
    end)
end

return RadiusHandler