-- IronBlood_SeydlitzUI
-- Author: jjj
-- DateCreated: 2024/8/26 12:26:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||===================local variables====================||--

local COLOR = UILens.CreateLensLayerHash("Hex_Coloring_Movement")
local m_SeydlitzSelected, m_SeydlitzPlot = false, nil

--||====================base functions====================||--

--judge the plot can place unit
function SeydlitzPlotCanHasUnits(pPlot, unitFormation)
    if pPlot == nil then return false end
    --loop
    for _, unit in ipairs(Units.GetUnitsInPlot(pPlot)) do
        if unit ~= nil then
            local unitInfo = GameInfo.Units[unit:GetType()]
            --has the unit, return false
            if unitInfo and unitInfo.FormationClass == unitFormation then
                return false
            end
        end
    end
    return true
end

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
        return unitFormation == 'FORMATION_CLASS_LAND_COMBAT'
            or unitFormation == 'FORMATION_CLASS_NAVAL'
            or unitFormation == 'FORMATION_CLASS_AIR'
    end
    return false
end

--get the plot can return
function SeydlitzGetPlots(pUnit)
    -- UIManager:SetUICursor(CursorTypes.RANGE_ATTACK)
    -- local eOperation = 509098169--UI.GetInterfaceModeParameter(UnitOperationTypes.PARAM_OPERATION_TYPE)
    -- print(eOperation)
    -- local tResults = UnitManager.GetOperationTargets(pUnit, eOperation)
    -- print(tResults[UnitOperationResults.PLOTS])
    -- return tResults[UnitOperationResults.PLOTS]
    -- I love Firaxis Games, fuck you

    --the plots
    local plots, hash = {}, {}
    --get the unit Domain
    local unitInfo = GameInfo.Units[pUnit:GetType()]
    if unitInfo then
        local domain = unitInfo.Domain
        local unitFormation = unitInfo.FormationClass
        --get the player
        local pPlayer = Players[pUnit:GetOwner()]
        --get cities
        local cities = pPlayer and pPlayer:GetCities()
        if cities == nil then return end
        for _, city in cities:Members() do
            --get the city plot
            local plot = Map.GetPlot(city:GetX(), city:GetY())
            --add the plot index to the table
            if SeydlitzPlotCanHasUnits(plot, unitFormation) then
                --if the unit domain is sea
                if domain == 'DOMAIN_SEA' then
                    if plot:IsAdjacentToShallowWater() then
                        table.insert(plots, plot:GetIndex())
                        hash[plot:GetIndex()] = 1
                    end
                else
                    table.insert(plots, plot:GetIndex())
                    hash[plot:GetIndex()] = 1
                end
            end
            --get the city districts
            local cityDistricts = city:GetDistricts()
            if not cityDistricts then return end
            for _, district in cityDistricts:Members() do
                if district:IsComplete() and not district:IsPillaged() then
                    --get the district info
                    local districtInfo = GameInfo.Districts[district:GetType()]
                    if districtInfo and districtInfo.MilitaryDomain == domain then
                        --get the district plot
                        local d_plot = Map.GetPlot(district:GetX(), district:GetY())
                        if SeydlitzPlotCanHasUnits(d_plot, unitFormation) then
                            table.insert(plots, d_plot:GetIndex())
                            hash[d_plot:GetIndex()] = 1
                        end
                    end
                end
            end
        end
    end
    --return the plots
    return plots, hash
end

--quit the reback mode
function SeydlitzQuitSelectMode(quit)
    if quit then
        UI.SetInterfaceMode(InterfaceModeTypes.SELECTION)
    end

    UILens.ClearLayerHexes(COLOR)
    UILens.ToggleLayerOff(COLOR)
    m_SeydlitzSelected = false
    Controls.Seydlitz_Button:SetSelected(false)
end

