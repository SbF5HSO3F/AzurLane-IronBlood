-- IronBlood_Z23
-- Author: jjj
-- DateCreated: 2023/12/27 21:04:38
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||====================ExposedMembers====================||--

--GameEvents
--ExposedMembers.GameEvents = GameEvents
--ExposedMembers
ExposedMembers.Z23 = ExposedMembers.Z23 or {}


--Heal Num
ExposedMembers.Z23.HealNum  = 25
--Turns
ExposedMembers.Z23.LastTurn = IronBloodSpeedModifier(10)
--||===================glabol variables===================||--

--||===================local variables====================||--

local Z23percent            = 0.15
local ability               = 'ABILITY_Z23_COMBAT_UNIT_EXTRA_BUFF'
local abilityExtra          = 'ABILITY_Z23_COMBAT_UNIT_PILLAGE_COMBAT'
local combatProperty        = 'Z23_PILLAGE_COMBAT'
local TurnLast              = 'Z23TurnLast'

--||====================base functions====================||--

--Gets tech or civic and returns value
function Z23BoostValue(playerID, index, percent, isCivic)
    --get the player
    local pPlayer, value = Players[playerID], 0
    if pPlayer then
        if isCivic then
            --get culture
            local culture = pPlayer:GetCulture()
            if culture then
                --Calculate the data
                value = IronBloodNumRound(culture:GetCultureCost(index) * percent)
            end
        else
            --get techs
            local techs = pPlayer:GetTechs()
            if techs then
                --Calculate the data
                value = IronBloodNumRound(techs:GetResearchCost(index) * percent)
            end
        end
        return value
    else
        print('No player found!')
        return 0
    end
end

--When boost triggered
function Z23OnBoostTriggered(playerID, index, isCivic)
    --is Z23?
    if not IronBloodLeaderTypeMatched(playerID, 'LEADER_Z23_1936A') then
        return
    end

    local pPlayer, value = Players[playerID], 0
    if isCivic then
        --get the value
        value = Z23BoostValue(playerID, index, Z23percent, true)
        --Get Culture
        pPlayer:GetCulture():ChangeCurrentCulturalProgress(value)
    else
        --get the value
        value = Z23BoostValue(playerID, index, Z23percent, false)
        --Get Science
        pPlayer:GetTechs():ChangeCurrentResearchProgress(value)
    end
    --details
    print('Gain ' .. value .. ((isCivic and ' Culture') or ' Science'))
end

--Get replaced districts
function Z23GetReplacedDistrict(districtType)
    --get the district information
    local districtInfo = GameInfo.Districts[districtType]
    for replace in GameInfo.DistrictReplaces() do
        if replace.CivUniqueDistrictType == districtInfo.DistrictType then
            return replace.ReplacesDistrictType
        end
    end
end

--Clear the ability
function Z23ClearAbilities(pUnit, eAbility)
    if pUnit then
        local unitAbility = pUnit:GetAbility()
        unitAbility:ChangeAbilityCount(eAbility, -unitAbility:GetAbilityCount(eAbility))
    end
end

--||=================GameEvents functions=================||--

--Clear the unit abilities and reduce the count
function Z23OnPlayerTurnStarted(playerID)
    --is Z23? no return
    if not IronBloodLeaderTypeMatched(playerID, 'LEADER_Z23_1936A') then
        return
    end

    --get the player
    local pPlayer = Players[playerID]
    for _, unit in pPlayer:GetUnits():Members() do
        --Clear the ability
        Z23ClearAbilities(unit, ability)
        Z23ClearAbilities(unit, abilityExtra)
        --clear the property
        unit:SetProperty(combatProperty, 0)
        --last turn--
        local turns = unit:GetProperty(TurnLast)
        if turns and turns > 0 then
            unit:SetProperty(TurnLast, math.max(0, turns - 1))
        end
    end
end

--Destruction Mode
function Z23ChangeMode(playerID, param)
    --get the player
    local pPlayer = Players[playerID]
    if pPlayer then
        --Get the Unit
        local pUnit = UnitManager.GetUnit(playerID, param.unitID)
        --Hp Heal
        pUnit:ChangeDamage(param.heal)
        --Add Ability
        pUnit:GetAbility():ChangeAbilityCount(ability, 1)
        --restore the attack and movement
        UnitManager.RestoreUnitAttacks(pUnit)
        UnitManager.RestoreMovementToFormation(pUnit)
        --Set property
        pUnit:SetProperty(TurnLast, param.turns)
        --get plot
        local pPlot = Map.GetPlot(param.x, param.y)
        if pPlayer:GetDiplomacy():IsAtWarWith(pPlot:GetOwner()) then
            local pTarget = Players[pPlot:GetOwner()]
            local pDistrict = pTarget:GetDistricts():FindID(pPlot:GetDistrictID())
            --Has district?
            if pDistrict then
                --plot id
                local pPlotID = pPlot:GetIndex()
                --Extra Strength
                pUnit:GetAbility():ChangeAbilityCount(abilityExtra, 1)
                pUnit:SetProperty(combatProperty, 0)
                --Destruction of District
                if not pDistrict:IsPillaged() then
                    pDistrict:SetPillaged(true)
                    --Add Combat Strength
                    pUnit:SetProperty(combatProperty, pUnit:GetProperty(combatProperty) + 3)
                end

                local pCity = pDistrict:GetCity()

                if pCity then
                    --if the district replaces district, get it
                    --local replaceDistrict = Z23GetReplacedDistrict(pDistrict:GetType())
                    local cityBuildings = pCity:GetBuildings()
                    -- and their buildings...
                    for row in GameInfo.Buildings() do
                        --if row.PrereqDistrict == districtInfo.DistrictType or row.PrereqDistrict == replaceDistrict then
                        if cityBuildings:HasBuilding(row.Index) and not cityBuildings:IsPillaged(row.Index) and cityBuildings:GetBuildingLocation(row.Index) == pPlotID then
                            pCity:GetBuildings():SetPillaged(row.Index, true)
                            --Add Combat Strength
                            pUnit:SetProperty(combatProperty, pUnit:GetProperty(combatProperty) + 3)
                        end
                        --end
                    end
                end
            else
                print('No district found')
            end
        end
        --add text
        local message = Locale.Lookup('LOC_UNITCOMMAND_Z23_NAME')
        local messageData = {
            MessageType = 0,
            MessageText = message,
            PlotX       = pUnit:GetX(),
            PlotY       = pUnit:GetY(),
            Visibility  = RevealedState.VISIBLE,
        }; Game.AddWorldViewText(messageData)
        --player animation
        UnitManager.ReportActivation(pUnit, "Z23_MODE")
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    -----------------Events-----------------
    Events.TechBoostTriggered.Add(function(playerID, iTechBoosted)
        Z23OnBoostTriggered(playerID, iTechBoosted, false)
    end)
    Events.CivicBoostTriggered.Add(function(playerID, iBoostedCivic)
        Z23OnBoostTriggered(playerID, iBoostedCivic, true)
    end)
    ---------------GameEvents---------------
    GameEvents.PlayerTurnStarted.Add(Z23OnPlayerTurnStarted)
    GameEvents.Z23ChangeNewMode.Add(Z23ChangeMode)
    ----------------------------------------
    print('Initial success!')
    print('Error: Z404 Not Found')
end

Initialize()
