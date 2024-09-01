extends Character

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
	else:
		ca = get_combat_action()
	
	if ca != null:
		emit_signal("on_combat_action_selected", ca, self)

func get_combat_action_of_type(type : CombatAction.AttackType) -> CombatAction:
	var available_actions : Array[CombatAction] = []
	
	for element in combat_actions:
		if element.attack_type == type:
			available_actions.append(element)
	
	return available_actions[randi() % available_actions.size()]

func get_combat_action() -> CombatAction:
	var available_actions : Array[CombatAction] = []
	
	for element in combat_actions:
		if element.attack_type != CombatAction.AttackType.Heal:
			available_actions.append(element)
	
	return available_actions[randi() % available_actions.size()]

func has_combat_action_type(type : CombatAction.AttackType) -> bool:
	for element in combat_actions:
		if element.attack_type == type:
			return true;
		
	return false

func combat_action_selected(combat_action : CombatAction) -> void:
	emit_signal("on_combat_action_selected", combat_action, self)
