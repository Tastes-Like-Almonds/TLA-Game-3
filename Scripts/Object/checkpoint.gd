extends Area2D

@onready var sprite : Sprite2D = $Sprite2D

@export var heal_on_reach: bool = true

## Sound played when a player reaches the checkpoint
@export var sound : SoundData

@export_group("Respawn")

## If true, all players' spawn position is set upon contact.
@export var set_all_players : bool = true

@export_group("Sprite")

## Sprite of the checkpoint while not activated.
@export var sprite_off : Texture2D = null

## Sprite of the checkpoint while activated.
@export var sprite_on : Texture2D = null

var respawn_position : Vector2

## If the checkpoint was on the last time update_texture was called.
var last_on : bool = false

## Used to connect player signals to texture update. Lambda wasn't used, as a check must be made
## to ensure it is not connected.
func _update_from_signal(_x:Variant) -> void:
	update_texture()

func is_on() -> bool:
	var player := Helper.get_closest_player(respawn_position)
	if player and player.respawn_pos == respawn_position:
		return true
	return false

func set_player_respawn(player : Player) -> void:
	var players : Array[Player] = [player]
	if set_all_players: players = Helper.get_all_players()
	
	if player.respawn_pos != respawn_position:
		if heal_on_reach:
			player.health = player.get_max_health()
	
	for p in players:
		p.respawn_pos = respawn_position
		if not p.respawn_point_changed.is_connected(_update_from_signal):
			p.respawn_point_changed.connect(_update_from_signal)
		update_texture()

func on_sword_hit(player : Player) -> void:
	set_player_respawn(player)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		body = body as PlayerBody
		var player : Player = body.get_player()
		
		# If the player is valid, set their spawn.
		if is_instance_valid(player):
			set_player_respawn(player)

func update_texture() -> void:
	var on : bool = is_on()
	
	# Tween light
	$PointLight2D.visible = on
	if (last_on != on) and on: # If just turned on
		if sound: Sfx.play_sound_2d(sound, global_position, false)
		
		$PointLight2D.scale = Vector2.ZERO
		
		var tween := get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(
			$PointLight2D,
			"scale",
			Vector2(8.0,8.0),
			1
		)
		tween.play()
		$GPUParticles2D.emitting = true
	
	if on:
		if sprite_on != null:
			sprite.texture = sprite_on
	else:
		if sprite_off != null:
			sprite.texture = sprite_off
	
	last_on = on

func _ready() -> void:
	respawn_position = global_position
	update_texture()
