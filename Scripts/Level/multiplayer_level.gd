class_name MultiplayerLevel extends Level

#region Private
## Setup the camera. Should only be overidden if specific functionality is needed. Otherwise,
## use _make_camera.
func _setup_camera() -> void:
	var camera := _make_camera()
	SignalBus.CameraChanged.emit(camera)
	add_child(camera)

## Setup the player. Should only be overidden if specific functionality is needed. Otherwise,
## use _make_player.
func _setup_player(id : int = 1) -> Player:
	
	var player := _make_player()
	var spawn := _get_first_spawn()
	
	player.id   = id
	player.name = str(id)
	
	push_warning("Player " + str(id) + " created.")
	
	if is_instance_valid(spawn): 
		player.get_player_body().global_position = _get_first_spawn().global_position
		player.properties.starting_weapon = _get_default_player_weapon()
		add_child(player)
		player.get_player_sword().body.global_position = player.get_player_body().global_position

	return player

## Instantiate and child the LevelUI. Must be registered to a player to display.
func _setup_ui() -> void:
	current_ui = load(level_ui_path).instantiate()
	add_child(current_ui)

func _handle_completion_event(event:CompletionEvent, val:Variant) -> void:
	
	match event:
		CompletionEvent.PLAYER_TAKEN_DAMAGE:
			completion_data.damage_taken += val
		
		CompletionEvent.PLAYER_DEALT_DAMAGE:
			completion_data.damage_dealt += val
		
		CompletionEvent.PLAYER_DEATH:
			completion_data.deaths += 1
		
		CompletionEvent.PLAYER_KILL:
			completion_data.kills += 1
		
		CompletionEvent.PLAYER_DASHED:
			completion_data.dashes += 1
		
#endregion

#region Public
func hide_ui() -> void:
	current_ui.hide()

## Syncronize displayed information (items, health, etc.) with a target player.
## Should be called whenever a new UI is created.
func register_ui(player : Player) -> void:
	current_ui.register_player(player)

func _player_connected(id : int) -> void:
	
	var player := _setup_player(id)
	player.CompletionEvent.connect(_handle_completion_event)
	
	if id == multiplayer.get_unique_id():
		_setup_ui()
		register_ui(player)

func initialize(config : LevelConfig = null) -> void:
	
	if not config:
		config = LevelConfig.new()
	level_config = config
	
	_player_connected(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(_player_connected)

	_setup_camera()
	
	on_load.emit()
	SignalBus.LevelLoaded.emit()
	loaded = true

## Ends the level and returns to the level selector.
func complete() -> void:
	SaveSlots.add_level_completion(level_config.world, level_config.sid, completion_data)
	Helper.fade_to_selector()

static func get_level_data() -> void:
	pass
#endregion

#region Inherited
func _ready() -> void:
	
	# Delegate pausing to separate node as to ensure level gets paused, as well.
	var pause_man : Node = load("res://Scenes/Component/pause_manager.tscn").instantiate()
	add_child(pause_man)
	
	completion_data = CompletionData.new()
	
	# Start tracks if set
	if starting_ambience:
		Music.start_track(Music.TrackLayer.AMBIENT, starting_ambience, 1.0)
	if starting_track:
		Music.start_track(Music.TrackLayer.MUSIC, starting_track, 1.0)

func _process(delta: float) -> void:
	completion_data.time_sec += delta
	current_ui.set_timer_value(completion_data.time_sec)
#endregion
