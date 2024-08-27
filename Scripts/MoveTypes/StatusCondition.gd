class_name StatusCondition

enum StatusConditionType {
	None = 0,
	# Reduces Attack Power Over Time: 5%
	Burnout = 1,
	# Target Occasionally Flinches Unable to Attack: 50%
	Shocked = 2,
	# Targets Speed Reduced: 10%
	Winded = 3,
	# Defense and Speed are Lowered: 5%
	Soaked = 4,
	# Speed Lowered by Significant Amount: 20%
	Petrify = 5
}
