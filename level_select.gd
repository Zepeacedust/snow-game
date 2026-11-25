extends Node2D


func _ready() -> void:
	SignalHub.level_select_screen.connect(activate)
	SignalHub.select_level.connect(load_level)
	

func activate() -> void:
	visible = true

func load_level(level_scene : PackedScene) -> void:
	var level = level_scene.instantiate()
	add_sibling(level)
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SignalHub.main_menu.emit()
		visible = false
