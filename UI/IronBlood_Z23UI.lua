-- IronBlood_Z23UI
-- Author: jjj
-- DateCreated: 2023/12/28 22:57:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||====================ExposedMembers====================||--

--GameEvents
GameEvents = ExposedMembers.GameEvents

--||===================local variables====================||--

local eReason_1 = DB.MakeHash("Z23_MODE")
local TurnLast = 'Z23TurnLast'
local heal = ExposedMembers.Z23.HealNum
local turns = ExposedMembers.Z23.LastTurn

--||====================base functions====================||--

--Can See button?
function Z23CanSee(playerID, unitID)
    local pUnit = UnitManager.GetUnit(playerID, unitID)
    if pUnit then
        if not IronBloodLeaderTypeMatched(playerID, 'LEADER_Z23_1936A') then
            return false
        end
        local unitInfo = GameInfo.Units[pUnit:GetType()]
        if not unitInfo then
            return false
        end
        local unitFormation = unitInfo.FormationClass
        return unitFormation == 'FORMATION_CLASS_LAND_COMBAT' or unitFormation == 'FORMATION_CLASS_NAVAL'
    end
    return false
end

--Button is Disabled?
function Z23IsDisable(pUnit)
    --the unit isn't nil
    if pUnit == nil then
        return true
    end

    --the owner isn't nil
    local pPlayer = Players[pUnit:GetOwner()]
    if pPlayer == nil then
        return true
    end

    --last turn > 0
    if pUnit:GetProperty(TurnLast) and pUnit:GetProperty(TurnLast) > 0 then
        return true
    end

    return false
end

--Reset Button
function Z23ResetButton(pUnit)
    local disabled = Z23IsDisable(pUnit)
    --Set the button
    Controls.Z23_Button:SetDisabled(disabled)
    Controls.Z23_Button:SetAlpha((disabled and 0.4) or 1)

    local string = Locale.Lookup('LOC_UNITCOMMAND_Z23') ..
        '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_DESC', heal, turns)
    local lastTruns = pUnit:GetProperty(TurnLast)
    if lastTruns and lastTruns > 0 then
        string = string .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_LAST', lastTruns)
    end

    if disabled then
        string = string .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_DISABLE')
        --the unit isn't nil
        if pUnit == nil then
            string = string .. '[NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_NO_UNIT')
        end

        --the owner isn't nil
        local pPlayer = Players[pUnit:GetOwner()]
        if pPlayer == nil then
            string = string .. '[NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_NO_PLAYER')
        end

        --last turn > 0
        if pUnit:GetProperty(TurnLast) and pUnit:GetProperty(TurnLast) > 0 then
            string = string .. '[NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_DISABLE_LAST')
        end
    end

    Controls.Z23_Button:SetToolTipString(string)
end

--Reset the Grid
function Z23Reset(playerID)
    if not IronBloodLeaderTypeMatched(playerID, 'LEADER_Z23_1936A') then
        Controls.Z23_Grid:SetHide(true)
        return
    end
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        if Z23CanSee(pUnit:GetOwner(), pUnit:GetID()) then
            Controls.Z23_Grid:SetHide(false)
            Z23ResetButton(pUnit)
        else
            Controls.Z23_Grid:SetHide(true)
        end
    else
        Controls.Z23_Grid:SetHide(true)
    end
end

--When button is clicked
function Z23OnButtonClicked()
    --Get the unit and set param
    local pUnit, param = UI.GetHeadSelectedUnit(), {}
    --set date
    param.unitID = pUnit:GetID()
    param.heal = -heal
    param.turns = turns
    param.x = pUnit:GetX()
    param.y = pUnit:GetY()
    param.OnStart = 'Z23ChangeNewMode'
    --request operations
    UI.RequestPlayerOperation(Game.GetLocalPlayer(), PlayerOperations.EXECUTE_SCRIPT, param)
end

--||===================Events functions===================||--

--When the unit is selected
function Z23OnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected then
        Z23Reset(playerId)

        ContextPtr:RequestRefresh()
    end
