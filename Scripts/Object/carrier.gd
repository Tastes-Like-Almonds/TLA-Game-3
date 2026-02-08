## A player-rideable object.
class_name CarrierObject extends Node2D

@onready var follow : PathFollow2D = $PathFollow2D

## The path to the AnimatableBody2D which is used for the carrier. Must be set.
@export_file_path("*.tscn") var body_path : String

@export_group("Trigger")
## If set, the carrier will start upon a player entering the zone.
@export var start_trigger : TriggerZone

## Time, in seconds, before the carrier will start moving after triggering.
@export var start_delay : float = 0.0

@export_group("Movement")
## The speed per second of the carrier.
@export var speed : float = 300.0

## If true, the carrier will start moving when loaded.
@export var start_moving : bool

var body : AnimatableBody2D
var moving : bool = false

func _ready() -> void:
	
	# Load and validate the body
	var scn := load(body_path)
	
	# File not found
	if not scn: push_warning("Invalid body_path set for carrier!") ; return
	
	body = scn.instantiate() # Assume it's a scene, as it must be ".tscn" to be selected.
	
	# Ensure type and validity
	if not is_instance_valid(body): push_warning("Invalid body_path set for carrier!") ; return
	if body is not AnimatableBody2D: push_warning("Carrier body must be AnimatableBody2D!") ; return
	
	follow.add_child(body)
	
	if start_moving:
		_start()
	
	if is_instance_valid(start_trigger):
		start_trigger.player_entered.connect(func(_x:Variant) -> void: _start())

## Starts moving the carrier.
func _start() -> void:
	get_tree().create_timer(start_delay).timeout.connect(func() -> void: moving = true)

## Resets the carrier to its initial position.
func _reset() -> void:
	follow.progress = 0.0

func _physics_process(delta: float) -> void:
	if moving:
		follow.progress += delta*speed
	var last_pos := body.global_position
	body.global_position = follow.global_position
	body.constant_linear_velocity = (last_pos - body.global_position)
