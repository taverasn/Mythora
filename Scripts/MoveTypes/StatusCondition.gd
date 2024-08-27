class_name StatusCondition

enum StatusConditionType {
	None = 0,
	# Reduces Attack Power Over Time: 5% Each Turn
	# Nature: Fire
	Burnout = 1,
	# Target Occasionally Flinches Unable to Attack: 50% Chance
	# Nature: Lightning
	Shocked = 2,
	# Targets Speed Reduced: 20% While Active
	# Nature: Wind
	Winded = 3,
	# Defense and Speed are Lowered: 10% While Active
	# Nature: Water
	Soaked = 4,
	# Reduces Attack Power and Speed: 10% While Active
	# Nature: Earth
	Petrify = 5
}

var status_condition : StatusConditionType
var percentage_effected : float
var increased_per_turn : bool
var statuses_effected : Array[CombatAction.Status]
var nature : Nature.NatureType

func _init(_status_condition : StatusConditionType, _nature : Nature.NatureType):
	self.status_condition = _status_condition
	self.nature = _nature
	
	match _status_condition:
		StatusConditionType.Burnout:
			set_up(0.05, [CombatAction.Status.Attack_Damage, CombatAction.Status.Ability_Power], true)
		StatusConditionType.Shocked:
			set_up(0.5)
		StatusConditionType.Winded:
			set_up(0.2, [CombatAction.Status.Speed])
		StatusConditionType.Soaked:
			set_up(0.1, [CombatAction.Status.Speed, CombatAction.Status.Armor, CombatAction.Status.Magic_Resist])
		StatusConditionType.Petrify:
			set_up(0.1, [CombatAction.Status.Speed, CombatAction.Status.Attack_Damage, CombatAction.Status.Ability_Power])

func set_up(_percentage_effected : float, _statuses_effected : Array[CombatAction.Status] = [], _increased_per_turn : bool = false) -> void:
	self.percentage_effected = _percentage_effected
	self.statuses_effected = _statuses_effected
	self.increased_per_turn = _increased_per_turn
