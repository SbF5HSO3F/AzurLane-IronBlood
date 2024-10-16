-- IronBlood_SeydlitzGreatPresonUI
-- Author: jjj
-- DateCreated: 2024/9/16 20:37:52
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||===================local variables====================||--

local generalIndex = GameInfo.Units['UNIT_GREAT_GENERAL'].Index
local admiralIndex = GameInfo.Units['UNIT_GREAT_ADMIRAL'].Index
local eReason_1    = DB.MakeHash("SeydlitzSetUpUnit")
local key          = 'SeydlitzSetUpUnitTurns'
local lastTurns    = IronCore:ModifyBySpeed(10)
local multiplier   = GlobalParameters.GOLD_PURCHASE_MULTIPLIER * GlobalParameters.GOLD_EQUIVALENT_OTHER_YIELDS
local standardType = MilitaryFormationTypes.STANDARD_FORMATION
local corpsType    = MilitaryFormationTypes.CORPS_FORMATION
local armyType     = MilitaryFormationTypes.ARMY_FORMATION

--||====================base functions====================||--

--get button detail
function SeydlitzGetGreatPresonButtonDetail(pUnit)
    local detail = {
        Disable = true,
        Type = standardType,
        UnitID = 0,
        Name = 'NONE',
        Reward = 0,
        Points = 0,
        SetUp = false,
        Reason = 'NONE'
    }
    local Formation = pUnit:GetType() == generalIndex and 'FORMATION_CLASS_LAND_COMBAT' or 'FORMATION_CLASS_NAVAL'
    --check the unit
    if pUnit == nil then
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_NOUNIT')
        return detail
    end
    --get the turns
    local turns = pUnit:GetProperty(key) or -lastTurns
    local last  = Game.GetCurrentGameTurn() - turns
    if last < lastTurns then
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_LAST', lastTurns - last)
        return detail
    end
    --check the plot has unit
    local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
    local hasUnit = false
    local playerID = pUnit:GetOwner()
    for _, unit in ipairs(Units.GetUnitsInPlot(pPlot)) do
        if unit:GetOwner() == playerID then
            --get the unit def
            local unitDef = GameInfo.Units[unit:GetType()]
            if unitDef.FormationClass == Formation then
                local unitID = unit:GetID()
                --from corps?
                if unit:GetMilitaryFormation() == standardType then
                    hasUnit = true
                    detail.UnitID = unitID
                    detail.Name = Locale.Lookup(unit:GetName())
                    detail.Reward = IronCore:ModifyBySpeed(unitDef.Cost * multiplier)
                    detail.Points = IronCore:ModifyBySpeed(unit:GetCombat())
                    detail.Type = corpsType
                    break
                elseif unit:GetMilitaryFormation() == corpsType then
                    hasUnit = true
                    detail.UnitID = unitID
                    detail.Name = Locale.Lookup(unit:GetName())
                    detail.Reward = IronCore:ModifyBySpeed(unitDef.Cost * 2 * multiplier)
                    detail.Points = IronCore:ModifyBySpeed(unit:GetCombat())
                    detail.Type = armyType
                    break
                end
            end
        end
    end
    if not hasUnit then
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_NOTARGET')
    else
        detail.SetUp = true
        detail.Disable = false
    end
    return detail
end

