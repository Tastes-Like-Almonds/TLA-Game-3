## An enemy's hitbox. Not required by default, 
## but is used to have a differing hitbox from the collision body.
class_name EnemyHitbox extends Area2D

var enemy : Enemy = null

func _ready() -> void:
	add_to_group("BladeHitable")
	var parent : Node = get_parent()
	if is_instance_valid(parent) and parent is Enemy:
		enemy = parent
	else:
		push_warning("Enemy hitbox is the child of an invalid enemy!")

func on_sword_hit(player : Player) -> void:
	enemy.on_sword_hit(player)
