local ShopClient = {}

-- Properties
local selectedItem = nil

function ShopClient.SelectItem(btnName)
    selectedItem = btnName

    ChangePreview()
end

-- main button pressed could mean equip / buy or even unequip
function ShopClient.Action(btnName)

end

-- Private Functions --
function ChangePreview()
    -- setup UI stuff which i dont have access to yet

    -- but the idea is to show selected item image and info
end

return ShopClient