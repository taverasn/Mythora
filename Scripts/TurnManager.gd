extends Node

@warning_ignore("unused_signal")
signal on_begin_turn
@warning_ignore("unused_signal")
signal on_end_turn
@warning_ignore("unused_signal")
signal on_next_action_selected(combat_message : String)

@export var next_turn_delay : float
@export var player_character : Area2D
@export var enemy_character : Area2D

var player_action : CombatAction
var enemy_action : CombatAction
var player_mythora_data : Mythora_Res
var enemy_mythora_data : Mythora_Res
var player_selected_different_action : bool
var enemy_selected_different_action : bool

var turns : Array[Turn]
var current_turn_index : int
var game_over : bool

func _ready():
	player_character.connect("on_combat_action_selected", on_combat_action_selected)
	player_character.connect("on_mythora_swap_selected", on_mythora_swap_selected)
	enemy_character.connect("on_combat_action_selected", on_combat_action_selected)
	begin_next_turn()

func begin_next_turn() -> void:
	emit_signal("on_begin_turn")
	
func end_turn() -> void:
	emit_signal("on_end_turn")
	current_turn_index = 0
	
	for i in range(turns.size() - 1, -1, -1):
		if turns[i].turns <= 0:
			turns.pop_at(i)
	
	await get_tree().create_timer(next_turn_delay).timeout
	
	player_mythora_data = null
	enemy_mythora_data = null
	
	if remove_action(player_action):
		player_action = null
	if remove_action(enemy_action):
		enemy_action = null
	begin_next_turn()
	
func on_combat_action_selected(combat_action : CombatAction, character : Area2D) -> void:
	if character.is_player:
		player_action = combat_action
	else:
		enemy_action = combat_action
	
	if (player_action != null and enemy_action != null):
		set_turn_order()
		next_action()
	elif player_mythora_data != null and enemy_action != null:
		turns.append(MythoraSwap_Turn.new(player_character, 1, player_mythora_data))
		add_new_turn(enemy_character, enemy_action)
		next_action()
	elif enemy_mythora_data != null and player_action != null:
		turns.append(MythoraSwap_Turn.new(enemy_character, 1, enemy_mythora_data))
		add_new_turn(player_character, player_action)
		next_action()
	elif player_mythora_data != null and enemy_mythora_data != null:
		turns.append(MythoraSwap_Turn.new(enemy_character, 1, enemy_mythora_data))
		turns.append(MythoraSwap_Turn.new(player_character, 1, player_mythora_data))
		next_action()

func on_mythora_swap_selected(mythora_data : Mythora_Res, character : Area2D) -> void:
	if player_character == character:
		player_mythora_data = mythora_data
	else:
		enemy_mythora_data = mythora_data
	
	if (player_action != null and enemy_action != null):
		set_turn_order()
		next_action()
	elif player_mythora_data != null and enemy_action != null:
		turns.append(MythoraSwap_Turn.new(player_character, 1, player_mythora_data))
		add_new_turn(enemy_character, enemy_action)
		next_action()
	elif enemy_mythora_data != null and player_action != null:
		turns.append(MythoraSwap_Turn.new(enemy_character, 1, enemy_mythora_data))
		add_new_turn(player_character, player_action)
		next_action()
	elif player_mythora_data != null and enemy_mythora_data != null:
		turns.append(MythoraSwap_Turn.new(enemy_character, 1, enemy_mythora_data))
		turns.append(MythoraSwap_Turn.new(player_character, 1, player_mythora_data))
		next_action()


func set_turn_order() -> void:
	if player_character.current_stats.get_stat(CharacterStats.Stat.Speed) <= enemy_character.current_stats.get_stat(CharacterStats.Stat.Speed):
		add_new_turn(enemy_character, enemy_action)
		add_new_turn(player_character, player_action)
	else:
		add_new_turn(player_character, player_action)
		add_new_turn(enemy_character, enemy_action)

func add_new_turn(caster : Character, combat_action : CombatAction) -> void:
	var turns_active : int = combat_action.turns_active
	var add_turn : bool = true
	
	for t in turns:
		if t.caster == caster and t is Combat_Turn:
			if t.combat_action.attack_type == combat_action.attack_type:
				if t.combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
					turns_active = 0
				if combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
					add_turn = false
	
	if add_turn:
		turns.append(Combat_Turn.new(caster, turns_active, combat_action))
	

func remove_action(combat_action) -> bool:
	var should_remove_turn : bool = true
	
	if combat_action == null:
		return false
	
	if turns.filter(func(t): if t is Combat_Turn: return t.combat_action.display_name == combat_action.display_name).size() > 0:
		if combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
			should_remove_turn = false
	
	return should_remove_turn

func next_action() -> void:
	if current_turn_index >= turns.size():
		end_turn()
		return
	
	emit_signal("on_next_action_selected", turns[current_turn_index].do_turn())
	
	current_turn_index += 1
