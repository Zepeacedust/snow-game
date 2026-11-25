extends Polygon2D

@export var colision_shape :CollisionPolygon2D
@export var visual_layers : Array[Polygon2D]
@export var outline : Line2D
@export var snow_enabled := false
@export var snow_thickness := 24.0
@export var snow_color := Color(0.96, 0.98, 1.0, 1.0)
@export_range(0.0, 90.0) var snow_max_slope_degrees := 55.0

func _ready() -> void:
	use_parent_material = true
	colision_shape.polygon = polygon
	for layer in visual_layers:
		layer.color = color
		layer.polygon = polygon
		layer.uv = uv
	outline.points = polygon
	outline.default_color = color
	if snow_enabled:
		_add_snow()

# Lays a strip of snow along every edge whose outward normal faces upward
func _add_snow() -> void:
	var count := polygon.size()
	var area := 0.0
	for i in count:
		var a := polygon[i]
		var b := polygon[(i + 1) % count]
		area += a.x * b.y - b.x * a.y
	var winding := 1.0 if area > 0.0 else -1.0
	var min_up := cos(deg_to_rad(snow_max_slope_degrees))
	for i in count:
		var a := polygon[i]
		var b := polygon[(i + 1) % count]
		var edge := b - a
		if edge.length() < 1.0:
			continue
		var outward := Vector2(edge.y, -edge.x).normalized() * winding
		if -outward.y < min_up:
			continue
		var offset := -outward * snow_thickness * 0.5
		var snow := Line2D.new()
		snow.points = PackedVector2Array([a + offset, b + offset])
		snow.width = snow_thickness
		snow.default_color = snow_color
		snow.antialiased = true
		add_child(snow)
