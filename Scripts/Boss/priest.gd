class_name WizardBoss extends Enemy

signal FightStarted
signal FightEnded

enum Phase {
	NONE,
	INTRO,
	SWORD,
	FIGHT,
	HURT,
	DEATH
}

enum Attack {
	LIGHTNING,
	FIREBALL,
	LANCE,
	SUN
}

@onready var scn_lightning : PackedScene = preload("res://Scenes/Projectile/lightning.tscn")
@onready var scn_fireball  : PackedScene = preload("res://Scenes/Projectile/fireball.tscn")
@onready var scn_lance     : PackedScene = preload("res://Scenes/Projectile/lance.tscn")
@onready var scn_sun       : PackedScene = preload("res://Scenes/Projectile/sun.tscn")

@onready var shield_sprite   := $Shield
@onready var shield_animator := $ShieldAnimator
@onready var shield_body     := $ShieldWall
@onready var shield_wall     := $ShieldWall/CollisionShape2D

## Time spent on each attacking phase
@export var phase_time : float = 11.015

## Time spent while shield is broken before it's restored
@export var hurt_time : float = 10.0

## Maximum damage that can be dealt during the hurt phase
@export var max_hurt_damage: float = 25.0

@export var shield_hits : int = 3
@export var swords : Array[PossessedSword]

@export var environment_anim : AnimationPlayer
@export var lance_pos        : Node2D
@export var target_start_pos : Node2D
@export var hurt_pos_node    : Node2D
@export var dialog           : DialogTree

@export var orb_trigger      : BoostOrb

@export var shield_damage_sound  : SoundData
@export var shield_break_sound   : SoundData
@export var shield_deflect_sound : SoundData
@export var shield_restore_sound : SoundData

@export_group("Music")
@export var intro_song : SongData
@export var loop_1     : SongData
@export var loop_2     : SongData
@export var loop_3     : SongData

var phase       : Phase
var phase_ended : bool = false

var phase_timer       : float = 0.0
var attack_cooldown   : float = 0.0
var hurt_damage_taken : float = 0.0

var swords_left : int = 0

var last_movement : Vector2 = Vector2.ZERO

var shield_dur : int = 0

#region Inherited from Enemy
func is_invincible() -> bool:
	if super(): return true
	if phase == Phase.INTRO: return true
	return shield_dur > 0

func on_shield_collision(object:Node2D) -> void:
	
	var dir := global_position.direction_to(object.global_position)
	print(object)
	
	if object is PlayerBody:
		var player : Player = object.get_player()
		var vel := dir*3000
	
		vel.y = abs(vel.y)
		player.set_velocity(vel)
	
		Sfx.play_sound_2d(shield_deflect_sound, global_position)
	
	elif object.get_parent() is Sword:
		var player : Player = object.get_parent()._get_player()
		var vel := dir*3000
	
		vel.y = abs(vel.y)
		player.set_velocity(vel)
	
		Sfx.play_sound_2d(shield_deflect_sound, global_position)

func deal_damage(amt: float) -> bool:
	if phase == Phase.HURT:
		if hurt_damage_taken + amt >= max_hurt_damage:
			hurt_damage_taken = 0.0
			amt = max_hurt_damage-hurt_damage_taken
			_restore_shield()
			attack_cooldown = -1
			change_phase(Phase.FIGHT)
		else:
			hurt_damage_taken += amt
	
	var killed := super(amt)
	return killed

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
	if shield_dur == 0:
		Sfx.play_sound_2d(shield_restore_sound, global_position)
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
		if phase == Phase.FIGHT:
			change_phase(Phase.HURT)
	else:
		shield_wall.disabled = false
		shield_animator.play("shield_damage")
		Sfx.play_sound_2d(shield_damage_sound, global_position, false)
		GameCamera.set_current_camera_shake(get_viewport(), 0.5)

#endregion

#region Helper
func _reset() -> void:
	Music.stop_track(Music.TrackLayer.MUSIC)
	environment_anim.play("default")
	shield_animator.play("shield_break")
	shield_wall.disabled = true
	shield_dur = 0
	health = start_health
	global_position = start_pos
	sprite.z_index = -10
	shield_sprite.z_index = -10
	change_phase(Phase.NONE)
	FightEnded.emit()

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
			fireball.global_position = global_position+direction*_get_shield_width()*1.2
			get_parent().get_parent().add_child(fireball)
			fireball.fire(
				self, 
				target.get_player_position(),
				randf_range(-400,400)
			)
		
		Attack.LANCE:
			var lance : Lance = scn_lance.instantiate()
			var direction : Vector2 = Vector2.ONE
			var dist : float = randf_range(0,4000)
			lance.direction = direction.normalized()
			lance.global_position = lance_pos.global_position + Vector2(1,-1)*dist
			get_parent().get_parent().add_child(lance)
		
		Attack.SUN:
			var sun : SunProjectile = scn_sun.instantiate()
			sun.target = _get_random_player().get_player_body()
			sun.lifetime = phase_time
			sun.global_position = global_position
			sun.global_position.y -= 100
			get_parent().get_parent().add_child(sun)

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

