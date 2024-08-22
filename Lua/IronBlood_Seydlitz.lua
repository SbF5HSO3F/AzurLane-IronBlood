-- IronBlood_Seydlitz
-- Author: jjj
-- DateCreated: 2024/8/22 19:36:27
--------------------------------------------------------------
--||=======================include========================||--
include('IronBlood_Core.lua')

--||===================local variables====================||--

local key_A = 'UnSinkableLegendAttack'
local key_D = 'UnSinkableLegendDefend'
local maxHp = GlobalParameters.COMBAT_MAX_HIT_POINTS
local perHp = 10

--||======================initialize======================||--

--when damage change
function SeydlitzSetProperty(playerID, unitID)
    --the leader is Seydlitz?
    if IronBloodLeaderTypeMatched(playerID, 'LEADER_SEYDLITZ') then
        --get the unit
        local pUnit = UnitManager.GetUnit(playerID, unitID)
        if not pUnit then return end
        --get the unit damage
        local LoseHp = pUnit:GetDamage()
        local HaveHp = maxHp - LoseHp
        --set the key
        pUnit:SetProperty(key_A, math.floor(HaveHp / perHp))
        pUnit:SetProperty(key_D, math.floor(LoseHp / perHp))
    end
end

--initialization function
function Initialize()
    -----------------------Events-----------------------
    Events.UnitDamageChanged.Add(SeydlitzSetProperty)
    Events.UnitAddedToMap.Add(SeydlitzSetProperty)
    ---------------------GameEvents---------------------

    ----------------------------------------------------
    ----------------------------------------------------
    print('Initial success!')
end

Initialize()
