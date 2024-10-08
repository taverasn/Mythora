class_name CombatText

static func get_combat_text(combat_action : CombatAction, damage : int, dealer : Mythora, receiver : Mythora, first_turn : bool) -> String:
	var combat_text : String = str(dealer.info.display_name, " Used ", combat_action.display_name, "!")
	var effectiveness : Nature.Effectiveness = receiver.nature.effectiveness(combat_action.nature_type)
	
	if combat_action.attack_type == CombatAction.AttackType.Status_Condition:
		combat_text = str(combat_text,
		get_status_condition_text(combat_action, effectiveness, receiver))
	elif combat_action.attack_type == CombatAction.AttackType.ResidualDamage and !first_turn:
		combat_text = str(receiver.info.display_name, " is Still Being Effected By ", combat_action.display_name, ".")
		combat_text = str(
		combat_text, 
		get_effectiveness_text(effectiveness),
		get_damage_dealt_text(combat_action, damage, dealer))
	else:
		combat_text = str(combat_text,
		get_effectiveness_text(effectiveness),
		get_damage_dealt_text(combat_action, damage, dealer),
		get_status_effect_text(combat_action.status_effected, combat_action.target, effectiveness, dealer.info.display_name, receiver.info.display_name))
	
	return combat_text

static func get_status_effect_text(status : CharacterStats.Stat, target : CombatAction.Target, effectiveness : Nature.Effectiveness, dealer : String, receiver : String) -> String:
	var status_effect_text : String
	
	match target:
		CombatAction.Target.Opponent:
			status_effect_text = receiver + "'s"
		CombatAction.Target.Self:
			status_effect_text = dealer + "'s"
	
	match status:
		CharacterStats.Stat.HP:
			status_effect_text += " HP will be reduced by"
		CharacterStats.Stat.Speed:
			status_effect_text += " Speed will be reduced by"
		CharacterStats.Stat.Armor:
			status_effect_text += " Armor will be reduced by"
		CharacterStats.Stat.Magic_Resist:
			status_effect_text += " Magic Resist will be reduced by"
		CharacterStats.Stat.Attack_Damage:
			status_effect_text += " Attack Damage will be reduced by"
		CharacterStats.Stat.Ability_Power:
			status_effect_text += " Ability Power will be reduced by"
		CharacterStats.Stat.None:
			return ""
	
	match effectiveness:
		Nature.Effectiveness.Weak:
			status_effect_text += " 5%"
		Nature.Effectiveness.Strong:
			status_effect_text += " 20%"
		Nature.Effectiveness.Neutral:
			status_effect_text += " 10%"
	
	return status_effect_text

static func get_damage_dealt_text(combat_action : CombatAction, damage : int, dealer : Mythora) -> String:
	var damage_dealt_text : String
	if combat_action.damage > 0:
		damage_dealt_text = str(" It Did ", damage, " Damage.")
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

static func get_status_condition_text(combat_action : CombatAction, effectiveness : Nature.Effectiveness, receiver : Mythora) -> String:
	var status_condition_text : String = str(get_effectiveness_text(effectiveness), " ", receiver.info.display_name)
	var status_condition : StatusCondition = StatusCondition.new(combat_action.status_condition, combat_action.nature_type)
	var damage_defense_multiplier : float = DamageHelpers.damage_defense_multiplier(effectiveness)
	var percentage_effected : float = status_condition.percentage_effected * 100 * damage_defense_multiplier
	
	if receiver.current_status_conditions.size() > 0:
		if receiver.current_status_conditions.filter(func(s : StatusCondition): return s.status_condition == status_condition.status_condition).size() > 0:
			match status_condition.status_condition:
				StatusCondition.StatusConditionType.Burnout:
					status_condition_text = str(" ", receiver.info.display_name, " is already Burnedout.")
				StatusCondition.StatusConditionType.Shocked:
					status_condition_text = str(" ", receiver.info.display_name, " is already Shocked.")
				StatusCondition.StatusConditionType.Winded:
					status_condition_text = str(" ", receiver.info.display_name, " is already Winded.")
				StatusCondition.StatusConditionType.Soaked:
					status_condition_text = str(" ", receiver.info.display_name, " is already Soaked.")
				StatusCondition.StatusConditionType.Petrify:
					status_condition_text = str(" ", receiver.info.display_name, " is already Petrified.")
			return status_condition_text
	
	
	
	match status_condition.status_condition:
		StatusCondition.StatusConditionType.Burnout:
			status_condition_text += " is Burnedout."
		StatusCondition.StatusConditionType.Shocked:
			status_condition_text += " is Shocked."
		StatusCondition.StatusConditionType.Winded:
			status_condition_text += " is Winded."
		StatusCondition.StatusConditionType.Soaked:
			status_condition_text += " is Soaked."
		StatusCondition.StatusConditionType.Petrify:
			status_condition_text += " is Petrified."
	
	for i in status_condition.statuses_effected.size():
		if i > 0:
			status_condition_text += " and"
		
		status_condition_text = str(status_condition_text, " ", CharacterStats.Stat.keys()[status_condition.statuses_effected[i]].replace("_", " "))
	
	status_condition_text = str(status_condition_text, " Lowered By ", percentage_effected, "%.")
	
	return status_condition_text

static func get_swap_text(caster : Mythora, new_mythora : Mythora_Info) -> String:
	var swap_text : String = str(caster.info.display_name, " is being swapped out for ", new_mythora.display_name)
	
	return swap_text

static func get_item_text(caster : Character, item_info : Item_Info) -> String:
	var item_text : String = str(caster.display_name, " is using ", item_info.display_name, " on ", caster.current_mythora.info.display_name, ".")
	item_text = str(item_text, " ", CharacterStats.Stat.keys()[item_info.stat_effected].replace("_", " "), " will be increased by ", item_info.amount)
	
	if item_info.effect_type == Item_Info.Item_Effect_Type.Percent:
		item_text = str(item_text,  "%")
	
	return item_text
