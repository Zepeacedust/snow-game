class_name Bridge
extends Path2D

# number of ticks the end of the bridge is in front of the player
@export var lead_ticks : int = 30
# maximum number of ticks that the constructs in one call to extend
@export var extension_rate : int = 2


@export var control_amount : float = 1
@export var line_visualizer : Line2D

var ghost_speed : float = NAN

func extend_bridge(from_index:int, curr_speed:float, desiredDirection:Vector2, delta: float):
	if desiredDirection == Vector2(0,0):
		desiredDirection = head_direction
	if is_nan(ghost_speed):
		ghost_speed = curr_speed
		for i in range(from_index, min(curve.point_count, from_index+lead_ticks)):
			ghost_speed = speed_change(i, ghost_speed, delta)
	var i = curve.point_count - 1
	var dest_ticks = min(from_index+lead_ticks, curve.point_count + extension_rate)
	while i <= dest_ticks:
		head_direction = (head_direction * ghost_speed + desiredDirection.normalized() * control_amount).normalized()
		ghost_speed = speed_change(i, ghost_speed, delta)
		add_point(curve.get_point_position(i) + head_direction*ghost_speed * delta)
		i += 1

func direction_from(from_index:int) -> Vector2:
	if from_index >= curve.point_count - 1:
		return head_direction
	return (curve.get_point_position(from_index+1) - curve.get_point_position(from_index))


func speed_change(from_index:int, curr_speed: float, delta:float):
	var next_vec = direction_from(from_index).normalized()
	var across = next_vec.y * ProjectSettings.get_setting("physics/2d/default_gravity")
	return curr_speed + across * delta

func add_point(point):
	self.curve.add_point(point)
	line_visualizer.add_point(point)

var head_direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curve = Curve2D.new()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
