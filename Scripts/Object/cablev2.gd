## A Cable/zipline for the player to ride on. Note: this is not very performant due to the collision
## checks; Use sparingly.

extends Path2D
class_name Cable

@onready var line := $Line2D
@export var cable_drag : float = 0.5

## The minimum velocity the player will have upon entering the cable. Setting this allows for
## the player to not as easily lose speed when riding one.
@export var min_start_velocity : float = 1000

## Speed required to reach maximum screen shake
@export var speed_shake_max : float = 100

## The maximum that the camera will shake will on the cable.
@export var screen_shake_max : float = 0.02

func _render_line() -> void:
	line.clear_points()
	for point in curve.get_baked_points():
		line.add_point(point)

func _ready() -> void:
	_render_line()

## Returns true if the passed offset is out of the cable's range.
func _offset_out_of_range(offset : float) -> bool:
	return (offset >= curve.get_baked_length()) or offset <= 0

## True = 1, False = -1
func _bool_to_dir(b : bool) -> int:
	if b:
		return 1
	return -1

func _get_normal_from_offset(offset : float, direction : bool = false) -> Vector2:
	var current_offset_pos : Vector2 = curve.sample_baked(offset)
	var next_offset_pos : Vector2 = curve.sample_baked(offset + _bool_to_dir(direction))
	return current_offset_pos.direction_to(next_offset_pos).rotated(PI/2)

func _physics_process(delta: float) -> void:
	for player : Player in get_tree().get_nodes_in_group("Player"):
		if player is not Player: continue
		
		# Get all neccessary information
		var sword := player.get_player_sword()
		var sword_loc := sword.get_tip_global_position()
		var closest := to_global(curve.get_closest_point(to_local(sword_loc)))
		var last_vel := sword.get_last_sword_velocity()
		
		# Dont do calculations if too far to be relevant. Might save performance, might not.
		if closest.distance_to(sword_loc) > last_vel.length()*delta: continue
		
		var offset : float = curve.get_closest_offset(sword.get_tip_global_position())
		var old_sword_pos := sword.get_tip_global_position() - last_vel*delta
		var grip_threshold : float = max(curve.bake_interval, last_vel.length()*delta)

		# Update if the player is attached
		if sword.on_cable == self:
			
			var dir := Vector2.ZERO
			
			if is_finite(offset): # Edge case check
				var current_offset_pos : Vector2 = curve.sample_baked(offset)
				
				# Next sword teleport location
				var next_offset_pos : Vector2 = curve.sample_baked(offset + sword.cable_speed*delta)
				
				var og_pos : Vector2 = sword.get_tip_global_position()
				
				dir = current_offset_pos.direction_to(next_offset_pos)
				
				# Update the camera shake in respect to player speed.
				GameCamera.set_current_camera_shake(get_viewport(),clampf(sword.cable_speed/speed_shake_max,0.0,1.0)*screen_shake_max)
				
				# Teleport the sword to next frame's position.
				var target : Vector2 = current_offset_pos
				if next_offset_pos.x-current_offset_pos.x < 0:
					
					# Accelerate the player if moving down
					sword.cable_speed += dir.y*player.get_cable_gravity()
					
					target = to_global(curve.get_closest_point(to_local(closest + dir*sword.cable_speed*delta)))
					sword.body.global_position = target
					
				elif next_offset_pos.x-current_offset_pos.x > 0:
					
					# Slow the player if moving up
					sword.cable_speed -= dir.y*player.get_cable_gravity()
					
					target = to_global(curve.get_closest_point(to_local(closest - dir*sword.cable_speed*delta)))
					sword.body.global_position = target
				
				# If the player isn't moving, exit the cable.
				if is_equal_approx((current_offset_pos.distance_to(target)), 0.0):
					sword.exit_cable()
					return 
				
				# Sword vel must be set each physics process, thus must be updated manually here.
				# Used for stuff like abilities and physics calculations
				sword.last_sword_velocity = (sword.body.global_position - og_pos) * 1/delta
				
				# Apply drag; raising coef to delta approximately applies it per second.
				sword.cable_speed *= pow(cable_drag, delta)

		# Attach to the cable if the player's sword crosses it
		elif Helper.line_passes_point_horizontally_or_vertically(old_sword_pos, sword.get_tip_global_position(), closest):
			if absf(old_sword_pos.x - closest.x) < grip_threshold and not _offset_out_of_range(offset):
				sword.body.global_position = closest
				
				var real_vel := player.get_player_body().get_real_velocity()
				
				# PI/4 offset to determine if the angle is roughly vertical.
				# Used to determine cable move direction.
				var is_vertical := Helper.is_angle_roughly_vertical(real_vel.angle())
				
				# If player's speed does not heavily imply a direction, use the player's sword to choose
				# which way to go.
				#
				# .slide() is used for both outcomes. This ensures that the player's direction
				# increases their speed depending on the angle of attack.
				# For instance, if a player falls vertically to a horizontal cable,
				# slide() ensures that velocity is not falsely applied.
				if real_vel.x < 0 or (is_vertical and sword.get_tip_global_position().x < player.get_player_position().x):
					sword.cable_speed = player.get_player_body().get_real_velocity().slide(_get_normal_from_offset(offset, true)).length()
				
				elif real_vel.x > 0 or (is_vertical and sword.get_tip_global_position().x > player.get_player_position().x):
					sword.cable_speed = -player.get_player_body().get_real_velocity().slide(_get_normal_from_offset(offset, true)).length()
				
				# Apply minimum velocity.
				if sword.cable_speed < 0:
					sword.cable_speed = min(sword.cable_speed, -min_start_velocity)
				elif sword.cable_speed > 0:
					sword.cable_speed = max(sword.cable_speed, min_start_velocity)
				
				sword.enter_cable(self)
		
		# Exit the cable if able
		if (
			player.get_player_position().y < closest.y - (player.get_max_distance()) or 
			(player.get_player_body().velocity.y < 0 and player.get_player_position().y < closest.y and player.get_player_sword()._get_target_pos().y < closest.y) or
			_offset_out_of_range(offset + sword.cable_speed*delta)) and sword.on_cable == self:
			sword.cable_speed = 0.0
			sword.exit_cable()
			
			var dir := Vector2.ZERO
				  
			var current_offset_pos : Vector2 = curve.sample_baked(offset)
			var next_offset_pos : Vector2 = curve.sample_baked(offset + sword.cable_speed*delta)
			
			dir = current_offset_pos.direction_to(next_offset_pos)
			
			# Transfer the sword's speed (on the cable) to the player's speed.
			player.apply_velocity(dir*sword.cable_speed)
			
			# Snap the sword to the location it should be at. Without this, the sword gets stuck on
			# the cable.
			sword.teleport_to_target_pos()
