class_name CharacterStats

enum Stat {
	None = 0,
	HP = 1,
	Speed = 2,
	Armor = 3,
	Magic_Resist = 4,
	Attack_Damage = 5,
	Ability_Power = 6,
}

var stats: Dictionary = {}

func _init(_hp: int, _speed: int, _armor: int, _magic_resist: int, _attack_damage: int, _ability_power: int):
	stats[Stat.HP] = _hp
	stats[Stat.Speed] = _speed
	stats[Stat.Armor] = _armor
	stats[Stat.Magic_Resist] = _magic_resist
	stats[Stat.Attack_Damage] = _attack_damage
	stats[Stat.Ability_Power] = _ability_power

func get_stat(stat_type: Stat) -> int:
	return stats.get(stat_type, 0)
