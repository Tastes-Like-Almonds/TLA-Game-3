extends WeaponVisual

func update_visual(origin : Vector2, dest : Vector2):
	super(origin, dest)
	$Sprite2D/GPUParticles2D.modulate.a = player.get_weapon_charge_perc()
