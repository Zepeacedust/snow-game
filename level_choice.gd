extends Control

@export var level_scene : PackedScene

var best_collected : Array[int] = [0,0,0]

var level : Level
func _ready() -> void:
	level = level_scene.instantiate()
	level.visible = false
	add_child(level)
	var flake_boxes = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer.get_children()
	$PanelContainer/MarginContainer/VBoxContainer/Button.text = level.level_name
	for i in range(3):
		flake_boxes[i].texture = level.collectables[i].texture
	update_info()
	level.close_level()
	
func update_info() -> void:
	var flake_boxes = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer.get_children()
	for i in range(3):
		if best_collected[i] == 0:
			flake_boxes[i].self_modulate = Color.BLACK
		else:
			flake_boxes[i].self_modulate = Color.WHITE

func compare_bests(collectables : Array[int]) -> void:
	if best_collected[0] + best_collected[1] +best_collected[2] < collectables[0] + collectables[1] +collectables[2]:
		best_collected = collectables
		update_info()

func _on_button_pressed() -> void:
	SignalHub.select_level.emit(level_scene)
