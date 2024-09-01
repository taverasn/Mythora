extends Turn
class_name MythoraSwap_Turn

var new_mythora : Mythora_Res

func _init(_caster : Character, _turns : int, _new_mythora : Mythora_Res):
	super(_caster, _turns)
	
	new_mythora = _new_mythora

func do_turn() -> String:
	var combat_text = CombatText.get_swap_text(caster, new_mythora)
	
	caster.set_up_mythora(new_mythora)
	
	turns -= 1
	
	return combat_text
