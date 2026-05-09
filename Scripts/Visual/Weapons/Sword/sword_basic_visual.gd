extends WeaponVisual

@export var sword_length : float = 60

@onready var line2D : Line2D = $Line2D

@export var texture : Texture
@export var trail_color : Color = Color.WHITE

var line_curve := Curve2D.new()

var point_wait_delay : float = 0.05
var current_wait_delay: float = 0.0

func get_hotbar_sprite() -> Texture2D:
	return load("res://Assets/Sprites/Placeholder/sword.png")

func update_visual(delta : float) -> void:
	current_wait_delay += delta
	super(delta)
	var origin := player.get_player_position()
	var dest := player.get_player_sword().get_tip_global_position()
	
	$Sprite2D/Drag.emitting = _is_dragging(0)
	
	if is_instance_valid(line2D):
		
		line2D.modulate.a = max(line2D.modulate.a-delta, pow(player.get_blade_damage_perc(),2)*0.4)
		
		line2D.width = sword_length*player.get_size_scale()
		
		# The line2D points only add after a given interval as to avoid choppiness which appears
		# with too many line segments.
		if current_wait_delay > point_wait_delay:
			current_wait_delay = 0.0
			line2D.add_point(dest + (dest.direction_to(origin)*line2D.width/2))
			if line2D.get_point_count() > 10:
				line2D.remove_point(0)
		else:
			# Update the last point as to sync with the current sword position
			if line2D.get_point_count() == 0: return
			line2D.remove_point(line2D.get_point_count()-1)
			line2D.add_point(dest + (dest.direction_to(origin)*line2D.width/2))
		
	
	$Sprite2D/Drag.global_position = _get_sprite().global_position
	$Sprite2D/GPUParticles2D.modulate.a = lerpf($Sprite2D/GPUParticles2D.modulate.a, player.get_blade_damage_perc(), 0.2)

func _ready() -> void:
	super()
	line2D.points = []
	line_curve.bake_interval = 1
	line2D.modulate = trail_color
	$Sprite2D/GPUParticles2D.modulate = trail_color
	if is_instance_valid(player):
		line2D.width = sword_length*player.get_size_scale()
	if (texture):
		$Sprite2D.texture = texture
