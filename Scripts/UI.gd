extends Control

@export var container : ColorRect
@export var combat_action_buttons : Array[Button]
@export var mythora_swap_buttons : Array[Button]
@export var mythora_team_container : VBoxContainer
@export var bag_container : VBoxContainer
@export var bag_buttons : Array[Button]
@export var combat_actions_container : VBoxContainer

@export_category("Action Buttons")
@export var actions_container : VBoxContainer
@export var action_buttons : Array[Button]
@export var combat_action_button : Button
@export var team_action_button : Button
@export var bag_action_button : Button
@export var flee_action_button : Button

@export var back_button : Button

var combat_text_label : RichTextLabel
var can_go_next_turn : bool

func _ready():
	combat_text_label = $Color_Background/Color_CombatTextBackground/MarginContainer/CombatText
	combat_text_label.text = ""
	get_parent().connect("on_begin_turn", on_begin_turn)
	get_parent().connect("on_end_turn", on_end_turn)
	get_parent().connect("on_first_turn", on_first_turn)
	get_parent().connect("on_next_action_selected", on_next_action_selected)
	bind_action_buttons()
	bind_mythora_swap_buttons()

func on_first_turn():
	can_go_next_turn = true

func on_begin_turn() -> void:
	reset_menus()
	bind_combat_action_buttons()
	bind_bag_buttons()

func bind_action_buttons() -> void:
	back_button.connect("pressed", reset_menus.bind())
	combat_action_button.connect("pressed", open_close_menus.bind(combat_actions_container, actions_container))
	team_action_button.connect("pressed", open_close_menus.bind(mythora_team_container, actions_container))
	bag_action_button.connect("pressed", open_close_menus.bind(bag_container, actions_container))
	#flee_action_button.connect("pressed", )

func bind_bag_buttons() -> void:
	var character = get_parent().player_character
	
	for i in range(bag_buttons.size()):
		if i < character.backpack.size():
			bag_buttons[i].show()
			var item_info : Item_Info = character.backpack[i].info
			bag_buttons[i].text = item_info.display_name
			
			if bag_buttons[i].is_connected("pressed", on_click_use_item.bind(item_info)):
				bag_buttons[i].disconnect("pressed", on_click_use_item.bind(item_info))
				
			bag_buttons[i].connect("pressed", on_click_use_item.bind(item_info))
		else:
			bag_buttons[i].hide()

func reset_menus():
	actions_container.visible = true
	combat_actions_container.visible = false
	mythora_team_container.visible = false
	bag_container.visible = false
	back_button.visible = false
	var character : Character = get_parent().player_character
	
	if character.current_mythora.is_dead:
		open_close_menus(mythora_team_container, actions_container)
		
	enable_disable_buttons()

func enable_disable_buttons() -> void:
	var character : Character = get_parent().player_character
	
	if get_parent().player_action == null:
		for i in range(combat_action_buttons.size()):
			combat_action_buttons[i].disabled = false
		for i in range(action_buttons.size()):
			action_buttons[i].disabled = false
		for i in range(mythora_swap_buttons.size()):
			if i < character.mythora_team.size():
				if character.mythora_team[i].is_dead or character.mythora_team[i] == character.current_mythora:
					mythora_swap_buttons[i].disabled = true
				else:
					mythora_swap_buttons[i].disabled = false
	else:
		for i in range(action_buttons.size()):
			action_buttons[i].disabled = true

func open_close_menus(open_container : VBoxContainer, close_container : VBoxContainer):
	open_container.visible = true
	close_container.visible = false
	if(open_container != actions_container):
		back_button.visible = true

func bind_combat_action_buttons() -> void:
	var mythora : Mythora = get_parent().player_character.current_mythora
	
	for i in range(combat_action_buttons.size()):
		if i < mythora.combat_actions.size():
			combat_action_buttons[i].show()
			var combat_action : CombatAction = mythora.combat_actions[i]
			combat_action_buttons[i].text = combat_action.display_name
			
			if combat_action_buttons[i].is_connected("pressed", on_click_combat_action.bind(combat_action)):
				combat_action_buttons[i].disconnect("pressed", on_click_combat_action.bind(combat_action))
				
			combat_action_buttons[i].connect("pressed", on_click_combat_action.bind(combat_action))
		else:
			combat_action_buttons[i].hide()

func bind_mythora_swap_buttons() -> void:
	var character : Character = get_parent().player_character
	
	for i in range(mythora_swap_buttons.size()):
		if i < character.mythora_infos.size():
			mythora_swap_buttons[i].show()
			var mythora_info : Mythora_Info = character.mythora_infos[i]
			mythora_swap_buttons[i].text = mythora_info.display_name
			
			if mythora_swap_buttons[i].is_connected("pressed", on_click_mythora_swap.bind(mythora_info)):
				mythora_swap_buttons[i].disconnect("pressed", on_click_mythora_swap.bind(mythora_info))
				
			mythora_swap_buttons[i].connect("pressed", on_click_mythora_swap.bind(mythora_info))
		else:
			mythora_swap_buttons[i].hide()

func on_end_turn() -> void:
	if !get_parent().game_over:
		combat_text_label.text = ""
	can_go_next_turn = false

func on_click_combat_action(combat_action : CombatAction) -> void:
	get_parent().player_character.combat_action_selected(combat_action)
	for i in range(combat_action_buttons.size()):
		combat_action_buttons[i].disabled = true

func on_click_mythora_swap(mythora_info : Mythora_Info) -> void:
	get_parent().player_character.mythora_swap_selected(mythora_info)
	
	for i in range(mythora_swap_buttons.size()):
		mythora_swap_buttons[i].disabled = true

func on_click_use_item(item_info : Item_Info) -> void:
	get_parent().player_character.use_item_selected(item_info)
	
	for i in range(bag_buttons.size()):
		bag_buttons[i].disabled = true

func on_next_action_selected(combat_message : String) -> void:
	combat_text_label.text = combat_message

func _on_combat_text_gui_input(event):
	if can_go_next_turn:
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				get_parent().next_action()
