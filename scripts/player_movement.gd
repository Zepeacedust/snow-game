extends CharacterBody2D

signal start_bridge
signal end_bridge

var bridge_obj = preload("res://BridgeObject.tscn")

@export var FOOT_SIZE : float = 100

@export_category("Movement Attributes")
@export var SPEED : float = 300.0
@export var JUMP_VELOCITY : float = -400.0
@export var ACCEL_CURVE : Curve

# object of attatched bridge, or null if not attatched.
var bridge_attatched : Bridge
# location in the bridge
var bridge_index : int


# Find the point where the players foot is supposed to be
func determine_foot_loc() -> Vector2:
	var forward = velocity.normalized()
	if forward.x < 0:
		return Vector2(forward.y, -forward.x) * FOOT_SIZE
	return Vector2(-forward.y, forward.x) * FOOT_SIZE


# Handle movement while the player is attatched to the bridge
func bridge_movement(delta: float, desired_direction) -> void:
	var cur_speed = velocity.length()
	if Input.get_action_strength("bridge"):
		# If not on bridge but making a bridge, push bridge.
		if bridge_attatched == null:
			bridge_index = 0
			bridge_attatched = bridge_obj.instantiate()
			add_sibling(bridge_attatched)
			bridge_attatched.init(position + determine_foot_loc(), velocity.normalized())

			
		bridge_attatched.extend_bridge(bridge_index, cur_speed, desired_direction, delta)
	if Input.is_action_just_pressed("jump"):
		bridge_attatched = null
		return
	if bridge_index >= bridge_attatched.curve.point_count:
		bridge_attatched = null
		return
	# Slightly mad on-bridge movement
	bridge_attatched.extend_bridge(bridge_index, cur_speed, desired_direction, delta)
	position = bridge_attatched.position + bridge_attatched.curve.get_point_position(bridge_index) - determine_foot_loc()
	velocity = bridge_attatched.direction_from(bridge_index).normalized() * bridge_attatched.speed_change(bridge_index, velocity.length(), delta)
	move_and_slide()
	if get_last_slide_collision() != null:
		bridge_attatched = null
		return
	bridge_index += 1

# Movement when not attatched to the bridge
func unattatched_movement(delta: float, direction) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	if direction and is_on_floor():
		velocity.x = direction.x * SPEED
	elif direction:
		velocity.x = direction.x * SPEED
	else: 
		velocity.x = move_toward(velocity.x, 0, delta * SPEED)
	
	move_and_slide()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if bridge_attatched or Input.get_action_strength("bridge"):
		bridge_movement(delta, direction)
	else:
		unattatched_movement(delta, direction)
