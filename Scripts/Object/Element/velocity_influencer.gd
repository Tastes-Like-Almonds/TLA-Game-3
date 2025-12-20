## Used to subtly make a player's velocity follow a path.
extends Path2D

## The speed at which the player is moved toward the curve2d. 
@export_range(0,1000) var player_pull : float = 1000

## The time taken to match the player's velocity to the target velocity.
## The lower this value is, the "stronger" the influence will be.
@export_range(0.001, 5) var vel_influence : float = 0.2

## The target player speed. If negative, the player's speed will not be modified.
@export var target_speed : float = -1

## If set, the influencer will only affect players in the target area. This should always
## be used, as excessive numbers of these may affect performance otherwise.
@export var active_area : Area2D

func _physics_process(delta: float) -> void:
	# We have two properties of the player to modify: Their direction and position.
	# We will modifiy the position via a "temporary velocity" property which only applies the
	# velocity for one physics frame. The player's direction (velocity property) will be
	# lerped to the target velocity which is equal to the slope of the nearest point on the
	# influencer. The strength of both of these properties will be determined via
	# exported variables.
	
	var players : Array[Player] = []
	if active_area:
		for body in active_area.get_overlapping_bodies():
			if body is PlayerBody:
				var player : Player = body.get_player()
				if is_instance_valid(player): players.append(player)
	else:
		players = Helper.get_all_players()
	
	for player in players:
		
		var body := player.get_player_body()
		var closest_point := curve.get_closest_point(body.global_position) + global_position
		var closest_offset := curve.get_closest_offset(closest_point - global_position)
		var next_closest_point := curve.sample_baked(closest_offset + curve.bake_interval) + global_position
		
		#region Lerp direction
		var vel := body.velocity
		
		# Calculate target speed (magnitude of velocity)
		var magnitude : float
		if target_speed < 0: 
			magnitude = vel.length()
		else: 
			magnitude = target_speed
		
		var target := closest_point.direction_to(next_closest_point)*magnitude
		Helper.debug_dot(get_parent(), body.global_position + target, "WW")
		Helper.debug_dot(get_parent(), body.global_position+body.velocity, "WWW", Color.BLUE)
		body.velocity = vel.lerp(target, 1-pow(vel_influence, delta))
		#endregion
		
		##region Player movement
		#Helper.debug_dot(get_parent(), closest_point, "WWWW", Color.GREEN)
		#var direction_to_closest : Vector2 = body.global_position.direction_to(closest_point)
		#var dist_to_closest : float = body.global_position.distance_to(closest_point)
		#var movement : Vector2 = direction_to_closest*max(dist_to_closest, player_pull)
		#body.add_temp_velocity(movement)
		##endregion
