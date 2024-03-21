local SpecialAbility = {}

--
local UIS = game:GetService("UserInputService")
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = RStorage:WaitForChild("Modules")

local PlayerData = require(Modules.PlayerData)
local RadiusHandler = require(Modules.RadiusHandler)
local Abilities = require(Modules.Abilities)

--
local RE = RStorage:WaitForChild("RemoteEvent")


function SpecialAbility.Init()
    -- Connect keys to abilities
    UIS.InputBegan:Connect(onInputBegan)


end

function onInputBegan(input, gameProcessedEvent)
    -- if any magnet equipped and it has a special ability
    local ability = PlayerData.Data.Equipped.SpecialAbility 
    if ability and not RadiusHandler.UsingAbility and (tick() - RadiusHandler.UsedAbilityTick) >= Abilities[ability].Cooldown then
        print("Client is ready to use special ability")
        if gameProcessedEvent then return end  -- Ignore input events that the game has already processed
        
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.E then
                RadiusHandler.UsedAbilityTick = tick()
                RadiusHandler.UsingAbility = true

                RE:FireServer({["ModuleScript"] = "SpecialAbilityS", ["Function"] = "UseAbility"})

            end
        end
    end
end

return SpecialAbility