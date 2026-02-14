extends Node2D

## Maps all sprite frames to their respective offsets. I tried, but there's no other way to do this
## I can think of.
const frame_offsets = {
	
	"idle": [
		Vector2(0,0),
		Vector2(0,3),
		Vector2(0,0)
	],
	"airborne": [
		Vector2(0,-9),
		Vector2(0,-9),
		Vector2(0,-9)
	]
}

@onready var body_cosmetic_node := preload("res://Scenes/Player/Cosmetic/body_cosmetic_node.tscn")

## Used for testing. Loads this cosmetic automatically when the player loads.
@export var autoload_cosmetic : BodyCosmetic

var player : Player
var player_sprite : AnimatedSprite2D = null

## Offset applied to cosmetics based on the player's current sprite frame.
var animation_offset : Vector2 = Vector2.ZERO

#region Public
func load_cosmetic(cosmetic : BodyCosmetic) -> void:
	
	var new_cosmetic : Node2D
	
	match cosmetic.sprite_type:
		BodyCosmetic.SpriteType.TEXTURE:
			new_cosmetic = Sprite2D.new()
			new_cosmetic.texture = cosmetic.texture
		BodyCosmetic.SpriteType.ANIMATED:
			new_cosmetic = AnimatedSprite2D.new()
			new_cosmetic.sprite_frames = cosmetic.sprite_frames
	
	new_cosmetic.scale = Vector2(3,3)
	new_cosmetic.set_meta("cosmetic_data", cosmetic)
	
	add_child(new_cosmetic)
#endregion

#region Private
func _player_frame_changed() -> void:
	
	# Grab offset from frame_offsets map
	if player_sprite.animation in frame_offsets:
		if len(frame_offsets[player_sprite.animation]) -1 >= player_sprite.frame:
			animation_offset = frame_offsets[player_sprite.animation][player_sprite.frame]
	
#endregion

#region Inherited
func _ready() -> void:
	
	var parent : Node = get_parent()
	if parent is PlayerBody:
		player = parent.get_player()
	
	if not player.is_node_ready():
		await player.ready # Needed for getting the player's sprite
		
	player_sprite = player.get_player_body().get_sprite()
	if player_sprite is AnimatedSprite2D:
		player_sprite.frame_changed.connect(_player_frame_changed)
		player_sprite.animation_changed.connect(_player_frame_changed)
	
	if autoload_cosmetic:
		load_cosmetic(autoload_cosmetic)
	
	for cosmetic in CosmeticLoader.get_body_cosmetics():
		load_cosmetic(cosmetic)

func _process(_delta: float) -> void:
	
	var fliph : bool = player_sprite.flip_h
	var flipv : bool = player_sprite.flip_v
	
	for child in get_children():
		if !child.has_meta("cosmetic_data"): return
		
		var meta : BodyCosmetic = child.get_meta("cosmetic_data")
		var offset : Vector2 = meta.offset
		
		offset += animation_offset
		
		# Manage flips
		
		if fliph == false:
			child.flip_h = meta.default_flip_h
		else:
			child.flip_h = !meta.default_flip_h
			offset.x *= -1
		
		if flipv == false:
			child.flip_v = meta.default_flip_v
		else:
			child.flip_v = !meta.default_flip_v
			offset.y *= -1
		
		child.position = offset
#endregion
