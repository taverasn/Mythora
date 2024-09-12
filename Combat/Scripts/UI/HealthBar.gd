extends Control

var style_box : StyleBoxFlat

func _ready():
	style_box = StyleBoxFlat.new()
	$ProgressBar.add_theme_stylebox_override("fill", style_box)
	style_box.bg_color = Color("14e114")
	MessageCenter.add_observer(self, "OnHealthChange", "_on_update_health")

func _on_update_health(msg : Dictionary) -> void:
	if msg.CharacterID != get_parent().get_instance_id():
		return
	
	var health_percentage = get_parent().get_health_percentage()
	var tween = get_tree().create_tween()
	tween.tween_property($ProgressBar, "value", health_percentage, .5).set_trans(Tween.TRANS_CUBIC)
	
	if health_percentage >= 60:
		style_box.bg_color = Color("14e114")
	elif health_percentage <= 60 and health_percentage >= 25:
		style_box.bg_color = Color("e1be32")
	else:
		style_box.bg_color = Color("e11e1e")
	
	$ProgressBar/Label.text = str(get_parent().current_mythora.current_stats.get_stat(CharacterStats.Stat.HP)) + " / " + str(get_parent().current_mythora.initial_stats.get_stat(CharacterStats.Stat.HP))
