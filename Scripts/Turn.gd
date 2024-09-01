class_name Turn

var caster : Character
var turns : int

func _init(_caster : Character, _turns : int):
	caster = _caster
	turns = _turns

func do_turn() -> String:
	return ""
