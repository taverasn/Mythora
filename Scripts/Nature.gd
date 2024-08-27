extends Resource
class_name Nature

enum Effectiveness {
	None = 0,
	Weak = 1,
	Neutral = 2,
	Strong = 3,
}

enum NatureType {
	None = 0,
	Water = 1,
	Fire = 2,
	Wind = 3,
	Earth = 4,
	Lightning = 5,
}

@export var type : NatureType
@export var water_effectiveness : Effectiveness = Effectiveness.Neutral
@export var fire_effectiveness : Effectiveness = Effectiveness.Neutral
@export var wind_effectiveness : Effectiveness = Effectiveness.Neutral
@export var earth_effectiveness : Effectiveness = Effectiveness.Neutral
@export var lightning_effectiveness : Effectiveness = Effectiveness.Neutral

func effectiveness(nature_type : NatureType) -> Effectiveness:
	match nature_type:
		NatureType.Water:
			return water_effectiveness
		NatureType.Fire:
			return fire_effectiveness
		NatureType.Wind:
			return wind_effectiveness
		NatureType.Earth:
			return earth_effectiveness
		NatureType.Lightning:
			return lightning_effectiveness
		NatureType.None:
			return Effectiveness.Neutral
	return Effectiveness.None
	
func damage_defense_multiplier(e : Effectiveness) -> float:
	match e:
		Effectiveness.Weak:
			return 0.5
		Effectiveness.Neutral:
			return 1
		Effectiveness.Strong:
			return 2
	return 1
