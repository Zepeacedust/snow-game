class_name Level extends Node2D

var level_complete_screen : PackedScene = preload("res://level_clear_screen.tscn")

@export var level_name : String

@export var collectables : Array[Sprite2D]

var camera : Camera2D
var time : float = 0.0
signal level_completed(collected : Array[int])

var start_position : Vector2 = Vector2.ZERO
func _ready() -> void:
	camera = $Camera2D
	SignalHub.level_select_screen.connect(close_level)
	start_position = $CharacterBody2D.position
	load_level()

func load_level() -> void:
	SignalHub.goal_reached.connect(on_level_complete)
	SignalHub.reset_level.connect(reset_self)

func _process(delta: float) -> void:
	time += delta
	
func unload_level() -> void:
	SignalHub.goal_reached.disconnect(on_level_complete)

func on_level_complete() -> void:
	var collected : Array[int] = []
	for flake in collectables:
		collected.append(int(flake.collected))
	level_completed.emit(collected)
	var clear_screen :LevelClearScreen = level_complete_screen.instantiate()
	clear_screen.update_clear_info(level_name, collectables, snappedf(time,.1))
	$SnowflakeDisplay.add_child(clear_screen)

func close_level() -> void:
	queue_free()

func reset_self() -> void:
	for flake in collectables:
		flake.collected = false
		flake.visible = true
	$CharacterBody2D.position = start_position
	time = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		reset_self()
	if event.is_action_pressed("ui_cancel"):
		SignalHub.level_select_screen.emit()
