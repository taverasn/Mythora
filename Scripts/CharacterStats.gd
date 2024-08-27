class_name CharacterStats

var stats: Dictionary = {}

func _init(_hp: int, _speed: int, _armor: int, _magic_resist: int, _attack_damage: int, _ability_power: int):
	stats[CombatAction.Status.HP] = _hp
	stats[CombatAction.Status.Speed] = _speed
	stats[CombatAction.Status.Armor] = _armor
	stats[CombatAction.Status.Magic_Resist] = _magic_resist
	stats[CombatAction.Status.Attack_Damage] = _attack_damage
	stats[CombatAction.Status.Ability_Power] = _ability_power

# Example usage:
func get_stat(stat_type: CombatAction.Status) -> int:
	return stats.get(stat_type, 0)  # Returns the stat value, or 0 if not found
