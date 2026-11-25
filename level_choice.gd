extends Node2D

@export var level : Level

var best_collected : Array[int] = [0,0,0]

func _ready() -> void:
	$Level/PanelContainer/MarginContainer/VBoxContainer/NameLabel.text = level.level_name
	update_info()
	
func update_info() -> void:
	var flake_boxes = $Level/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer.get_children()
	for i in range(3):
		flake_boxes[i].texture = level.colectables[i]
		if best_collected[i] == 0:
			flake_boxes[i].self_modulate = Color.BLACK
		else:
			flake_boxes[i].self_modulate = Color.WHITE

func compare_bests(collectables : Array[int]) -> void:
	if best_collected[0] + best_collected[1] +best_collected[2] < collectables[0] + collectables[1] +collectables[2]:
		best_collected = collectables
		update_info()

func _on_button_pressed() -> void:
	level.load()
