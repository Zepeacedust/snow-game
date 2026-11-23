extends Node2D

@export var hip : Bone2D
@export var player : PlayerMovement

@onready var hand1 = $Hand1Target
@onready var hand2 = $Hand2Target
@onready var leg1 = $Leg1Target
@onready var leg2 = $Leg2Target

var leg1_dest : Vector2
var leg2_dest : Vector2

class LegDirector:
	func _init(leg_controller:Marker2D) -> void:
		self.leg_controller = leg_controller
		self.default = 
	func tick() -> void:
		pass

func _process(delta: float) -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + Vector2(50, 100))
	var result = space_state.intersect_ray(query)
	if result:
		leg1_dest=result.position
	else:
		leg1_dest=global_position + Vector2(10,30)
	if (leg2_dest - global_position).length() > 100:
		query = PhysicsRayQueryParameters2D.create(global_position, global_position + (player.velocity + Vector2(0,300)))
		query.exclude = [player]
		result = space_state.intersect_ray(query)
		if result:
			leg2_dest=result.position
		else:
			print_debug("No ground found");
			leg2_dest=self.global_position + Vector2(-10,30)
		
	leg1.global_position = lerp(leg1.global_position, leg1_dest, delta * 10)
	leg2.global_position = lerp(leg2.global_position, leg2_dest, delta * 10)
