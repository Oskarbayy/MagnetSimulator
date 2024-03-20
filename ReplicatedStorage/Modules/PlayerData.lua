local PlayerData = {
    ["Data"] = {}
};

function PlayerData.UpdateData(args)
    PlayerData["Data"] = args["Data"]
end

return PlayerData
