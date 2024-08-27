extends Resource
class_name Mythora

@export var display_name : String
@export var nature : Nature
@export var move_set_dict : Dictionary
@export var starting_combat_actions : Array[CombatAction]
@export var visual : Texture2D

@export_category("BaseStats")
@export var hp : int
@export var speed : int
@export var armor : int
@export var magic_resist : int
@export var attack_damage : int
@export var ability_power : int
