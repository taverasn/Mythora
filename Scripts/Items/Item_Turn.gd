extends Turn
class_name Item_Turn

var item_info : Item_Info

func _init(_caster : Character, _turns : int, _item_info : Item_Info):
	super(_caster, _turns)
	
	item_info = _item_info

func do_turn() -> String:
	var combat_text = CombatText.get_item_text(caster, item_info)
	
	caster.use_item(item_info)
	
	turns -= 1
	
	return combat_text
