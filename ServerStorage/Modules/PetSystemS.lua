--[[ Dependencies
    DataHandler["Inventory"]["Pets"]
    DataHandler["PetsEquipped"]

--]]

local PetSystemS = {}

-- Services
local RStorage = game:GetService("ReplicatedStorage")
local SStorage = game:GetService("ServerStorage")

-- Modules
local Modules = SStorage:WaitForChild("Modules")

local DH = require(Modules.DataHandler)

--
local RE = RStorage:WaitForChild("RemoteEvent")

function PetSystemS.EquipPet(plr, args)
    -- expected to have an under inventory index called "Pets" in DataHandler
    local pet = args["Pet"]

    local inventory = DH.GetData(plr, "Inventory")

    -- if you own the pet
    if inventory["Pets"][pet] then
        -- Change Data
        local petsEquipped = DH.GetData(plr, "PetsEquipped")
        
        table.insert(petsEquipped, inventory["Pets"][pet])
        print(petsEquipped) -- debug

        DH.SetData(plr, "PetsEquipped", petsEquipped)

        -- Update all clients with the new pets
        RE:FireAllClients({
            ["ModuleScript"] = "PetSystem", 
            ["Function"] = "UpdatePlayerPets", 
            ["Player"] = plr,   
            ["PetsEquipped"] = petsEquipped
        })
    end
end

function PetSystemS.UnEquipPet(plr, args)

end

return PetSystemS