extends Area2D
class_name Character

@warning_ignore("unused_signal")
signal on_health_change
@warning_ignore("unused_signal")
signal on_die(character : Area2D)
@warning_ignore("unused_signal")
signal on_combat_action_selected(combat_action : CombatAction, character : Area2D)

@export var mythora_data : Mythora
@export var hit_particles : PackedScene
var combat_actions : Array[CombatAction]
var nature : Nature
@export var opponent : Area2D
@export var is_player : bool
@export var character : Area2D
var current_health : int = 25
var max_health : int = 25
var cur_level : int
var has_multi_move_damage_active : bool
var turns_multi_move_damage_active : int
@export var attack_move_speed : int = 2500
@export var return_move_speed : int = 1500

var active_residual_damages : Array[ResidualDamageMove]

var start_position : Vector2
var attack_opponent : bool
var current_combat_action : CombatAction
var stats : CharacterStats

func _ready():
	start_position = position
	get_parent().connect("on_begin_turn", on_begin_turn)
	
	stats = CharacterStats.new(
		mythora_data.hp,
		mythora_data.speed,
		mythora_data.armor,
		mythora_data.magic_resist,
		mythora_data.attack_damage,
		mythora_data.ability_power)
	
	current_health = mythora_data.hp
	max_health = mythora_data.hp
	
	$Sprite2D.texture = mythora_data.visual
	$Sprite2D.flip_h = !is_player
	
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

func take_damage(action : CombatAction) -> void:
	var hit_particles_instance : CPUParticles2D = hit_particles.instantiate()
	get_parent().add_child(hit_particles_instance)
	hit_particles_instance.position = position
	hit_particles_instance.emitting = true
	
	# Adjust Damage Based on Type of Nature, Damage and Defenses
	var damage = calculate_damage(action)
	
	current_health -= damage
	
	emit_signal("on_health_change")
	
	if current_health <= 0:
		die()
		
func calculate_damage(combat_action : CombatAction) -> int:
	var damage = combat_action.damage * nature.damage_defense_multiplier(nature.effectiveness(combat_action.nature_type))
	var damage_factor : float = ((float(2) * float(cur_level) / float(5))) + 2
	var attack_defense_ratio : CombatAction.DamageType
	
	if combat_action.damage_type == CombatAction.DamageType.Physical:
		attack_defense_ratio = opponent.mythora_data.attack_damage / mythora_data.armor
	else:
		attack_defense_ratio = opponent.mythora_data.ability_power / mythora_data.magic_resist
	
	var damage_as_float : float = (damage_factor * float(damage) * attack_defense_ratio) / 50 + 2
	
	return int(damage_as_float)

func die() -> void:
	get_parent().get_node("Death").play()
	get_parent().game_over = true
	queue_free()

func heal(combat_action : CombatAction) -> void:
	current_health += combat_action.heal
	
	if current_health > max_health:
		current_health = max_health
	emit_signal("on_health_change")

func cast_combat_action(combat_action : CombatAction) -> void:
	current_combat_action = combat_action
	if combat_action.attack_style == CombatAction.AttackStyle.Melee:
		get_parent().get_node("Hit").play()
		attack_opponent = true
	elif combat_action.attack_style == CombatAction.AttackStyle.Ranged:
		var projectile_instance : Sprite2D = combat_action.projectile_scene.instantiate()
		projectile_instance.initialize(opponent, combat_action)
		get_parent().add_child(projectile_instance)
		projectile_instance.position = position
		get_parent().get_node("Fireball").play()
	elif combat_action.heal > 0:
		heal(combat_action)
	elif combat_action.attack_type == CombatAction.AttackType.Status:
		opponent.change_stat(combat_action)
	elif combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
		opponent.take_residual_damage(combat_action)
	elif combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
		if !has_multi_move_damage_active:
			has_multi_move_damage_active = true
			turns_multi_move_damage_active = combat_action.turns_active
		
		turns_multi_move_damage_active -= 1
		
		if turns_multi_move_damage_active == 0:
			has_multi_move_damage_active = false
		
		opponent.take_damage(combat_action)

func take_residual_damage(combat_action : CombatAction) -> void:
	var residual_damage_move : ResidualDamageMove
	if active_residual_damages.size() > 0:
		var index : int = -1
		
		for i in range(active_residual_damages.size()):
			if active_residual_damages[i].display_name == combat_action.display_name:
				index = i
				break
		
		if index >= 0:
			residual_damage_move = active_residual_damages[index]
	
	if residual_damage_move == null:
		residual_damage_move = ResidualDamageMove.new(combat_action.turns_active, combat_action.residual_damage_type, combat_action.display_name, combat_action)
		active_residual_damages.append(residual_damage_move)
	
	take_damage(combat_action)
	residual_damage_move.next_turn()
	if residual_damage_move.turns_active == 0:
		active_residual_damages.pop_at(active_residual_damages.find(residual_damage_move))
		residual_damage_move = null
	

func change_stat(combat_action : CombatAction):
	var status_effect_percentage : float
	match nature.effectiveness(combat_action.nature_type):
		Nature.Effectiveness.Weak:
			status_effect_percentage = 0.05
		Nature.Effectiveness.Strong:
			status_effect_percentage = 0.1
		Nature.Effectiveness.Neutral:
			status_effect_percentage = 0.2
	
	match combat_action.status_effected:
		CombatAction.Status.HP:
			stats.hp = int(float(stats.hp) - (float(stats.hp) * status_effect_percentage))
		CombatAction.Status.Speed:
			stats.speed = int(float(stats.speed) - (float(stats.speed) * status_effect_percentage))
		CombatAction.Status.Armor:
			stats.armor = int(float(stats.armor) - (float(stats.armor) * status_effect_percentage))
		CombatAction.Status.Magic_Resist:
			stats.magic_resist = int(float(stats.magic_resist) - (float(stats.magic_resist) * status_effect_percentage))
		CombatAction.Status.Attack_Damage:
			stats.attack_damage = int(float(stats.attack_damage) - (float(stats.attack_damage) * status_effect_percentage))
		CombatAction.Status.Ability_Power:
			stats.ability_power = int(float(stats.ability_power) - (float(stats.ability_power) * status_effect_percentage))


func on_begin_turn() -> void:
	if !is_player:
		determine_combat_action()

func determine_combat_action() -> void:
	var health_percentage : float = get_health_percentage()
	var want_to_heal : bool
	var ca : CombatAction
	
	var random : int = randi() % 3 # returns 0, 1, 2
	
	if health_percentage <= 35:
		if random == 0:
			want_to_heal = true
	
	if want_to_heal && has_combat_action_type(CombatAction.AttackType.Heal):
		ca = get_combat_action_of_type(CombatAction.AttackType.Heal)
	elif has_combat_action_type(CombatAction.AttackType.Damage):
		ca = get_combat_action_of_type(CombatAction.AttackType.Damage)
	
	if ca != null:
		emit_signal("on_combat_action_selected", ca, self)

func combat_action_selected(combat_action : CombatAction) -> void:
	emit_signal("on_combat_action_selected", combat_action, self)

func get_health_percentage() -> float:
	return float(current_health) / float(max_health) * 100

func has_combat_action_type(type : CombatAction.AttackType) -> bool:
	for element in combat_actions:
		if element.attack_type == type:
			return true;
		
	return false

func get_combat_action_of_type(type : CombatAction.AttackType) -> CombatAction:
	var available_actions : Array[CombatAction] = []
	
	for element in combat_actions:
		if element.attack_type == type:
			available_actions.append(element)
	
	return available_actions[randi() % available_actions.size()]
