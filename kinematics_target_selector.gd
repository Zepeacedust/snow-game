class_name KinematicsThinker
extends Node2D

@export var hip : Bone2D
@export var player : PlayerMovement

@onready var hand1 = $Hand1Target
@onready var hand2 = $Hand2Target
@onready var leg1 = $Leg1Target
@onready var leg2 = $Leg2Target

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
		move_duration = change.length() / 500
		if move_duration == 0:
			move_duration = 0.01
		move_height = change.length()
		print_debug(move_duration)
		destination = where
		
	
	func move_complete() -> bool:
		return (leg_controller.global_position - destination).length() < 5
	
	func _init(_leg_controller:Marker2D, _default : Vector2, _parent : PlayerMovement) -> void:
		leg_controller = _leg_controller
		default = _default
		parent = _parent
	
	func get_scanline() -> Vector2:
		var dir = parent.velocity
		#if state == LegState.AIRBORNE:
		dir += Vector2(0,980) # simulate gravity-ish to place foot where you would land
		if other.state == LegState.AIRBORNE and state != LegState.AIRBORNE:
			# If only one leg is airborne then the player is probably on a cliff
			# TODO: find edge properly, in the meantime just go directly down
			return Vector2(0,1000)
			
		if other.state == LegState.GROUNDED:
			if relative_direction().x * dir.x >  other.relative_direction().x * dir.x:
				# if this is the leading foot and it needs to readjust, go down
				dir = Vector2(0, 1)
			elif relative_direction().x * dir.x >= 0:
				# if this is the trailing foot and it is in front of the player, try to mirror the leading foot
				dir = other.relative_direction()
				dir.x = -dir.x
			elif other.relative_direction().x * dir.x >=0:
				# if this is the trailing foot and the other foot is behind the player, move ahead
				# if this is the trailing foot and it is behind the player, put it down and forwards
				dir += Vector2(sign(dir.x) * 200,0)
			#else:
				# if this is the trailing foot and the other foot is in front of the player, go to below the player
			#	dir = Vector2(0,1)
			#var leg = other.destination - parent.global_position
			#var angle = dir.angle_to(leg)
			#dir = dir.rotated(-0.3*angle)
		return dir.normalized() * 150
	
	func need_retarget() -> bool:
		if state == LegState.AIRBORNE:
			return true
		if (destination - parent.global_position).length() > 110:
			print_debug("leg too long, retargetting")
			return true
		 #retarget if both targets are on the same side of velocity
		if sign((parent.velocity + Vector2(0,500)).angle_to(relative_direction())) == sign((parent.velocity + Vector2(0,980)).angle_to(other.relative_direction())):
			instability += 1
			if instability > 30:
				print_debug("Unstable, retargetting")
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
		var query = PhysicsRayQueryParameters2D.create(parent.global_position, parent.global_position + scanline)
		query.exclude = [parent]
		var result = space_state.intersect_ray(query)
		if result:
			state = LegState.GROUNDED
			set_destination(result.position)
			print_debug("Found ground at ", destination)
		else:
			print_debug("No ground found");
			state = LegState.AIRBORNE			
			set_destination(parent.global_position + default)
		
	func tick(delta : float) -> void:
		retarget()
		if not move_complete():
			move_elapsed += delta
			var move_fraction = clamp(move_elapsed/move_duration,0,1)
			leg_controller.global_position = lerp(move_start, destination, move_fraction) + move_height * Vector2(0,-move_fraction*(1-move_fraction))

var leg1_director : LegDirector
var leg2_director : LegDirector
func _ready():
	leg1_director = LegDirector.new(leg1, Vector2(10,20), player)
	leg2_director = LegDirector.new(leg2, Vector2(0,20), player)
	leg1_director.other = leg2_director
	leg2_director.other = leg1_director


func _process(delta: float) -> void:
	leg1_director.tick(delta)
	leg2_director.tick(delta)
