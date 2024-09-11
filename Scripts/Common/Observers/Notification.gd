class_name Notification

var name : String
var observers : Array[Observer]

func _init(_name : String) -> void:
	name = _name
	observers = []

func add_observer(_object : Node, _action : String) -> void:
	observers.append(Observer.new(_object, _action))
