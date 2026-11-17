extends CharacterBody2D

signal start_bridge
signal end_bridge

var bridge_obj = preload("res://BridgeObject.tscn")

@export_category("Movement Attributes")
@export var SPEED : float = 300.0

@export var JUMP_VELOCITY : float = -400.0
@export var ACCEL_CURVE : Curve

# object of attatched bridge, or null if not attatched.
var bridge_attatched : Bridge
# location in the bridge
var bridge_index : int

func determine_foot_loc() -> Vector2:
	var forward = velocity.normalized()
	if forward.x > 0:
		return Vector2(forward.y, -forward.x)
	return Vector2(-forward.y, forward.x)

func bridge_movement(delta: float, desired_direction) -> void:
	var cur_speed = velocity.length()
	if Input.get_action_strength("bridge"):
		if not bridge_attatched:
			bridge_attatched = bridge_obj.instantiate()
			bridge_attatched.position = position + determine_foot_loc()
			bridge_attatched.curve.add_point(Vector2(0,0))
			bridge_index=0
			bridge_attatched.head_direction = velocity.normalized()
			
		bridge_attatched.extend_bridge(bridge_index, cur_speed, desired_direction, delta)
	if Input.is_action_just_pressed("jump"):
		bridge_attatched = null
		return
	bridge_index += 1
	bridge_attatched.extend_bridge(bridge_index, cur_speed, desired_direction, delta)
	position = bridge_attatched.position + bridge_attatched.curve.get_point_position(bridge_index)
	print_debug(bridge_index)
func unattatched_movement(delta: float, direction) -> void:
	if direction and is_on_floor():
		velocity.x = direction.x * SPEED
	elif direction:
		velocity = velocity * 0.9 + 0.1 * direction * SPEED
	
	move_and_slide()



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not bridge_attatched:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_vector("left", "right", "up", "down")
	
	if bridge_attatched or Input.get_action_strength("bridge"):
		bridge_movement(delta, direction)
	else:
		unattatched_movement(delta, direction)
