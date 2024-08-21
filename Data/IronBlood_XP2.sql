-- IronBlood_XP2
-- Author: jjj
-- DateCreated: 2023/11/1 12:38:25
--------------------------------------------------------------
--District Adjacency
INSERT INTO District_Adjacencies
		(DistrictType,		YieldChangeId)
VALUES	('DISTRICT_RUHR',	'Aqueduct_Production'),
		('DISTRICT_RUHR',	'Bath_Production'),
		('DISTRICT_RUHR',	'Canal_Production'),
		('DISTRICT_RUHR',	'Dam_Production');

--Unit abilities
INSERT INTO Types
		(Type,									Kind)
VALUES	('ABILITY_KRUPP_FREE_MELEE_UNITS_XP2',	'KIND_ABILITY');

INSERT INTO TypeTags
		(Type,									Tag)
VALUES	('ABILITY_KRUPP_FREE_MELEE_UNITS_XP2',	'CLASS_MELEE');

INSERT INTO UnitAbilities
		(UnitAbilityType,						Name,											Description,											Inactive)
VALUES	('ABILITY_KRUPP_FREE_MELEE_UNITS_XP2',	'LOC_ABILITY_KRUPP_FREE_MELEE_UNITS_XP2_NAME',	'LOC_ABILITY_KRUPP_FREE_MELEE_UNITS_XP2_DESCRIPTION',	1);

INSERT INTO UnitAbilityModifiers
		(UnitAbilityType,						ModifierId)
VALUES	('ABILITY_KRUPP_FREE_MELEE_UNITS_XP2',	'KRUPP_FREE_MELEE_FREE_BUFF'),
		('ABILITY_KRUPP_FREE_MELEE_UNITS_XP2',	'KRUPP_FREE_MELEE_COMBAT_BUFF');

INSERT INTO Modifiers
		(ModifierId,						ModifierType)
VALUES	('KRUPP_FREE_MELEE_FREE_BUFF',		'MODIFIER_PLAYER_UNIT_ADJUST_IGNORE_RESOURCE_MAINTENANCE'),
		('KRUPP_FREE_MELEE_COMBAT_BUFF',	'MODIFIER_SINGLE_UNIT_ADJUST_COMBAT_FOR_UNUSED_MOVEMENT');
INSERT INTO ModifierArguments
		(ModifierId,					Name,		Value)
VALUES	('KRUPP_FREE_MELEE_FREE_BUFF',	'Ignore',	'true'),
		('KRUPP_FREE_MELEE_COMBAT_BUFF','Amount',	'3');

UPDATE Districts
SET Description = 'LOC_DISTRICT_KRUPP_DESCRIPTION_XP2'
WHERE DistrictType = 'DISTRICT_KRUPP';

UPDATE ModifierArguments
SET Value = 'ABILITY_KRUPP_FREE_MELEE_UNITS_XP2'
WHERE ModifierId = 'KRUPP_FREE_MELEE_UNIT' AND Name = 'UnitAbilityType';