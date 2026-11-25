class_name LevelClearScreen extends Control


func update_clear_info(level_name : String, collectables : Array[Sprite2D], time : float) -> void:
	$PanelContainer/MarginContainer/VBoxContainer/NameLabel.text = level_name
	
	var collectable_displays : Array[TextureRect] = [
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Collectable1,
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Collectable2,
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Collectable3
	]
	for i in range(3):
		collectable_displays[i].texture = collectables[i].texture
		if not collectables[i].collected:
			collectable_displays[i].self_modulate = Color(0.129, 0.098, 0.157, 1.0)
	
	$PanelContainer/MarginContainer/VBoxContainer/TimeLabel.text = "Time : " + str(time) + " s"


func _on_retry_button_pressed() -> void:
	SignalHub.reset_level.emit()
	queue_free()


func _on_levels_button_pressed() -> void:
	SignalHub.level_select_screen.emit()
	queue_free()
