extends Sprite2D

@export var speed : float
var combat_action : CombatAction

var target : Area2D

func initialize(projectile_target : Area2D, action : CombatAction) -> void:
	target = projectile_target
	combat_action = action

func _process(delta):
	if target == null:
		return
	
	position = position.move_toward(target.position, delta * speed)
	
	if position == target.position:
		target.take_damage(combat_action)
		queue_free()
