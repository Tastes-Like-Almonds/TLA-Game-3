extends BoostOrb

func hit_effect(player : Player) -> void:
	super(player) 
	player.reset_weapon_use()
