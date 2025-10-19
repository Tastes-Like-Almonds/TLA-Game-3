class_name ProximityText extends RichTextLabel

@export var bob_height : float = 20
@export var bob_speed : float = 0.5

@export var min_distance : float = 400
@export var max_distance : float = 1000

@export var min_alpha : float = 0.1

@export var fade_speed : float = 0.8

var anim_progress : float = 0.0

var start_pos : Vector2 = Vector2.ZERO

func get_content_center() -> Vector2:
	return global_position + Vector2(get_content_width()/2.0, get_content_height()/2.0)

func _process(delta: float) -> void:
	
	# Update fade
	var closest : Player = Helper.get_closest_player(global_position)
	var dist := get_content_center().distance_to(closest.get_player_position())
	var perc := 1-(clampf(dist, min_distance, max_distance)-min_distance)/(max_distance-min_distance)
	modulate.a = lerpf(modulate.a, (1-min_alpha)*perc+min_alpha, pow(fade_speed, delta))

	# Bob animation
	anim_progress += delta*bob_speed
	anim_progress = fmod(anim_progress, 2*PI)
	global_position.y = start_pos.y + bob_height*sin(anim_progress)

func _ready() -> void:
	start_pos = global_position
