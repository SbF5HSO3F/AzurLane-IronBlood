-- IronBlood_Seydlitz
-- Author: jjj
-- DateCreated: 2024/8/22 19:36:27
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||====================ExposedMembers====================||--

--||===================local variables====================||--

local key_A = 'UnSinkableLegendAttack'
local key_D = 'UnSinkableLegendDefend'
local key_L = 'SeydlitzSetUpUnitTurns'
local perHp = 10

--||====================base functions====================||--


--||===================Events functions===================||--

--when damage change
function SeydlitzSetProperty(playerID, unitID)
    --the leader is Seydlitz?
    if IronCore.CheckLeaderMatched(playerID, 'LEADER_SEYDLITZ') then
        --get the unit
        local pUnit = UnitManager.GetUnit(playerID, unitID)
        if not pUnit then return end
        --get the unit damage
        local LoseHp = pUnit:GetDamage()
        local maxHp = pUnit:GetMaxDamage()
        local HaveHp = maxHp - LoseHp
        --set the key
        pUnit:SetProperty(key_A, math.floor(HaveHp / perHp))
        pUnit:SetProperty(key_D, math.floor(LoseHp / perHp))
    end
end

--||=================GameEvents functions=================||--

--transmission unit
function SeydlitzPlaceUnit(playerID, param)
    local pPlayer = Players[playerID]
    if pPlayer then
        local pUnit = UnitManager.GetUnit(playerID, param.unitID)
        if pUnit then
            UnitManager.PlaceUnit(pUnit, param.x, param.y)
            pUnit:SetDamage(0)
        end
    end
end

--setup unit
function SeydlitzSetupUnit(playerID, param)
    local pPlayer = Players[playerID]
    if pPlayer then
        local unit = UnitManager.GetUnit(playerID, param.UnitID)
        local upUnit = UnitManager.GetUnit(playerID, param.UpUnitID)
        if not upUnit or not unit then return end
        --grant the reward
        local reward = param.Reward
        pPlayer:GetTreasury():ChangeGoldBalance(reward)
        --show the message
        local message = Locale.Lookup("LOC_UNITCOMMAND_IRON_WILLED_LEADER_REWARD_FLOAT", reward)
        local messageData = {
            MessageType = 0,
            MessageText = message,
            PlotX       = unit:GetX(),
            PlotY       = unit:GetY(),
            Visibility  = RevealedState.VISIBLE,
        }; Game.AddWorldViewText(messageData)
        --grant the great person points
        local class = unit:GetGreatPerson():GetClass()
        local classDef = GameInfo.GreatPersonClasses[class]
        --add the great person points
        pPlayer:GetGreatPeoplePoints():ChangePointsTotal(classDef.Index, param.Points)
        --show the message
        local name = classDef.Name
        --set the string
        local fString = Locale.Lookup(
            'LOC_UNITCOMMAND_IRON_WILLED_LEADER_PIONTS_FLOAT', param.Points, name
        )
        --Add the message
        local fStringData = {
            MessageType = 0,
            MessageText = fString,
            PlotX       = unit:GetX(),
            PlotY       = unit:GetY(),
            Visibility  = RevealedState.VISIBLE,
        }; Game.AddWorldViewText(fStringData)
        --set the unit turns
        unit:SetProperty(key_L, Game.GetCurrentGameTurn())
        --set the unit Formation
        upUnit:SetMilitaryFormation(param.Type)
        --set the animation
        UnitManager.ReportActivation(unit, "SeydlitzSetUpUnit")
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------------Events-----------------------
    Events.UnitDamageChanged.Add(SeydlitzSetProperty)
    Events.UnitAddedToMap.Add(SeydlitzSetProperty)
    ---------------------GameEvents---------------------
    GameEvents.SeydlitzRePlaceUnit.Add(SeydlitzPlaceUnit)
    GameEvents.SeydlitzSetUpUnit.Add(SeydlitzSetupUnit)
    ----------------------------------------------------
    ----------------------------------------------------
    print('Initial success!')
end

Initialize()

include(true)
