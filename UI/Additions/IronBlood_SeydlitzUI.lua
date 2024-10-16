-- IronBlood_SeydlitzUI
-- Author: jjj
-- DateCreated: 2024/8/26 12:26:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||===================local variables====================||--

local COLOR = UILens.CreateLensLayerHash("Hex_Coloring_Movement")
local m_SeydlitzSelected, m_SeydlitzPlot = false, nil

--||======================MetaTable=======================||--

SeydlitzContext = {}

--reset all
function SeydlitzContext:Reset()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    --check the leader is Seydlitz
    if IronCore.CheckLeaderMatched(
            Game.GetLocalPlayer(), 'LEADER_SEYDLITZ'
        ) and pUnit
    then
        --reset the Military button
        local show_1 = self.Military:Reset(pUnit)
        --the final show
        local show = not show_1
        Controls.Seydlitz_Grid:SetHide(show)
    else
        --hide the grid
        Controls.Seydlitz_Grid:SetHide(true)
    end
    --reset the Unit Panel
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--init
function SeydlitzContext:Init()
    local context = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if context then
        --change the parent
        Controls.Seydlitz_Grid:ChangeParent(context)
        --Register Callback
        SeydlitzContext.Military:Register()
        --reset the button
        self:Reset()
    end
end

--||====================base functions====================||--

--military button

SeydlitzContext.Military = {
    --Button = Controls.Seydlitz_Button
}

--get the button's Visibility
function SeydlitzContext.Military.GetVisibility(pUnit)
    if pUnit then
        if not IronCore.CheckLeaderMatched(pUnit:GetOwner(), 'LEADER_SEYDLITZ') then
            return false
        end
        return IronCore.IsMilitary(pUnit)
    end
    return false
end

--get the plot can return
function SeydlitzContext.Military.GetPlots(pUnit)
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
        --get the player
        local pPlayer = Players[pUnit:GetOwner()]
        --get cities
        local cities = pPlayer and pPlayer:GetCities()
        if cities == nil then return end
        for _, city in cities:Members() do
            --get the city plot
            local plot = Map.GetPlot(city:GetX(), city:GetY())
            --add the plot index to the table
            if IronCore.CanHaveUnit(plot, unitInfo) then
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
                        if IronCore.CanHaveUnit(d_plot, unitInfo) then
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
function SeydlitzContext.Military.Quit(quit)
    if quit then
        UI.SetInterfaceMode(InterfaceModeTypes.SELECTION)
    end

    UILens.ClearLayerHexes(COLOR)
    UILens.ToggleLayerOff(COLOR)
    m_SeydlitzSelected = false
    Controls.Seydlitz_Button:SetSelected(false)
end

--set the button state
function SeydlitzContext.Military:ChangeState(state, pUnit)
    --set ui state
    if state then
        UI.SetInterfaceMode(InterfaceModeTypes.SELECTION)
        UI.SetInterfaceMode(InterfaceModeTypes.WB_SELECT_PLOT)
        local plots, hash = self.GetPlots(pUnit)
        m_SeydlitzPlot = hash
        if #plots > 0 then
            UILens.SetLayerHexesArea(COLOR, Game.GetLocalPlayer(), plots)
            UILens.ToggleLayerOn(COLOR)
        end
    else
        self.Quit(true)
    end
    --set the button selected state
    Controls.Seydlitz_Button:SetSelected(state)
end

--get the button detail
function SeydlitzContext.Military:GetDetail(pUnit)
    local detail = { Disable = true, Reason = 'NONE' }
    -- if pUnit:GetDamage() == 0 then
    --     --damage, disabled
    --     detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_NODAMAGE')
    -- else
    if pUnit:GetMovesRemaining() == 0 then
        --no movement, disabled
        detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_NOMOVEMENT')
    else
        local plots = self.GetPlots(pUnit)
        if plots and #plots > 0 then
            detail.Disable = false
        else
            --no plot, disabled
            detail.Reason = Locale.Lookup('LOC_UNITCOMMAND_UNSINKABLE_LEGEND_NOPLOT')
        end
    end
    --end

    --return the button detail
    return detail
