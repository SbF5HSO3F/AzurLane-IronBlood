-- IronBlood_Z46
-- Author: jjj
-- DateCreated: 2023/10/14 19:34:50
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||===================Events functions===================||--

--Create GreatWork City Buff
function Z46CreateGreatWorkCityBuff(playerID, unitID, iCityPlotX, iCityPlotY)
    --is Z46?
    if not IronCore.CheckLeaderMatched(playerID, 'LEADER_Z46_1936C') then
        return
    end

    local pCity = CityManager.GetCityAt(iCityPlotX, iCityPlotY)
    if pCity ~= nil then
        pCity:AttachModifierByID('Z46_DISTICTS_CULTURE_BONUS')
    end
end

--1936C Kill Air Buff
function AirKilledBy1936C(killedPlayerID, killedUnitID, playerID, unitID)
    local pUnit = UnitManager.GetUnit(playerID, unitID)
    local pKilledUnit = UnitManager.GetUnit(killedPlayerID, killedUnitID)
    if (pUnit == nil or pKilledUnit == nil) then
        return
    end
    local UnitInfo = GameInfo.Units[pUnit:GetType()]
    local KilledUnitInfo = GameInfo.Units[pKilledUnit:GetType()]
    if (pUnit ~= nil and UnitInfo.UnitType == 'UNIT_1936C') then
        if (pKilledUnit ~= nil and KilledUnitInfo.Domain == 'DOMAIN_AIR') then
            local property = pUnit:GetProperty('1936C_UNIT_COMBAT') or 0
            pUnit:SetProperty('1936C_UNIT_COMBAT', property + 5)
        end
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------Events-----------------
    Events.GreatWorkCreated.Add(Z46CreateGreatWorkCityBuff)
    Events.UnitKilledInCombat.Add(AirKilledBy1936C)
    ----------------------------------------
    print('Initial success!')
end

Initialize()
