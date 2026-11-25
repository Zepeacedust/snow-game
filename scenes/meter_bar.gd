extends ProgressBar

var default_color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var style := self.get_theme_stylebox("background") as StyleBoxFlat
	default_color = style.bg_color
	SignalHub.entered_no_bridge_zone.connect(entered_no_bridge_zone)
	SignalHub.exited_no_bridge_zone.connect(exited_no_bridge_zone)


func _set_background_color(color: Color) -> void:
	var style := (self.get_theme_stylebox("background") as StyleBoxFlat).duplicate() as StyleBoxFlat
	style.bg_color = color
	style.bg_color.a = default_color.a
	self.add_theme_stylebox_override("background", style)


func entered_no_bridge_zone() -> void:
	_set_background_color(Color.RED)


func exited_no_bridge_zone() -> void:
	_set_background_color(default_color)
