local PushHandlerS = {
    ["Players"] = {}
}

-- Services
local SStorage = game:GetService("ServerStorage")
local RStorage = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

-- Modules
local sModules = SStorage:WaitForChild("Modules")
local cModules = RStorage:WaitForChild("Modules")

local DH = require(sModules.DataHandler)


function PushHandlerS.Push(plr, args)
    -- Verify Request
    local players = args["Players"]

    local plrData = DH.GetData(plr)

    if plrData.Equipped and plrData.PVP then
        print("good")

        for _, player in pairs(players) do
            local playerData = DH.GetData(player)

            if playerData.PVP then
                local distance = calcDistance(plr, player)
                if distance <= plrData.Equipped.Range then
                    Push(plr, player)

                    if playerData.Equipped then
                        Push(player, plr)
                    end

                end

            end
        end
    end
end

function PushHandlerS.Init()
    RS.Heartbeat:Connect(function()
        UpdatePushersList()
        for targetPlayer, pushers in pairs(PushHandlerS.Players) do
            local totalForce = Vector3.new()
            for _, pusher in ipairs(pushers) do
                if pusher.Character and pusher.Character:FindFirstChild("HumanoidRootPart") and
                targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    -- Calculate force direction and magnitude
                    local direction = (targetPlayer.Character.HumanoidRootPart.Position - pusher.Character.HumanoidRootPart.Position).unit
                    local forceMagnitude = 50 -- Customize this value based on desired push strength
                    totalForce += direction * forceMagnitude
                end
            end
            
            -- Apply total force to target player
            if not targetPlayer.Character:FindFirstChild("BodyVelocity") then
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 4000 -- Adjust max force as needed
                bodyVelocity.Velocity = totalForce
                bodyVelocity.Parent = targetPlayer.Character.HumanoidRootPart
            else
                targetPlayer.Character.BodyVelocity.Velocity = totalForce
            end
        end
    end)
end

function UpdatePushersList()
    for targetPlayer, pushers in pairs(PushHandlerS.Players) do
        for i = #pushers, 1, -1 do
            local pusher = pushers[i]
            if pusher.Character and pusher.Character:FindFirstChild("HumanoidRootPart") and
               targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local distance = calcDistance(pusher, targetPlayer)
                local pusherData = DH.GetData(pusher)
                if distance > pusherData.Equipped.Range then
                    -- Pusher is out of range, remove from the list
                    table.remove(PushHandlerS.Players[targetPlayer], i)
                end
            else
                -- If either character is missing, consider them out of range
                table.remove(PushHandlerS.Players[targetPlayer], i)
            end
        end
    end
end

function Push(plr, targetPlayer)
    -- Create tables of people being pushed by
    if not PushHandlerS["Players"][targetPlayer] then
        PushHandlerS["Players"][targetPlayer] = {}
    end
    -- 

    table.insert(PushHandlerS["Players"][targetPlayer], plr)
    

end

function calcDistance(plr, player)
    local char = plr.Character
    local char2 = player.Character

    if char and char.PrimaryPart and char2 and char2.PrimaryPart then
        return (char.PrimaryPart.Position-char2.PrimaryPart.Position).Magnitude
    end

    return math.huge
end


return PushHandlerS