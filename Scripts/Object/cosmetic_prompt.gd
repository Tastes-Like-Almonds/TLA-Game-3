extends Node2D

@onready var name_label   : Label                = $Node2D/NameLabel
@onready var desc_label   : Label                = $Node2D/DescLabel
@onready var prompt       : CosmeticDialogPrompt = $DialogPrompt
@onready var display_area : Area2D               = $Area2D
@onready var animator     : AnimationPlayer      = $AnimationPlayer

@export var cosmetic: Cosmetic

func _equip() -> void:
	print("EQUIPING")
	CosmeticLoader.equip_cosmetic(cosmetic)
	SignalBus.ReloadCosmetics.emit()

func _ready() -> void:
	
	if not cosmetic: return
	
	if cosmetic.is_unlocked():
		name_label.text = cosmetic.name
		desc_label.text = cosmetic.desc
	
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
