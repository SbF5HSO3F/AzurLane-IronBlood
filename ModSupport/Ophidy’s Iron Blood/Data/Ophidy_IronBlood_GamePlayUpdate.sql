-- Ophidy_IronBlood_GamePlayUpdate
-- Author: jjj
-- DateCreated: 2024/4/14 20:02:02
--------------------------------------------------------------
--更新首都
UPDATE CivilizationLeaders
SET CapitalName = 'LOC_CITY_NAME_IRON_BLOOD_18'
WHERE LeaderType = 'LEADER_OP_FRIEDRICH_CCXC';

UPDATE CivilizationLeaders
SET CapitalName = 'LOC_CITY_NAME_IRON_BLOOD_7'
WHERE LeaderType = 'LEADER_OP_HUTTEN_CCXC';

--更新文本
UPDATE Traits
SET Description = 'LOC_TRAIT_LEADER_POET_OF_REVO_SBF5_DESCRIPTION'
WHERE TraitType = 'TRAIT_LEADER_POET_OF_REVO';

--更新加载界面和外交界面
UPDATE LoadingInfo
SET BackgroundImage = 'IMG_IRON_BLOOD_LOADING_BACKGROUND'
WHERE LeaderType IN ('LEADER_OP_FRIEDRICH_CCXC', 'LEADER_OP_HUTTEN_CCXC');

INSERT INTO DiplomacyInfo
    (Type,				        BackgroundImage)
VALUES
    ('LEADER_OP_FRIEDRICH_CCXC','IMG_IRON_BLOOD_DIPLOMACY_BACKGROUND.dds'),
    ('LEADER_OP_HUTTEN_CCXC',	'IMG_IRON_BLOOD_DIPLOMACY_BACKGROUND.dds');

--删除特质拥有的modifier
DELETE FROM TraitModifiers
WHERE TraitType = 'TRAIT_LEADER_POET_OF_REVO'
    AND ModifierId IN (
        'MODFEAT_HUTTEN_GOV_SLOT_MILITARY',
        'MODFEAT_HUTTEN_GOV_SLOT_ECONOMIC',
        'MODFEAT_HUTTEN_GOV_SLOT_DIPLOMATIC',
        'MODFEAT_HUTTEN_GOV_SLOT_WILDCARD'
    );

--删除Modifer的req
UPDATE Modifiers
SET SubjectRequirementSetId = NULL
WHERE ModifierId IN (
        'MODFEAT_HUTTEN_GOV_SLOT_MILITARY',
        'MODFEAT_HUTTEN_GOV_SLOT_ECONOMIC',
        'MODFEAT_HUTTEN_GOV_SLOT_DIPLOMATIC',
        'MODFEAT_HUTTEN_GOV_SLOT_WILDCARD'
    );