--reset the great general button
function SeydlitzResetGreatPersonButton()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and IronCore.CheckLeaderMatched(
            pUnit:GetOwner(), 'LEADER_SEYDLITZ'
        ) and (
            pUnit:GetType() == generalIndex or
            pUnit:GetType() == admiralIndex
        ) then
        --get the unit type
        local unitType = pUnit:GetType()
        --show the button
        Controls.SeydlitzGreatPersonGrid:SetHide(false)
        --set the button icon
        if unitType == generalIndex then
            Controls.SeydlitzGreatPersonIcon:SetIcon('ICON_SEYDLITZ_GENERAL')
            Controls.SeydlitzGreatPersonIcon:SetOffsetX(-1)
        else
            Controls.SeydlitzGreatPersonIcon:SetIcon('ICON_SEYDLITZ_ADMIRAL')
            Controls.SeydlitzGreatPersonIcon:SetOffsetX(0)
        end
        --get the button detail
        local detail = SeydlitzGetGreatPresonButtonDetail(pUnit)
        --set the button disable
        local disable = detail.Disable
        Controls.SeydlitzGreatPersonButton:SetDisabled(disable)
        Controls.SeydlitzGreatPersonButton:SetAlpha((disable and 0.4) or 1)
        --set the button tooltip
        local tooltip = Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_TITLE')
        if detail.SetUp then
            --judge the unit from
            local fromType = detail.Type
            local unitName = detail.Name
            if fromType == armyType then
                if unitType == generalIndex then
                    unitName = unitName .. ' ' .. Locale.Lookup('LOC_HUD_UNIT_PANEL_CORPS_SUFFIX')
                else
                    unitName = unitName .. ' ' .. Locale.Lookup('LOC_HUD_UNIT_PANEL_FLEET_SUFFIX')
                end
            end
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_DETAIL', unitName, detail.Name)
            if fromType == corpsType then
                if unitType == generalIndex then
                    tooltip = tooltip .. ' ' .. Locale.Lookup('LOC_HUD_UNIT_PANEL_CORPS_SUFFIX')
                else
                    tooltip = tooltip .. ' ' .. Locale.Lookup('LOC_HUD_UNIT_PANEL_FLEET_SUFFIX')
                end
            elseif fromType == armyType then
                if unitType == generalIndex then
                    tooltip = tooltip .. ' ' .. Locale.Lookup('LOC_HUD_UNIT_PANEL_ARMY_SUFFIX')
                else
                    tooltip = tooltip .. ' ' .. Locale.Lookup('LOC_HUD_UNIT_PANEL_ARMADA_SUFFIX')
                end
            end
            if detail.Reward > 0 then
                tooltip = tooltip .. '[NEWLINE]' ..
                    Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_REWARD', detail.Reward)
            end
            if detail.Points > 0 then
                if unitType == generalIndex then
                    tooltip = tooltip .. '[NEWLINE]' ..
                        Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_GENERAL_PIONTS', detail.Points)
                else
                    tooltip = tooltip .. '[NEWLINE]' ..
                        Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_ADMIRAL_PIONTS', detail.Points)
                end
            end
        else
            if unitType == generalIndex then
                tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_GENERAL_DESC')
            else
                tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                    Locale.Lookup('LOC_UNITCOMMAND_IRON_WILLED_LEADER_ADMIRAL_DESC')
            end
        end
        if detail.Disable then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_DISABLE') .. '[NEWLINE]' .. detail.Reason
        end
        Controls.SeydlitzGreatPersonButton:SetToolTipString(tooltip)
    else
        --hide the button
        Controls.SeydlitzGreatPersonGrid:SetHide(true)
    end

    --reset the Unit Panel
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--when the great general button is clicked
function OnGreatGeneralButtonClicked()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        --get the detail
        local detail = SeydlitzGetGreatPresonButtonDetail(pUnit)
        if detail.Disable then return end
        UI.RequestPlayerOperation(Game.GetLocalPlayer(),
            PlayerOperations.EXECUTE_SCRIPT, {
                OnStart = 'SeydlitzSetUpUnit',
                UnitID = pUnit:GetID(),
                UpUnitID = detail.UnitID,
                Type = detail.Type,
                Reward = detail.Reward,
                Points = detail.Points,
            }
        )
    end
end

--||===================Events functions===================||--

--when the selection changed
function SeydlitzGreatPersonOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then
        SeydlitzResetGreatPersonButton()
    end
end

--On Unit Active
function SeydlitzUnitActive(owner, unitID, x, y, eReason)
    local pUnit = UnitManager.GetUnit(owner, unitID);
    if eReason == eReason_1 then
        SeydlitzResetGreatPersonButton()
        SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
    end
end

--Add a button to Unit Panel
function SeydlitzGreatPersonOnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.SeydlitzGreatPersonGrid:ChangeParent(pContext)
        Controls.SeydlitzGreatPersonButton:RegisterCallback(Mouse.eLClick, OnGreatGeneralButtonClicked)
        Controls.SeydlitzGreatPersonButton:RegisterCallback(Mouse.eMouseEnter, IronBloodEnter)

        SeydlitzResetGreatPersonButton()
    end
end

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(SeydlitzGreatPersonOnLoadGameViewStateDone)
    Events.UnitSelectionChanged.Add(SeydlitzGreatPersonOnUnitSelectChanged)
    Events.UnitActivate.Add(SeydlitzUnitActive)
    ------------------------------------------
    Events.UnitOperationSegmentComplete.Add(SeydlitzResetGreatPersonButton)
    Events.UnitCommandStarted.Add(SeydlitzResetGreatPersonButton)
    Events.UnitDamageChanged.Add(SeydlitzResetGreatPersonButton)
    Events.UnitMoveComplete.Add(SeydlitzResetGreatPersonButton)
    Events.UnitChargesChanged.Add(SeydlitzResetGreatPersonButton)
    Events.UnitPromoted.Add(SeydlitzResetGreatPersonButton)
    Events.UnitOperationsCleared.Add(SeydlitzResetGreatPersonButton)
    Events.UnitOperationAdded.Add(SeydlitzResetGreatPersonButton)
    Events.UnitOperationDeactivated.Add(SeydlitzResetGreatPersonButton)
    Events.UnitMovementPointsChanged.Add(SeydlitzResetGreatPersonButton)
    Events.UnitMovementPointsCleared.Add(SeydlitzResetGreatPersonButton)
    Events.UnitMovementPointsRestored.Add(SeydlitzResetGreatPersonButton)
    Events.UnitAbilityLost.Add(SeydlitzResetGreatPersonButton)
    Events.UnitFormCorps.Add(SeydlitzResetGreatPersonButton)
    Events.UnitFormArmy.Add(SeydlitzResetGreatPersonButton)
    ------------------------------------------
    Events.PhaseBegin.Add(SeydlitzResetGreatPersonButton)
    ------------------------------------------
    print('Initial success!')
end

Initialize()
