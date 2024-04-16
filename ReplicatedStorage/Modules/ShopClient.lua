local ShopClient = {}

--
local RStorage = game:GetService("ReplicatedStorage")

-- 
local Modules = RStorage:WaitForChild("Modules")

local Magnets = require(Modules.Magnets)
local PlayerData = require(Modules.PlayerData)

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")

-- UI
local container
local template

-- Properties
local selectedItem = nil

function ShopClient.SelectItem(btn)
    local btnName = btn
    
    if not btn.Locked.Visible then
        selectedItem = btnName
    end

    ChangePreview()
end

-- main button pressed could mean equip / buy or even unequip
function ShopClient.Action(btn)
    local btnName = btn.Name

    if btnName == "Equip" then
        RE:FireServer({["ModuleScript"] = "ToolHandler", ["Function"] = "EquipTool", ["Item"] = selectedItem})

    elseif btnName == "Buy" then
        local status = RF:InvokeServer({["ModuleScript"] = "ShopHandler", ["Function"] = "BuyItem", ["Item"] = selectedItem})

        print(status["Message"])
    elseif btnName == "UnEquip" then
        RE:FireServer({["ModuleScript"] = "ToolHandler", ["Function"] = "UnEquipTool"})

    end
end

function ShopClient.LoadShop()
    local isFirstNotOwned = true

    for Magnet, properties in pairs(Magnets) do
        -- Create a UI for every item that can be bought

        local shopItem = template:Clone()
        shopItem.Parent = container

        shopItem.Locked.Visible = true

        -- setup properties
        shopItem.Name.Text = Magnet
        shopItem.Stats.Effectiveness = properties.Effectiveness
        shopItem.Icon.Image = properties.Image
        shopItem.Range.Text = properties.Range
        shopItem.Price.Text = properties.Price

        -- check if locked
        if PlayerData.Inventory[Magnet] then
            -- if player owns the magnet then its definitely not locked
            shopItem.Locked.Visible = false
        elseif isFirstNotOwned then
            isFirstNotOwned = false

            shopItem.Locked.Visible = false
        end
    end
end

-- Private Functions --
function ChangePreview()
    -- setup UI stuff which i dont have access to yet

    -- but the idea is to show selected item image and info
end



return ShopClient