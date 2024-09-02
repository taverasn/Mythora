class_name Mythora

var info : Mythora_Info
var nature : Nature
var combat_actions : Array[CombatAction]
var initial_stats : CharacterStats
var current_stats : CharacterStats
var current_status_conditions : Array[StatusCondition]
var cur_level : int
var is_dead : bool
func _init(_info : Mythora_Info, _combat_actions : Array[CombatAction] = [], _cur_level : int = 1, _is_dead : bool = false) -> void:
	info = _info
	nature = info.nature
	if _combat_actions.size() == 0:
		combat_actions = info.starting_combat_actions
	else:
		combat_actions = _combat_actions
	cur_level = _cur_level
	is_dead = _is_dead
	set_up_stats(info)
	
func set_up_stats(_info : Mythora_Info) -> void:
	current_stats = CharacterStats.new(
		_info.hp,
		_info.speed,
		_info.armor,
		_info.magic_resist,
		_info.attack_damage,
		_info.ability_power)
		
	initial_stats = CharacterStats.new(
		_info.hp,
		_info.speed,
		_info.armor,
		_info.magic_resist,
		_info.attack_damage,
		_info.ability_power)

func take_damage(combat_action : CombatAction, dealer_stats : CharacterStats) -> void:
	current_stats.stats[CharacterStats.Stat.HP] -= calculate_damage(combat_action, dealer_stats)
	if current_stats.get_stat(CharacterStats.Stat.HP) <= 0:
		current_stats.stats[CharacterStats.Stat.HP] = 0
		is_dead = true

func heal(combat_action : CombatAction) -> void:
	current_stats.stats[CharacterStats.Stat.HP] += combat_action.heal
	if current_stats.get_stat(CharacterStats.Stat.HP) > initial_stats.get_stat(CharacterStats.Stat.HP):
		current_stats.stats[CharacterStats.Stat.HP] = initial_stats.get_stat(CharacterStats.Stat.HP)

func handle_status_condition(combat_action : CombatAction) -> void:
	# Prevent Duplicate Conditions and From Having More Than 2 Status Conditions
	if current_status_conditions.size() > 0:
		if current_status_conditions[0].status_condition == combat_action.status_condition || current_status_conditions.size() >= 2:
			return
	
	var status_condition : StatusCondition = StatusCondition.new(combat_action.status_condition, combat_action.nature_type)
	
	current_status_conditions.append(status_condition)
	
	var damage_defense_multiplier : float = status_condition.percentage_effected * DamageHelpers.damage_defense_multiplier(nature.effectiveness(combat_action.nature_type))
	for s in status_condition.statuses_effected:
		current_stats.stats[s] = int(float(current_stats.get_stat(s)) - (float(current_stats.get_stat(s)) * damage_defense_multiplier))

func change_stat(combat_action : CombatAction):
	var status_effect_percentage : float
	match nature.effectiveness(combat_action.nature_type):
		Nature.Effectiveness.Weak:
			status_effect_percentage = 0.05
		Nature.Effectiveness.Strong:
			status_effect_percentage = 0.1
		Nature.Effectiveness.Neutral:
			status_effect_percentage = 0.2
	
	current_stats.stats[combat_action.status_effected] = int(float(current_stats.get_stat(combat_action.status_effected)) - (float(combat_action.status_effected) * status_effect_percentage))

func calculate_damage(combat_action : CombatAction, dealer_stats : CharacterStats) -> int:
	var damage = combat_action.damage * DamageHelpers.damage_defense_multiplier(nature.effectiveness(combat_action.nature_type))
	var damage_factor : float = ((float(2) * float(cur_level) / float(5))) + 2
	var resistance_ratio : float = get_resistance_ratio(combat_action.damage_type, dealer_stats)
	var damage_as_float : float = (damage_factor * float(damage) * resistance_ratio) / 50.0 + 2.0
	return int(damage_as_float)

func get_resistance_ratio(damage_type : CombatAction.DamageType, dealer_stats : CharacterStats) -> float:
	var resistance_ratio : float = 1
	if damage_type == CombatAction.DamageType.Physical:
		resistance_ratio = float(dealer_stats.get_stat(CharacterStats.Stat.Attack_Damage)) / float(current_stats.get_stat(CharacterStats.Stat.Armor))
	else:
		resistance_ratio = float(dealer_stats.get_stat(CharacterStats.Stat.Ability_Power)) / float(current_stats.get_stat(CharacterStats.Stat.Magic_Resist))
	return resistance_ratio

func get_health_percentage() -> float:
	return float(current_stats.get_stat(CharacterStats.Stat.HP)) / float(initial_stats.get_stat(CharacterStats.Stat.HP)) * 100
