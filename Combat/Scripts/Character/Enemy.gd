extends Character

var previous_combat_action : CombatAction

func _on_begin_turn(_msg : Dictionary) -> void:
	if !is_player:
		if current_mythora.is_dead:
			mythora_died()
		else:
			determine_action()

func determine_action() -> void:
	if should_swap_mythora():
		var m : Mythora_Info = null
		m = get_mythora()
		if m != null:
			var msg : Dictionary = {
				"Type": "OnMythoraSwapSelected",
				"MythoraInfo": m,
				"Character": self
			}
			MessageCenter.post_msg(msg)
	elif should_and_can_use_item():
		var i : Item_Info = null
		i = backpack[0].info
		var msg : Dictionary = {
			"Type": "OnUseItemSelected",
			"ItemInfo": i,
			"Character": self
		}
		MessageCenter.post_msg(msg)
	else:
		var ca : CombatAction = null
		ca = get_combat_action()
		
		if ca != null:
			var msg : Dictionary = {
				"Type": "OnCombatActionSelected",
				"CombatAction": ca,
				"Character": self
			}
			MessageCenter.post_msg(msg)

func get_mythora() -> Mythora_Info:
	var m : Mythora_Info = null
	var living_mythora_team : Array[Mythora] = mythora_team.filter(func(mythora : Mythora): if mythora.info.display_name != current_mythora.info.display_name: return !mythora.is_dead)
	
	for mythora in living_mythora_team:
		if opponent.current_mythora.nature.effectiveness(mythora.nature.type) == Nature.Effectiveness.Strong:
			m = mythora.info
	
	if m == null and living_mythora_team.size() > 0:
		m = living_mythora_team[randi() % living_mythora_team.size()].info
	
	return m

func should_and_can_use_item() -> bool:
	if current_mythora.current_stats.get_stat(CharacterStats.Stat.HP) < float(current_mythora.initial_stats.get_stat(CharacterStats.Stat.HP)) * 0.2:
		if backpack.size() > 0:
			return true
	return false

func should_swap_mythora() -> bool:
	if mythora_team.filter(func(m): return !m.is_dead).size() <= 1:
		return false
	
	if current_mythora.nature.effectiveness(opponent.current_mythora.nature.type) == Nature.Effectiveness.Strong:
		return true
	
	if get_health_percentage() < 10:
		return true
	
	return false

func get_combat_action() -> CombatAction:
	var combat_action : CombatAction = null
	
	for ca in current_mythora.combat_actions:
		if ca == previous_combat_action:
			continue
		
		if opponent.current_mythora.calculate_damage(ca, current_mythora.current_stats) >= opponent.current_mythora.current_stats.get_stat(CharacterStats.Stat.HP):
			combat_action = ca
			break
		elif ca.attack_type == CombatAction.AttackType.Status_Condition and select_status_condition(ca):
			# Status condition move found, store it if no strong move has been found yet
			if combat_action == null or opponent.current_mythora.nature.effectiveness(combat_action.nature_type) != Nature.Effectiveness.Strong or combat_action.attack_type != CombatAction.AttackType.Status_Condition:
				combat_action = ca
		elif ca.attack_type == CombatAction.AttackType.ResidualDamage:
			# Residual Damage Move found store if no residual damage move is currently active
			if !casted_residual_damage_active:
				# And if no strong or status condition move has been found yet
				if combat_action == null or (combat_action.attack_type != CombatAction.AttackType.Status_Condition and opponent.current_mythora.nature.effectiveness(combat_action.nature_type) != Nature.Effectiveness.Strong):
					combat_action = ca
		elif ca.attack_type == CombatAction.AttackType.Status and select_status_move(ca):
			# Status move found, store it if no strong, status condition, or residual damage move has been found yet
			if combat_action == null or (combat_action.attack_type != CombatAction.AttackType.ResidualDamage and combat_action.attack_type != CombatAction.AttackType.Status_Condition and opponent.current_mythora.nature.effectiveness(combat_action.nature_type) != Nature.Effectiveness.Strong):
				combat_action = ca
		elif opponent.current_mythora.nature.effectiveness(ca.nature_type) == Nature.Effectiveness.Weak:
			continue
		elif ca.attack_type == CombatAction.AttackType.Regular || ca.attack_type == CombatAction.AttackType.MultiMoveDamage:
			if combat_action == null and opponent.current_mythora.nature.effectiveness(ca.nature_type) == Nature.Effectiveness.Strong:
				# Strong move found, store it and continue checking other moves
				combat_action = ca
		
	if combat_action == null:
		combat_action = current_mythora.combat_actions[randi() % current_mythora.combat_actions.size()]
	
	previous_combat_action = combat_action
	
	return combat_action

func has_combat_action_type(type : CombatAction.AttackType) -> bool:
	for element in current_mythora.combat_actions:
		if element.attack_type == type:
			return true;
		
	return false

func select_status_condition(combat_action : CombatAction) -> bool:
	if opponent.current_mythora.current_status_conditions.size() == 0:
		return true
		
	if opponent.current_mythora.current_status_conditions[0].status_condition != combat_action.status_condition:
		return true
	
	return false

func select_status_move(combat_action : CombatAction) -> bool:
	if opponent.current_mythora.current_stats.get_stat(combat_action.status_effected) > current_mythora.current_stats.get_stat(combat_action.status_effected):
		return true
	
	return false

func mythora_died() -> void:
	super.mythora_died()
	var m : Mythora_Info = null
	m = get_mythora()
	if m != null:
		var msg : Dictionary = {
			"Type": "OnMythoraSwapSelected",
			"MythoraInfo": m,
			"Character": self
		}
		MessageCenter.post_msg(msg)
