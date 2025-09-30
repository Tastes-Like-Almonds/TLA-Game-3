class_name BoostOrb extends Node2D

## The time before the orb regenerates after use.
@export var respawn_time : float = 1.0

@export var bob_dist : float = 5.0
@export var bob_speed : float = 1.0

var bob_time : float = 0.0

func _process(delta: float) -> void:
	bob_time += delta*bob_speed
	bob_time = fmod(bob_time, 2*PI)
	position.y = bob_dist * sin(bob_time)
