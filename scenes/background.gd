extends TextureRect
@export var cloud_noise : NoiseTexture2D
@export var dither_noise : NoiseTexture2D
@export var rift_noise : NoiseTexture2D
@export var star_noise : NoiseTexture2D
@export var star_cell_noise : NoiseTexture2D


#func _process(delta: float) -> void:
	#cloud_noise.noise.offset += Vector3(.01,0,0)
	#rift_noise.noise.offset += Vector3(.02,.01,0)