--set the button state
function SeydlitzSetButtonState(state, pUnit)
    --set ui state
    if state then
        UI.SetInterfaceMode(InterfaceModeTypes.SELECTION)
        UI.SetInterfaceMode(InterfaceModeTypes.WB_SELECT_PLOT)
        local plots, hash = SeydlitzGetPlots(pUnit)
        m_SeydlitzPlot = hash
        if #plots > 0 then
            UILens.SetLayerHexesArea(COLOR, Game.GetLocalPlayer(), plots)
            UILens.ToggleLayerOn(COLOR)
        end
    else
        SeydlitzQuitSelectMode(true)
    end
    --set the button selected state
    Controls.Seydlitz_Button:SetSelected(state)
end

--get the button detail
function SeydlitzGetButtonDetail(pUnit)
    local detail = { Disable = true, Reason = 'NONE' }
    if pUnit:GetDamage() == 0 then
        --damage, disabled
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_NODAMAGE')
    else
        if pUnit:GetMovesRemaining() == 0 then
            --no movement, disabled
            detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_NOMOVEMENT')
        else
            local plots = SeydlitzGetPlots(pUnit)
            if plots then
                detail.Disable = false
            else
                --no plot, disabled
                detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_NOPLOT')
            end
        end
    end

    --return the button detail
    return detail
end

--Reset the button
function SeydlitzResetButton()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit and SeydlitzGetButtonVisibility(pUnit) then
        Controls.Seydlitz_Grid:SetHide(false)
        --get the detail of the button
        local detail = SeydlitzGetButtonDetail(pUnit)
        --get the disable
        local disable = detail.Disable
        --Set the Button
        Controls.Seydlitz_Button:SetDisabled(disable)
        Controls.Seydlitz_Button:SetAlpha((disable and 0.4) or 1)
        --the tooltip
        local tooltip = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_TITLE') ..
            '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_DESC')
        if disable then
            tooltip = tooltip .. '[NEWLINE][NEWLINE]' ..
                Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_DISABLE') ..
                '[NEWLINE]' .. detail.Reason
            --quit the mode
            SeydlitzQuitSelectMode(false)
        end
        --set the tooltip
        Controls.Seydlitz_Button:SetToolTipString(tooltip)
    else
        Controls.Seydlitz_Grid:SetHide(true)
    end

    --reset the Unit Panel
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--When button is clicked
function SeydlitzOnButtonClicked()
    --Get the unit and set param
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        --Switched Selected State
        m_SeydlitzSelected = not m_SeydlitzSelected
        --set the button state
        SeydlitzSetButtonState(m_SeydlitzSelected, pUnit)
    end
end

--||===================Events functions===================||--

--When the unit is selected
function SeydlitzOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then
        SeydlitzResetButton()
    end
end

--On ui mode change
function SeydlitzUIModeChange(intPara, currentInterfaceMode)
    if m_SeydlitzSelected and currentInterfaceMode ~= InterfaceModeTypes.WB_SELECT_PLOT then
        SeydlitzQuitSelectMode(false)
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

--||=================LuaEvents functions==================||--

--On selected plot
function SeydlitzSelectPlot(plotID, edge, lbutton, rbutton)
    if not lbutton then
        if rbutton then
            SeydlitzQuitSelectMode(true)
        else
            local pUnit = UI.GetHeadSelectedUnit()
            if pUnit and m_SeydlitzPlot and m_SeydlitzPlot[plotID] == 1 then
                SeydlitzQuitSelectMode(true)
                UI.RequestPlayerOperation(Game.GetLocalPlayer(),
                    PlayerOperations.EXECUTE_SCRIPT, {
                        OnStart = 'SeydlitzRePlaceUnit',
                        unitID = pUnit:GetID(),
                        x = Map.GetPlotByIndex(plotID):GetX(),
                        y = Map.GetPlotByIndex(plotID):GetY(),
                    }
                ); m_SeydlitzPlot = nil; UI.PlaySound("Unit_CondemnHeretic_2D")
            end
        end
    end
end

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
    Events.InterfaceModeChanged.Add(SeydlitzUIModeChange)
    ------------------------------------------
    LuaEvents.WorldInput_WBSelectPlot.Add(SeydlitzSelectPlot)
    ------------------------------------------
    print('Initial success!')
end

Initialize()
