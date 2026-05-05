extends Node2D

@onready var name_label   : Label                = $Node2D/NameLabel
@onready var desc_label   : Label                = $Node2D/DescLabel
@onready var prompt       : CosmeticDialogPrompt = $DialogPrompt
@onready var display_area : Area2D               = $Area2D
@onready var animator     : AnimationPlayer      = $AnimationPlayer
@onready var toggle_anim  : AnimationPlayer      = $Toggler

@export var cosmetic: Cosmetic

func _equip() -> void:
	CosmeticLoader.equip_cosmetic(cosmetic)
	SignalBus.ReloadCosmetics.emit()

func _update_unlocked() -> void:
	if cosmetic.is_unlocked():
		toggle_anim.play("unlocked")
		name_label.text = cosmetic.name
		desc_label.text = cosmetic.desc
	else:
		toggle_anim.play("locked")
		name_label.text = "???"
		desc_label.text = cosmetic.hint

func _ready() -> void:
	
	if not cosmetic: return
	
	animator.play("hide")
	
	_update_unlocked()
	SignalBus.CosmeticUnlocked.connect(_update_unlocked)
	
	if cosmetic is BodyCosmetic:
		var node_cosmetic : Node2D = cosmetic.get_node()
		$Visual.add_child(node_cosmetic)
	
	prompt.Triggered.connect(_equip)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerBody:
		animator.play("show")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerBody:
		
		var empty : bool = true
		for b in display_area.get_overlapping_bodies():
			if b is PlayerBody and b != body:
				empty = false
		
		if empty:
			animator.play("hide")
