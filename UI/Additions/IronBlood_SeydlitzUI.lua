-- IronBlood_SeydlitzUI
-- Author: jjj
-- DateCreated: 2024/8/26 12:26:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||===================local variables====================||--

G_HexColoringMovement	= UILens.CreateLensLayerHash("Hex_Coloring_Movement");

--||====================base functions====================||--

--get the button's Visibility
function SeydlitzGetButtonVisibility(pUnit)
    if pUnit then
        if not IronBloodLeaderTypeMatched(pUnit:GetOwner(), 'LEADER_SEYDLITZ') then
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

--get the plot can return
function SeydlitzGetPlots(pUnit)
    local eOperation = UI.GetInterfaceModeParameter(UnitOperationTypes.PARAM_OPERATION_TYPE)
    print(eOperation)
    local tResults = UnitManager.GetOperationTargets(pUnit, eOperation)
    print(tResults[UnitOperationResults.PLOTS])
    return tResults[UnitOperationResults.PLOTS]
end

--Reset the button
function SeydlitzResetButton()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and SeydlitzGetButtonVisibility(pUnit) then
        Controls.Seydlitz_Grid:SetHide(false)
        --get the detail of the button
        -- local detail = Z23GetButtonDetail(pUnit)
        --get the disable
        local disable = false
        --Set the Button
        Controls.Seydlitz_Button:SetDisabled(disable)
        Controls.Seydlitz_Button:SetAlpha((disable and 0.4) or 1)
    else
        Controls.Seydlitz_Grid:SetHide(true)
    end
end

--When button is clicked
function SeydlitzOnButtonClicked()
    --Get the unit and set param
    local pUnit = UI.GetHeadSelectedUnit()
    local plots = SeydlitzGetPlots(pUnit)
    if plots then
        local t_plot = {}
        for i, value in ipairs(plots) do
            table.insert(t_plot, plots[i])
        end

        IronBloodPrintTable(t_plot)

        if #t_plot > 0 then
            local eLocalPlayer = Game.GetLocalPlayer();
            UILens.ToggleLayerOn(G_HexColoringMovement);
            UILens.SetLayerHexesArea(G_HexColoringMovement, eLocalPlayer, t_plot);
        end
    end
end

--||===================Events functions===================||--

--When the unit is selected
function SeydlitzOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then
        SeydlitzResetButton()
    end
end

--Add a button to Unit Panel
function SeydlitzOnLoadGameViewStateDone()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.Seydlitz_Grid:ChangeParent(pContext)
        Controls.Seydlitz_Button:RegisterCallback(Mouse.eLClick, SeydlitzOnButtonClicked)
        Controls.Seydlitz_Button:RegisterCallback(Mouse.eMouseEnter, IronBloodEnter)

        SeydlitzResetButton()
    end
end

--||======================initialize======================||--

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(SeydlitzOnLoadGameViewStateDone)
    Events.UnitSelectionChanged.Add(SeydlitzOnUnitSelectChanged)
    -- Events.UnitActivate.Add(Z23UnitActive)
    ------------------------------------------
    Events.UnitOperationSegmentComplete.Add(SeydlitzResetButton)
    Events.UnitCommandStarted.Add(SeydlitzResetButton)
    Events.UnitDamageChanged.Add(SeydlitzResetButton)
    Events.UnitMoveComplete.Add(SeydlitzResetButton)
    Events.UnitChargesChanged.Add(SeydlitzResetButton)
    Events.UnitPromoted.Add(SeydlitzResetButton)
    Events.UnitOperationsCleared.Add(SeydlitzResetButton)
    Events.UnitOperationAdded.Add(SeydlitzResetButton)
    Events.UnitOperationDeactivated.Add(SeydlitzResetButton)
    Events.UnitMovementPointsChanged.Add(SeydlitzResetButton)
    Events.UnitMovementPointsCleared.Add(SeydlitzResetButton)
    Events.UnitMovementPointsRestored.Add(SeydlitzResetButton)
    Events.UnitAbilityLost.Add(SeydlitzResetButton)
    ------------------------------------------
    Events.PhaseBegin.Add(SeydlitzResetButton)
    ------------------------------------------
    print('Initial success!')
end

Initialize()
