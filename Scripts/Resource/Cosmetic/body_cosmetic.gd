class_name BodyCosmetic extends Cosmetic

enum SpriteType {
	TEXTURE,
	ANIMATED
}

@export_group("Display")
@export var default_flip_h : bool = false
@export var default_flip_v : bool = false
@export var offset : Vector2 = Vector2.ZERO

@export_group("Sprite")
@export var sprite_type    : SpriteType   = SpriteType.TEXTURE
@export var texture        : Texture2D    = null
@export var texture_behind : Texture2D    = null
@export var sprite_frames  : SpriteFrames = null

func _init() -> void:
	
	# Validate
	match sprite_type:
		SpriteType.TEXTURE:
			if texture == null:
				push_warning("No sprite set for BodyCosmetic resource!")
		
		SpriteType.ANIMATED:
			if sprite_frames == null:
				push_warning("No sprite frames set for BodyCosmetic resource!")
