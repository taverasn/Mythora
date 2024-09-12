extends Turn
class_name MythoraSwap_Turn

var mythora_info : Mythora_Info

func _init(_caster : Character, _turns : int, _mythora_info : Mythora_Info):
	super(_caster, _turns)
	
	mythora_info = _mythora_info

func do_turn() -> String:
	var combat_text = CombatText.get_swap_text(caster.current_mythora, mythora_info)
	
	caster.set_up_mythora(mythora_info)
	
	turns -= 1
	
	return combat_text
