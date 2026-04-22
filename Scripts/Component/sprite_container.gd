class_name SpriteContainer extends Node2D

@export var flip_h : bool = false :
	set(new):
		for child in get_children():
			if "flip_h" in child:
				child.flip_h = new
		flip_h = new

@export var flip_v : bool = false :
	set(new):
		for child in get_children():
			if "flip_v" in child:
				child.flip_v = new
		flip_v = new
