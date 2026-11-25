class_name NoBridgeZone extends Node2D

var bridge_meter: float = 0.0
var meter_recharge: float = 0.0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	# Disable set current bridge meter and meter recharge to zero
	var info = _body.get_bridge_meter_info()
	bridge_meter = info[0]
	meter_recharge = info[1]
	SignalHub.modify_bridge_meter.emit(0.0, 0.0)
	SignalHub.entered_no_bridge_zone.emit()

func _on_area_2d_body_shape_exited(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	# Restore the bridge meter and meter recharge to their previous values
	SignalHub.modify_bridge_meter.emit(bridge_meter, meter_recharge)
	SignalHub.exited_no_bridge_zone.emit()
	
