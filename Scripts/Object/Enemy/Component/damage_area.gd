## An enemy's hitbox. Not required by default, 
## but is used to have a differing hitbox from the collision body.
class_name DamageArea extends Area2D

signal Hit(body:PhysicsBody2D)

## If true, the area will automatically call on_hit in the parent enemy should a player enter.
## One may set this to false should an enemy require more precise control over when on_hit is called.
@export var call_on_hit : bool = true

var enemy : Enemy = null

func _ready() -> void:
	var parent : Node = get_parent()
	if is_instance_valid(parent) and parent is Enemy:
		enemy = parent
	else:
		push_warning("Enemy Damage Area is the child of an invalid enemy!")

func _on_body_entered(body: PhysicsBody2D) -> void:
	Hit.emit(body)
	if call_on_hit:
		enemy.on_hit(body)
