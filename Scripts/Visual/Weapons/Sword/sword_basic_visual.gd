extends WeaponVisual

func update_visual(origin : Vector2, dest : Vector2):
	$Sprite2D.global_position = dest
	$Sprite2D.rotation = origin.direction_to(dest).angle() + PI/4
	$Sprite2D/GPUParticles2D.modulate.a = charge_prog
	if player:
		var last_sword_vel = player.get_player_sword().get_last_sword_velocity()
		$Sprite2D/Sparks.emitting = (player.get_last_collision() != null and last_sword_vel.length() > 1000)
		#print(last_sword_vel)
		$Sprite2D/Sparks.amount_ratio = (last_sword_vel.length()-1000) / 10000
		$Sprite2D/Sparks.process_material.direction = Vector3(last_sword_vel.x, last_sword_vel.y, 0)
	
func _ready() -> void:
	$Sprite2D/Sparks.emitting = false
