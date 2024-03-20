local ToolHandler = {
    ["Players"] = {}
}

--
local RStorage = game:GetService("ReplicatedStorage")
local SStorage = game:GetService("ServerStorage")

-- Modules
local sModules = SStorage:WaitForChild("Modules")
local cModules = RStorage:WaitForChild("Modules")

local DH = require(sModules.DataHandler)


function ToolHandler.EquipTool(plr, args)
    -- if owns item then equip it in the datahandler
    local item = args["Item"]
    local inventory = DH.GetData(plr, "Inventory")

    if inventory[item] then
        -- Equip Item
        DH.SetData(plr, "Equipped", item)
        return item
    end
end

function ToolHandler.UnEquipTool(plr, args)
    DH.SetData(plr, "Equipped", nil)
end

return ToolHandler