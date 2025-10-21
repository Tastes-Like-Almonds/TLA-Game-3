extends Weapon
class_name HammerWeapon

const MAX_CHARGE = 1
const MAX_STRENGTH = 2000.0
const MAX_COOLDOWN = 0.25

var cooldown := 0.0
var fall_multi:float = 1.0

var max_fall_multi : float = 3.0

var hit_sound := SoundData.new("res://Assets/Sound/SFX/Player/Sword/Hammer Strike.wav")

func on_equip() -> void:
	if not is_instance_valid(_wielder) : return
	if (not _wielder.sword_collision.is_connected(_explode)) and _wielder.last_collision == null:
		_wielder.sword_collision.connect(_explode)

func _explode(collision: KinematicCollision2D) -> void:
	if not collision: return
	if cooldown < MAX_COOLDOWN: return
	
	var sword := _wielder.get_player_sword()
	var vel := (collision.get_remainder() + collision.get_travel()) / sword.last_delta
	var vel_perc := clampf(vel.length()*2 / _wielder.get_sword_speed(), 0.0, 1.0)
	
	if vel_perc < 0.6: return
	
	var kb := vel.normalized()*vel_perc*MAX_STRENGTH*-1
	kb *= Vector2(1.25, 0.75) # Favor horizontal movement
	
	if _wielder.get_player_body().velocity.y > 0 and kb.y < 0: _wielder.get_player_body().velocity.y = 0
	
	# Manage Sound
	hit_sound.pitch_scale = 1-clampf(vel.y/_wielder.get_gravity(), 0.0, 1.0)*0.3
	
	if fall_multi < (max_fall_multi-1)/2+1: # Change for heavy/small strike
		hit_sound.sound_string = "res://Assets/Sound/SFX/Player/Sword/Hammer Strike.wav"
	else:
		hit_sound.sound_string = "res://Assets/Sound/SFX/Player/Sword/Hammer Strike Full.wav"
		
	Sfx.play_sound_2d(hit_sound, collision.get_position())
	
	var multi := fall_multi * _wielder.get_size_scale()
	_wielder.apply_velocity(kb*multi)
	# Only apply fall multi to knockback and size, as to keep damage balance.
	Explosion.make_explosion(_wielder.get_parent(), sword.get_tip_global_position(), ["EnemyBody"], vel_perc*150*multi, 3*fall_multi, 500*multi)
	GameCamera.set_current_camera_shake(_wielder.get_viewport(), 0.05*fall_multi)
	cooldown = 0
	fall_multi = 1.0

func process_weapon(delta:float) -> void:
	super(delta)
	cooldown += delta
	if _wielder.get_player_body().is_on_floor():
		fall_multi = 1.0
	if _wielder.get_player_sword().on_cable != null:
		fall_multi = 1.0

func get_gravity_multi() -> float:
	var val := 1.3
	val *= fall_multi
	return val

func get_property_modifiers() -> Dictionary[String, Array]:
	return {
		"strength":[PropertyModifier.new(0.2, PropertyModifier.ModiferType.MULTIPLY)],
		"gravity":[PropertyModifier.new(fall_multi, PropertyModifier.ModiferType.MULTIPLY)],
		"max_distance": [
			PropertyModifier.new(
			1-_wielder.get_weapon_charge_perc()*0.2,
			PropertyModifier.ModiferType.MULTIPLY)
		]
	}

func on_unequip() -> void:
	super()
	if _wielder.sword_collision.is_connected(_explode):
		_wielder.sword_collision.disconnect(_explode)

func get_cooldown() -> float:
	return 0.1

func on_use(_charge_time : float) -> void:
	fall_multi = 1+_wielder.get_weapon_charge_perc()*(max_fall_multi-1)

func get_charge_prog(prog : float) -> float:
	return clampf(prog/MAX_CHARGE, 0, 1)
