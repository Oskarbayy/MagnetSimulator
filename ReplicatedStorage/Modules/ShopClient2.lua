--[[ Dependencies
    ShopCamera
    UIs
]]

-- Settings
local ShopCamera = workspace.ShopCamera

--
local ShopClient = {}

-- Services
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local cModules = RStorage:WaitForChild("Modules")

-- Shop Item table:
local Magnets = require(cModules.Magnets)

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")

local plr = game.Players.LocalPlayer

-- UI
local plrGui = plr.PlayerGui

local shopUI = plrGui:WaitForChild("ShopUI")
local itemFrames = shopUI.ItemFrames -- maybe a folder?

-- Current State variables
local currentItemIndex = 1

-- sort magnets
local sortedMagnets = {}
for name, details in pairs(Magnets) do
    details.Name = name  -- Preserve the name within the details
    table.insert(sortedMagnets, details)
end

table.sort(sortedMagnets, function(a, b)
    return a.Price < b.Price
end)

--

function ShopClient.Open() 
    ShopClient.IsOpen = true

    ShopClient.UpdateUI()

    local camera = workspace.CurrentCamera

    camera.CameraType = Enum.CameraType.Scriptable
    camera.CFrame = ShopCamera.CFrame
end

function ShopClient.Action(btn)
    local btnName = btn.Name
    local selectedItem = sortedMagnets[currentItemIndex].Name

    if btnName == "Equip" then
        RE:FireServer({["ModuleScript"] = "ToolHandler", ["Function"] = "EquipTool", ["Item"] = selectedItem})

    elseif btnName == "Buy" then
        local status = RF:InvokeServer({["ModuleScript"] = "ShopHandler", ["Function"] = "BuyItem", ["Item"] = selectedItem})

        print(status["Message"])

        -- Update the shop since its bought now?
        if ShopClient.IsOpen then
            ShopClient.UpdateUI()
        end
    elseif btnName == "UnEquip" then
        RE:FireServer({["ModuleScript"] = "ToolHandler", ["Function"] = "UnEquipTool"})

    end
end


function ShopClient.UpdateUI()
    local visibleItems = 5 -- Define how many items to display at once
    local totalItems = #sortedMagnets -- Total number of sorted items

    -- Calculate the start index of the items to display based on the current item index
    local startIndex = math.max(1, currentItemIndex - math.floor(visibleItems / 2))
    local endIndex = math.min(totalItems, startIndex + visibleItems - 1)

    -- Adjust startIndex if we are at the end of the list to still show 'visibleItems' items
    if endIndex == totalItems then
        startIndex = math.max(1, endIndex - visibleItems + 1)
    end

    --[[ Is this needed?
    Clear existing items in the frame
    for i, frame in ipairs(itemFrames:GetChildren()) do
        frame
    end
    ]]

    -- Populate the item frames with new items
    for i = startIndex, endIndex do
        local frameIndex = i - startIndex + 1
        local item = sortedMagnets[i]
        local frame = itemFrames:FindFirstChild("ItemFrame" .. frameIndex)

        if frame then
            -- Update the frame with new item details
            if frameIndex == 3 then -- if item is selected
                frame.ItemName.Text = item.Name
                frame.ItemPrice.Text = "$" .. item.Price
            end
            if item.Image ~= "" then
                frame.ItemImage.Image = item.Image
            else
                frame.ItemImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
            end
        end
    end
end

function ShopClient.MoveRight()
    currentItemIndex = math.min(#sortedMagnets, currentItemIndex + 1)
    ShopClient.UpdateUI()
end

function ShopClient.MoveLeft()
    currentItemIndex = math.max(1, currentItemIndex - 1)
    ShopClient.UpdateUI()
end

function ShopClient.Close()
    ShopClient.IsOpen = false

    local camera = workspace.CurrentCamera

    camera.CameraType = Enum.CameraType.Custom
end

return ShopClient