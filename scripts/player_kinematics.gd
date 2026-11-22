@tool
extends Node2D

@export var kinematicChain : Array[Bone2D]
@export var kinematicTarget : Node2D

func circle_circle_intersect(p1:Vector2, p2:Vector2, r:float) -> Vector2:
	var d=sqrt((p2.x-p1.x)**2 + (p2.y-p1.y)**2)
	if d > r * 2 + 0.1:
		return (p1+p2)/2
	var a=(d**2)/(2*d)
	var h=sqrt(r**2-a**2)
	if is_nan(h):
		return (p1+p2)/2
	
	var x2=p1.x+a*(p2.x-p1.x)/d   
	var y2=p1.y+a*(p2.y-p1.y)/d   
	var x3=x2+h*(p2.y-p1.y)/d       # also x3=x2-h*(y1-y0)/d
	var y3=y2-h*(p2.x-p1.x)/d       # also y3=y2+h*(x1-x0)/d
	assert(not is_nan(x3))
	assert(not is_nan(y3))
	return Vector2(x3,y3)
	
func atan2v(v: Vector2):
	return atan2(v.y, v.x)

func perform_kinematics(parts : Array[Bone2D], target:Node2D):
	var midpoint = circle_circle_intersect(parts[0].global_position, target.global_position, parts[0].get_length())
	var angle1 = atan2v(midpoint-parts[0].global_position) - atan2v(parts[1].position)
	var angle2 = atan2v(target.global_position - midpoint) - atan2v(parts[2].position)
	
	parts[0].global_rotation = angle1
	parts[1].global_rotation = angle2

func _process(delta: float) -> void:
	if kinematicTarget:
		perform_kinematics(kinematicChain, kinematicTarget);
