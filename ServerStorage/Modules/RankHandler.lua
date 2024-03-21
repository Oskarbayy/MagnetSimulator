-- Settings --
local baseExp = 100
local multiplier = 1.25


local RankHandler = {
    ["Ranks"] = {}
}

function RankHandler.Init(plr)
    RankHandler["Ranks"][plr] = {
        Rank = 1,
        Exp = 0
    }
    
end

function RankHandler.AwardExp(plr, exp)
    local plrData = RankHandler.Ranks[plr]
    while exp > 0 do
        local reqExp = baseExp * multiplier^(plrData.Rank - 1)

        if plrData.Exp + exp >= reqExp then
            exp = exp - (reqExp - plrData.Exp)
            plrData.Exp = 0
            plrData.Rank = plrData.Rank + 1

        else
            plrData.Exp = plrData.Exp + exp
            exp = 0
        end
    end
end

return RankHandler