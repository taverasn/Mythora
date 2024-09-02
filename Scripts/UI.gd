extends Control

@export var container : ColorRect
@export var combat_action_buttons : Array[Button]
@export var mythora_swap_buttons : Array[Button]
@export var mythora_team_container : VBoxContainer
@export var bag_container : VBoxContainer
@export var combat_actions_container : VBoxContainer


@export_category("Action Buttons")
@export var actions_container : VBoxContainer
@export var action_buttons : Array[Button]
@export var combat_action_button : Button
@export var team_action_button : Button
@export var bag_action_button : Button
@export var flee_action_button : Button


var combat_text_label : RichTextLabel

func _ready():
	combat_text_label = $Color_Background/Color_CombatTextBackground/MarginContainer/CombatText
	combat_text_label.text = ""
	get_parent().connect("on_begin_turn", on_begin_turn)
	get_parent().connect("on_end_turn", on_end_turn)
	get_parent().connect("on_next_action_selected", on_next_action_selected)
	bind_action_buttons()
	bind_mythora_swap_buttons()

func on_begin_turn() -> void:
	reset_menus()
	
	if get_parent().player_action == null:
		for i in range(combat_action_buttons.size()):
			combat_action_buttons[i].disabled = false
		for i in range(action_buttons.size()):
			action_buttons[i].disabled = false
		for i in range(mythora_swap_buttons.size()):
			mythora_swap_buttons[i].disabled = false
	else:
		for i in range(action_buttons.size()):
			action_buttons[i].disabled = true
	
	bind_combat_action_buttons()

func bind_action_buttons() -> void:
	combat_action_button.connect("pressed", open_close_menus.bind(combat_actions_container, actions_container))
	team_action_button.connect("pressed", open_close_menus.bind(mythora_team_container, actions_container))
	#bag_action_button.connect("pressed", open_close_menus.bind(bag_container, actions_container))
	#flee_action_button.connect("pressed", )
	

func reset_menus():
	actions_container.visible = true
	combat_actions_container.visible = false
	mythora_team_container.visible = false

func open_close_menus(open_container : VBoxContainer, close_container : VBoxContainer):
	open_container.visible = true
	close_container.visible = false


func bind_combat_action_buttons() -> void:
	var character : Character = get_parent().player_character
	
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

func bind_mythora_swap_buttons() -> void:
	var character : Character = get_parent().player_character
	
	for i in range(mythora_swap_buttons.size()):
		if i < character.mythora_team.size():
			mythora_swap_buttons[i].show()
			var mythora_data : Mythora_Res = character.mythora_team[i]
			mythora_swap_buttons[i].text = mythora_data.display_name
			
			if mythora_swap_buttons[i].is_connected("pressed", on_click_mythora_swap.bind(mythora_data)):
				mythora_swap_buttons[i].disconnect("pressed", on_click_mythora_swap.bind(mythora_data))
				
			mythora_swap_buttons[i].connect("pressed", on_click_mythora_swap.bind(mythora_data))
		else:
			mythora_swap_buttons[i].hide()

func on_end_turn() -> void:
	combat_text_label.text = ""


func on_click_combat_action(combat_action : CombatAction) -> void:
	get_parent().player_character.combat_action_selected(combat_action)
	
	for i in range(combat_action_buttons.size()):
		combat_action_buttons[i].disabled = true

func on_click_mythora_swap(mythora_data : Mythora_Res) -> void:
	get_parent().player_character.mythora_swap_selected(mythora_data)
	
	for i in range(combat_action_buttons.size()):
		mythora_swap_buttons[i].disabled = true

func on_next_action_selected(combat_message : String) -> void:
	combat_text_label.text = combat_message

func _on_combat_text_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().next_action()
