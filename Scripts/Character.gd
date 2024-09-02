extends Area2D
class_name Character

@warning_ignore("unused_signal")
signal on_health_change
@warning_ignore("unused_signal")
signal on_die(character : Area2D)
@warning_ignore("unused_signal")
signal on_combat_action_selected(combat_action : CombatAction, character : Area2D)
@warning_ignore("unused_signal")
signal on_mythora_swap_selected(_mythora_data : Mythora_Res, character : Area2D)

@export var mythora_team : Array[Mythora_Res]
var mythora_data : Mythora_Res
var combat_actions : Array[CombatAction]
var nature : Nature

@export var opponent : Area2D
@export var is_player : bool

var cur_level : int
@export var attack_move_speed : int = 2500
@export var return_move_speed : int = 1500

var start_position : Vector2
var attack_opponent : bool
var current_combat_action : CombatAction
var current_stats : CharacterStats
var initial_stats : CharacterStats

var current_status_conditions : Array[StatusCondition]
var casted_residual_damage_active : bool

func set_up(_mythora_data : Mythora_Res) -> void:
	current_stats = CharacterStats.new(
		_mythora_data.hp,
		_mythora_data.speed,
		_mythora_data.armor,
		_mythora_data.magic_resist,
		_mythora_data.attack_damage,
		_mythora_data.ability_power)
		
	initial_stats = CharacterStats.new(
		_mythora_data.hp,
		_mythora_data.speed,
		_mythora_data.armor,
		_mythora_data.magic_resist,
		_mythora_data.attack_damage,
		_mythora_data.ability_power)

func _ready():
	start_position = position
	set_up_mythora(mythora_team[0])
	$Sprite2D.flip_h = !is_player
	get_parent().connect("on_begin_turn", on_begin_turn)
	

func set_up_mythora(_mythora_data : Mythora_Res) -> void:
	mythora_data = _mythora_data
	set_up(mythora_data)
	$Sprite2D.texture = mythora_data.visual
	combat_actions = mythora_data.starting_combat_actions
	nature = mythora_data.nature
	emit_signal("on_health_change")
	

func _process(delta):
	if attack_opponent:
		position = position.move_toward(opponent.position, delta * attack_move_speed)
	if !attack_opponent:
		position = position.move_toward(start_position, delta * return_move_speed)

	if get_parent().game_over:
		return

	if position.x == opponent.position.x and attack_opponent:
		attack_opponent = false
		opponent.take_damage(current_combat_action)
		
func instantiate_hit_particles(hit_particles : PackedScene) -> void:
	var hit_particles_instance : CPUParticles2D = hit_particles.instantiate()
	get_parent().add_child(hit_particles_instance)
	hit_particles_instance.position = position
	hit_particles_instance.emitting = true

func take_damage(action : CombatAction) -> void:
	instantiate_hit_particles(action.hit_particles)
	
	# Adjust Damage Based on Type of Nature, Damage and Defenses
	var damage = calculate_damage(action)
	
	current_stats.stats[CharacterStats.Stat.HP] -= damage
	
	emit_signal("on_health_change")
	
	if current_stats.get_stat(CharacterStats.Stat.HP) <= 0:
		die()
		
func calculate_damage(combat_action : CombatAction) -> int:
	var damage = combat_action.damage * DamageHelpers.damage_defense_multiplier(nature.effectiveness(combat_action.nature_type))
	var damage_factor : float = ((float(2) * float(cur_level) / float(5))) + 2
	var attack_defense_ratio : CombatAction.DamageType
	
	if combat_action.damage_type == CombatAction.DamageType.Physical:
		attack_defense_ratio = opponent.mythora_data.attack_damage / mythora_data.armor
	else:
		attack_defense_ratio = opponent.mythora_data.ability_power / mythora_data.magic_resist
	
	var damage_as_float : float = (damage_factor * float(damage) * attack_defense_ratio) / 50.0 + 2.0
	
	return int(damage_as_float)

func die() -> void:
	get_parent().get_node("Death").play()
	get_parent().game_over = true
	queue_free()

func heal(combat_action : CombatAction) -> void:
	instantiate_hit_particles(combat_action.hit_particles)
	current_stats.stats[CharacterStats.Stat.HP] += combat_action.heal
	if current_stats.get_stat(CharacterStats.Stat.HP) > initial_stats.get_stat(CharacterStats.Stat.HP):
		current_stats.stats[CharacterStats.Stat.HP] = initial_stats.get_stat(CharacterStats.Stat.HP)
	emit_signal("on_health_change")

func cast_combat_action(combat_action : CombatAction) -> void:
	current_combat_action = combat_action
	if combat_action.attack_type == CombatAction.AttackType.Regular or combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
		attack_style(combat_action)
	elif combat_action.heal > 0:
		heal(combat_action)
	elif combat_action.attack_type == CombatAction.AttackType.Status:
		if combat_action.target == CombatAction.Target.Opponent:
			opponent.change_stat(combat_action)
		else:
			change_stat(combat_action)
	elif combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
		opponent.take_damage(combat_action)
	elif combat_action.attack_type == CombatAction.AttackType.Status_Condition:
		opponent.handle_status_condition(combat_action)

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

func attack_style(combat_action : CombatAction) -> void:
	if combat_action.attack_style == CombatAction.AttackStyle.Melee:
		get_parent().get_node("Hit").play()
		attack_opponent = true
	elif combat_action.attack_style == CombatAction.AttackStyle.Ranged:
		var projectile_instance : Sprite2D = combat_action.projectile_scene.instantiate()
		projectile_instance.initialize(opponent, combat_action)
		get_parent().add_child(projectile_instance)
		projectile_instance.position = position
		get_parent().get_node("Fireball").play()

func change_stat(combat_action : CombatAction):
	instantiate_hit_particles(combat_action.hit_particles)
	
	var status_effect_percentage : float
	match nature.effectiveness(combat_action.nature_type):
		Nature.Effectiveness.Weak:
			status_effect_percentage = 0.05
		Nature.Effectiveness.Strong:
			status_effect_percentage = 0.1
		Nature.Effectiveness.Neutral:
			status_effect_percentage = 0.2
	
	current_stats.stats[combat_action.status_effected] = int(float(current_stats.get_stat(combat_action.status_effected)) - (float(combat_action.status_effected) * status_effect_percentage))

func on_begin_turn() -> void:
	pass

func combat_action_selected(combat_action : CombatAction) -> void:
	emit_signal("on_combat_action_selected", combat_action, self)

func mythora_swap_selected(_mythora_data : Mythora_Res) -> void:
	emit_signal("on_mythora_swap_selected", _mythora_data, self)

func get_health_percentage() -> float:
	return float(current_stats.get_stat(CharacterStats.Stat.HP)) / float(initial_stats.get_stat(CharacterStats.Stat.HP)) * 100
