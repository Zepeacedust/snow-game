extends Camera2D

@export var target : Node2D
@export var SPEED : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target:
		position = target.position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		position = lerp(position, target.position, SPEED * delta)
	pass
