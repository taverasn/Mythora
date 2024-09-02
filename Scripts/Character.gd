extends Area2D
class_name Character

@warning_ignore("unused_signal")
signal on_health_change
@warning_ignore("unused_signal")
signal on_die(character : Area2D)
@warning_ignore("unused_signal")
signal on_combat_action_selected(combat_action : CombatAction, character : Area2D)
@warning_ignore("unused_signal")
signal on_mythora_swap_selected(_mythora_data : Mythora_Info, character : Area2D)

@export var mythora_infos : Array[Mythora_Info]
var mythora_team : Array[Mythora]
var current_mythora : Mythora

@export var opponent : Area2D
@export var is_player : bool

var cur_level : int
@export var attack_move_speed : int = 2500
@export var return_move_speed : int = 1500

var start_position : Vector2
var attack_opponent : bool
var current_combat_action : CombatAction
var casted_residual_damage_active : bool

func _ready():
	start_position = position
	create_team()
	set_up_mythora(mythora_team[0].info)
	$Sprite2D.flip_h = !is_player
	get_parent().connect("on_begin_turn", on_begin_turn)
	

func create_team() -> void:
	for info in mythora_infos:
		mythora_team.append(Mythora.new(info))

func set_up_mythora(mythora_info : Mythora_Info) -> void:
	for m in mythora_team:
		if m.info.display_name == mythora_info.display_name:
			current_mythora = m
	$Sprite2D.texture = current_mythora.info.visual
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

func take_damage(combat_action : CombatAction) -> void:
	instantiate_hit_particles(combat_action.hit_particles)
	current_mythora.take_damage(combat_action, opponent.current_mythora.current_stats)
	emit_signal("on_health_change")
	if current_mythora.is_dead():
		die()

func die() -> void:
	get_parent().get_node("Death").play()
	get_parent().game_over = true
	queue_free()

func heal(combat_action : CombatAction) -> void:
	instantiate_hit_particles(combat_action.hit_particles)
	current_mythora.heal(combat_action)
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

func handle_status_condition(combat_action : CombatAction) -> void:
	instantiate_hit_particles(combat_action.hit_particles)
	current_mythora.handle_status_condition(combat_action)

func change_stat(combat_action : CombatAction):
	instantiate_hit_particles(combat_action.hit_particles)
	current_mythora.change_stat(combat_action)

func on_begin_turn() -> void:
	pass

func combat_action_selected(combat_action : CombatAction) -> void:
	emit_signal("on_combat_action_selected", combat_action, self)

func mythora_swap_selected(mythora_info : Mythora_Info) -> void:
	emit_signal("on_mythora_swap_selected", mythora_info, self)

func get_health_percentage() -> float:
	return current_mythora.get_health_percentage()
