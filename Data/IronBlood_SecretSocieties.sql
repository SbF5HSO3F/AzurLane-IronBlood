-- IronBlood_SecretSocieties
-- Author: HSbF6HSO3F
-- DateCreated: 2023/10/16 16:14:59
--------------------------------------------------------------
INSERT INTO BuildingPrereqs
		(Building,						PrereqBuilding)
VALUES	('BUILDING_ALCHEMICAL_SOCIETY',	'BUILDING_ANNETTE');

INSERT INTO District_Adjacencies
		(DistrictType,		YieldChangeId)
VALUES	('DISTRICT_RUHR',	'LeyLine_Production');