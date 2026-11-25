extends AudioStreamPlayer2D

func _ready() -> void:
	SignalHub.audio = self
