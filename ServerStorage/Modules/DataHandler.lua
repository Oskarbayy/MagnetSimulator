local DataHandler = {
    ["Players"] = {}
}

local DataTypes = {
    ["Range"] = 10,
    ["Speed"] = 16,
    ["Coins"] = 0,
    ["Equipped"] = nil,
    ["PetsEquipped"] = {},
    ["Inventory"] = {},
    ["PVP"] = true,
    ["Settings"] = {
        ["CoinAnimations"] = true
    }
}

-- 
local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")
local RStorage = game:GetService("ReplicatedStorage")

--
local RE = RStorage:WaitForChild("RemoteEvent")

function DataHandler.Init(plr)
    local userId = tostring(plr.UserId) -- Convert userId to string for DataStore key
    local data = LoadDataFromDataStore(userId)
    if not data then
        data = {}
        for type, value in pairs(DataTypes) do
            data[type] = value
        end
    end
    DataHandler["Players"][plr] = data
    UpdateClientData(plr) -- Initialize client data upon joining
end

function DataHandler.GetData(plr, type)
    local data = DataHandler["Players"][plr]
    if not type then
        return data
    end
    return data[type]
end

function DataHandler.AddData(plr, type, increment)
    local data = DataHandler["Players"][plr]
    data[type] = data[type] + increment
    UpdateClientData(plr)
end

function DataHandler.SetData(plr, type, value)
    local data = DataHandler["Players"][plr]
    data[type] = value
    UpdateClientData(plr)
end

-- 
function SaveDataToDataStore(userId, data)
    local success, errorMessage = pcall(function()
        PlayerDataStore:SetAsync(userId, data)
    end)
    if not success then
        warn("Failed to save data for user ID " .. userId .. ": " .. errorMessage)
    end
end

function LoadDataFromDataStore(userId)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(userId)
    end)
    if success then
        return data
    else
        warn("Failed to load data for user ID " .. userId)
        return nil
    end
end

function UpdateClientData(plr)
    local data = DataHandler["Players"][plr]
    RE:FireClient(plr, {["ModuleScript"] = "PlayerData", ["Function"] = "UpdateData", ["Data"] = data})
end

-- Save player data when they leave
game.Players.PlayerRemoving:Connect(function(plr)
    local userId = tostring(plr.UserId)
    local data = DataHandler["Players"][plr]
    SaveDataToDataStore(userId, data)
    DataHandler["Players"][plr] = nil -- Clear cached data
end)

return DataHandler
