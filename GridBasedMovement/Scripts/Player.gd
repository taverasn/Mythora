extends CharacterBody2D

class_name Player

@export var tile_size : int = 16 

## Maximum Nuber of Tiles that Can Be Moved Per Second
@export var tiles_per_second : int = 4
## Movement Speed Between Tiles. Increasing This Number to Much Can Make Movement Choppy. 
## Decreasing this Number to Much Will Cause Movement Below the tiles_per_second
@export var move_speed : float = 50

@onready var sprite : Sprite2D = $Sprite2D

var movement_direction = Vector2()
var max_wait_time : float
var wait_time : float = 0
var is_moving : bool
var target_pos : Vector2

func _ready() -> void:
	self.position = Vector2(self.position + Vector2(tile_size/2, tile_size/2))
	max_wait_time = 1.0 / float(tiles_per_second)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event.is_action_pressed("Right"):
			movement_direction = Vector2(1, 0)
			sprite.look_at(self.position + movement_direction)
		elif event.is_action_pressed("Left"):
			movement_direction = Vector2(-1, 0)
			sprite.look_at(self.position + movement_direction)
		elif event.is_action_pressed("Up"):
			movement_direction = Vector2(0, -1)
			sprite.look_at(self.position + movement_direction)
		elif event.is_action_pressed("Down"):
			movement_direction = Vector2(0, 1)
			sprite.look_at(self.position + movement_direction)
	elif !event.is_pressed():
		movement_direction = Vector2()

func _process(delta: float) -> void:
	wait_time += delta

	if movement_direction != Vector2() and wait_time >= max_wait_time and !is_moving:
		target_pos = self.position + movement_direction * tile_size
		wait_time = 0
		is_moving = true
		
	if is_moving:
		var movement = target_pos - self.position
		if movement.length() > 0:
			self.position += movement.normalized() * move_speed * delta
			if (self.position - target_pos).length() < move_speed * delta:
				self.position = target_pos
		
		if self.position == target_pos:
			is_moving = false
	

	
