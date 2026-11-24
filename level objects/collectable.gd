extends Sprite2D

@export var holder : Sprite2D
@export var speed : float
var collected : bool = false

func _ready() -> void:
	holder.texture = texture

func _process(_delta: float) -> void:
	if collected:
		holder.modulate = lerp(holder.modulate,Color(1.0, 1.0, 1.0, 1.0),speed)
		holder.scale = lerp(holder.scale, Vector2.ONE *.9, speed)


func _on_area_2d_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if not collected:
		collected = true
		visible = false
		
