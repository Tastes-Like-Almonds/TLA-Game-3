class_name BasicHitbox extends Area2D

## Fired when the player hits or runs into the hitbox.
signal PlayerTrigger   (player : Player)

## Fired when the player's sword collides with the hitbox.
signal BladeHit        (player : Player)

## Fired when the player's body collides with the hitbox.
signal PlayerCollide   (player : Player)

func on_sword_hit(player : Player) -> void:
	BladeHit.emit(player)
	PlayerTrigger.emit(player)

func on_player_collide(body : Node2D) -> void:
	if body is PlayerBody:
		PlayerCollide.emit(body.get_player())
		PlayerTrigger.emit(body.get_player())
