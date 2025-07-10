-- Ophidy_IronBlood_Hutten
-- Author: HSbF6HSO3F
-- DateCreated: 2024/4/14 20:25:47
--------------------------------------------------------------
--||=======================include========================||--
include('IronBloodCore.lua')

--||===================local variables====================||--

local key_1 = 'HuttenDistrictComplete'
local key_2 = 'HuttenDistrictCounter'
local key_3 = 'HuttenGrantSlotCounter'
local modifierTable = {
    'MODFEAT_HUTTEN_GOV_SLOT_DIPLOMATIC',
    'MODFEAT_HUTTEN_GOV_SLOT_WILDCARD',
    'MODFEAT_HUTTEN_GOV_SLOT_MILITARY',
    'MODFEAT_HUTTEN_GOV_SLOT_ECONOMIC',
}

--||===================Events functions===================||--

--Districts complete
function HuttenOnDistrictComplete(playerID, districtID, cityID, iX, iY, districtType, era, civilization, percentComplete)
    --check the leader is Hutten
    if IronCore.CheckLeaderMatched(playerID, 'LEADER_OP_HUTTEN') or
        IronCore.CheckLeaderMatched(playerID, 'LEADER_OP_HUTTEN_CCXC') then
        --get the player
        local pPlayer = Players[playerID]
        --get the district
        local pDistrict = pPlayer and pPlayer:GetDistricts():FindID(districtID)
        if pDistrict and pDistrict:GetProperty(key_1) ~= true and percentComplete == 100 then
            --get the leader property
            local districtCounter = pPlayer:GetProperty(key_2) or 0
            local grantSlotCounter = pPlayer:GetProperty(key_3) or 0
            --calculate the property
            districtCounter = (districtCounter or 0) + 1
            local fourNum = districtCounter % 4
            if fourNum == 0 then
                grantSlotCounter = (grantSlotCounter or 0) + 1
                --get the slot gain
                local modifier = modifierTable[(grantSlotCounter % 4) + 1]
                --attach modifier
                pPlayer:AttachModifierByID(modifier)
                --set the property
                pPlayer:SetProperty(key_3, grantSlotCounter)
                --get the player culture
                local playerCulture = pPlayer:GetCulture()
                if playerCulture == nil then return end
                --get the enact policies
                local slotNum, policies = playerCulture:GetNumPolicySlots(), {}
                --begin loop
                for i = 0, slotNum - 1, 1 do
                    local slotPolicy = playerCulture:GetSlotPolicy(i)
                    if slotPolicy ~= -1 then
                        local policyType = GameInfo.Policies[slotPolicy].PolicyType
                        table.insert(policies, policyType)
                    end
                end
                --attach the modifier, again
                for _, policy in ipairs(policies) do
                    for policyModifier in GameInfo.PolicyModifiers() do
                        if policyModifier.PolicyType == policy then
                            pPlayer:AttachModifierByID(policyModifier.ModifierId)
                        end
                    end
                end
            end
            --set the property
            pDistrict:SetProperty(key_1, true)
            pPlayer:SetProperty(key_2, districtCounter)
        end
    end
end

--||======================initialize======================||--

--Initialize
function Initialize()
    -------------------Events-------------------
    Events.DistrictBuildProgressChanged.Add(HuttenOnDistrictComplete)
    --------------------------------------------
    print('Initial success!')
end

include('Ophidy_IronBlood_Hutten_', true)

Initialize()
