extends Camera2D
@export var target : PhysicsBody2D
@export var SPEED : float

@export var MINIMUM_ZOOM : int = 1
@export var SCALE_FACTOR : float = 1.5

enum CameraMode {
	FOLLOWING,
	DIRECTED,
	AUTODIRECT
}

@onready var goal =  get_tree().get_first_node_in_group("Goal").global_position
@onready var start =  get_tree().get_first_node_in_group("PlayerStart")

@export var camera_mode : CameraMode = CameraMode.FOLLOWING

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	autodirect_timer = wide_time
	# Start at the destination no matter what the haters say
	if target and camera_mode == CameraMode.FOLLOWING:
		position = target.position

func follow_mode(delta):
	# keep camera 0.5-ish seconds ahead of the player
	position = lerp(position, 
					target.position + target.velocity * 0.5, 
					SPEED * delta)
	var difference = target.position - position
	# how far the player is from the centre relative to the axes of the viewport
	var relative_offset = Vector2(
		difference.x/get_viewport_rect().size.x, 
		difference.y/get_viewport_rect().size.y
		).length() * 2 
	# times 2 since we are measuring from the centre not an edge
	
	# Fallback in case we are exactly centred.
	if relative_offset == 0:
		zoom = Vector2(1,1)
		return
		
	var cam_scale : float = relative_offset * SCALE_FACTOR
	# zoom to keep in the inner 
	if cam_scale < MINIMUM_ZOOM:
		cam_scale = MINIMUM_ZOOM
	
	zoom = Vector2(1/cam_scale, 1/cam_scale)

@export var world_rect : Rect2

@export_category("Autodirect parameters")
@export var wide_time : float
@export var goal_time : float
@export var goal_into_time : float
@export var player_into_time : float

var autodirect_timer = wide_time
var autodirect_destination
var autodirect_scale
var autodirect_start
var autodirect_start_scale


enum AutoDirectState {
	WIDE_SHOT_WAIT,
	GOAL_INTO,
	GOAL_WAIT,
	PLAYER_INTO,
	PLAYER_WAIT,
}
var autodirect_state = AutoDirectState.WIDE_SHOT_WAIT

func wide_shot_wait(timer:float):
	if autodirect_timer < 0:
		autodirect_state = AutoDirectState.GOAL_INTO
		autodirect_start = global_position
		autodirect_start_scale = zoom
		autodirect_timer = goal_into_time
		print_debug("wide shot timer")

func goal_into(timer : float):
	if autodirect_timer < 0:
		autodirect_timer = goal_time
		autodirect_state = AutoDirectState.GOAL_WAIT
		print_debug("goal_into_timer", goal)
		return
	global_position = lerp(autodirect_start, goal,1- clamp(autodirect_timer / goal_into_time, 0, 1))
	zoom = lerp(autodirect_start_scale, Vector2(1,1) / max(SCALE_FACTOR, MINIMUM_ZOOM), 1-clamp(autodirect_timer / goal_into_time, 0, 1))
	

func goal_wait(timer: float):
	if autodirect_timer < 0:
		autodirect_timer = player_into_time
		autodirect_state = AutoDirectState.PLAYER_INTO
		autodirect_start = global_position
		autodirect_start_scale = zoom
		print_debug("goal timer")

func player_into(timer : float):
	if autodirect_timer < 0:
		autodirect_timer = -1
		autodirect_state = AutoDirectState.PLAYER_WAIT
		print_debug("player_into_timer", start)
		return
	global_position = lerp(autodirect_start, start.global_position, 1- clamp(autodirect_timer / player_into_time, 0, 1))
	zoom = lerp(autodirect_start_scale, Vector2(1,1) / max(SCALE_FACTOR, MINIMUM_ZOOM), 1- clamp(autodirect_timer / goal_into_time, 0, 1))
	


func player_wait(timer: float):
	if Input.is_anything_pressed():
		camera_mode = CameraMode.FOLLOWING


func autodirect_mode(delta):
	if Input.is_anything_pressed():
		camera_mode = CameraMode.FOLLOWING
		return
	autodirect_timer -= delta
	match autodirect_state:
		AutoDirectState.WIDE_SHOT_WAIT:
			wide_shot_wait(autodirect_timer)
		AutoDirectState.GOAL_INTO:
			goal_into(autodirect_timer)
		AutoDirectState.GOAL_WAIT:
			goal_wait(autodirect_timer)
		AutoDirectState.PLAYER_INTO:
			player_into(autodirect_timer)
		AutoDirectState.PLAYER_WAIT:
			player_wait(autodirect_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target and camera_mode == CameraMode.FOLLOWING:
		follow_mode(delta)
	if camera_mode == CameraMode.AUTODIRECT:
		autodirect_mode(delta)
