-- Z23UnitPanel
-- Author: HSbF6HSO3F
-- DateCreated: 2023/12/28 22:57:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronCore.lua')

--||====================ExposedMembers====================||--

--||===================local variables====================||--

local eReason_1 = DB.MakeHash("Z23_MODE")
local TurnLast = 'Z23TurnLast'
local heal = ExposedMembers.Z23.HealNum
local turns = ExposedMembers.Z23.LastTurn

--||======================MetaTable=======================||--

Z23UnitPanel = {}

--||====================base functions====================||--

--get the button's Visibility
function Z23UnitPanel.GetVisibility(pUnit)
    if pUnit then
        if not IronCore.CheckLeaderMatched(
                pUnit:GetOwner(), 'LEADER_Z23_1936A'
            ) then
            return false
        end
        return IronCore.IsMilitary(pUnit)
    end
    return false
end

--Get the Button's Detail
function Z23UnitPanel.GetDetail(pUnit)
    --set the detail
    local detail = { Disable = false, Reason = 'NONE' }
    --the unit isn't nil
    if pUnit == nil then
        detail.Disable = true
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_Z23_NO_UNIT')
        return detail
    end

    --the owner isn't nil
    if Players[pUnit:GetOwner()] == nil then
        detail.Disable = true
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_Z23_NO_PLAYER')
        return detail
    end

    --last turn > 0
    if pUnit:GetProperty(TurnLast) and pUnit:GetProperty(TurnLast) > 0 then
        detail.Disable = true
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_Z23_DISABLE_LAST')
        return detail
    end

    return detail
end

--Reset Button
function Z23UnitPanel:Refresh()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and self.GetVisibility(pUnit) then
        Controls.Z23Grid:SetHide(false)
        --get the detail of the button
        local detail = self.GetDetail(pUnit)
        --get the disable
        local disable = detail.Disable
        --Set the Button
        Controls.DestructionButton:SetDisabled(disable)
        Controls.DestructionButton:SetAlpha((disable and 0.7) or 1)

        local string = Locale.Lookup('LOC_UNITCOMMAND_Z23') ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_DESC', heal, turns)
        local lastturns = pUnit:GetProperty(TurnLast)
        if lastturns and lastturns > 0 then
            string = string .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_Z23_LAST', lastturns)
        end

        if disable then
            string = string .. '[NEWLINE][NEWLINE]' .. detail.Reason
        end

        Controls.DestructionButton:SetToolTipString(string)
    else
        Controls.Z23Grid:SetHide(true)
    end

    --reset the Unit Panel
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--When button is clicked
function Z23UnitPanel:Callback()
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
    Network.BroadcastPlayerInfo()
end

-- Resigter the function to the button
function Z23UnitPanel:Register()
    Controls.DestructionButton:RegisterCallback(Mouse.eLClick, function() self:Callback() end)
    Controls.DestructionButton:RegisterCallback(Mouse.eMouseEnter, IronBloodEnter)
end

-- Initialize the button
function Z23UnitPanel:Init()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.Z23Grid:ChangeParent(pContext)
        self:Register(); self:Refresh()
    end
end

--||===================Events functions===================||--

-- Refresh the button
function Z23Refresh()
    Z23UnitPanel:Refresh()
end

-- Add the button to the Unit Panel
function Z23AddButton()
    Z23UnitPanel:Init()
end

-- When the unit is selected
function Z23UnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then Z23UnitPanel:Refresh() end
end

-- On Unit Active
function Z23UnitActive(owner, unitID, x, y, eReason)
    local pUnit = UnitManager.GetUnit(owner, unitID);
    if eReason == eReason_1 then
        Z23UnitPanel:Refresh()
        SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
    end
end

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(Z23AddButton)
    Events.UnitSelectionChanged.Add(Z23UnitSelectChanged)
    Events.UnitActivate.Add(Z23UnitActive)
    ------------------------------------------
    Events.UnitOperationSegmentComplete.Add(Z23Refresh)
    Events.UnitCommandStarted.Add(Z23Refresh)
    Events.UnitDamageChanged.Add(Z23Refresh)
    Events.UnitMoveComplete.Add(Z23Refresh)
    Events.UnitChargesChanged.Add(Z23Refresh)
    Events.UnitPromoted.Add(Z23Refresh)
    Events.UnitOperationsCleared.Add(Z23Refresh)
    Events.UnitOperationAdded.Add(Z23Refresh)
    Events.UnitOperationDeactivated.Add(Z23Refresh)
    Events.UnitMovementPointsChanged.Add(Z23Refresh)
    Events.UnitMovementPointsCleared.Add(Z23Refresh)
    Events.UnitMovementPointsRestored.Add(Z23Refresh)
    Events.UnitAbilityLost.Add(Z23Refresh)
    ------------------------------------------
    Events.PhaseBegin.Add(Z23Refresh)
    ------------------------------------------
    print('Initial success!')
end

include('Z23UnitPanel_', true)

Initialize()
