extends WeaponVisual

@export var sword_length : float = 20

@onready var line2D := $Line2D
var line_curve := Curve2D.new()

func update_visual(delta : float) -> void:
	super(delta)
	var origin := player.get_player_position()
	var dest := player.get_player_sword().get_tip_global_position()
	
	if is_instance_valid(line2D):
		line_curve.add_point(dest + (dest.direction_to(origin)*sword_length/2))
		line2D.width = sword_length*player.get_size_scale()
		
		if line_curve.get_baked_points().size() > 50:
			line_curve.remove_point(0)
		
		line2D.points = line_curve.get_baked_points()
		
	$Sprite2D/GPUParticles2D.modulate.a = player.get_weapon_charge_perc()

func _ready() -> void:
	super()
	line2D.points = []
