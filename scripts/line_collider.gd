class_name LineCollider 
extends Area2D

@onready var holder : CollisionShape2D = $LineRegion
@export var width : int = 20
var start_index : int
var end_index : int

func extend(point: Vector2):
	holder.shape.size.x = max(holder.shape.size.x, point.x + 10)
	holder.position.x = holder.shape.size.x /2 - 5

func set_start(point: Vector2, heading:Vector2, index: int):
	position=point
	look_at(to_global(heading))
