local ShopClient = {}

--
local RStorage = game:GetService("ReplicatedStorage")

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")

-- Properties
local selectedItem = nil

function ShopClient.SelectItem(btnName)
    selectedItem = btnName

    ChangePreview()
end

-- main button pressed could mean equip / buy or even unequip
function ShopClient.Action(btnName)
    if btnName == "Equip" then
        RE:FireServer({["ModuleScript"] = "ToolHandler", ["Function"] = "EquipTool", ["Item"] = selectedItem})

    elseif btnName == "Buy" then
        local status = RF:InvokeServer({["ModuleScript"] = "ShopHandler", ["Function"] = "BuyItem", ["Item"] = selectedItem})

        print(status["Message"])
    elseif btnName == "UnEquip" then
        RE:FireServer({["ModuleScript"] = "ToolHandler", ["Function"] = "UnEquipTool"})

    end
end

-- Private Functions --
function ChangePreview()
    -- setup UI stuff which i dont have access to yet

    -- but the idea is to show selected item image and info
end

return ShopClient