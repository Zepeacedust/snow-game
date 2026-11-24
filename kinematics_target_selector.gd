class_name KinematicsThinker
extends Node2D

@export var hip : Bone2D
@export var player : PlayerMovement

@onready var hand1 = $Hand1Target
@onready var hand2 = $Hand2Target
@onready var leg1 = $Leg1Target
@onready var leg2 = $Leg2Target


@export var leg1_kinematics : PlayerKinematics
@export var leg2_kinematics : PlayerKinematics
@export var hand1_kinematics : PlayerKinematics
@export var hand2_kinematics : PlayerKinematics


var leg1_dest : Vector2
var leg2_dest : Vector2

enum LegState {
	GROUNDED,
	AIRBORNE
	
}

class LegDirector:
	var leg_controller : Marker2D
	var default : Vector2
	var parent : PlayerMovement
	var target : Vector2 = Vector2(0,0)
	var destination : Vector2
	var other : LegDirector
	var state : LegState = LegState.AIRBORNE
	
	var instability : int = 0
	
	var move_duration : float = 0
	var move_elapsed : float = 0
	var move_start : Vector2 = Vector2(0,0)
	var move_height : float = 0
	
	var kinematics : PlayerKinematics
	
	func set_destination(where : Vector2):
		var redirect =  (where - destination).length() < 50
		var change
		if redirect:
			change = where - move_start
		else:
			change = where - destination
		
		if not redirect:
			move_elapsed = 0
			move_start = destination
		move_duration = change.length() / 600
		if move_duration == 0:
			move_duration = 0.01
		move_height = change.length()
		destination = where
		
	
	func move_complete() -> bool:
		return (leg_controller.global_position - destination).length() < 5
	
	func _init(_leg_controller:Marker2D, _default : Vector2, _parent : PlayerMovement, _kinematics : PlayerKinematics) -> void:
		leg_controller = _leg_controller
		default = _default
		parent = _parent
		kinematics = _kinematics
	func get_scanline() -> Vector2:
		return Vector2(0,100)
	
	func need_retarget() -> bool:
		if state == LegState.AIRBORNE:
			return true
		if (destination - parent.global_position).length() > 90:
			return true
		 #retarget if both targets are on the same side of velocity
		if sign((parent.velocity + Vector2(0,500)).angle_to(relative_direction())) == sign((parent.velocity + Vector2(0,980)).angle_to(other.relative_direction())):
			instability += 1
			if instability > 30:
				instability = 0
				return move_complete()
		else:
			instability = 0
		return false
	
	func relative_direction():
		return destination - parent.global_position
	
	func retarget():
		if not need_retarget():
			return
		var space_state = parent.get_world_2d().direct_space_state	
		
		var scanline = get_scanline()
		var start_point = parent.global_position + 0.3 * Vector2(parent.velocity.x, 0)
		start_point.x += other.relative_direction().x
		var query = PhysicsRayQueryParameters2D.create(start_point, start_point + scanline)
		query.exclude = [parent]
		var result = space_state.intersect_ray(query)
		if result:
			state = LegState.GROUNDED
			set_destination(result.position)
		else:
			state = LegState.AIRBORNE
			set_destination(parent.global_position + default)
		
	func tick(delta : float) -> void:
		retarget()
		if parent.velocity.x > 0:
			kinematics.midpointPreference = kinematics.MidPointPreference.COUNTERCLOCKWISE
		elif parent.velocity.x < 0:
			kinematics.midpointPreference = kinematics.MidPointPreference.CLOCKWISE

		if not move_complete():
			move_elapsed += delta
			var move_fraction = clamp(move_elapsed/move_duration,0,1)
			leg_controller.global_position = lerp(move_start, destination, move_fraction) + move_height * Vector2(0,-move_fraction*(1-move_fraction))

var leg1_director : LegDirector
var leg2_director : LegDirector
func _ready():
	leg1_director = LegDirector.new(leg1, Vector2(10,20), player, leg1_kinematics)
	leg2_director = LegDirector.new(leg2, Vector2(0,20), player, leg2_kinematics)
	leg1_director.other = leg2_director
	leg2_director.other = leg1_director


func _process(delta: float) -> void:
	leg1_director.tick(delta)
	leg2_director.tick(delta)
	if player.velocity.x > 0:
		hand1_kinematics.midpointPreference = hand1_kinematics.MidPointPreference.CLOCKWISE
		hand2_kinematics.midpointPreference = hand2_kinematics.MidPointPreference.CLOCKWISE
	elif player.velocity.x < 0:
		hand1_kinematics.midpointPreference = hand1_kinematics.MidPointPreference.COUNTERCLOCKWISE
		hand2_kinematics.midpointPreference = hand2_kinematics.MidPointPreference.COUNTERCLOCKWISE
	hand1.position = leg1.position  + Vector2(sign(player.velocity.x) * 20,-40)
	hand2.position = leg2.position  +Vector2(sign(player.velocity.x) * 20,-40)
	hand2.position.x *= 1.2
	hip.rotation = move_toward(hip.rotation, sqrt(player.velocity.length())/40 * sign(player.velocity.x), delta)
	if player.bridge_attatched:
		hip.rotation = player.determine_foot_loc().angle() - PI/2

		leg1.position = Vector2(00,40).rotated(hip.rotation)
		leg2.position = Vector2(20,40).rotated(hip.rotation)
		
		leg1_director.destination = leg1.global_position
		leg2_director.destination = leg2.global_position
		
		hand1.position = Vector2(30,-10).rotated(hip.rotation)
		hand2.position = Vector2(30,-15).rotated(hip.rotation)
		hip.rotation += clamp(sqrt(player.velocity.length())/40, 0, PI/3)
