extends Enemy

enum Phase {
	NONE,
	INTRO,
	FIGHT,
	DEATH
}

@export var target_start_pos : Node2D
@export var dialog : DialogTree
var phase : Phase
var phase_ended : bool = false

func _intro(delta : float) -> void:
	var movement := Vector2.ZERO
	var dist := absf(target_start_pos.global_position.y - global_position.y)
	
	movement = global_position.direction_to(target_start_pos.global_position)
	movement *= 80 # Hardcoded movement speed; no need to be flexible here.
	
	if dist < movement.y:
		if movement.y < 0:
			movement.y = -dist
		else:
			movement.y = dist
	
	if not phase_ended:
		move_and_collide(movement*delta)
		if movement.y - dist == 0:
			phase_ended = true
			GameCamera.set_current_camera_shake(get_viewport(), 0.3)
		

func _movement(delta : float) -> void:
	match phase:
		Phase.NONE:
			return
		Phase.INTRO:
			_intro(delta)
			if !DialogLoader.is_playing_dialog() and phase_ended:
				change_phase(Phase.FIGHT)
		Phase.FIGHT:
			return
		Phase.DEATH: 
			return

func change_phase(p:Phase) -> void:
	phase = p
	phase_ended = false
	
	var cam := get_viewport().get_camera_2d()
	if cam is not GameCamera:
		push_warning("Camera should be GameCamera.")
		cam = null # Easier checking later on
	print("RAN. CURRENT:")
	print(p)
	match p:
		Phase.NONE:
			return
		Phase.INTRO:
			if cam:
				cam.set_target_node(self)
			DialogLoader.play_dialog_tree(dialog)
		Phase.FIGHT:
			sprite.z_index = 5
			for player:Player in get_tree().get_nodes_in_group(&"Player"):
				cam.set_target_node(player.get_player_body())
		Phase.DEATH: 
			return

func _ready() -> void:
	super()
	SignalBus.LevelLoaded.connect(change_phase.bind(Phase.INTRO))
