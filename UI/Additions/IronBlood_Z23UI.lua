-- IronBlood_Z23UI
-- Author: jjj
-- DateCreated: 2023/12/28 22:57:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||====================ExposedMembers====================||--

--||===================local variables====================||--

local eReason_1 = DB.MakeHash("Z23_MODE")
local TurnLast = 'Z23TurnLast'
local heal = ExposedMembers.Z23.HealNum
local turns = ExposedMembers.Z23.LastTurn

--||====================base functions====================||--

--get the button's Visibility
function Z23GetButtonVisibility(playerID, unitID)
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

--Get the Button's Detail
function Z23GetButtonDetail(pUnit)
    --set the detail
    local detail = { Disable = false, Reason = 'NONE' }
    --set the Reason
    detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_Z23_DISABLE')
    --the unit isn't nil
    if pUnit == nil then
        detail.Disable = true
        detail.Reason = detail.Reason ..
            '[NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_NO_UNIT')
    end

    --the owner isn't nil
    if Players[pUnit:GetOwner()] == nil then
        detail.Disable = true
        detail.Reason = detail.Reason .. '[NEWLINE]'
            .. Locale.Lookup('LOC_UNITCOMMAND_Z23_NO_PLAYER')
    end

    --last turn > 0
    if pUnit:GetProperty(TurnLast) and pUnit:GetProperty(TurnLast) > 0 then
        detail.Disable = true
        detail.Reason = detail.Reason .. '[NEWLINE]'
            .. Locale.Lookup('LOC_UNITCOMMAND_Z23_DISABLE_LAST')
    end

    return detail
end

--Reset Button
function Z23ResetButton()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and Z23GetButtonVisibility(
            pUnit:GetOwner(), pUnit:GetID()
        ) then
        Controls.Z23_Grid:SetHide(false)
        --get the detail of the button
        local detail = Z23GetButtonDetail(pUnit)
        --get the disable
        local disable = detail.Disable
        --Set the Button
        Controls.Z23_Button:SetDisabled(disable)
        Controls.Z23_Button:SetAlpha((disable and 0.4) or 1)

        local string = Locale.Lookup('LOC_UNITCOMMAND_Z23') ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_DESC', heal, turns)
        local lastTruns = pUnit:GetProperty(TurnLast)
        if lastTruns and lastTruns > 0 then
            string = string .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_LAST', lastTruns)
        end

        if disable then
            string = string .. '[NEWLINE][NEWLINE]' .. detail.Reason
        end

        Controls.Z23_Button:SetToolTipString(string)
    else
        Controls.Z23_Grid:SetHide(true)
    end

    --reset the Unit Panel
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--When button is clicked
function Z23OnButtonClicked()
    --Get the unit and set param
    local pUnit = UI.GetHeadSelectedUnit()
    --request operations
    UI.RequestPlayerOperation(Game.GetLocalPlayer(),
        PlayerOperations.EXECUTE_SCRIPT, {
            unitID = pUnit:GetID(),
            heal = -heal,
            turns = turns,
            x = pUnit:GetX(),
            y = pUnit:GetY(),
            OnStart = 'Z23ChangeNewMode',
        }
    ); UI.PlaySound("Unit_CondemnHeretic_2D")
end

--||===================Events functions===================||--

--When the unit is selected
function Z23OnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then
        Z23ResetButton()
    end
end

--On Unit Active
function Z23UnitActive(owner, unitID, x, y, eReason)
    local pUnit = UnitManager.GetUnit(owner, unitID);
    if eReason == eReason_1 then
        Z23ResetButton()
        SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
    end
end

--Add a button to Unit Panel
function Z23OnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.Z23_Grid:ChangeParent(pContext)
        Controls.Z23_Button:RegisterCallback(Mouse.eLClick, Z23OnButtonClicked)
        Controls.Z23_Button:RegisterCallback(Mouse.eMouseEnter, IronBloodEnter)

        Z23ResetButton()
    end
end

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(Z23OnLoadGameViewStateDone)
    Events.UnitSelectionChanged.Add(Z23OnUnitSelectChanged)
    Events.UnitActivate.Add(Z23UnitActive)
    ------------------------------------------
    Events.UnitOperationSegmentComplete.Add(Z23ResetButton)
    Events.UnitCommandStarted.Add(Z23ResetButton)
    Events.UnitDamageChanged.Add(Z23ResetButton)
    Events.UnitMoveComplete.Add(Z23ResetButton)
    Events.UnitChargesChanged.Add(Z23ResetButton)
    Events.UnitPromoted.Add(Z23ResetButton)
    Events.UnitOperationsCleared.Add(Z23ResetButton)
    Events.UnitOperationAdded.Add(Z23ResetButton)
    Events.UnitOperationDeactivated.Add(Z23ResetButton)
    Events.UnitMovementPointsChanged.Add(Z23ResetButton)
    Events.UnitMovementPointsCleared.Add(Z23ResetButton)
    Events.UnitMovementPointsRestored.Add(Z23ResetButton)
    Events.UnitAbilityLost.Add(Z23ResetButton)
    ------------------------------------------
    Events.PhaseBegin.Add(Z23ResetButton)
    ------------------------------------------
    print('Initial success!')
end

Initialize()
