extends Resource
class_name CombatAction

enum DamageType {
	Physical,
	Magic
}

enum AttackType {
	Regular = 0,
	Heal = 1,
	Status = 2,
	ResidualDamage = 3,
	MultiMoveDamage = 4,
	Status_Condition = 5
}

enum AttackStyle {
	None = 0,
	Melee = 1,
	Ranged = 2
}

enum Status {
	None = 0,
	HP = 1,
	Speed = 2,
	Armor = 3,
	Magic_Resist = 4,
	Attack_Damage = 5,
	Ability_Power = 6,
}

enum Target {
	Opponent = 0,
	Self = 1
}

@export_category("General")
@export var display_name : String = "Action (x DMG)"
@export var description : String
@export var hit_particles : PackedScene
@export var turns_active : int = 1

@export_category("Damage")
@export var heal : int = 0
@export var damage : int = 0
@export var projectile_scene : PackedScene
@export var nature_type : Nature.NatureType
@export var damage_type : DamageType
@export var attack_type : AttackType
@export var attack_style : AttackStyle

@export_category("Status Effect")
@export var status_effected : Status
@export var target : Target

@export_category("Status Condition")
@export var status_condition : StatusCondition.StatusConditionType
