local SpecialAbilityS = {}

--
local RStorage = game:GetService("ReplicatedStorage")
local SStorage = game:GetService("ServerStorage")

-- Modules
local sModules = SStorage:WaitForChild("Modules")
local cModules = RStorage:WaitForChild("Modules")

local Abilities = require(cModules.Abilities)
local DH = require(sModules.DataHandler)
local CoinHandler = require(sModules.CoinHandler)

function SpecialAbilityS.UseAbility(plr)
    -- Check if valid request
    local data = DH.GetData(plr)
    if data.Equipped.SpecialAbility then
        local ability = data.Equipped.SpecialAbility

        if tick()-data.Equipped.UsedAbilityTick >= Abilities[ability].Cooldown then
            -- Ready to use ability
            if ability == "Black Hole" then
                CoinHandler.UseAbility(plr)
            end
        end
    end

end

return SpecialAbilityS