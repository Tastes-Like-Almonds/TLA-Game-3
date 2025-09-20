extends Path2D

@onready var line : Line2D = $Line2D

@export var grip_distance : float = 50.0

@export var cable_speed : float = 100.0

@export var cable_acel : float = 100.0

var player_vel_map : Dictionary[Player, Vector2]

func _render_line() -> void:
	line.clear_points()
	for point in curve.get_baked_points():
		line.add_point(point)

func _ready() -> void:
	_render_line()

func _physics_process(delta: float) -> void:
	for player : Player in get_tree().get_nodes_in_group("Player"):
		if player is not Player: continue
		
		var sword := player.get_player_sword()
		var sword_loc := player.get_player_sword().get_tip_global_position()
		var closest := curve.get_closest_point(to_local(sword_loc))
		
		if player.get_movement_mode() != player.MovementMode.PLAYER_ORBIT:
			
			if to_global(closest).distance_to(sword_loc) <= grip_distance: # Grip if close enough
				player_vel_map.set(player, player.get_player_body().get_real_velocity())
				player.set_movement_mode(player.MovementMode.PLAYER_ORBIT)
			else:
				continue
			
		if player in player_vel_map:
			# Remove player from dict if left cable
			#if to_global(closest).distance_to(sword_loc) > grip_distance: player_vel_map.erase(player)
			
			var vel = player_vel_map.get(player)
			var closest_offset := curve.get_closest_offset(to_local(sword_loc))
			
			var speed : float = vel.length()
			if cable_speed < speed:
				speed = clampf(speed - cable_acel*delta, cable_speed, speed)
			else:
				speed = clampf(speed + cable_acel*delta, speed, cable_speed)
			
			var target = curve.sample_baked(closest_offset + speed*delta)
			
			player_vel_map.set(player, sword.body.global_position.direction_to(target)*speed)
			sword.body.move_and_collide(player_vel_map.get(player)*delta)
			
