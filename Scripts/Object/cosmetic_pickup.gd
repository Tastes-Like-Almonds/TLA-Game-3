extends Node2D

## IMPORTANT: This must be a cosmetic FILE, not an inline cosmetic resource. Otherwise, it will
## not properly save and may do weird stuff.
@export var cosmetic : Cosmetic

@onready var hitbox : BasicHitbox = $Hitbox

func _player_collision(_player : Player) -> void:
	print("COLLIDe")
	CosmeticLoader.give_cosmetic(cosmetic.resource_path)
	modulate.a = 0.3
	$Hitbox.queue_free()

func _ready() -> void:
	hitbox.PlayerTrigger.connect(_player_collision)
	if cosmetic is BodyCosmetic:
		var node_cosmetic : Node2D = cosmetic.get_node()
		$Visual.add_child(node_cosmetic)
	if CosmeticLoader.has_cosmetic(cosmetic):
		modulate.a = 0.3
		$Hitbox.queue_free()
