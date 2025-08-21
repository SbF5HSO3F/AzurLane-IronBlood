-- IronBlood_SeydlitzUI
-- Author: HSbF6HSO3F
-- DateCreated: 2024/8/26 12:26:33
--------------------------------------------------------------
--||=======================include========================||--
include('IronCore.lua')

--||===================local variables====================||--

local COLOR = UILens.CreateLensLayerHash("Hex_Coloring_Movement")
local m_SeydlitzSelected, m_SeydlitzPlot = false, nil


--the great person
local generalIndex = GameInfo.Units['UNIT_GREAT_GENERAL'].Index
local admiralIndex = GameInfo.Units['UNIT_GREAT_ADMIRAL'].Index
local eReason_1    = DB.MakeHash("SeydlitzSetUpUnit")
local key          = 'SeydlitzSetUpUnitTurns'
local lastTurns    = IronMath:ModifyBySpeed(10)
local multiplier   = GlobalParameters.GOLD_PURCHASE_MULTIPLIER * GlobalParameters.GOLD_EQUIVALENT_OTHER_YIELDS
local standardType = MilitaryFormationTypes.STANDARD_FORMATION
local corpsType    = MilitaryFormationTypes.CORPS_FORMATION
local armyType     = MilitaryFormationTypes.ARMY_FORMATION

--||======================MetaTable=======================||--


--the context
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
        --reset the great person button
        local show_2 = self.GreatPerson:Reset(pUnit)
        --the final show
        local show = not (show_1 or show_2)
        Controls.SeydlitzGrid:SetHide(show)
    else
        --hide the grid
        Controls.SeydlitzGrid:SetHide(true)
    end
    --reset the Unit Panel
    ContextPtr:LookUpControl("/InGame/UnitPanel"):RequestRefresh()
end

--init
function SeydlitzContext:Init()
    local context = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if context then
        --change the parent
        Controls.SeydlitzGrid:ChangeParent(context)
        --Register Callback
        self.Military:Register()
        self.GreatPerson:Register()
        --reset the button
        self:Reset()
    end
end

--||====================base functions====================||--

--military button

SeydlitzContext.Military = {}

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
    Controls.MilitaryButton:SetSelected(false)
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
    Controls.MilitaryButton:SetSelected(state)
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
        Controls.MilitaryButton:SetHide(false)
        --get the detail of the button
        local detail = self:GetDetail(pUnit)
        --get the disable
        local disable = detail.Disable
        --Set the Button
        Controls.MilitaryButton:SetDisabled(disable)
        Controls.MilitaryButton:SetAlpha((disable and 0.7) or 1)
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
        Controls.MilitaryButton:SetToolTipString(tooltip)
        return true
    else
        Controls.MilitaryButton:SetHide(true)
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
    Controls.MilitaryButton:RegisterCallback(Mouse.eLClick, function() self:Callback() end)
    Controls.MilitaryButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over") end)
end

--great preson button

SeydlitzContext.GreatPerson = {}

--get the button's Visibility
--get the button detail
function SeydlitzContext.GreatPerson.GetDetail(pUnit)
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
                    detail.Reward = IronMath:ModifyBySpeed(unitDef.Cost * multiplier)
                    detail.Points = IronMath:ModifyBySpeed(unit:GetCombat())
                    detail.Type = corpsType
                    break
                elseif unit:GetMilitaryFormation() == corpsType then
                    hasUnit = true
                    detail.UnitID = unitID
                    detail.Name = Locale.Lookup(unit:GetName())
                    detail.Reward = IronMath:ModifyBySpeed(unitDef.Cost * 2 * multiplier)
                    detail.Points = IronMath:ModifyBySpeed(unit:GetCombat())
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

--reset the button
function SeydlitzContext.GreatPerson:Reset(pUnit)
    --get the unit
    if pUnit and IronCore.CheckLeaderMatched(
            pUnit:GetOwner(), 'LEADER_SEYDLITZ'
        ) and (
            pUnit:GetType() == generalIndex or
            pUnit:GetType() == admiralIndex
        ) then
        --get the unit type
        local unitType = pUnit:GetType()
        --show the button
        Controls.GreatPersonButton:SetHide(false)
        --set the button icon
        if unitType == generalIndex then
            Controls.GreatPersonIcon:SetIcon('ICON_SEYDLITZ_GENERAL')
            Controls.GreatPersonIcon:SetOffsetX(-1)
        else
            Controls.GreatPersonIcon:SetIcon('ICON_SEYDLITZ_ADMIRAL')
            Controls.GreatPersonIcon:SetOffsetX(0)
        end
        --get the button detail
        local detail = self.GetDetail(pUnit)
        --set the button disable
        local disable = detail.Disable
        Controls.GreatPersonButton:SetDisabled(disable)
        Controls.GreatPersonButton:SetAlpha((disable and 0.7) or 1)
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
        Controls.GreatPersonButton:SetToolTipString(tooltip)
        return true
    else
        --hide the button
        Controls.GreatPersonButton:SetHide(true)
        return false
    end
end

--about the callback
function SeydlitzContext.GreatPerson:Callback()
    --get the unit
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit then
        --get the detail
        local detail = self.GetDetail(pUnit)
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
        ); Network.BroadcastPlayerInfo()
    end
end

--Register Callback
function SeydlitzContext.GreatPerson:Register()
    Controls.GreatPersonButton:RegisterCallback(Mouse.eLClick, function() self:Callback() end)
    Controls.GreatPersonButton:RegisterCallback(Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over") end)
end

--||===================Events functions===================||--


--When the unit is selected
function SeydlitzOnUnitSelectChanged(playerId, unitId, locationX, locationY, locationZ, isSelected, isEditable)
    if isSelected and playerId == Game.GetLocalPlayer() then
        SeydlitzContext:Reset()
    end
end

--On Unit Active
function SeydlitzUnitActive(owner, unitID, x, y, eReason)
    local pUnit = UnitManager.GetUnit(owner, unitID);
    if eReason == eReason_1 then
        SeydlitzContext:Reset()
        SimUnitSystem.SetAnimationState(pUnit, "SPAWN", "IDLE")
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

--reset the grid
function SeydlitzGridReset()
    SeydlitzContext:Reset()
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
            Network.BroadcastPlayerInfo()
        end
    end
end

--||======================initialize======================||--

--Initialize
function Initialize()
    Events.LoadGameViewStateDone.Add(SeydlitzOnLoadGameViewStateDone)
    Events.UnitSelectionChanged.Add(SeydlitzOnUnitSelectChanged)
    Events.UnitActivate.Add(SeydlitzUnitActive)
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
    Events.UnitFormCorps.Add(SeydlitzGridReset)
    Events.UnitFormArmy.Add(SeydlitzGridReset)
    ------------------------------------------
    Events.PhaseBegin.Add(SeydlitzGridReset)
    Events.InterfaceModeChanged.Add(SeydlitzUIModeChange)
    ------------------------------------------
    LuaEvents.WorldInput_WBSelectPlot.Add(SeydlitzSelectPlot)
    ------------------------------------------
    print('Initial success!')
end

include('IronBlood_SeydlitzUI_', true)

Initialize()
