extends Node
#
### Returns the active camera, if if there is not one, creates it at (0,0).
#func get_camera_2d(parent: Node2D = null) -> Camera2D:
	#
	#var camera : Camera2D = get_viewport().get_camera_2d()
	#if is_instance_valid(camera): return camera
	#
	#if is_instance_valid(parent):
		#camera = Camera2D.new()
		#camera.zoom = Vector2(1,1)
		#camera.global_position = Vector2(0,0)
		#parent.add_child(parent)
#
	#return camera
#
#func set_camera_target_position(position : Vector2, parent : Node2D) -> void:
	#print("SET")
	#var cam := get_camera_2d(parent)
	#cam.set_meta("target_cam_pos", position) 
#
#func _process(_delta: float) -> void:
	#var cam := get_camera_2d()
	#if is_instance_valid(cam):
		#print("EE")
		#if cam.has_meta("target_cam_pos"):
			#print("E")
			#cam.global_position = cam.get_meta("target_cam_pos")
