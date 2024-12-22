-- IronBlood_Seydlitz_XP2
-- Author: HSbF6HSO3F
-- DateCreated: 2024/9/17 21:59:42
--------------------------------------------------------------
--Units_XP2
INSERT INTO Units_XP2
		(UnitType,		        ResourceCost,	ResourceMaintenanceType,ResourceMaintenanceAmount)
VALUES	('UNIT_SMS_SEYDLITZ',	1,				'RESOURCE_OIL',			1);

--Battle Ship
UPDATE Units
SET PrereqTech = 'TECH_REFINING'
WHERE UnitType = 'UNIT_SMS_SEYDLITZ';

--Update
UPDATE Traits
SET Description = 'LOC_TRAIT_LEADER_UNSINKABLE_LEGEND_DESCRIPTION_XP2'
WHERE TraitType = 'TRAIT_LEADER_UNSINKABLE_LEGEND';