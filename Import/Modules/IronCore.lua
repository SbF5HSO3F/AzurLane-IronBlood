-- IronCore
-- Author: HSbF6HSO3F
-- DateCreated: 2025/7/10 22:17:03
--------------------------------------------------------------
--||=======================include========================||--
include('IronDebug')
include('IronMath')

--||======================MetaTable=======================||--
IronCore = {}

--||===================Check Functions====================||--

-- 判断领袖，玩家不为指定领袖类型则返回false (GamePlay, UI)
---- playerID          玩家ID
---- leaderType        领袖类型
function IronCore.CheckLeaderMatched(playerID, leaderType)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == leaderType
end

-- 判断文明，玩家文明不为指定文明类型则返回false (GamePlay, UI)
---- playerID          玩家ID
---- civilizationType  文明类型
function IronCore.CheckCivMatched(playerID, civilizationType)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == civilizationType
end

--||====================Is Functions======================||--

-- 检查table中是否有指定元素 (GamePlay, UI)
---- table             要检查的table
---- element           要查找的元素
function IronCore.IsInclude(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

-- 检查单位是否是军事单位 (GamePlay, UI)
---- unit              单位对象
function IronCore.IsMilitary(unit)
    if unit == nil then return false end
    local unitInfo = GameInfo.Units[unit:GetType()]
    if unitInfo == nil then return false end
    local unitFormation = unitInfo.FormationClass
    return unitFormation == 'FORMATION_CLASS_LAND_COMBAT'
        or unitFormation == 'FORMATION_CLASS_NAVAL'
        or unitFormation == 'FORMATION_CLASS_AIR'
end

--||====================Has Functions=====================||--

-- 检查科技或者市政是否拥有提升 (GamePlay, UI)
---- techOrCivic       科技或者市政类型
function IronCore.HasBoost(techOrCivic)
    for boost in GameInfo.Boosts() do
        if techOrCivic == boost.TechnologyType
            or techOrCivic == boost.CivicType then
            return true
        end
    end
    return false
end

-- 检查单位是否拥有战斗力 (GamePlay, UI)
---- unit              单位对象
function IronCore.HasStrength(unit)
    return unit and (unit:GetCombat() > 0 or unit:GetRangedCombat() > 0 or unit:GetBombardCombat() > 0)
end

--||====================Get Functions=====================||--

-- 获得玩家游戏进度。返回为百分比，需除以100 (GamePlay, UI)
---- playerID          玩家ID
function IronCore:GetPlayerProgress(playerID)
    local pPlayer = Players[playerID]
    if pPlayer == nil then return 0 end
    local playerTech = pPlayer:GetTechs()
    local techNum, techedNum = 0, 0
    for row in GameInfo.Technologies() do
        techNum = techNum + 1
        if playerTech:HasTech(row.Index) then
            techedNum = (techedNum or 0) + 1
        end
    end
    local playerCulture = pPlayer:GetCulture()
    local civicNum, civicedNum = 0, 0
    for row in GameInfo.Civics() do
        civicNum = civicNum + 1
        if playerCulture:HasCivic(row.Index) then
            civicedNum = (civicedNum or 0) + 1
        end
    end
    local civicProgress = civicNum ~= 0 and civicedNum / civicNum or 0
    local techProgress = techNum ~= 0 and techedNum / techNum or 0
    return AzurMath.Round(100 * math.max(techProgress, civicProgress))
end

-- 获取两个对象之间的距离 (GamePlay, UI)
---- object_1          对象1
---- object_2          对象2
function IronCore.GetDistance(object_1, object_2)
    local result = 0
    if object_1 and object_2 then
        result = Map.GetPlotDistance(
            object_1:GetX(), object_1:GetY(),
            object_2:GetX(), object_2:GetY()
        )
    end; return result
end

-- 获取玩家宗教，已创建宗教则返回创建的宗教，没有则返回玩家的主流宗教，否则返回-1 (GamePlay, UI)
---- playerID          玩家ID
function IronCore.GetPlayerReligion(playerID)
    local pPlayer = Players[playerID]
    if pPlayer == nil then return -1 end
    local pPlayerReligion = Players[playerID]:GetReligion()
    if pPlayerReligion == nil then return -1 end
    if pPlayerReligion:GetReligionTypeCreated() ~= -1 then
        return pPlayerReligion:GetReligionTypeCreated()
    else
        return pPlayerReligion:GetReligionInMajorityOfCities()
    end
end

-- 获取玩家的区域数量 (GamePlay, UI)
---- playerID          玩家ID
---- index             区域索引
function IronCore.GetPlayerDistrictCount(playerID, index)
    local pPlayer, count = Players[playerID], 0
    if not pPlayer then return count end
    local districts = pPlayer:GetDistricts()
    for _, district in districts:Members() do
        if district:GetType() == index and district:IsComplete() and (not district:IsPillaged()) then
            count = count + 1
        end
    end
    return count
end

-- 获取玩家建筑数量 (GamePlay, UI)
---- playerID          玩家ID
---- buildingIndex     建筑索引
---- isPillaged        被掠夺是否不计入
function IronCore.GetPlayerBuildingCount(playerID, buildingIndex, isPillaged)
    local pPlayer = Players[playerID]
    if not pPlayer then return 0 end
    local count, cities = 0, pPlayer:GetCities()
    for _, city in cities:Members() do
        local buildings = city:GetBuildings()
        if buildings then
            if buildings:HasBuilding(buildingIndex) and (not isPillaged or not buildings:IsPillaged(buildingIndex)) then
                count = count + 1
            end
        end
    end
    return count
end

-- 玩家获得随机数量的尤里卡 (GamePlay)
---- playerID          玩家ID
---- iSource           尤里卡来源
---- num               数量
function IronCore:GetRandomTechBoosts(playerID, iSource, num)
    local pPlayer = Players[playerID]
    local EraIndex = 1
    local playerTech = pPlayer:GetTechs()
    local limit = num or 1
    while limit > 0 do
        local EraType = nil
        for era in GameInfo.Eras() do
            if era.ChronologyIndex == EraIndex then
                EraType = era.EraType
                break
            end
        end
        if EraType then
            local techlist = {}
            for row in GameInfo.Technologies() do
                if not (playerTech:HasTech(row.Index) or
                        playerTech:HasBoostBeenTriggered(row.Index) or
                        not self.HasBoost(row.TechnologyType))
                    and row.EraType == EraType then
                    table.insert(techlist, row.Index)
                end
            end
            if #techlist > 0 then
                local iTech = techlist[AzurMath.GetRandNum(#techlist)]
                playerTech:TriggerBoost(iTech, iSource)
                limit = limit - 1
            else
                EraIndex = (EraIndex or 0) + 1
            end
        else
            break
        end
    end
end

--玩家获得随机数量的鼓舞 (GamePlay)
---- playerID          玩家ID
---- iSource           尤里卡来源
---- num               数量
function IronCore:GetRandomCivicBoosts(playerID, iSource, num)
    local pPlayer = Players[playerID]
    local EraIndex = 1
    local playerCulture = pPlayer:GetCulture()
    local limit = num or 1
    while limit > 0 do
        local EraType = nil
        for era in GameInfo.Eras() do
            if era.ChronologyIndex == EraIndex then
                EraType = era.EraType
                break
            end
        end
        if EraType then
            local civiclist = {}
            for row in GameInfo.Civics() do
                if not (playerCulture:HasCivic(row.Index) or
                        playerCulture:HasBoostBeenTriggered(row.Index) or
                        not self.HasBoost(row.CivicType))
                    and row.EraType == EraType then
                    table.insert(civiclist, row.Index)
                end
            end
            if #civiclist > 0 then
                local iCivic = civiclist[AzurMath.GetRandNum(#civiclist)]
                playerCulture:TriggerBoost(iCivic, iSource)
                limit = limit - 1
            else
                EraIndex = (EraIndex or 0) + 1
            end
        else
            break
        end
    end
end

--获取城市生产详细信息 (UI)
---- city              城市对象
function IronCore.GetProductionDetail(city)
    local details = { --城市生产详细信息
        --项目哈希值
        Hash       = 0,
        --城市是否进行生产
        Producting = false,
        --是否是建筑
        IsBuilding = false,
        --是否是奇观
        IsWonder   = false,
        --是否是区域
        IsDistrict = false,
        --是否是单位
        IsUnit     = false,
        --是否是项目
        IsProject  = false,
        --生产项目类型
        ItemType   = 'NONE',
        --生产项目名字
        ItemName   = 'NONE',
        --生产项目索引
        ItemIndex  = -1,
        --生产进度
        Progress   = 0,
        --生产成本
        TotalCost  = 0,
        --生产所需回合
        TurnsLeft  = 0
    }; if not city then return details end
    --获取城市生产队列，判断是否在生产
    local cityBuildQueue = city:GetBuildQueue()
    local productionHash = cityBuildQueue:GetCurrentProductionTypeHash()
    if productionHash ~= 0 then
        details.Hash       = productionHash
        details.Producting = true
        --建筑、区域、单位、项目
        local pBuildingDef = GameInfo.Buildings[productionHash]
        local pDistrictDef = GameInfo.Districts[productionHash]
        local pUnitDef     = GameInfo.Units[productionHash]
        local pProjectDef  = GameInfo.Projects[productionHash]
        --判断城市当前进行的生产
        if pBuildingDef ~= nil then
            --获取索引，方便后续获取进度和总成本
            local index = pBuildingDef.Index
            --城市正在生产建筑
            details.IsBuilding = true
            --城市生产的建筑是奇观还是普通建筑
            details.IsWonder = pBuildingDef.IsWonder
            --城市生产的建筑类型
            details.ItemType = pBuildingDef.BuildingType
            --城市生产的建筑名称
            details.ItemName = Locale.Lookup(pBuildingDef.Name)
            --城市生产的建筑索引
            details.ItemIndex = index
            --生产进度和总成本
            details.Progress = cityBuildQueue:GetBuildingProgress(index)
            details.TotalCost = cityBuildQueue:GetBuildingCost(index)
        elseif pDistrictDef ~= nil then
            --获取索引，方便后续获取进度和总成本
            local index = pDistrictDef.Index
            --城市正在生产区域
            details.IsDistrict = true
            --城市生产的区域类型
            details.ItemType = pDistrictDef.DistrictType
            --城市生产的区域名称
            details.ItemName = Locale.Lookup(pDistrictDef.Name)
            --城市生产的区域索引
            details.ItemIndex = index
            --生产进度和总成本
            details.Progress = cityBuildQueue:GetDistrictProgress(index)
            details.TotalCost = cityBuildQueue:GetDistrictCost(index)
        elseif pUnitDef ~= nil then
            --获取索引，方便后续获取进度和总成本
            local index = pUnitDef.Index
            --城市正在生产单位
            details.IsUnit = true
            --城市生产的单位类型
            details.ItemType = pUnitDef.UnitType
            --城市生产的单位名称
            details.ItemName = Locale.Lookup(pUnitDef.Name)
            --城市生产的单位索引
            details.ItemIndex = index
            --生产进度
            details.Progress = cityBuildQueue:GetUnitProgress(index)
            --获取当前单位的军事形式，计算总成本
            local formation = cityBuildQueue:GetCurrentProductionTypeModifier()
            --是标准
            if formation == MilitaryFormationTypes.STANDARD_FORMATION then
                details.TotalCost = cityBuildQueue:GetUnitCost(index)
                --是军团
            elseif formation == MilitaryFormationTypes.CORPS_FORMATION then
                details.TotalCost = cityBuildQueue:GetUnitCorpsCost(index)
                --更新单位名称
                if pUnitDef.Domain == 'DOMAIN_SEA' then
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_FLEET_SUFFIX")
                else
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_CORPS_SUFFIX")
                end
                --是军队
            elseif formation == MilitaryFormationTypes.ARMY_FORMATION then
                details.TotalCost = cityBuildQueue:GetUnitArmyCost(index)
                --更新单位名称
                if pUnitDef.Domain == 'DOMAIN_SEA' then
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_ARMADA_SUFFIX")
                else
                    details.ItemName = details.ItemName .. " " .. Locale.Lookup("LOC_UNITFLAG_ARMY_SUFFIX")
                end
            end
        elseif pProjectDef ~= nil then
            --获取索引，方便后续获取进度和总成本
            local index = pProjectDef.Index
            --城市正在生产项目
            details.IsProject = true
            --城市生产的项目类型
            details.ItemType = pProjectDef.ProjectType
            --城市生产的项目名称
            details.ItemName = Locale.Lookup(pProjectDef.Name)
            --城市生产的项目索引
            details.ItemIndex = index
            --生产进度和总成本
            details.Progress = cityBuildQueue:GetProjectProgress(index)
            details.TotalCost = cityBuildQueue:GetProjectCost(index)
        end
        --生产所需回合
        details.TurnsLeft = cityBuildQueue:GetTurnsLeft()
    end
    return details
end

--获取玩家拥有的资源数量，计算了玩家宗主的城邦所提供的资源 (GamePlay)
---- player            玩家对象
---- resourceType      资源类型
function IronCore.GetPlayerResource(player, resourceType)
    local playerID = player:GetID()
    local resourceData = player:GetResources()
    if resourceData == nil then return 0 end
    local num = resourceData:GetResourceAmount(resourceType)
    for _, minor in ipairs(PlayerManager.GetAliveMinors()) do
        local influence = minor:GetInfluence()
        if influence ~= nil and influence:GetSuzerain() == playerID then
            num = num + minor:GetResources():GetResourceAmount(resourceType)
        end
    end; return num
end

--||======================Utilities=======================||--

--比较单位，如果单位2强度高于单位1则返回true (GamePlay, UI)
---- unit1             单位1Def
---- unit2             单位2Def
function IronCore.CompareUnitDef(unit1Def, unit2Def)
    if unit1Def == nil then return true end
    if unit2Def == nil then return false end

    if unit1Def.Combat ~= unit2Def.Combat then
        return unit1Def.Combat < unit2Def.Combat
    end

    if unit1Def.RangedCombat ~= unit2Def.RangedCombat then
        return unit1Def.RangedCombat < unit2Def.RangedCombat
    end

    if unit1Def.Bombard ~= unit2Def.Bombard then
        return unit1Def.Bombard < unit2Def.Bombard
    end

    if unit1Def.Range ~= unit2Def.Range then
        return unit1Def.Range < unit2Def.Range
    end

    return unit1Def.BaseMoves < unit2Def.BaseMoves
end

--判断单元格是否可以放置指定单位 (GamePlay, UI)
---- plot              单元格
---- unitdef           单位Def
function IronCore.CanHaveUnit(plot, unitdef)
    if plot == nil then return false end
    local canHave = true
    for _, unit in ipairs(Units.GetUnitsInPlot(plot)) do
        if unit then
            local unitInfo = GameInfo.Units[unit:GetType()]
            if unitInfo then
                if unitInfo.IgnoreMoves == false then
                    if unitInfo.Domain == unitdef.Domain and unitInfo.FormationClass == unitdef.FormationClass then
                        canHave = false
                    end
                end
            end
        end
    end
    return canHave
end

--规范每回合价值显示 (GamePlay, UI)
---- value             价值
function IronCore.FormatValue(value)
    if value == 0 then
        return Locale.ToNumber(value)
    else
        return Locale.Lookup("{1: number +#,###.#;-#,###.#}", value)
    end
end

--对单位造成伤害，超出生命值则死亡 (GamePlay)
---- unit              单位对象
---- damage            伤害值
function IronCore.DamageUnit(unit, damage)
    local maxDamage = unit:GetMaxDamage()
    if (unit:GetDamage() + damage) >= maxDamage then
        unit:SetDamage(maxDamage)
        UnitManager.Kill(unit, false)
        return true
    else
        unit:ChangeDamage(damage)
        return false
    end
end

--传播宗教，以x,y为中心，向range范围内的城市施加pressure点宗教压力 (GamePlay)
---- playerID          玩家ID
---- x                 坐标x
---- y                 坐标y
---- range             范围
---- pressure          压力大小
function IronCore:SpreadReligion(playerID, x, y, range, pressure)
    local religion = self.GetPlayerReligion(playerID)
    if religion == -1 then return end
    for _, player in ipairs(Game.GetPlayers()) do
        local cities = player:GetCities()
        for _, city in cities:Members() do
            if city ~= nil and Map.GetPlotDistance(
                    x, y, city:GetX(), city:GetY()
                ) <= range then
                city:GetReligion():AddReligiousPressure(8, religion, pressure, playerID)
            end
        end
    end
end


--mouse enter the button (UI)
function IronBloodEnter()
    UI.PlaySound("Main_Menu_Mouse_Over")
end