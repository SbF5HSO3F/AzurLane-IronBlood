-- IronBlood_Core
-- Author: HSbF6HSO3F
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

--judge a plot can have a unit or not (GamePlay, UI)
function IronCore.CanHaveUnit(plot, unitdef)
    if plot == nil then return false end
    local canHave = true
    for _, unit in ipairs(Units.GetUnitsInPlot(plot)) do
        if unit then
            local unitInfo = GameInfo.Units[unit:GetType()]
            if unitInfo then
                if unitInfo.IgnoreMoves == false then
                    if unitInfo.Domain == unitdef.Domain and unitInfo.FormationClass == unitdef.FormationClass then
                        canHave = false
                    end
                end
            end
        end
    end
    return canHave
end

--check a unit is a millitary unit or not (GamePlay, UI)
function IronCore.IsMilitary(unit)
    if unit == nil then return false end
    local unitInfo = GameInfo.Units[unit:GetType()]
    if unitInfo == nil then return false end
    local unitFormation = unitInfo.FormationClass
    return unitFormation == 'FORMATION_CLASS_LAND_COMBAT'
        or unitFormation == 'FORMATION_CLASS_NAVAL'
        or unitFormation == 'FORMATION_CLASS_AIR'
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
