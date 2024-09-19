class_name Movement

var tile_size : int = 16 
var move_speed : float = 50
var sprite : Sprite2D
var movement_direction = Vector2()
var max_wait_time : float
var wait_time : float = 0
var is_moving : bool
var target_pos : Vector2
enum Movement_Action
{
	None,
	Right,
	Left,
	Up,
	Down
}
var character : CharacterBody2D

func _init(_character : CharacterBody2D, _tile_size : int, _move_speed : float, _sprite : Sprite2D, _tiles_per_second : int) -> void:
	_character.position = Vector2(_character.position + Vector2(_tile_size/2, _tile_size/2))
	self.character = _character
	self.tile_size = _tile_size
	self.move_speed = _move_speed
	self.sprite = _sprite
	self.max_wait_time = 1.0 / float(_tiles_per_second)

func set_movement_direction(movement_action : Movement_Action) -> void:
	if Movement_Action.Right == movement_action:
		movement_direction = Vector2(1, 0)
		sprite.look_at(character.position + movement_direction)
	elif Movement_Action.Left == movement_action:
		movement_direction = Vector2(-1, 0)
		sprite.look_at(character.position + movement_direction)
	elif Movement_Action.Up == movement_action:
		movement_direction = Vector2(0, -1)
		sprite.look_at(character.position + movement_direction)
	elif Movement_Action.Down == movement_action:
		movement_direction = Vector2(0, 1)
		sprite.look_at(character.position + movement_direction)
	else:
		movement_direction = Vector2()

func tick(delta: float, movement_action : Movement_Action) -> void:
	set_movement_direction(movement_action)
	
	wait_time += delta
	
	if movement_direction != Vector2() and wait_time >= max_wait_time and !is_moving:
		target_pos = character.position + movement_direction * tile_size
		wait_time = 0
		is_moving = true
		
	if is_moving:
		var movement = target_pos - character.position
		if movement.length() > 0:
			character.position += movement.normalized() * move_speed * delta
			if (character.position - target_pos).length() < move_speed * delta:
				character.position = target_pos
		
		if character.position == target_pos:
			is_moving = false
