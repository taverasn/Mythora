extends Node

@warning_ignore("unused_signal")
signal on_begin_turn
@warning_ignore("unused_signal")
signal on_end_turn
@warning_ignore("unused_signal")
signal on_attacks_selected(combat_messages : Array[String])

@export var next_turn_delay : float
@export var player_character : Area2D
@export var enemy_character : Area2D

var player_action : CombatAction
var enemy_action : CombatAction

var player_casted : bool
var enemy_casted : bool
var player_first : bool
var current_character_index : int = -1
var game_over : bool

func _ready():
	player_character.connect("on_combat_action_selected", on_combat_action_selected)
	enemy_character.connect("on_combat_action_selected", on_combat_action_selected)
	begin_next_turn()

func begin_next_turn() -> void:
	emit_signal("on_begin_turn")
	
func end_turn() -> void:
	emit_signal("on_end_turn")
	await get_tree().create_timer(next_turn_delay).timeout
	player_casted = false
	enemy_casted = false
	if !player_character.has_multi_move_damage_active:
		player_action = null
	if !enemy_character.has_multi_move_damage_active:
		enemy_action = null
	begin_next_turn()
	
func on_combat_action_selected(combat_action : CombatAction, character : Area2D) -> void:
	if character.is_player:
		player_action = combat_action
	else:
		enemy_action = combat_action
	
	if player_action != null and enemy_action != null:
		set_turn_order()
		attack_messages_queue()

func set_turn_order() -> void:
	if player_character.stats.speed <= enemy_character.stats.speed:
		player_first = false
	else:
		player_first = true

func attack_messages_queue() -> void:
	var message_array : Array[String]
	var is_residual_damage_dealt : bool = false
	
	if player_first:
		for rd in player_character.active_residual_damages:
			is_residual_damage_dealt = true
			
			enemy_character.cast_combat_action(rd.combat_action)
			
			message_array.append(
				CombatText.get_residual_damage_text(rd.combat_action, 
				enemy_character.calculate_damage(rd.combat_action), 
				player_character, 
				enemy_character))
		
		for rd in enemy_character.active_residual_damages:
			is_residual_damage_dealt = true
			
			player_character.cast_combat_action(rd.combat_action)
			
			message_array.append(
			CombatText.get_residual_damage_text(rd.combat_action, 
			player_character.calculate_damage(rd.combat_action), 
			enemy_character, 
			player_character))
		
	else:
		for rd in enemy_character.active_residual_damages:
			is_residual_damage_dealt = true
			
			player_character.cast_combat_action(rd.combat_action)
			
			message_array.append(
			CombatText.get_residual_damage_text(rd.combat_action, 
			player_character.calculate_damage(rd.combat_action), 
			enemy_character, 
			player_character))
			
		
		for rd in player_character.active_residual_damages:
			is_residual_damage_dealt = true
			
			enemy_character.cast_combat_action(rd.combat_action)
			
			message_array.append(
				CombatText.get_residual_damage_text(rd.combat_action, 
				enemy_character.calculate_damage(rd.combat_action), 
				player_character, 
				enemy_character))
	
		if player_first:
			if !is_residual_damage_dealt:
				player_character.cast_combat_action(player_action)
				player_casted = true
			
			message_array.append(
				CombatText.get_combat_text(player_action, 
				enemy_character.calculate_damage(player_action), 
				player_character, 
				enemy_character))
				
			message_array.append(
				CombatText.get_combat_text(enemy_action, 
				player_character.calculate_damage(enemy_action), 
				enemy_character, 
				player_character))
		else:
			if !is_residual_damage_dealt:
				enemy_character.cast_combat_action(enemy_action)
				enemy_casted = true
			
			message_array.append(
				CombatText.get_combat_text(enemy_action, 
				player_character.calculate_damage(enemy_action), 
				enemy_character, 
				player_character))
				
			message_array.append(
				CombatText.get_combat_text(player_action, 
				enemy_character.calculate_damage(player_action), 
				player_character, 
				enemy_character))
	
	emit_signal("on_attacks_selected", message_array)
	
func next_action() -> void:
	if player_first:
		if !player_casted:
			player_casted = true
			player_character.cast_combat_action(player_action)
		else:
			enemy_casted = true
			enemy_character.cast_combat_action(enemy_action)
	else:
		if !enemy_casted:
			enemy_casted = true
			enemy_character.cast_combat_action(enemy_action)
		else:
			player_casted = true
			player_character.cast_combat_action(player_action)
	
