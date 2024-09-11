extends Node

@export var next_turn_delay : float
@export var player_character : Area2D
@export var enemy_character : Area2D

var player_action : CombatAction
var enemy_action : CombatAction
var player_added_turn : bool
var enemy_added_turn : bool

var turns : Array[Turn]
var current_turn_index : int
var game_over : bool

func _ready():
	MessageCenter.add_observer(self, "OnCombatActionSelected", "_on_combat_action_selected")
	MessageCenter.add_observer(self, "OnMythoraSwapSelected", "_on_mythora_swap_selected")
	MessageCenter.add_observer(self, "OnMythoraDied", "_on_mythora_died")
	MessageCenter.add_observer(self, "OnUseItemSelected", "_on_use_item_selected")
	begin_next_turn()

func begin_next_turn() -> void:
	if game_over:
		turns.clear()
		var msg : Dictionary = {
			"Type": "OnNextActionSelected",
			"Message": "Game Over"
		}
		MessageCenter.post_msg(msg)
	else:
		var msg : Dictionary = {
			"Type": "OnBeginTurn"
		}
		MessageCenter.post_msg(msg)

func end_turn() -> void:
	var msg : Dictionary = {
			"Type": "OnEndTurn"
		}
	MessageCenter.post_msg(msg)
	
	current_turn_index = 0
	
	if remove_action(player_action, player_character):
		player_action = null
	
	if player_action == null:
		player_added_turn = false
	
	if remove_action(enemy_action, enemy_character):
		enemy_action = null
		enemy_added_turn = false
	
	if enemy_action == null:
		enemy_added_turn = false
	
	for i in range(turns.size() - 1, -1, -1):
		if turns[i].turns <= 0:
			turns.pop_at(i)
		
	begin_next_turn()

func _on_combat_action_selected(msg : Dictionary) -> void:
	var combat_action : CombatAction = msg["CombatAction"]
	var character : Character = msg["Character"]
	if character.is_player:
		player_action = combat_action
		add_new_turn(player_character, player_action)
		player_added_turn = true
	else:
		enemy_action = combat_action
		add_new_turn(enemy_character, enemy_action)
		enemy_added_turn = true
		
	add_turns()

func _on_mythora_swap_selected(msg : Dictionary) -> void:
	var mythora_info : Mythora_Info = msg["MythoraInfo"]
	var character : Character = msg["Character"]
	if character.is_player:
		turns.append(MythoraSwap_Turn.new(player_character, 1, mythora_info))
		player_added_turn = true
	else:
		turns.append(MythoraSwap_Turn.new(enemy_character, 1,mythora_info))
		enemy_added_turn = true
		
	add_turns()

func _on_use_item_selected(msg : Dictionary) -> void:
	var item_info : Item_Info = msg["ItemInfo"]
	var character : Character = msg["Character"]
	if character.is_player:
		turns.append(Item_Turn.new(player_character, 1, item_info))
		player_added_turn = true
	else:
		turns.append(Item_Turn.new(enemy_character, 1,item_info))
		enemy_added_turn = true
	
	add_turns()

func add_turns() -> void:
	if !player_added_turn or !enemy_added_turn:
		return
	
	set_turn_order()
	next_action()

func speed_check(turn1 : Turn, turn2 : Turn) -> int:
	return turn2.caster.current_mythora.current_stats.get_stat(CharacterStats.Stat.Speed) - turn1.caster.current_mythora.current_stats.get_stat(CharacterStats.Stat.Speed)

func set_turn_order():
	var mythora_swap_turns : Array[Turn]
	var use_item_turns : Array[Turn]
	var status_condition_turns : Array[Turn]
	var residual_damage_turns : Array[Turn]
	var remaining_turns : Array[Turn]
	
	for turn : Turn in turns:
		if turn is MythoraSwap_Turn:
			mythora_swap_turns.append(turn)
		elif turn is Item_Turn:
			use_item_turns.append(turn)
		elif turn is Combat_Turn:
			var combat_turn : Combat_Turn = turn as Combat_Turn
			if combat_turn.combat_action.attack_type == CombatAction.AttackType.Status_Condition and !combat_turn.first_turn:
				status_condition_turns.append(turn)
			elif combat_turn.combat_action.attack_type == CombatAction.AttackType.ResidualDamage and !combat_turn.first_turn:
				residual_damage_turns.append(turn)
			else:
				remaining_turns.append(turn)
		else:
			remaining_turns.append(turn)
	
	remaining_turns.sort_custom(speed_check)
	
	turns.clear()
	turns += mythora_swap_turns
	turns += use_item_turns
	turns += status_condition_turns
	turns += residual_damage_turns
	turns += remaining_turns

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

func remove_action(combat_action : CombatAction, caster : Character) -> bool:
	if combat_action == null:
		return false
	
	if caster.current_mythora.is_dead:
		return true
	
	if turns.filter(func(t): 
		if t is Combat_Turn: 
			if t.combat_action.attack_type == CombatAction.AttackType.MultiMoveDamage:
				if t.turns > 0 && caster == t.caster:
					return t.combat_action.display_name == combat_action.display_name).size() > 0:
						return false
	
	return true

func next_action() -> void:
	var msg : Dictionary
	if current_turn_index == 0:
		msg = {
		"Type": "OnFirstTurn"
		}
		MessageCenter.post_msg(msg)

	if current_turn_index >= turns.size():
		end_turn()
		return
	
	msg = {
		"Type": "OnNextActionSelected",
		"Message": turns[current_turn_index].do_turn()
	}
	MessageCenter.post_msg(msg)
	current_turn_index += 1

func _on_mythora_died(msg : Dictionary) -> void:
	var character : Character = msg["Character"]
	
	for i in range(turns.size() - 1, -1, -1):
		if turns[i] is Combat_Turn:
			if turns[i].caster == character:
				turns.pop_at(i)
			elif  turns[i].combat_action.attack_style != CombatAction.AttackType.MultiMoveDamage && turns[i].caster != character:
				turns.pop_at(i)
				
