extends Node


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
	
	## Idle
	#"res://Assets/Sprites/Player/Sewer Guy Idle 1.png" = Vector2(0,0),
	#"res://Assets/Sprites/Player/Sewer Guy Idle 2.png" = Vector2(0,0),
	#"res://Assets/Sprites/Player/Sewer Guy Idle 3.png" = Vector2(0,0),
	#"res://Assets/Sprites/Player/Sewer Guy Idle 4.png" = Vector2(0,0),
	#
	## Airborne
	#"res://Assets/Sprites/Player/Airborne/Airborne 1.png" = Vector2(0,0),
	#"res://Assets/Sprites/Player/Airborne/Airborne 2.png" = Vector2(0,0),
	#"res://Assets/Sprites/Player/Airborne/Airborne 3.png" = Vector2(0,0),
	
}

## Vertical offset applied to hats; should only be used for animation synchronizing.
@export var anim_hat_offset : float = 0

var player : Player = null
var player_sprite : AnimatedSprite2D = null

func _player_frame_changed() -> void:
	
	var offset := Vector2.ZERO
	var cosmetics := player.get_player_body().get_cosmetics_node()
	
	# Grab offset from frame_offsets map
	if player_sprite.animation in frame_offsets:
		if len(frame_offsets[player_sprite.animation]) -1 >= player_sprite.frame:
			offset = frame_offsets[player_sprite.animation][player_sprite.frame]
	
	# Applies to all cosmetics (connected to the player)
	cosmetics.position = offset

func _process(delta: float) -> void:
	var body : PlayerBody = player.get_player_body()
	var cosmetics := body.get_cosmetics_node()
	
	#var flip_h_different : bool = (body.get_sprite().flip_h == false)
	#var flip_h_different : bool = (body.get_sprite().flip_v == false)
	
	#for cosmetic in cosmetics.get_children():
		#if cosmetic is CosmeticSprite:
			#if body.get_sprite().flip_h == false:
				#cosmetic.flip_h = cosmetic.default_flip_h
			#else:
				#cosmetic.flip_h = !cosmetic.default_flip_h

func _ready() -> void:
	
	var parent : Node = get_parent()
	if parent is Player:
		player = parent
		
	player_sprite = player.get_player_body().get_sprite()
	if player_sprite is AnimatedSprite2D:
		player_sprite.frame_changed.connect(_player_frame_changed)
