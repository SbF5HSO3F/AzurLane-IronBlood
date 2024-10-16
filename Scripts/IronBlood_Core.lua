-- IronBlood_Core
-- Author: jjj
-- DateCreated: 2023/12/28 19:29:54
--------------------------------------------------------------
--||======================MetaTable=======================||--

IronCore = {}

--||====================GamePlay, UI======================||--

--Leader type judgment. if macth, return true (GamePlay, UI)
function IronCore.CheckLeaderMatched(playerID, leaderType)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == leaderType
end

--Civilization type judgment. if macth, return true (GamePlay, UI)
function IronCore.CheckCivMatched(playerID, civType)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == civType
end

--process rounding (GamePlay, UI)
function IronCore.Round(num)
    return math.floor((num + 0.05) * 10) / 10
end

--Random number generator [1,num+1] (GamePlay, UI)
function IronCore.tableRandom(num)
    return Game.GetRandNum and (Game.GetRandNum(num) + 1) or 1
end

--Game Speed Modifier (GamePlay, UI)
function IronCore:ModifyBySpeed(num)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then num = self.Round(num * gameSpeed.CostMultiplier / 100) end
    return num
end

--||=========================UI=========================||--

--mouse enter the button
function IronBloodEnter()
    UI.PlaySound("Main_Menu_Mouse_Over")
end

--||========================Test========================||--

--test function
function IronBloodPrintTable(t, indent)
    indent = indent or 0

    for k, v in pairs(t) do
        if type(v) == "table" then
            print(string.rep(" ", indent) .. k .. ": {")
            IronBloodPrintTable(v, indent + 4)
            print(string.rep(" ", indent) .. "}")
        else
            print(string.rep(" ", indent) .. k .. ": " .. tostring(v))
        end
    end
end