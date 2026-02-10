extends Area2D

@export var damage : float = 3.4
@export var kb : float = 200

func check_damage(body: Node2D) -> void:
	if body not in get_overlapping_bodies(): return
	if is_instance_valid(body) and body is PlayerBody:
		var player : Player = body.get_player()
		if player:
			if player.iframes_active(): # Try again later if player is invincible
				get_tree().create_timer(player.get_invincibility_time()).timeout.connect(check_damage.bind(body))
				return
			player.deal_damage(damage)
			player.set_velocity(player.get_player_body().velocity*-1)
			get_tree().create_timer(player.get_invincibility_time()).timeout.connect(check_damage.bind(body))

func _on_body_entered(body: Node2D) -> void:
	check_damage(body)

func _ready() -> void:
	$AnimatedSprite2D.play("spin")
