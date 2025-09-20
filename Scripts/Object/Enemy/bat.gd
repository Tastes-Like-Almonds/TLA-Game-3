extends AnimatableBody2D

@export var health : float = 10.0

@export var movement_speed : float = 100.0

@export var aggro_range : float = 3000.0

@export var respawn : bool = true:
	set(value):
		respawn = value

@export var respawn_time : float = 3.0

var movement_delay : float = 1.0

var respawn_cooldown : float = 0.0
var movement_cooldown: float = 0.0
var respawning : bool = false
var target_point : Vector2

var start_pos : Vector2

var target_player : Player
var start_health = health

func on_sword_hit(player : Player) -> void:
	
	if respawning : return
	
	var damage = player.get_blade_damage()
	var vel = player.get_player_sword().get_last_sword_velocity()
	
	health -= damage
	player.apply_velocity(vel*0.5)
	
	if health <= 0:
		_kill()

func _kill() -> void:
	if respawn:
		visible = false
		respawning = true
	else:
		queue_free()

func _respawn() -> void:
	visible = true
	respawning = false
	health = start_health
	global_position = start_pos

func _movement(delta : float):
	
	movement_cooldown -= delta
	
	if movement_cooldown <= 0 or not target_point:
		movement_cooldown = movement_delay
		if target_player:
			# Cancel and redo if player out of range
			if target_player.get_player_position().distance_to(global_position) > aggro_range: target_player = null ; _movement(delta) ; return
			target_point = target_player.get_player_position()
		else:
			target_point = Vector2(cos(randf()*2*PI), sin(randf()*2*PI))*100.0 + global_position
			var nearest_player : Player = Helper.get_closest_player(global_position, aggro_range)
			if nearest_player:
				target_player = nearest_player

	if target_point:
		move_and_collide(global_position.direction_to(target_point) )

func _process(delta: float) -> void:
	
	if respawning:
		respawn_cooldown += delta
		if respawn_cooldown >= respawn_time:
			respawn_cooldown = 0
			respawning = false
			_respawn()
		return
	
	_movement(delta)

func _ready() -> void:
	start_pos = global_position
