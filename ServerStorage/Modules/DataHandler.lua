local DataHandler = {
    ["Players"] = {}
}

local DataTypes = {
    ["Range"] = 10,
    ["Speed"] = 16,
    ["Coins"] = 0,
    ["Equipped"] = nil,
    ["Inventory"] = {}
}

function DataHandler.Init(plr)
    DataHandler["Players"][plr] = {}

    local data = DataHandler["Players"][plr]

    for type, value in pairs(DataTypes) do
        data[type] = value
    end
end

function DataHandler.GetData(plr, type)
    local data = DataHandler["Players"][plr]

    return data[type]
end

function DataHandler.AddData(plr, type, increment)
    local data = DataHandler["Players"][plr]

    data[type] = data[type] + increment
end

function DataHandler.SetData(plr, type, value)
    local data = DataHandler["Players"][plr]

    data[type] = value
end


return DataHandler