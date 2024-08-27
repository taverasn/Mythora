extends Control

@export var container : ColorRect
@export var combat_action_buttons : Array[Button]
var combat_text_label : RichTextLabel
var current_combat_messages : Array[String]
var current_message_index : int

func _ready():
	combat_text_label = $Color_Background/Color_CombatTextBackground/MarginContainer/CombatText
	combat_text_label.text = ""
	get_parent().connect("on_begin_turn", on_begin_turn)
	get_parent().connect("on_end_turn", on_end_turn)
	get_parent().connect("on_attacks_selected", on_attacks_selected)

func on_begin_turn() -> void:
	var character = get_parent().player_character
	
	if !character.has_multi_move_damage_active:
		for i in range(combat_action_buttons.size()):
			combat_action_buttons[i].disabled = false
	
	for i in range(combat_action_buttons.size()):
		if i < character.combat_actions.size():
			combat_action_buttons[i].show()
			var combat_action : CombatAction = character.combat_actions[i]
			combat_action_buttons[i].text = combat_action.display_name
			
			if combat_action_buttons[i].is_connected("pressed", on_click_combat_action.bind(combat_action)):
				combat_action_buttons[i].disconnect("pressed", on_click_combat_action.bind(combat_action))
				
			combat_action_buttons[i].connect("pressed", on_click_combat_action.bind(combat_action))
		else:
			combat_action_buttons[i].hide()
	
func on_end_turn() -> void:
	current_combat_messages.clear()

func on_click_combat_action(combat_action : CombatAction) -> void:
	get_parent().get_node("Hit").play()
	get_parent().player_character.combat_action_selected(combat_action)
	
	for i in range(combat_action_buttons.size()):
		combat_action_buttons[i].disabled = true

func on_attacks_selected(combat_messages : Array[String]) -> void:
	current_combat_messages = combat_messages
	combat_text_label.text = combat_messages[0]
	current_message_index = 0

func _on_combat_text_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and current_combat_messages.size() > 0:
			current_message_index += 1
			if current_message_index < current_combat_messages.size():
				get_parent().next_action()
				combat_text_label.text = current_combat_messages[current_message_index]
			else:
				combat_text_label.text = ""
				get_parent().end_turn()
			
