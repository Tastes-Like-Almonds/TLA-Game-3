extends Path2D
class_name Cable

@onready var line = $Line2D

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
		var closest := to_global(curve.get_closest_point(to_local(sword_loc)))
		var last_vel = sword.get_last_sword_velocity()
		var old_sword_pos = sword.get_tip_global_position() - last_vel*delta
		var grip_threshold : float = max(curve.bake_interval, last_vel.length()*delta)

		if (old_sword_pos.y < closest.y and sword.get_tip_global_position().y >= closest.y) or sword.is_on_cable():
			if absf(old_sword_pos.x - closest.x) < grip_threshold:
				sword.body.global_position = closest
				sword.enter_cable(self)
		
		if player.get_player_position().y < closest.y:
			sword.exit_cable()
