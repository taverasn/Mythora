class_name ResidualDamageMove

enum ResidualDamageType {
	None = 0,
	DOT = 1,
	Drain = 2
}

var turns_active : int
var residual_damage_type : ResidualDamageType
var display_name : String
var combat_action : CombatAction

func _init(_turns_active: int, _residual_damage_type: ResidualDamageType, _display_name : String, _combat_action : CombatAction):
	self.turns_active = _turns_active
	self.residual_damage_type = _residual_damage_type
	self.display_name = _display_name
	self.combat_action = _combat_action
	
func next_turn() -> void:
	if turns_active > 0:
		turns_active -= 1
