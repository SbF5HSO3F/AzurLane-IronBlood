-- IronBlood_Buildings
-- Author: HSbF6HSO3F
-- DateCreated: 2023/11/14 15:13:47
--------------------------------------------------------------
CREATE TEMPORARY TABLE temp_Krupp_Table (
     ModifierId_Gold TEXT,
     ModifierId_Sinence TEXT,
     BuildingType TEXT
);

INSERT INTO temp_Krupp_Table
	(ModifierId_Gold,												ModifierId_Sinence,													BuildingType)
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
FROM temp_Krupp_Table;
UNION ALL
	ModifierId_Gold,'YieldType',	'YIELD_GOLD'
FROM temp_Krupp_Table;
UNION ALL
	ModifierId_Gold,'BuildingType',	BuildingType
FROM temp_Krupp_Table;

--Building Add Sinence
INSERT INTO DistrictModifiers
	(DistrictType,    ModifierId)
SELECT
	'DISTRICT_KRUPP',   ModifierId_Sinence
FROM temp_Krupp_Table;

INSERT INTO Modifiers
	(ModifierId,        ModifierType)
SELECT
	ModifierId_Sinence,'MODIFIER_IRON_BLOOD_SINGLE_CITY_ADJUST_BUILDING_YIELD_CHANGE'
FROM temp_Krupp_Table;

INSERT INTO ModifierArguments
	(ModifierId,	    Name,			Value)
SELECT
	ModifierId_Sinence,'Amount',		2
FROM temp_Krupp_Table;
UNION ALL
SELECT
	ModifierId_Sinence,'YieldType',		'YIELD_SCIENCE'
FROM temp_Krupp_Table;
UNION ALL
SELECT
	ModifierId_Sinence,'BuildingType',	BuildingType
FROM temp_Krupp_Table;