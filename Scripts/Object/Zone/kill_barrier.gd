extends StaticBody2D

@onready var texture_rect := $TextureRect
@onready var shape := $CollisionShape2D
@onready var animation_player := $AnimationPlayer

## An array of enemies. When all enemies are killed once, the barrier clears.
@export var links : Array[Enemy]

## Speed of the texture movement
@export var move_speed : float = 5.0

var killed : Array[bool]
var num_killed : int = 0

func _ready() -> void:
	
	# Initialize killed array
	for link in links:
		if !is_instance_valid(link):
			push_warning("No links set for kill barrier!")
			return
		killed.append(false)
		link.Killed.connect(func() -> void: _on_death(link))
	
	# Calculate barrier size
	var barrier_size : Vector2 = shape.shape.size * scale
	texture_rect.texture.width = barrier_size.x
	texture_rect.texture.height = barrier_size.y
	texture_rect.global_position = global_position - (barrier_size*shape.scale)/2

func _process(delta: float) -> void:
	texture_rect.texture.noise.offset.x += delta*4
	texture_rect.texture.noise.offset.y += delta*4

func _on_death(enemy:Enemy) -> void:

	for i in range(len(links)):
		if links[i] == enemy and killed[i] == false:
			killed[i] = true
			num_killed += 1
	
	if num_killed >= len(links):
		move_speed = 0 # Not neccessary but looks slightly better
		$CollisionShape2D.disabled = true
		_clear()
			
## Open the barrier
func _clear() -> void:
	animation_player.play("clear")
	
	# Lambda used to shut up warning
	animation_player.animation_finished.connect(func(_x:Variant) -> void: queue_free())
