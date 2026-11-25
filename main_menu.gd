extends Node2D



func _ready() -> void:
	SignalHub.main_menu.connect(open)

func open() -> void:
	visible = true

func _on_levels_button_pressed() -> void:
	SignalHub.level_select_screen.emit()
	visible = false


func _on_credits_button_pressed() -> void:
	SignalHub.credits_screen.emit()
	visible = false


func _on_exit_button_pressed() -> void:
	get_tree().quit()
