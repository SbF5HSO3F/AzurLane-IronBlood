-- IronBlood_Leader_Z46
-- Author: HSbF6HSO3F
-- DateCreated: 2023/10/14 17:34:43
--------------------------------------------------------------
CREATE TEMPORARY TABLE temp_Z46_Table (
     ModifierId TEXT,
     DistrictType TEXT
);

INSERT INTO temp_Z46_Table
		(ModifierId,						DistrictType)
SELECT	'Z46_ADD_CULTURE_' || DistrictType,	DistrictType
FROM Districts WHERE DistrictType NOT IN (SELECT CivUniqueDistrictType FROM DistrictReplaces);

INSERT INTO TraitModifiers
		(TraitType,								ModifierId)
SELECT	'TRAIT_LEADER_THE_GIRL_PURSUING_NAME',	ModifierId
FROM temp_Z46_Table;

INSERT INTO Modifiers
		(ModifierId,ModifierType)
SELECT	ModifierId,	'MODIFIER_PLAYER_CITIES_DISTRICT_ADJACENCY'
FROM temp_Z46_Table;

INSERT INTO ModifierArguments
		(ModifierId,	Name,			Value)
SELECT	ModifierId,		'Amount',		1
FROM temp_Z46_Table;
UNION ALL
SELECT	ModifierId,		'Description',	'LOC_Z46_Culture_Adjacency_From_District'
FROM temp_Z46_Table;
UNION ALL
SELECT	ModifierId,		'DistrictType',	DistrictType
FROM temp_Z46_Table;
UNION ALL
SELECT	ModifierId,		'TilesRequired',1
FROM temp_Z46_Table;
UNION ALL
SELECT	ModifierId,		'YieldType',	'YIELD_CULTURE'
FROM temp_Z46_Table;