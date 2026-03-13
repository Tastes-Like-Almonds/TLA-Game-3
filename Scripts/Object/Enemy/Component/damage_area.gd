## An enemy's hitbox. Not required by default, 
## but is used to have a differing hitbox from the collision body.
class_name DamageArea extends Area2D

signal Hit(body:PhysicsBody2D)

## If true, the area will automatically call on_hit in the parent enemy should a player enter.
## One may set this to false should an enemy require more precise control over when on_hit is called.
@export var call_on_hit : bool = true

## If true, the enemy will attack any player within its hitbox each physics process.
## This only works if call_on_hit is true.
@export var check_on_process : bool = true

var enemy : Enemy = null

func _ready() -> void:
	var parent : Node = get_parent()
	if is_instance_valid(parent) and parent is Enemy:
		enemy = parent
	else:
		push_warning("Enemy Damage Area is the child of an invalid enemy!")

func check_hits() -> void:
	for body in get_overlapping_bodies():
		if body is PlayerBody:
			enemy.on_hit(body)

func _physics_process(_delta: float) -> void:
	if call_on_hit:
		check_hits()

func _on_body_entered(body: PhysicsBody2D) -> void:
	Hit.emit(body)
	if call_on_hit:
		enemy.on_hit(body)
