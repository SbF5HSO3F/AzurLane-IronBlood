-- Mode_Megalopolis
-- Author: HSbF6HSO3F
-- DateCreated: 2025/8/22 7:48:36
--------------------------------------------------------------
INSERT INTO District_Adjacencies
    (DistrictType,      YieldChangeId)
VALUES
	('DISTRICT_RUHR',   'GA_RUHR_PRODUCTION_STANDARD'),
    ('DISTRICT_RUHR',   'GA_RUHR_PRODUCTION'),
    ('DISTRICT_RUHR',   'GA_RUHR_PRODUCTION_MEGA');

INSERT INTO Adjacency_YieldChanges
    (ID,							Description,						YieldType,			YieldChange,    TilesRequired,  AdjacentDistrict,	PrereqCivic)
VALUES
    ('GA_RUHR_PRODUCTION_STANDARD',	'LOC_GA_RUHR_PRODUCTION_STANDARD',	'YIELD_PRODUCTION',	1,				1,              'DISTRICT_RUHR',    NULL),
    ('GA_RUHR_PRODUCTION',			'LOC_GA_RUHR_PRODUCTION',			'YIELD_PRODUCTION', 1,              1,              'DISTRICT_RUHR',	'CIVIC_CIVIL_SERVICE'),
    ('GA_RUHR_PRODUCTION_MEGA',		'LOC_GA_RUHR_PRODUCTION_MEGA',		'YIELD_PRODUCTION', 1,              1,              'DISTRICT_RUHR',	'CIVIC_URBANIZATION');