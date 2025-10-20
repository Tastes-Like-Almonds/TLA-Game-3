class_name Hotbar extends Control

@onready var hbox_container : HBoxContainer = $MarginContainer/HBoxContainer
@onready var template_item : TextureRect = $TemplateItem

## Deletes/adds texturerects until the count is equal to amt.
func _set_child_count(amt : int) -> void:
	var children : Array[Node] = hbox_container.get_children()
	var count := len(children)
	
	if count == amt: return
	
	if count > amt: # Clone from TemplateItem to fill
		for x in range(amt-count):
			var child := template_item.duplicate()
			hbox_container.add_child(child)
	
	if count < amt:
		for x in range(count-amt):
			children[x].queue_free() # Free the first n children

func update_items(items : Array[Weapon], selected_index : int, max:int, player : Player) -> void:
	
	_set_child_count(items.size())
	var children : Array[Node] = hbox_container.get_children()
	for idx in range(children.size()):
		var item := items[idx]
		var child := children[idx]
		
