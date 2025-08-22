-- IronBlood_U96
-- Author: HSbF6HSO3F
-- DateCreated: 2024/4/13 23:43:35
--------------------------------------------------------------
--||=======================include========================||--
include('IronCore.lua')

--||===================local variables====================||--

local key_1 = 'U96Pillaged'

--||=================GameEvents functions=================||--

--Unit On Piliaged
function U96Pillaged(unitPlayerID, unitID)
    --check the leader is the U-96
    if IronCore.CheckLeaderMatched(unitPlayerID, 'LEADER_U_96_VIIC') then
        --get the unit
        local pUnit = UnitManager.GetUnit(unitPlayerID, unitID)
        if pUnit == nil then return end
        --add the unit movement
        UnitManager.ChangeMovesRemaining(pUnit, 1)
        --add the combat
        local combat = pUnit:GetProperty(key_1) or 0
        pUnit:SetProperty(key_1, (combat or 0) + 3)
    end
end

--when the U-96 turns begin
function U96TurnStarted(playerID)
    --check the leader is the U-96
    if IronCore.CheckLeaderMatched(playerID, 'LEADER_U_96_VIIC') then
        --get the player
        local pPlayer = Players[playerID]
        --begin the loop about the unit
        for _, unit in pPlayer:GetUnits():Members() do
            --clear the property
            unit:SetProperty(key_1, 0)
        end
    end
end

--||======================initialize======================||--

function Initialize()
    --------------------------Events--------------------------

    ------------------------GameEvents------------------------
    GameEvents.OnPillage.Add(U96Pillaged)
    GameEvents.PlayerTurnStarted.Add(U96TurnStarted)
    ----------------------------------------------------------
    print('Initial success!')
end

include('IronBloodU96_', true)

Initialize()
