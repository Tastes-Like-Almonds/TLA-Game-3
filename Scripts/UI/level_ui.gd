## UI For displaying game data such as health and weapons.
class_name LevelUI extends CanvasLayer

@onready var health_bar : TextureProgressBar = $Control/Health/HealthBar
@onready var health_label : Label = $Control/Health/HealthBar/Label
@onready var hotbar : Hotbar = $Control/Hotbar
@onready var timer  : Label = $MarginContainer/Timer

@export_group("Health Bar")

@export var pulse_speed : float = 10.0

@export var pulse_size_multi : float = 0.1515

@export var max_pulse_speed : float = 30.0
@export var max_pulse_size_multi : float = 0.333

var heart_animation_time: float = 0.0

var player : Player

#region Timer

func set_timer(active:bool) -> void:
	if active:
		timer.visible = true
	else:
		timer.visible = false

func set_timer_value(val : float) -> void:
	timer.text = Helper.format_time(val)
#endregion


## Returns true if the UI as a player associated.
func has_player() -> bool:
	return is_instance_valid(player)

func unregister_player() -> void:
	if not is_instance_valid(player): return
	if player.health_changed.is_connected(on_health_update):
		player.health_changed.disconnect(on_health_update)
	if player.loadout_changed.is_connected(on_loadout_update):
		player.loadout_changed.disconnect(on_loadout_update)

## Registers a player to the ui.
func register_player(p : Player) -> void:
	
	player = p
	
	# Register signals
	player.health_changed.connect(on_health_update)
	on_health_update(player.health)
	
	player.loadout_changed.connect(on_loadout_update)
	
	on_loadout_update()

func on_loadout_update() -> void:
	if not is_instance_valid(player): return
	if is_instance_valid(hotbar):
		hotbar.update_items(
			player.held_weapons,
			player.get_current_weapon_index()
		)
		hotbar.visible = len(player.held_weapons) > 1
	

func on_health_update(new : float) -> void:
	health_bar.value = clampf(new/player.get_max_health(), 0.0, 1.0)
	health_label.text = str(roundf(new*10)/10)

func _process(delta: float) -> void:
	
	var perc := player.health / player.get_max_health()
	
	heart_animation_time += delta * lerpf(pulse_speed, max_pulse_speed, 1-perc)
	
	var result := sin(heart_animation_time)-sin(heart_animation_time*2)-2*sin(heart_animation_time*0.5)
	if result < 0: result = 0
	result *= lerpf(pulse_size_multi, max_pulse_size_multi, 1-perc)
	health_bar.scale = Vector2(result+4, result+4)

func _ready() -> void:
	health_bar.pivot_offset = health_bar.size/2
	on_loadout_update()
