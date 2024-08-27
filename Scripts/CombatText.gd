class_name CombatText

static func get_combat_text(combat_action : CombatAction, damage : int, dealer : Character, receiver : Character) -> String:
	var combat_text : String = str(dealer.mythora_data.display_name, " Used ", combat_action.display_name, "!")
	var effectiveness : Nature.Effectiveness = receiver.nature.effectiveness(combat_action.nature_type)
	
	combat_text = str(
		combat_text, 
		get_effectiveness_text(effectiveness), 
		get_damage_dealt_text(combat_action, damage, dealer),
		get_status_effect_text(combat_action.status_effected, combat_action.target, effectiveness, dealer.mythora_data.display_name, receiver.mythora_data.display_name))
	
	return combat_text

static func get_residual_damage_text(combat_action : CombatAction, damage : int, dealer : Character, receiver : Character) -> String:
	var combat_text : String = str(combat_action.display_name, " is Still Active")
	var effectiveness : Nature.Effectiveness = receiver.nature.effectiveness(combat_action.nature_type)
	
	combat_text = str(
	combat_text, 
	get_effectiveness_text(effectiveness),
	get_damage_dealt_text(combat_action, damage, dealer))
	
	return combat_text

static func get_status_effect_text(status : CombatAction.Status, target : CombatAction.Target, effectiveness : Nature.Effectiveness, dealer : String, receiver : String) -> String:
	var status_effect_text : String
	
	match target:
		CombatAction.Target.Opponent:
			status_effect_text = receiver + "'s"
		CombatAction.Target.Self:
			status_effect_text = dealer + "'s"
	
	match status:
		CombatAction.Status.HP:
			status_effect_text += " HP will be reduced by"
		CombatAction.Status.Speed:
			status_effect_text += " Speed will be reduced by"
		CombatAction.Status.Armor:
			status_effect_text += " Armor will be reduced by"
		CombatAction.Status.Magic_Resist:
			status_effect_text += " Magic Resist will be reduced by"
		CombatAction.Status.Attack_Damage:
			status_effect_text += " Attack Damage will be reduced by"
		CombatAction.Status.Ability_Power:
			status_effect_text += " Ability Power will be reduced by"
		CombatAction.Status.None:
			return ""
	
	match effectiveness:
		Nature.Effectiveness.Weak:
			status_effect_text += " 5%"
		Nature.Effectiveness.Strong:
			status_effect_text += " 20%"
		Nature.Effectiveness.Neutral:
			status_effect_text += " 10%"
	
	return status_effect_text

static func get_damage_dealt_text(combat_action : CombatAction, damage : int, dealer : Character) -> String:
	var damage_dealt_text : String
	if combat_action.damage > 0:
		damage_dealt_text = str(" Did ", damage, " Damage.")
	elif combat_action.heal > 0:
		if dealer.current_health == dealer.max_health:
			damage_dealt_text = str(" Healed to Full Health.")
		else:
			damage_dealt_text = str(" Healed ", combat_action.heal, " HP.")
	
	return damage_dealt_text

static func get_effectiveness_text(effectiveness : Nature.Effectiveness) -> String:
	var effectiveness_text : String
	if effectiveness == Nature.Effectiveness.Weak:
		effectiveness_text = " It was Ineffective."
	elif effectiveness == Nature.Effectiveness.Strong:
		effectiveness_text = " It was Super Effective."
	elif effectiveness == Nature.Effectiveness.None:
		effectiveness_text = " ... Nothing Happened."
	
	return effectiveness_text