func _move_to_center(delta:float) -> void:
	var dest := global_position.lerp(target_start_pos.global_position, 1-pow(0.2,delta))
	dest.y += 2*sin(phase_timer)
	move_and_collide(dest-global_position)

func _move_to_hurt(delta:float) -> void:
	var dest := global_position.lerp(hurt_pos_node.global_position, 1-pow(0.1,delta))
	dest.y += sin(phase_timer/2)
	move_and_collide(dest-global_position)

func _movement(delta : float) -> void:
	
	var last_pos := global_position
	phase_timer += delta
	attack_cooldown += delta
	
	match phase:
		
		Phase.NONE:
			return
		
		Phase.INTRO:
			_intro(delta)
			if !DialogLoader.is_playing_dialog() and phase_ended:
				FightStarted.emit()
				change_phase(Phase.SWORD)
		
		Phase.SWORD:
			_sword_movement(delta)
		
		Phase.FIGHT:
			
			if phase_timer < phase_time:
				if phase_timer - delta <= 0.0:
					environment_anim.play("lightning")
				_sword_movement(delta)
				if attack_cooldown > 1.0:
					_attack(Attack.LIGHTNING)
					attack_cooldown = 0.0
			
			elif phase_timer < phase_time*2:
				# Spawn sun if phase changed
				if phase_timer - delta < phase_time:
					environment_anim.play("dark")
					_attack(Attack.SUN)
				
				_move_to_center(delta)
				if attack_cooldown > 0.1:
					_attack(Attack.LANCE)
					attack_cooldown = 0.0
			
			elif phase_timer < phase_time*3:
				
				if phase_timer - delta < phase_time*2:
					environment_anim.play("fire")
					Music.start_track(Music.TrackLayer.MUSIC, loop_3, true)
				_move_to_center(delta)
				if attack_cooldown > 1.0:
					_attack(Attack.FIREBALL)
					attack_cooldown = 0.0
			
			else:
				Music.start_track(Music.TrackLayer.MUSIC, loop_2, true)
				phase_timer = 0.0
		
		Phase.HURT:
			_move_to_hurt(delta)
			if phase_timer > hurt_time:
				_restore_shield()
				attack_cooldown = -1
				change_phase(Phase.FIGHT)
		
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
			Music.start_track(Music.TrackLayer.MUSIC, intro_song)
			DialogLoader.play_dialog_tree(dialog)
		
		Phase.SWORD:
			Music.start_track(Music.TrackLayer.MUSIC, loop_1)
			for player in get_tree().get_nodes_in_group("Player"):
				cam.set_target_node(player.get_player_body())
			cam.set_target_zoom(Vector2(0.7,0.7))
			
			swords_left = 0
			sprite.z_index = 5
			shield_sprite.z_index = 5
			global_position = target_start_pos.global_position
			environment_anim.play("gutter")
			_restore_shield()
			
			for player:Player in get_tree().get_nodes_in_group(&"Player"):
				if cam:
					cam.set_target_node(player.get_player_body())
			
			for sword in swords:
				if is_instance_valid(sword):
					sword.awaken()
					swords_left += 1
			
			if swords_left == 0:
				change_phase(Phase.FIGHT)
		Phase.HURT:
			Music.start_track(Music.TrackLayer.MUSIC, loop_1, true)
		
		Phase.FIGHT:
			Music.start_track(Music.TrackLayer.MUSIC, loop_2, true)
			_restore_shield()
			attack_cooldown = -1
			sprite.z_index = 5
			shield_sprite.z_index = 5
		
		Phase.DEATH: 
			return

func _physics_process(delta: float) -> void:
	super(delta)
	shield_body.global_position = global_position

func _ready() -> void:
	super()
	environment_anim.play("default")
	for sword in swords:
		sword.Killed.connect(func() -> void:
			swords_left -= 1
			attack_cooldown = -1
			if swords_left == 0:
				change_phase(Phase.FIGHT)
		)
	#SignalBus.LevelLoaded.connect(change_phase.bind(Phase.INTRO))
	if orb_trigger:
		orb_trigger.Hit.connect(change_phase.bind(Phase.INTRO))
	SignalBus.PlayerKilled.connect(func(_p:Player) -> void: _reset())
	shield_body.body_entered.connect(on_shield_collision)
