class_name CharacterStats

var hp : int
var speed : int
var armor : int
var magic_resist : int
var attack_damage : int
var ability_power : int

func _init(_hp: int, _speed: int, _armor: int, _magic_resist: int, _attack_damage: int, _ability_power: int):
	self.hp = _hp
	self.speed = _speed
	self.armor = _armor
	self.magic_resist = _magic_resist
	self.attack_damage = _attack_damage
	self.ability_power = _ability_power
