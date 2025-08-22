-- IronBlood_Z23
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/27 21:04:38
--------------------------------------------------------------
--||=======================include========================||--
include('IronCore.lua')

--||====================ExposedMembers====================||--

ExposedMembers.Z23 = ExposedMembers.Z23 or {}
--Heal Num
ExposedMembers.Z23.HealNum = 25
--Turns
ExposedMembers.Z23.LastTurn = IronMath:ModifyBySpeed(10)

--||===================local variables====================||--

local Z23percent = 0.15
local ability = 'ABILITY_Z23_COMBAT_UNIT_EXTRA_BUFF'
local abilityExtra = 'ABILITY_Z23_COMBAT_UNIT_PILLAGE_COMBAT'
local combatProperty = 'Z23_PILLAGE_COMBAT'
local TurnLast = 'Z23TurnLast'

--||====================base functions====================||--

--get the tech boost
function Z23GetTechBoost(playerID, tech, percent)
    --get the player
    local pPlayer, value = Players[playerID], 0
    --if has player
    if pPlayer then
        --get techs
        local techs = pPlayer:GetTechs()
        if techs then
            --Calculate the data
            value = IronMath.Round(techs:GetResearchCost(tech) * percent)
        end
    end
    return value
end

--get the civic boost
function Z23GetCivicBoost(playerID, civic, percent)
    --get the player
    local pPlayer, value = Players[playerID], 0
    --if has player
    if pPlayer then
        --get techs
        local civics = pPlayer:GetCulture()
        if civics then
            --Calculate the data
            value = IronMath.Round(civics:GetCultureCost(civic) * percent)
        end
    end
    return value
end

--Clear the ability
function Z23ClearAbilities(pUnit, eAbility)
    if pUnit then
        local unitAbility = pUnit:GetAbility()
        unitAbility:ChangeAbilityCount(eAbility, -unitAbility:GetAbilityCount(eAbility))
    end
end

--||===================Events functions===================||--

function Z23TirggerTechBoost(playerID, tech)
    --is Z23?
    if IronCore.CheckLeaderMatched(playerID, 'LEADER_Z23_1936A') then
        local pPlayer, value = Players[playerID], 0
        --get the value
        value = Z23GetTechBoost(playerID, tech, Z23percent)
        --Get Science
        pPlayer:GetTechs():ChangeCurrentResearchProgress(value)
    end
end

function Z23TirggerCivicBoost(playerID, civic)
    --is Z23?
    if IronCore.CheckLeaderMatched(playerID, 'LEADER_Z23_1936A') then
        local pPlayer, value = Players[playerID], 0
        --get the value
        value = Z23GetCivicBoost(playerID, civic, Z23percent)
        --Get Culture
        pPlayer:GetCulture():ChangeCurrentCulturalProgress(value)
    end
end

--||=================GameEvents functions=================||--

--Clear the unit abilities and reduce the count
function Z23OnPlayerTurnStarted(playerID)
    --is Z23? no return
    if not IronCore.CheckLeaderMatched(playerID, 'LEADER_Z23_1936A') then
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
                    --Get the buildings in the city
                    local cityBuildings = pCity:GetBuildings()
                    -- and their buildings...
                    for row in GameInfo.Buildings() do
                        if cityBuildings:HasBuilding(row.Index) and not cityBuildings:IsPillaged(row.Index) and cityBuildings:GetBuildingLocation(row.Index) == pPlotID then
                            pCity:GetBuildings():SetPillaged(row.Index, true)
                            --Add Combat Strength
                            pUnit:SetProperty(combatProperty, pUnit:GetProperty(combatProperty) + 3)
                        end
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
    Events.TechBoostTriggered.Add(Z23TirggerTechBoost)
    Events.CivicBoostTriggered.Add(Z23TirggerCivicBoost)
    ---------------GameEvents---------------
    GameEvents.PlayerTurnStarted.Add(Z23OnPlayerTurnStarted)
    GameEvents.Z23ChangeNewMode.Add(Z23ChangeMode)
    ----------------------------------------
    print('Initial success!')
    print('Error: Z404 Not Found')
end

include('IronBloodZ23_', true)

Initialize()
