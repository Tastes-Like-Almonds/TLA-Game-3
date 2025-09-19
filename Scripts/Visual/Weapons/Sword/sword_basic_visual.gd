extends WeaponVisual

func update_visual(origin : Vector2, dest : Vector2):
	$Sprite2D.global_position = dest
	$Sprite2D.rotation = origin.direction_to(dest).angle() + PI/4
	$Sprite2D/GPUParticles2D.modulate.a = charge_prog
	