end

--What will happan when unit action

--[[function Z23UnitMoveComplete(playerId, unitId, locationX, locationY)
    Z23Reset(playerId, unitId)
    print('Z23UnitMoveComplete')
end

function Z23UnitCommandStarts(playerId, unitId, hCommand, iData1)
    Z23Reset(playerId, unitId)
    print('Z23UnitCommandStarts')
end

function Z23UnitOperationSegmentComplete(playerId, unitId, hCommand, iData1)
    Z23Reset(playerId, unitId)
    print('Z23UnitOperationSegmentComplete')
end

function Z23UnitChargesChanged(playerId, unitId)
    Z23Reset(playerId, unitId)
    print('Z23UnitChargesChanged')
end

function Z23UnitDamageChanged(playerId, unitId, damage)
    Z23Reset(playerId, unitId)
    print('Z23UnitDamageChanged')
end

function Z23UnitPromotionChanged(playerId, unitId)
    Z23Reset(playerId, unitId)
    print('Z23UnitPromotionChanged')
end

function Z23UnitOperationsCleared(playerId, unitId)
    Z23Reset(playerId, unitId)
    print('Z23UnitOperationsCleared')
end

function Z23UnitOperationAdded(playerId, unitId, hOperation)
    Z23Reset(playerId, unitId)
    print('Z23UnitOperationAdded')
end

function Z23UnitOperationDeactivated(playerId, unitId, hOperation, iData1)
    Z23Reset(playerId, unitId)
    print('Z23UnitOperationDeactivated')
end

function Z23UnitMovementPointsChanged(playerId, unitId)
    Z23Reset(playerId, unitId)
    print('Z23UnitMovementPointsChanged')
end

function Z23UnitAbilityLost(playerId, unitId, eAbilityType)
    Z23Reset(playerId, unitId)
    print('Z23UnitAbilityLost')
end]]--function Z23Reset is too powerful

--New event: PhaseBegin
function Z23OnPhaseBegin()
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        if Z23CanSee(pUnit:GetOwner(), pUnit:GetID()) then
            Controls.Z23_Grid:SetHide(false)
            Z23ResetButton(pUnit)
        else
            Controls.Z23_Grid:SetHide(true)
        end
    else
        Controls.Z23_Grid:SetHide(true)
    end
end

--On Unit Active
function Z23UnitActive(owner, unitID, x, y, eReason)
    local pUnit = UnitManager.GetUnit(owner, unitID);
    if eReason == eReason_1 then
        Z23ResetButton(pUnit)
        SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
    end
end

--Add a button to Unit Panel
function Z23OnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.Z23_Grid:ChangeParent(pContext)
        Controls.Z23_Button:RegisterCallback(Mouse.eLClick, Z23OnButtonClicked)
    end
end

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(Z23OnLoadGameViewStateDone)
    Events.UnitSelectionChanged.Add(Z23OnUnitSelectChanged)
    Events.UnitActivate.Add(Z23UnitActive)
    ------------------------------------------
    Events.UnitOperationSegmentComplete.Add(Z23Reset)
    Events.UnitCommandStarted.Add(Z23Reset)
    Events.UnitDamageChanged.Add(Z23Reset)
    Events.UnitMoveComplete.Add(Z23Reset)
    Events.UnitChargesChanged.Add(Z23Reset)
    Events.UnitPromoted.Add(Z23Reset)
    Events.UnitOperationsCleared.Add(Z23Reset)
    Events.UnitOperationAdded.Add(Z23Reset)
    Events.UnitOperationDeactivated.Add(Z23Reset)
    Events.UnitMovementPointsChanged.Add(Z23Reset)
    Events.UnitMovementPointsCleared.Add(Z23Reset)
    Events.UnitMovementPointsRestored.Add(Z23Reset)
    Events.UnitAbilityLost.Add(Z23Reset)
    ------------------------------------------
    Events.PhaseBegin.Add(Z23OnPhaseBegin)
    ------------------------------------------
    print('IronBlood_Z23UI Initial success!')
end

Initialize()
