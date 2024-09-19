extends CharacterBody2D
class_name Player

@export_category("Movement")
@export var tile_size : int = 16 
## Maximum Nuber of Tiles that Can Be Moved Per Second
@export var tiles_per_second : int = 4
## Movement Speed Between Tiles. Increasing This Number to Much Can Make Movement Choppy. 
## Decreasing this Number to Much Will Cause Movement Below the tiles_per_second
@export var move_speed : float = 50
@onready var sprite : Sprite2D = $Sprite2D
var movement : Movement
var most_recent_movement_actions : Array[Movement.Movement_Action]
var movement_actions : Dictionary

func _ready() -> void:
	most_recent_movement_actions.append(Movement.Movement_Action.None)
	most_recent_movement_actions.append(Movement.Movement_Action.Right)
	most_recent_movement_actions.append(Movement.Movement_Action.Left)
	most_recent_movement_actions.append(Movement.Movement_Action.Up)
	most_recent_movement_actions.append(Movement.Movement_Action.Down)
	movement_actions[Movement.Movement_Action.Right] = "Right"
	movement_actions[Movement.Movement_Action.Left] = "Left"
	movement_actions[Movement.Movement_Action.Up] = "Up"
	movement_actions[Movement.Movement_Action.Down] = "Down"
	
	movement = Movement.new(self, tile_size, move_speed, sprite, tiles_per_second)

func _input(event: InputEvent) -> void:
	handle_movement_input(event)

func handle_movement_input(event : InputEvent) -> void:
	for movement_action in movement_actions:
		if event.is_action_pressed(movement_actions[movement_action]):
			set_most_recent_action(movement_action, true)
		if event.is_action_released(movement_actions[movement_action]):
			set_most_recent_action(movement_action, false)

func set_most_recent_action(movement_action : Movement.Movement_Action, front : bool) -> void:
	for i in range(most_recent_movement_actions.size() - 1, -1, -1):
		if most_recent_movement_actions[i] == movement_action:
			most_recent_movement_actions.remove_at(i)
			if front:
				most_recent_movement_actions.push_front(movement_action)
			else:
				most_recent_movement_actions.push_back(movement_action)
			break

func _process(delta: float) -> void:
	movement.tick(delta, most_recent_movement_actions.front())
