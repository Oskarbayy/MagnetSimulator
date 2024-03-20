-- Player just joined and this runs when player is added to the server
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = RStorage:WaitForChild("Modules")

local CoinCollect = require(Modules.CoinCollect)

CoinCollect.Init();