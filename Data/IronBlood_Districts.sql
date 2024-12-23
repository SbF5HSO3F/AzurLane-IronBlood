-- IronBlood_Buildings
-- Author: HSbF6HSO3F
-- DateCreated: 2023/11/14 15:13:47
--------------------------------------------------------------
CREATE TEMPORARY TABLE temp_Krupp_Table (
     ModifierId_Gold TEXT,
     ModifierId_Science TEXT,
     BuildingType TEXT
);

INSERT INTO temp_Krupp_Table
	(ModifierId_Gold,												ModifierId_Science,													BuildingType)
SELECT
	'KRUPP_ADD_' || REPLACE(BuildingType,'BUILDING_','') || '_GLOD','KRUPP_ADD_' || REPLACE(BuildingType,'BUILDING_','') || '_SINENCE',	BuildingType
FROM Buildings WHERE PrereqDistrict = 'DISTRICT_ENCAMPMENT' AND BuildingType NOT IN (SELECT CivUniqueBuildingType FROM BuildingReplaces);

--Building Add Gold
INSERT INTO DistrictModifiers
	(DistrictType,		ModifierId)
SELECT
	'DISTRICT_KRUPP',	ModifierId_Gold
FROM temp_Krupp_Table;

INSERT INTO Modifiers
	(ModifierId,    	ModifierType)
SELECT
	ModifierId_Gold,	'MODIFIER_IRON_BLOOD_SINGLE_CITY_ADJUST_BUILDING_YIELD_CHANGE'
FROM temp_Krupp_Table;

INSERT INTO ModifierArguments
	(ModifierId,	Name,			Value)
SELECT
	ModifierId_Gold,'Amount',   	4
FROM temp_Krupp_Table
UNION ALL
SELECT
	ModifierId_Gold,'YieldType',	'YIELD_GOLD'
FROM temp_Krupp_Table
UNION ALL
SELECT
	ModifierId_Gold,'BuildingType',	BuildingType
FROM temp_Krupp_Table;

--Building Add Sinence
INSERT INTO DistrictModifiers
	(DistrictType,    ModifierId)
SELECT
	'DISTRICT_KRUPP',   ModifierId_Science
FROM temp_Krupp_Table;

INSERT INTO Modifiers
	(ModifierId,        ModifierType)
SELECT
	ModifierId_Science,'MODIFIER_IRON_BLOOD_SINGLE_CITY_ADJUST_BUILDING_YIELD_CHANGE'
FROM temp_Krupp_Table;

INSERT INTO ModifierArguments
	(ModifierId,	    Name,			Value)
SELECT
	ModifierId_Science,'Amount',		2
FROM temp_Krupp_Table
UNION ALL
SELECT
	ModifierId_Science,'YieldType',		'YIELD_SCIENCE'
FROM temp_Krupp_Table
UNION ALL
SELECT
	ModifierId_Science,'BuildingType',	BuildingType
FROM temp_Krupp_Table;