extends BoostOrb

## The size of the explosion
@export var size:float = 100

## The damage the explosion deals to the targets
@export var damage:float = 5.0

## Knockback dealt upon explosion
@export var knockback:float = 400.0

## Knockback dealt to the attacker upon explosion. Appled even when the explosion does not hit.
@export var hit_knockback : float = 1000.0

## The tags required by a collisionbody to be hit
@export var targets : Array[StringName] = [&"PlayerBody"]

func hit_effect(player : Player) -> void:
	super(player)
	Explosion.make_explosion(get_parent(), global_position, targets, size, damage, )
	player.set_velocity(Vector2.ZERO)
	player.deal_knockback(hit_knockback*global_position.direction_to(player.get_player_position()))
