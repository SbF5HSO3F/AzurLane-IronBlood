-- IronBlood_Core
-- Author: jjj
-- DateCreated: 2023/12/28 19:29:54
--------------------------------------------------------------
--||====================GamePlay, UI======================||--

--Leader type judgment. if macth, return true (GamePlay, UI)
function IronBloodLeaderTypeMatched(playerID, LeaderTpye)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == LeaderTpye
end

--process rounding (GamePlay, UI)
function IronBloodNumRound(num)
    return math.floor((num + 0.05) * 10) / 10
end

--Game Speed Modifier (GamePlay, UI)
function IronBloodSpeedModifier(num)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then
        num = IronBloodNumRound(num * gameSpeed.CostMultiplier / 100)
    end
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