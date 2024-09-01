extends Control

@export var container : ColorRect
@export var combat_action_buttons : Array[Button]
var combat_text_label : RichTextLabel

func _ready():
	combat_text_label = $Color_Background/Color_CombatTextBackground/MarginContainer/CombatText
	combat_text_label.text = ""
	get_parent().connect("on_begin_turn", on_begin_turn)
	get_parent().connect("on_end_turn", on_end_turn)
	get_parent().connect("on_next_action_selected", on_next_action_selected)

func on_begin_turn() -> void:
	var character : Character = get_parent().player_character
	
	if get_parent().player_action == null:
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
	combat_text_label.text = ""


func on_click_combat_action(combat_action : CombatAction) -> void:
	get_parent().get_node("Hit").play()
	get_parent().player_character.combat_action_selected(combat_action)
	
	for i in range(combat_action_buttons.size()):
		combat_action_buttons[i].disabled = true

func on_next_action_selected(combat_message : String) -> void:
	combat_text_label.text = combat_message

func _on_combat_text_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().next_action()
