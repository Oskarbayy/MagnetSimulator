-- Server

--
local RStorage = game:GetService("ReplicatedStorage")
local SStorage = game:GetService("ServerStorage")

-- Modules
local cModules = RStorage:WaitForChild("Modules")
local sModules = SStorage:WaitForChild("Modules")

local CoinHandler = require(sModules.CoinHandler)
local DataHandler = require(sModules.DataHandler)

--
local RE = RStorage:WaitForChild("RemoteEvent")
local RF = RStorage:WaitForChild("RemoteFunction")

-- Server Just Started
print("Server Starting...")

-- Setup Player
print("Setting up Player")
game.Players.PlayerAdded:Connect(function(plr)
    DataHandler.Init(plr)
end)

-- Start Spawning Coins
CoinHandler.Init()

-- Connect Remotes


function ErrorMessage(msg, args)
	print("---")
	print(msg)
	if args then
		for i,v in pairs(args) do
			print(i,v)
		end
	end
	print("---")
end

RE.OnServerEvent:Connect(function(plr, args)
	local Function = args["Function"]
	local ModuleScript = args["ModuleScript"]

	if ModuleScript then
		if Function then
			if sModules:FindFirstChild(ModuleScript) then

				ModuleScript = require(sModules:FindFirstChild(ModuleScript))
				ModuleScript[Function](plr, args)

			else
				ErrorMessage("ERROR, ModuleScript: '"..ModuleScript.."' Doesnt Exist!")
			end
		else
			if sModules:FindFirstChild(ModuleScript) then
				ModuleScript = require(sModules:FindFirstChild(ModuleScript))
				ModuleScript.New(plr, args)

			else
				ErrorMessage("ERROR, ModuleScript: '"..ModuleScript.."' Doesnt Exist!")
			end
		end
	else
		ErrorMessage("ERROR, No module script to call with the remote. Info:", args)
	end

end)

RF.OnServerInvoke = function(plr, args)
	local Function = args["Function"]
	local ModuleScript = args["ModuleScript"]
	local result

	print("Remote Function Invoked:", plr, args)

	if ModuleScript then
		if Function then
			if sModules:FindFirstChild(ModuleScript) then
				ModuleScript = require(sModules:FindFirstChild(ModuleScript))
				if ModuleScript[Function] then
					result = ModuleScript[Function](plr, args)

				else
					ErrorMessage("ERROR, Function: '"..Function.."' Doesnt Exist!")
				end
			else
				ErrorMessage("ERROR, ModuleScript: '", ModuleScript, "' Doesnt Exist!")
			end
		else
			if sModules:FindFirstChild(ModuleScript) then
				ModuleScript = require(sModules:FindFirstChild(ModuleScript))
				result = ModuleScript.New(plr, args)

			else
				ErrorMessage("ERROR, ModuleScript: '"..ModuleScript.."' Doesnt Exist!")
			end
		end
	else
		ErrorMessage("ERROR, No module script to call with the remote. Info:", args)
	end

	return result
end