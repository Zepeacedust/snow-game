class_name Crystal extends Node2D

@export var twirls : Array[Sprite2D]


func _process(_delta: float) -> void:
	twirls[0].rotate(.01)
	twirls[0].scale = lerp(twirls[1].scale, Vector2.ONE * randf_range(.22,.27), .2)
	twirls[1].rotate(.02)
	twirls[1].scale = lerp(twirls[1].scale, Vector2.ONE * randf_range(.22,.27), .2)
	twirls[2].rotate(.03)
	twirls[2].scale = lerp(twirls[2].scale, Vector2.ONE * randf_range(.22,.27), .2)

func _on_area_2d_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	SignalHub.refresh_ice.emit(100)
	# Make a collection animation
	queue_free()
