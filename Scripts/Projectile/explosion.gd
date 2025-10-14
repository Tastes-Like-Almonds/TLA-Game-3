## A one-shot explosion scene. Auto deletes after explode() is called. Make sure to set
## target_groups before exploding, as it won't deal damage otherwise.
class_name Explosion extends Node2D

signal physics_process_finished

## Damage dealt upon explosion. Fixed value.
@export var damage : float = 3.0

## Knockback applied to all bodies within explosion
@export var knockback : float = 300.0

## Color of the explosion. Auto fades out at the end.
@export var color : Color = Color("ffffff")

# An array of groups to target. Nodes not in one of the groups provided will not be dealt
# damage/knockback.
@export var target_groups : Array[StringName]

## Get the path to which scene should be instantiated upon make_explosion() being called.
static func get_self_path() -> String:
	return "res://Scenes/Projectile/explosion.tscn"

## Create an explosion at the target location.
static func make_explosion(parent:Node, pos: Vector2, targets : Array[StringName], size: float = 8, dam: float = 1, knock : float = 300.0) -> void:
	var explosion : Explosion = load(get_self_path()).instantiate()
	
	explosion.damage = dam
	explosion.set_explosion_size(size)
	explosion.knockback = knock
	explosion.target_groups = targets
	explosion.global_position = pos
	
	parent.add_child(explosion)
	explosion.explode()

## Update the texture and collision shape to reflect the passed size.
func set_explosion_size(size : float = 8.0) -> void:
	if size < 8: size = 8
	$Area2D/CollisionShape2D.scale = Vector2(size/8,size/8) # 8 is the texture size for both
	$GPUParticles2D.texture.width = size*1.5/8
	$GPUParticles2D.texture.height = size*1.5/8
	$GPUParticles2D3.texture.width = size/8
	$GPUParticles2D3.texture.height = size/8
	$GPUParticles2D.scale = Vector2(size*1.5/8,size*1.5/8)
	$GPUParticles2D.amount = size/8

func explode() -> void:
	await physics_process_finished
	$GPUParticles2D.emitting = true
	$GPUParticles2D3.emitting = true
	# Get bodies in range, and apply damage
	for body:Node2D in $Area2D.get_overlapping_bodies():
		for group:StringName in target_groups:
			if body.is_in_group(group):

				var kb_dir := global_position.direction_to(body.global_position) 

				if body.has_method("deal_damage"): body.deal_damage(damage)
				if body is PlayerBody: body.get_player().deal_damage(damage)

				if body.has_method("deal_knockback"):
					body.deal_knockback(kb_dir*knockback)
				elif body is PlayerBody:
					body.get_player().deal_knockback(kb_dir)
					
	$GPUParticles2D.finished.connect(queue_free)

func _physics_process(_delta: float) -> void:
	physics_process_finished.emit()
