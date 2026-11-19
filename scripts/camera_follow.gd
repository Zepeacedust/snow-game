extends Camera2D
@export var target : PhysicsBody2D
@export var SPEED : float

@export var LEAD_CURVE : Curve
@export var ZOOM_CURVE : Curve

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start at the destination no matter what the haters say
	if target:
		position = target.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		var target_speed = target.velocity.length()
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
		var scale : float = relative_offset * 1.5
		# zoom to keep in the inner 
		if scale < 1:
			scale = 1
		
		zoom = Vector2(1/scale, 1/scale)
