class_name PlayerMovement
extends CharacterBody2D

var bridge_obj = preload("res://scenes/BridgeObject.tscn")

@export var FOOT_SIZE : float = 100

@export_category("Movement Attributes")
@export var SPEED : float = 300.0
@export var JUMP_VELOCITY : float = -400.0
@export var ACCEL_CURVE : Curve
@export var AIR_PIVOT : Curve
@export var BRIDGE_BOOST : float
@export var DETATCH_BOOST : float

@export_category("Bridge Attributes")
@export var max_meter : float = 100
@export var meter_recharge : float = 1
@export var meter_depletion : float = .5
@export_range(0.0,1.0) var bridge_start_preference : float = .3


# object of attatched bridge, or null if not attatched.
var bridge_attatched : Bridge
# location in the bridge
var bridge_index : int

@onready var meter_particles : CPUParticles2D = $Meter
@onready var meter_bar : ProgressBar = $HUD/MeterBar
@onready var current_meter : float = max_meter

func _ready() -> void:
	SignalHub.refresh_ice.connect(refresh_ice)
	SignalHub.modify_bridge_meter.connect(modify_bridge_meter)
	meter_bar.max_value = max_meter
# Find the point where the players foot is supposed to be
func determine_foot_loc() -> Vector2:
	var forward = velocity.normalized()
	if forward.x < 0:
		return Vector2(forward.y, -forward.x) * FOOT_SIZE
	return Vector2(-forward.y, forward.x) * FOOT_SIZE

func refresh_ice(ammount : float) -> void:
	current_meter = min(max_meter, current_meter+ammount)

func modify_bridge_meter(meter: float, recharge: float) -> void:
	current_meter = meter
	meter_recharge = recharge

func get_bridge_meter_info() -> Vector3:
	return Vector3(current_meter, meter_recharge, meter_depletion)

# Handle movement while the player is attatched to the bridge
func bridge_movement(delta: float, desired_direction) -> void:
	var cur_speed = velocity.length()
	var is_bridge_attatched = bridge_attatched != null
	if Input.get_action_strength("bridge"):
		# If not on bridge but making a bridge, push bridge.
		if !is_bridge_attatched and current_meter > 0:
			bridge_attatched = bridge_obj.instantiate()
			add_sibling(bridge_attatched)
			bridge_attatched.position = position + determine_foot_loc()
			bridge_attatched.curve.add_point(Vector2(0,0))
			bridge_index=0
			var new_angle : Vector2 = lerp(velocity.normalized(),desired_direction, bridge_start_preference) 
			#velocity += new_angle * BRIDGE_BOOST * (1- abs(new_angle.dot(velocity)))
			bridge_attatched.head_direction = new_angle
			
			
		if is_bridge_attatched:
			bridge_attatched.extend_bridge(bridge_index, cur_speed, desired_direction, delta)
	if is_bridge_attatched:
		if Input.is_action_just_pressed("jump"):
			bridge_attatched = null
			velocity.y += JUMP_VELOCITY
			return
		if bridge_index >= bridge_attatched.curve.point_count - 1:
			bridge_attatched = null
			velocity += velocity.normalized() * DETATCH_BOOST
			print("detatch")
			return
		# Slightly mad on-bridge movement
		if current_meter > 0 :
			bridge_attatched.extend_bridge(bridge_index, cur_speed, desired_direction, delta)
		position = bridge_attatched.position + bridge_attatched.curve.get_point_position(bridge_index) - determine_foot_loc()
		velocity = bridge_attatched.direction_from(bridge_index).normalized() * bridge_attatched.speed_change(bridge_index, velocity.length(), delta)
		meter_particles.position = to_local(bridge_attatched.to_global(bridge_attatched.curve.get_point_position(bridge_attatched.curve.point_count - 2)))
		move_and_slide()
		if get_last_slide_collision() != null:
			bridge_attatched = null
			return
		bridge_index += 1
		current_meter = max(0, current_meter - meter_depletion)
		print_debug((velocity.length()), bridge_attatched.head_direction, bridge_attatched.ghost_speed)

# Movement when not attatched to the bridge
func unattatched_movement(delta: float, direction) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY


	if direction and is_on_floor():
		velocity.x =move_toward(velocity.x, direction.x*SPEED, delta*SPEED*5)
	elif direction:
		velocity.x = move_toward(velocity.x, direction.x*SPEED, delta *SPEED*AIR_PIVOT.sample(direction.dot(velocity)) )
	else: 
		velocity.x = move_toward(velocity.x, 0, delta * SPEED)
	
	move_and_slide()
	current_meter = min(max_meter,current_meter + meter_recharge)

func _process(_delta: float) -> void:
	meter_bar.value = current_meter

func _physics_process(delta: float) -> void:
	# Add the gravity.
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if bridge_attatched or Input.get_action_strength("bridge"):
		meter_particles.visible = true
		meter_particles.lifetime = lerp(.001,2.0,float(current_meter/max_meter)**2)
		meter_particles.scale_amount_min = lerp(0.0,.2,float(current_meter/max_meter))
		meter_particles.scale_amount_max = lerp(0.0,.3,float(current_meter/max_meter))
		meter_particles.emission_sphere_radius = lerp(16.0,64.0,float(current_meter/max_meter))
		bridge_movement(delta, direction)
	else:
		meter_particles.visible = false
		unattatched_movement(delta, direction)
