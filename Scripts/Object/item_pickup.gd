## A weapon pickup for the player. Logic with handling the weapon itself is done in the player;
## this class just allows the player to pick it up. Uses the WeaponVisual class to display
## the weapon.

class_name ItemPickup extends Node2D

## The Area2D node for player collisions.
@onready var area : Area2D = $Area2D

## The weapon to be given.
@export var weapon : Weapon

## The cooldown before the item can be collected. Used when creating the dropped item pickup.
@export var cooldown : float = 0.0

## The visual of the weapon (Grabbed via CosmeticLoader)
var weapon_visual : WeaponVisual

## The time spent on animating the visual (Used to make bobbing effect)
var visual_time : float = 0.0

## Resets the weapon visual
func _reset_weapon_visual() -> void:
	if is_instance_valid(weapon_visual):
		weapon_visual.queue_free()
	weapon_visual = CosmeticLoader.get_weapon_visual(weapon).instantiate()
	add_child(weapon_visual) 

## Give the weapon to the passed player
func _give_item(player : Player) -> void:
	var dropped : Weapon = player.pickup_weapon(weapon)
	if not is_instance_valid(dropped): queue_free()
	replace_weapon(dropped)

## Check to see if the player is colliding, and if they do, give them the item.
func _check_collision(body: PhysicsBody2D) -> void:
	if body is PlayerBody:
		var player : Player = body.get_player()
		if is_instance_valid(player): _give_item(player)

func _ready() -> void:
	area.body_entered.connect(_check_collision)
	_reset_weapon_visual()

func _process(delta: float) -> void:
	visual_time += delta
	visual_time = fmod(visual_time, PI*2)
	if is_instance_valid(weapon_visual):
		weapon_visual.position.y = 20*sin(visual_time)

func replace_weapon(new : Weapon) -> void:
	weapon = new
	_reset_weapon_visual()
