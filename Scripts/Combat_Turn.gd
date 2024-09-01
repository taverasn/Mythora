extends Turn
class_name Combat_Turn 

var combat_action : CombatAction
var first_turn : bool = true

func _init(_caster : Character, _turns : int, _combat_action : CombatAction):
	super(_caster, _turns)
	combat_action = _combat_action
	
	if turns > 0 and combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
		if combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
			caster.casted_residual_damage_active = true

func do_turn() -> String:
	var combat_text : String = CombatText.get_combat_text(combat_action, 
		caster.opponent.calculate_damage(combat_action), 
		caster, 
		caster.opponent,
		first_turn)
	
	caster.cast_combat_action(combat_action)
	
	turns -= 1
	
	if turns <= 0 and combat_action.attack_type == CombatAction.AttackType.ResidualDamage:
		caster.casted_residual_damage_active = false
	
	if first_turn:
		first_turn = false
	
	return combat_text 
