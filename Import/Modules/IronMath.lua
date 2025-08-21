-- IronMath
-- Author: HSbF6HSO3F
-- DateCreated: 2025/8/22 7:38:57
--------------------------------------------------------------
--||======================MetaTable=======================||--

-- IronMath 用于数学相关的处理
IronMath = {}

--||====================Based functions===================||--

--数字不小于其1位小数处理 (GamePlay, UI)
function IronMath.Ceil(num)
    return math.ceil(num * 10) / 10
end

--数字不大于其1位小数处理 (GamePlay, UI)
function IronMath.Floor(num)
    return math.floor(num * 10) / 10
end

-- 数字四舍五入 (GamePlay, UI)
function IronMath.Round(num)
    return math.floor((num + 0.05) * 10) / 10
end

--||====================Modify functions==================||--

-- 将输入的数字按照百分比进行修正 (GamePlay, UI)
function IronMath:ModifyByPercent(num, percent, effect)
    return self.Round(num * (effect and percent or (100 + percent)) / 100)
end

-- 将输入的数字按照当前游戏速度进行修正 (GamePlay, UI)
function IronMath:ModifyBySpeed(num)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then num = self.Round(num * gameSpeed.CostMultiplier / 100) end
    return num
end

--||====================Random functions==================||--

-- 随机数生成器，范围为[1,num] (GamePlay)
function IronMath.GetRandNum(num)
    return Game.GetRandNum and (Game.GetRandNum(num) + 1) or 1
end

-- 随机数生成器，范围为[x,y] (GamePlay)
function IronMath:GetRandom(x, y)
    y = math.max(x, y)
    if x == y then return x end
    local a = x - 1
    local n = y - a
    return self.GetRandNum(n) + a
end