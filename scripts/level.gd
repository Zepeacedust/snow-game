class_name Level extends Node2D

var level_clear_screen : PackedScene = preload("res://level_clear_screen.tscn")

@export var level_name : String
@export var collectables : Array[Sprite2D]

var time : float = 0.0

func _ready() -> void:
	SignalHub.goal_reached.connect(goal_reached)
	# TODO : Start zoomed out, zoom into goal, move to player


func _process(delta: float) -> void:
	# TODO : Make it so time doesn't start until first input
	time += delta
	


func goal_reached() -> void:
	# TODO : Add zoom out to see level 
	var clear_screen : LevelClearScreen = level_clear_screen.instantiate()
	clear_screen.update_clear_info(level_name, collectables, snappedf(time,.1))
	$SnowflakeDisplay.add_child(clear_screen)
