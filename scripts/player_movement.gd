extends CharacterBody2D

signal start_bridge
signal end_bridge

var scene = preload("res://my_scene.tscn")

@export_category("Movement Attributes")
@export var SPEED : float = 300.0

@export var JUMP_VELOCITY : float = -400.0
@export var ACCEL_CURVE : Curve

var bridge_attatched : bridge_object
var bridge_index : int
var bridge_build

func bridge_movement(delta: float, direction) -> void:
	var cur_speed = velocity.length()

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
	
	if bridge_attatched:
		bridge_movement(delta, direction)
	else:
		unattatched_movement(delta, direction)
