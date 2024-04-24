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
    local pet = args["Pet"]

    local inventory = DH.GetData(plr, "Inventory")

    -- if you own the pet
    if inventory["Pets"][pet] then
        -- Change Data
        local petsEquipped = DH.GetData(plr, "PetsEquipped")

        -- might have to fix this isnce the inventory might not just incldue an index of pet variable
        -- and maybe its a table with an ID instead of a string index
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
    local pet = args["Pet"]
    local petsEquipped = DH.GetData(plr, "PetsEquipped")

    -- if you have this pet equipped
    if petsEquipped[pet] then
        -- Change Data

        petsEquipped[pet] = nil
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

return PetSystemS