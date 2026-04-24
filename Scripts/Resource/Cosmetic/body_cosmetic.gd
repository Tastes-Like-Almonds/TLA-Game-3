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

## Gets the node version of this cosmetic. Will be a CosmeticContainer,
## A Sprite2D, or an AnimatedSprite2D.
func get_node() -> Node2D:
	
	var new_cosmetic : Node2D
	match sprite_type:
		BodyCosmetic.SpriteType.TEXTURE:
			
			new_cosmetic = SpriteContainer.new()
			
			# Above texture
			if texture:
				var above := Sprite2D.new()
				above.texture = texture
				new_cosmetic.add_child(above)
			
			# Below texture
			if texture_behind:
				var below := Sprite2D.new()
				below.show_behind_parent = true
				below.z_index -= 1
				below.texture = texture_behind
				new_cosmetic.add_child(below)
			
		
		BodyCosmetic.SpriteType.ANIMATED:
			new_cosmetic = AnimatedSprite2D.new()
			new_cosmetic.sprite_frames = sprite_frames
	
	new_cosmetic.scale = Vector2(3,3)
	new_cosmetic.set_meta("cosmetic_data", self)
	
	return new_cosmetic
