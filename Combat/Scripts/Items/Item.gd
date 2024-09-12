class_name Item

var info : Item_Info
var amount : int

func _init(_info : Item_Info = null, _amount : int = 1) -> void:
	info = _info
	amount = _amount

func use() -> void:
	amount -= 1
