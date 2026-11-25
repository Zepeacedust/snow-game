extends Polygon2D

@export var colision_shape :CollisionPolygon2D
@export var visual_layers : Array[Polygon2D]
@export var outline : Line2D

func _ready() -> void:
	use_parent_material = true
	colision_shape.polygon = polygon
	for layer in visual_layers:
		layer.color = color
		layer.polygon = polygon
		layer.uv = uv
	outline.points = polygon
	outline.default_color = color
