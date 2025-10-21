class_name Hotbar extends Control

@onready var hbox_container : HBoxContainer = $MarginContainer/HBoxContainer
@onready var template_item : TextureRect = $TemplateItem

## Deletes/adds texturerects until the count is equal to amt.
func _set_child_count(amt : int) -> void:
	var children : Array[Node] = hbox_container.get_children()
	var count := len(children)
	
	if count == amt: return
	
	if count > amt: # Clone from TemplateItem to fill
		for x in range(count-amt):
			children[x].queue_free() # Free the first n children
	
	if count < amt:
		for x in range(amt-count):
			var child := template_item.duplicate()
			hbox_container.add_child(child)
			child.visible = true

func update_items(items : Array[Weapon], selected_index : int) -> void:
	
	_set_child_count(items.size())
	var children : Array[Node] = Helper.get_all_valid_children(hbox_container)
	for idx in range(children.size()):
		#var item := items[idx]
		var child := children[idx]
		# TODO Load image
		child.set_meta("weapon_idx", idx)
		
		if child is Control:
			if idx == selected_index:
				child.modulate.a = 1.0
			else:
				child.modulate.a = 0.4
	return
