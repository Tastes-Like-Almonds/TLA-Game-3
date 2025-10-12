extends Weapon
class_name HammerWeapon

const MAX_CHARGE = 1
const MAX_STRENGTH = 2000.0
const MAX_COOLDOWN = 0.25

var cooldown := 0.0
var fall_multi:float = 1.0

func init_weapon(player: Player) -> void:
	super(player)
	if not is_instance_valid(player) : return
	player.sword_collision.connect(_explode)

func _explode(collision: KinematicCollision2D) -> void:
	if not collision: return
	if cooldown < MAX_COOLDOWN: return
	
	var sword := _wielder.get_player_sword()
	var vel := (collision.get_remainder() + collision.get_travel()) / sword.last_delta
	var vel_perc := vel.length() / _wielder.get_sword_speed()
	
	if vel_perc < 0.1: return
	if vel_perc < 0.5: vel_perc = 0.5
	
	var kb := vel.normalized()*vel_perc*MAX_STRENGTH*-1
	kb *= Vector2(1.25, 0.75) # Favor horizontal movement
	
	if _wielder.get_player_body().velocity.y > 0 and kb.y < 0: _wielder.get_player_body().velocity.y = 0
	
	
	_wielder.apply_velocity(kb*fall_multi)
	Explosion.make_explosion(_wielder.get_parent(), sword.get_tip_global_position(), ["EnemyBody"], vel_perc*150*fall_multi, 1*fall_multi, 500*fall_multi)
	cooldown = 0
	fall_multi = 1.0

func process_weapon(delta:float) -> void:
	super(delta)
	cooldown += delta
	if _wielder.get_player_body().is_on_floor():
		fall_multi = 1.0

func get_gravity_multi() -> float:
	var val := 1.3
	val *= fall_multi
	return val

func get_property_modifiers() -> Dictionary[String, Array]:
	return {
		"strength":[PropertyModifier.new(0.2, PropertyModifier.ModiferType.MULTIPLY)],
		"gravity":[PropertyModifier.new(get_gravity_multi(), PropertyModifier.ModiferType.MULTIPLY)]
	}
		#"gravity": [PropertyModifier.new(-1, PropertyModifier.ModiferType.MULTIPLY)]
	#}

func get_cooldown() -> float:
	return 0.1

func on_use(_charge_time : float) -> void:
	#_wielder.apply_velocity(_wielder.get_player_position().direction_to(get_pointer_pos())*min(MAX_CHARGE,charge_time)*3000)
	#_wielder.teleport_toward(_get_target_point())
	fall_multi = 1+_wielder.get_weapon_charge_perc()*2.0

func get_max_distance_increase() -> float:
	return min(_wielder.get_ability_charge()/MAX_CHARGE, 1)*-20

func get_charge_prog(prog : float) -> float:
	return clampf(prog/MAX_CHARGE, 0, 1)
