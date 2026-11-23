extends Polygon2D

@export var colision_shape :CollisionPolygon2D

func _ready() -> void:
	colision_shape.polygon = polygon
