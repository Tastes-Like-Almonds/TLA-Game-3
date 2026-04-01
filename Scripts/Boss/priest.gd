extends Enemy

enum Phase {
	NONE,
	INTRO,
	FIGHT,
	DEATH
}

@onready var scn_lightning : PackedScene = preload("res://Scenes/Projectile/lightning.tscn")
@onready var scn_fireball : PackedScene = preload("res://Scenes/Projectile/fireball.tscn")
@onready var shield_sprite := $Shield

@export var target_start_pos : Node2D
@export var dialog : DialogTree

@export var shield_damage_sound : SoundData
@export var shield_break_sound : SoundData

var phase : Phase
var phase_ended : bool = false
var phase_timer : float = 0.0

var shield_dur : int = 3

enum Attack {
	LIGHTNING,
	FIREBALL
}

#region Inherited from Enemy
func on_projectile_hit(projectile : Node) -> void:
	if projectile is Fireball:
		if projectile.sender is not Player: return
		_damage_shield()
#endregion

#region Shield
func _damage_shield() -> void:
	if shield_dur <= 0: return
	shield_dur = clamp(shield_dur-1, 0, 3)
	print(shield_dur)
	if shield_dur == 0:
		Sfx.play_sound_2d(shield_break_sound, global_position, false)
		GameCamera.set_current_camera_shake(get_viewport(), 0.8)
	else:
		Sfx.play_sound_2d(shield_damage_sound, global_position, false)
		GameCamera.set_current_camera_shake(get_viewport(), 0.5)

#endregion

#region Helper
func _get_random_player() -> Player:
	return Helper.get_all_players().pick_random()

func _get_shield_width() -> int:
	return shield_sprite.texture.get_width()
#endregion

#region Attacks / Movement
func _attack(attack:Attack) -> void:
	match attack:
		Attack.LIGHTNING:
			var player := _get_random_player()
			var pos := player.get_player_position()
			pos.x += player.get_player_body().velocity.x*Lightning.warn_time
			pos.y -= 2000
			
			var space_state := get_world_2d().direct_space_state
			var query := PhysicsRayQueryParameters2D.create(
				pos,
				pos+Vector2.DOWN*4000,
				1
			)
			var result := space_state.intersect_ray(query)
			
			if result:
				pos = result.position
				_strike_lightning(pos)
		Attack.FIREBALL:
			var fireball  : Fireball = scn_fireball.instantiate()
			var target    := _get_random_player()
			var direction := global_position.direction_to(target.get_player_position())
			fireball.global_position = global_position+direction*_get_shield_width()
			get_parent().get_parent().add_child(fireball)
			fireball.fire(
				self, 
				target.get_player_position(),
				randf_range(-400,400)
			)

func _strike_lightning(pos:Vector2) -> void:
	var lightning : Lightning = scn_lightning.instantiate()
	get_parent().add_child(lightning)
	lightning.global_position = pos

func _intro(delta : float) -> void:
	var movement := Vector2.ZERO
	var dist := absf(target_start_pos.global_position.y - global_position.y)
	
	movement = global_position.direction_to(target_start_pos.global_position)
	movement *= 80 # Hardcoded movement speed; no need to be flexible here.
	
	if dist < movement.y:
		if movement.y < 0:
			movement.y = -dist
		else:
			movement.y = dist
	if not phase_ended:
		move_and_collide(movement*delta)
		if movement.y - dist == 0:
			phase_ended = true
			GameCamera.set_current_camera_shake(get_viewport(), 0.3)

func _movement(delta : float) -> void:
	phase_timer += delta
	
	match phase:
		
		Phase.NONE:
			return
		
		Phase.INTRO:
			_intro(delta)
			if !DialogLoader.is_playing_dialog() and phase_ended:
				change_phase(Phase.FIGHT)
		
		Phase.FIGHT:
			
			if phase_timer > 1:
				#_attack(Attack.LIGHTNING)
				_attack(Attack.FIREBALL)
				phase_timer = 0.0
		
		Phase.DEATH: 
			return
#endregion

func change_phase(p:Phase) -> void:
	phase = p
	phase_timer = 0.0
	phase_ended = false
	
	var cam := get_viewport().get_camera_2d()
	if cam is not GameCamera:
		push_warning("Camera should be GameCamera.")
		cam = null # Easier checking later on
	
	print("RAN. CURRENT PHASE:")
	print(p)
	match p:
		Phase.NONE:
			return
		Phase.INTRO:
			if cam:
				cam.set_target_node(self)
			DialogLoader.play_dialog_tree(dialog)
		Phase.FIGHT:
			sprite.z_index = 5
			shield_sprite.z_index = 5
			print(global_position)
			print(target_start_pos.global_position)
			global_position = target_start_pos.global_position
			print(global_position)
			for player:Player in get_tree().get_nodes_in_group(&"Player"):
				if cam:
					cam.set_target_node(player.get_player_body())
		Phase.DEATH: 
			return

func _ready() -> void:
	super()
	SignalBus.LevelLoaded.connect(change_phase.bind(Phase.FIGHT))
