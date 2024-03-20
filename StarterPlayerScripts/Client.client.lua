-- Player just joined and this runs when player is added to the server
local RStorage = game:GetService("ReplicatedStorage")

-- Modules
local Modules = RStorage:WaitForChild("Modules")

local CoinCollect = require(Modules.CoinCollect)

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")

-- Setup player
local thread = coroutine.create(CoinCollect.Init)
coroutine.resume(thread)


-- Setup client events

function ClientEvent(args) -- Client Remote woooho
	local func = args["Function"]
	local ModuleScript = args["ModuleScript"]

	if ModuleScript then
		local ModuleScript = require(Modules:FindFirstChild(ModuleScript))

		if func then
			ModuleScript[func](args)
		else
			ModuleScript.New(args)
		end

	else
		print("Client Event didn't pass a ModuleScript!")
	end
end

RE.OnClientEvent:Connect(ClientEvent)