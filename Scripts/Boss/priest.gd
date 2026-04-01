extends Enemy

enum Phase {
	NONE,
	INTRO,
	SWORD,
	FIGHT,
	DEATH
}

enum Attack {
	LIGHTNING,
	FIREBALL
}

@onready var scn_lightning : PackedScene = preload("res://Scenes/Projectile/lightning.tscn")
@onready var scn_fireball : PackedScene = preload("res://Scenes/Projectile/fireball.tscn")

@onready var shield_sprite   := $Shield
@onready var shield_animator := $ShieldAnimator
@onready var shield_body     := $ShieldWall
@onready var shield_wall     := $ShieldWall/CollisionShape2D

@export var shield_hits : int = 10
@export var swords : Array[PossessedSword]

@export var target_start_pos : Node2D
@export var dialog           : DialogTree

@export var shield_damage_sound  : SoundData
@export var shield_break_sound   : SoundData
@export var shield_deflect_sound : SoundData
@export var shield_restore_sound : SoundData

var phase : Phase
var phase_ended : bool = false
var phase_timer : float = 0.0


var last_movement : Vector2 = Vector2.ZERO

var shield_dur : int = 0



#region Inherited from Enemy
func is_invincible() -> bool:
	if super(): return true
	if phase == Phase.INTRO: return true
	return shield_dur > 0

func on_sword_hit(player : Player) -> void:
	
	if respawning : return
	if time_since_last_hit < hit_time: return
	
	if shield_dur > 0:
		Sfx.play_sound_2d(shield_deflect_sound, global_position)
		time_since_last_hit = 0.0
	else:
		if is_invincible(): return
		super(player)

func on_projectile_hit(projectile : Node) -> void:
	if projectile is Fireball:
		if projectile.sender is not Player: return
		if shield_dur > 0:
			_damage_shield()
		else:
			deal_damage(10)
			shield_wall.process_mode = Node.PROCESS_MODE_PAUSABLE
			TextDisplay.damage_display(get_parent(), global_position, str(10), Vector2.UP)
			GameCamera.set_current_camera_shake(get_viewport(), 0.35)
			if hit_sound:
				Sfx.play_sound(hit_sound)
#endregion

#region Shield
func _restore_shield() -> void:
	Sfx.play_sound_2d(shield_restore_sound, global_position)
	if shield_dur == 0:
		shield_animator.play("shield_restore")
	shield_wall.disabled = false
	shield_dur = shield_hits

func _damage_shield() -> void:
	if shield_dur <= 0: return
	shield_dur = clamp(shield_dur-1, 0, shield_hits)
	if shield_dur == 0:
		shield_wall.disabled = true
		shield_animator.play("shield_break")
		Sfx.play_sound_2d(shield_break_sound, global_position, false)
		GameCamera.set_current_camera_shake(get_viewport(), 0.8)
	else:
		shield_wall.disabled = false
		shield_animator.play("shield_damage")
		Sfx.play_sound_2d(shield_damage_sound, global_position, false)
		GameCamera.set_current_camera_shake(get_viewport(), 0.5)

#endregion

#region Helper
func _get_random_player() -> Player:
	return Helper.get_all_players().pick_random()

func _get_shield_width() -> int:
	return shield_sprite.texture.get_width()

func _get_target_player() -> Player:
	if is_instance_valid(target_player) and target_player.is_alive():
		return target_player
	return _get_random_player()
#endregion

#region Attacks
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
#endregion

#region Movement
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

func _sword_movement(delta:float) -> void:
	
	var player := _get_target_player()
	var dest : Vector2 = player.get_player_position()
	dest.y -= 550
	dest.y -= 150*sin(2*phase_timer)
	
	dest = global_position.lerp(dest, 1-pow(0.2,delta))
	move_and_collide(dest-global_position)
	
	#var dir := global_position.direction_to(dest)
	#var change := delta*dir*global_position.distance_to(dir)
	#
	#if velocity.normalized().dot(dir.normalized()) < 0.5:
		#change *= 3
	#velocity += change
	#
	#move_and_collide(velocity*delta)

func _movement(delta : float) -> void:
	
	var last_pos := global_position
	phase_timer += delta
	
	match phase:
		
		Phase.NONE:
			return
		
		Phase.INTRO:
			_intro(delta)
			if !DialogLoader.is_playing_dialog() and phase_ended:
				change_phase(Phase.SWORD)
		
		Phase.SWORD:
			_sword_movement(delta)
		
		Phase.FIGHT:
			
			if phase_timer > 1:
				#_attack(Attack.LIGHTNING)
				_attack(Attack.FIREBALL)
				phase_timer = 0.0
		
		Phase.DEATH: 
			return
	
	last_movement = global_position - last_pos

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
		
		Phase.SWORD:
			sprite.z_index = 5
			shield_sprite.z_index = 5
			global_position = target_start_pos.global_position
			_restore_shield()
			
			for player:Player in get_tree().get_nodes_in_group(&"Player"):
				if cam:
					cam.set_target_node(player.get_player_body())
			
			for sword in swords:
				sword.awaken()
			
			if swords.size() == 0:
				change_phase(Phase.FIGHT)
		
		Phase.FIGHT:
			return
		
		Phase.DEATH: 
			return

func _physics_process(delta: float) -> void:
	super(delta)
	shield_body.global_position = global_position
	shield_body.constant_linear_velocity = last_movement

func _ready() -> void:
	super()
	SignalBus.LevelLoaded.connect(change_phase.bind(Phase.SWORD))
