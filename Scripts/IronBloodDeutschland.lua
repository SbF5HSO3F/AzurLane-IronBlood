-- IronBlood_Deutschland
-- Author: HSbF6HSO3F
-- DateCreated: 2023/11/16 13:35:04
--------------------------------------------------------------
--||=======================include========================||--
include('IronCore.lua')

--||====================base functions====================||--

--Reward calculation formula
function DeutschlandRewardFormula(pCity, YieldType, baseNum)
    if pCity ~= nil then
        local cityPop = pCity:GetPopulation()
        local cityYield = pCity:GetYield(YieldType)
        --CostMultiplier
        local Reward = IronMath:ModifyBySpeed(cityPop * (2 * cityYield + baseNum))
        --[[local speedModifier = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier / 100
        local Reward = IronMath.Round(cityPop * (2 * cityYield + baseNum) * speedModifier)]]
        return Reward
    end
end

--||================GameEvents functions=================||--

--Deutschland Capture City
function DeutschlandConquerCity(newPlayerID, oldPlayerID, newCityID, iCityX, iCityY)
    --is Deutschland?
    if not IronCore.CheckLeaderMatched(newPlayerID, 'LEADER_DEUTSCHLAND_A') then
        return
    end

    local pPlayer = Players[newPlayerID]
    local pCity = CityManager.GetCityAt(iCityX, iCityY)
    if pCity ~= nil then
        pCity:ChangeLoyalty(999)
        local GetSinence = DeutschlandRewardFormula(pCity, YieldTypes.SCIENCE, 5)
        local GetCulture = DeutschlandRewardFormula(pCity, YieldTypes.CULTURE, 5)
        local GetGold = DeutschlandRewardFormula(pCity, YieldTypes.GOLD, 30)
        pPlayer:GetTechs():ChangeCurrentResearchProgress(GetSinence)
        pPlayer:GetCulture():ChangeCurrentCulturalProgress(GetCulture)
        pPlayer:GetTreasury():ChangeGoldBalance(GetGold)
        local message = nil
        if GetSinence > 0 then
            print('Science: ' .. GetSinence)
            if message == nil then
                message = Locale.Lookup('LOC_DEUTSCHLAND_ABOVE_ALL_CONQUER_SCIENCE_TEXT', GetSinence)
            else
                message = message .. ' ' .. Locale.Lookup('LOC_DEUTSCHLAND_ABOVE_ALL_CONQUER_SCIENCE_TEXT', GetSinence)
            end
        end
        if GetCulture > 0 then
            print('Culture: ' .. GetCulture)
            if message == nil then
                message = Locale.Lookup('LOC_DEUTSCHLAND_ABOVE_ALL_CONQUER_CULTURE_TEXT', GetCulture)
            else
                message = message .. ' ' .. Locale.Lookup('LOC_DEUTSCHLAND_ABOVE_ALL_CONQUER_CULTURE_TEXT', GetCulture)
            end
        end
        if GetGold > 0 then
            print('Gold: ' .. GetGold)
            if message == nil then
                message = Locale.Lookup('LOC_DEUTSCHLAND_ABOVE_ALL_CONQUER_GOLD_TEXT', GetGold)
            else
                message = message .. ' ' .. Locale.Lookup('LOC_DEUTSCHLAND_ABOVE_ALL_CONQUER_GOLD_TEXT', GetGold)
            end
        end
        if message ~= nil then
            local messageData = {
                MessageType = 0,
                MessageText = message,
                PlotX       = iCityX,
                PlotY       = iCityY,
                Visibility  = RevealedState.VISIBLE,
            }; Game.AddWorldViewText(messageData)
        end
    end
end

--||======================initialize======================||--

--initialization function
function Initialize()
    ---------------GameEvents---------------
    GameEvents.CityConquered.Add(DeutschlandConquerCity)
    ----------------------------------------
    print('Initial success!')
end

include('IronBlood_Deutschland_', true)

Initialize()
