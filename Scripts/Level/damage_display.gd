extends TextureProgressBar

@export var dummy : Enemy

var target_val : float = 0.0
var opened := false

func _ready() -> void:
	dummy.HitBy.connect(func(player:Player) -> void:
		var perc : float = player.get_blade_damage_perc()
		target_val = perc
		if perc >= 1.0 and not opened:
			opened = true
			$StaticBody2D.queue_free()
			Sfx.play_sound_2d(SoundData.new("res://Assets/Sound/SFX/Other/Unlock 1.wav", 0.8), global_position)
			GameCamera.set_current_camera_shake(get_viewport(), 0.2)
	)

func _process(delta: float) -> void:
	value = lerpf(value, target_val, 1.0 - exp(-8.0 * delta))
