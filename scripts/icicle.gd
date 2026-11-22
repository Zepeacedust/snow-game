class_name Icicle extends Polygon2D

@export var length_curve : Curve
var extension_chance : float = .7


@export_storage var bridge_points : Array[Vector2]


func make_shape() -> void:
	var new_points : Array[Vector2] = [bridge_points.pop_front()]
	for point in bridge_points:
		if randf() < extension_chance:
			new_points.append(point + Vector2.DOWN*length_curve.sample(randf()))
		else:
			new_points.append(point)
	new_points.pop_back()
	new_points.append(bridge_points[-1])
	polygon = new_points
	queue_redraw()
