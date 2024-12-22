-- Ophidy_IronBlood_ConfigUpdate
-- Author: HSbF6HSO3F
-- DateCreated: 2024/4/14 19:34:34
--------------------------------------------------------------
--文本更新
UPDATE Players
SET LeaderAbilityDescription = 'LOC_TRAIT_LEADER_POET_OF_REVO_SBF5_DESCRIPTION'
WHERE LeaderAbilityDescription = 'LOC_TRAIT_LEADER_POET_OF_REVO_DESCRIPTION';

--背景更新
UPDATE Players
SET PortraitBackground = 'IMG_IRON_BLOOD_BACKGROUND'
WHERE LeaderType IN ('LEADER_OP_FRIEDRICH_CCXC', 'LEADER_OP_HUTTEN_CCXC');