class_name DamageHelpers

static func damage_defense_multiplier(e : Nature.Effectiveness) -> float:
	match e:
		Nature.Effectiveness.Weak:
			return 0.5
		Nature.Effectiveness.Neutral:
			return 1
		Nature.Effectiveness.Strong:
			return 2
	return 1
