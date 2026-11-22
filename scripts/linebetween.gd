@tool
extends Line2D

@export var things : Array[Node2D]

func _ready() -> void:
	points = PackedVector2Array();
	for thing in things:
		if thing == null:
			continue
		add_point(to_local(thing.global_position));

func _process(delta: float) -> void:
	if len(things) != len(points):
			_ready()
	for i in range(len(things)):
		if things[i] == null:
			continue

		
		set_point_position(i, to_local(things[i].global_position));