end

--Reset the button
function SeydlitzContext.Military:Reset(pUnit)
    --check the button visibility
    if pUnit and self.GetVisibility(pUnit) then
        Controls.Seydlitz_Button:SetHide(false)
        --get the detail of the button
        local detail = self:GetDetail(pUnit)
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
            self.Quit(false)
        end
        --set the tooltip
        Controls.Seydlitz_Button:SetToolTipString(tooltip)
        return true
    else
        Controls.Seydlitz_Button:SetHide(true)
        return false
    end
end

--When button is clicked
function SeydlitzContext.Military:Callback()
    --Get the unit and set param
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        --Switched Selected State
        m_SeydlitzSelected = not m_SeydlitzSelected
        --set the button state
        self:ChangeState(m_SeydlitzSelected, pUnit)
    end
end

--Register Callback
function SeydlitzContext.Military:Register()
    Controls.Seydlitz_Button:RegisterCallback(Mouse.eLClick, function() self:Callback() end)
    Controls.Seydlitz_Button:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over") end)
end

--||===================Events functions===================||--

--reset the grid
function SeydlitzGridReset()
    SeydlitzContext:Reset()
end

--When the unit is selected
function SeydlitzOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then
        SeydlitzGridReset()
    end
end

--On ui mode change
function SeydlitzUIModeChange(intPara, currentInterfaceMode)
    if m_SeydlitzSelected and currentInterfaceMode ~= InterfaceModeTypes.WB_SELECT_PLOT then
        SeydlitzContext.Military.Quit(false)
    end
end

--Add a button to Unit Panel
function SeydlitzOnLoadGameViewStateDone()
    SeydlitzContext:Init()
end

--||=================LuaEvents functions==================||--

--On selected plot
function SeydlitzSelectPlot(plotID, edge, lbutton, rbutton)
    if lbutton then return end
    if rbutton then
        SeydlitzContext.Military.Quit(true)
    else
        local pUnit = UI.GetHeadSelectedUnit()
        if pUnit and m_SeydlitzPlot and m_SeydlitzPlot[plotID] == 1 then
            SeydlitzContext.Military.Quit(true)
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

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(SeydlitzOnLoadGameViewStateDone)
    Events.UnitSelectionChanged.Add(SeydlitzOnUnitSelectChanged)
    -- Events.UnitActivate.Add(Z23UnitActive)
    ------------------------------------------
    Events.UnitOperationSegmentComplete.Add(SeydlitzGridReset)
    Events.UnitCommandStarted.Add(SeydlitzGridReset)
    Events.UnitDamageChanged.Add(SeydlitzGridReset)
    Events.UnitMoveComplete.Add(SeydlitzGridReset)
    Events.UnitChargesChanged.Add(SeydlitzGridReset)
    Events.UnitPromoted.Add(SeydlitzGridReset)
    Events.UnitOperationsCleared.Add(SeydlitzGridReset)
    Events.UnitOperationAdded.Add(SeydlitzGridReset)
    Events.UnitOperationDeactivated.Add(SeydlitzGridReset)
    Events.UnitMovementPointsChanged.Add(SeydlitzGridReset)
    Events.UnitMovementPointsCleared.Add(SeydlitzGridReset)
    Events.UnitMovementPointsRestored.Add(SeydlitzGridReset)
    Events.UnitAbilityLost.Add(SeydlitzGridReset)
    ------------------------------------------
    Events.PhaseBegin.Add(SeydlitzGridReset)
    Events.InterfaceModeChanged.Add(SeydlitzUIModeChange)
    ------------------------------------------
    LuaEvents.WorldInput_WBSelectPlot.Add(SeydlitzSelectPlot)
    ------------------------------------------
    print('Initial success!')
end

Initialize()
