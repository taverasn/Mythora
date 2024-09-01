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

var turns : Array[Turn]
var current_turn_index : int
var game_over : bool

func _ready():
	player_character.connect("on_combat_action_selected", on_combat_action_selected)
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
	
	if remove_turn(player_action):
		player_action = null
	if remove_turn(enemy_action):
		enemy_action = null
	begin_next_turn()
	
func on_combat_action_selected(combat_action : CombatAction, character : Area2D) -> void:
	if character.is_player:
		player_action = combat_action
	else:
		enemy_action = combat_action
	
	if player_action != null and enemy_action != null:
		set_turn_order()
		next_action()

func set_turn_order() -> void:
	if player_character.stats.get_stat(CombatAction.Status.Speed) <= enemy_character.stats.get_stat(CombatAction.Status.Speed):
		add_new_turn(enemy_character, enemy_action)
		add_new_turn(player_character, player_action)
	else:
		add_new_turn(player_character, player_action)
		add_new_turn(enemy_character, enemy_action)

func add_new_turn(caster : Character, combat_action : CombatAction) -> void:
	var turns_active : int = combat_action.turns_active
	var add_turn : bool = true
	if turns.filter(func(t): return t.combat_action.display_name == combat_action.display_name).size() > 0:
		if combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
			turns_active = 0
		elif combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
			add_turn = false
	
	if add_turn:
		turns.append(Turn.new(caster, combat_action, turns_active))
	

func remove_turn(combat_action) -> bool:
	var should_remove_turn : bool = true
	if turns.filter(func(t): return t.combat_action.display_name == combat_action.display_name).size() > 0:
		if combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
			should_remove_turn = false
	
	return should_remove_turn

func next_action() -> void:
	if current_turn_index >= turns.size():
		end_turn()
		return
	
	emit_signal("on_next_action_selected", turns[current_turn_index].cast_combat_action())
	
	current_turn_index += 1
