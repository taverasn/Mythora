class_name Turn

var caster : Character
var combat_action : CombatAction
var turns : int
var first_turn : bool = true

func _init(_caster : Character, _combat_action : CombatAction, _turns : int):
	caster = _caster
	combat_action = _combat_action
	turns = _turns

func cast_combat_action() -> String:
	var combat_text = CombatText.get_combat_text(combat_action, 
		caster.opponent.calculate_damage(combat_action), 
		caster, 
		caster.opponent,
		first_turn)
	
	caster.cast_combat_action(combat_action)
	
	turns -= 1
	
	if first_turn:
		first_turn = false
	
	return combat_text 
