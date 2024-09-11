extends Resource
class_name Item_Info

enum Item_Effect_Type
{
	Flat,
	Percent
}

@export var display_name : String
@export var stat_effected : CharacterStats.Stat
@export var effect_type : Item_Effect_Type
@export var amount : int
