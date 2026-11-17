extends CharacterBody2D

signal start_bridge
signal end_bridge

@export_category("Movement Attributes")
@export var SPEED : float = 300.0

@export var JUMP_VELOCITY : float = -400.0

@export var ACCEL_CURVE : Curve

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_vector("left", "right", "up", "down")
	if direction and is_on_floor():
		velocity.x = direction.x * SPEED
	elif direction:
		velocity = velocity * 0.9 + 0.1 * direction * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
