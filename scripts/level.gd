class_name Level extends Node2D

@export var level_name : String

@export var collectables : Array[Sprite2D]

signal level_completed(collected : Array[int])

func load_level() -> void:
	SignalHub.goal_reached.connect(on_level_complete)

func unload_level() -> void:
	SignalHub.goal_reached.disconnect(on_level_complete)

func on_level_complete() -> void:
	var collected : Array[int] = []
	for flake in collectables:
		collected.append(int(flake.collected))
	level_completed.emit(collected)
