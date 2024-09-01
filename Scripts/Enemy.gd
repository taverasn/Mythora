extends Character

var previous_combat_action : CombatAction

func on_begin_turn() -> void:
	if !is_player:
		determine_combat_action()

func determine_combat_action() -> void:
	var ca : CombatAction = null
	
	ca = get_combat_action()
	
	if ca != null:
		emit_signal("on_combat_action_selected", ca, self)

func get_combat_action() -> CombatAction:
	var combat_action : CombatAction = null
	
	for ca in combat_actions:
		if ca == previous_combat_action:
			continue
		
		if ca.attack_type == CombatAction.AttackType.Status_Condition and select_status_condition(ca):
			# Status condition move found, store it if no strong move has been found yet
			if combat_action == null or opponent.nature.effectiveness(combat_action.nature_type) != Nature.Effectiveness.Strong or combat_action.attack_type != CombatAction.AttackType.Status_Condition:
				combat_action = ca
		elif ca.attack_type == CombatAction.AttackType.ResidualDamage:
			# Residual Damage Move found store if no residual damage move is currently active
			if !casted_residual_damage_active:
				# And if no strong or status condition move has been found yet
				if combat_action == null or (combat_action.attack_type != CombatAction.AttackType.Status_Condition and opponent.nature.effectiveness(combat_action.nature_type) != Nature.Effectiveness.Strong):
					combat_action = ca
		elif ca.attack_type == CombatAction.AttackType.Status and select_status_move(ca):
			# Status move found, store it if no strong, status condition, or residual damage move has been found yet
			if combat_action == null or (combat_action.attack_type != CombatAction.AttackType.ResidualDamage and combat_action.attack_type != CombatAction.AttackType.Status_Condition and opponent.nature.effectiveness(combat_action.nature_type) != Nature.Effectiveness.Strong):
				combat_action = ca
		elif opponent.nature.effectiveness(ca.nature_type) == Nature.Effectiveness.Weak:
			continue
		elif ca.attack_type == CombatAction.AttackType.Regular || ca.attack_type == CombatAction.AttackType.MultiMoveDamage:
			if combat_action == null and opponent.nature.effectiveness(ca.nature_type) == Nature.Effectiveness.Strong:
				# Strong move found, store it and continue checking other moves
				combat_action = ca
		
	if combat_action == null:
		combat_action = combat_actions[randi() % combat_actions.size()]
	
	previous_combat_action = combat_action
	
	return combat_action

func has_combat_action_type(type : CombatAction.AttackType) -> bool:
	for element in combat_actions:
		if element.attack_type == type:
			return true;
		
	return false

func combat_action_selected(combat_action : CombatAction) -> void:
	emit_signal("on_combat_action_selected", combat_action, self)
	

func select_status_condition(combat_action : CombatAction) -> bool:
	if opponent.current_status_conditions.size() == 0:
		return true
		
	if opponent.current_status_conditions[0].status_condition != combat_action.status_condition:
		return true
	
	return false
	
func select_status_move(combat_action : CombatAction) -> bool:
	if opponent.current_stats.get_stat(combat_action.status_effected) > current_stats.get_stat(combat_action.status_effected):
		return true
	
	return false
