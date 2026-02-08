class_name MapNode extends Node2D

## Unique ID for the node; must be set or else an error will be thrown by the map.
## This ID is used for saving data, so changing it will wipe existing save data for the node.
## In short, don't change this.
@export var unique_id : int = -1

## The data associated with this map node
@export var node_data : MapNodeData

## The node card used to interact with the map node. 
## Not required by default, but it is for certain MapNodeData types.
@export var node_card : NodeCard

#region Utility
## If node_data is null, return false and print an error.
func _err_if_no_data() -> bool:
	if node_data == null:
		printerr("Node data not set for MapNode! Name: " + name) 
		return true
	return false
#endregion

#region Public
func open_card() -> void:
	if node_card: node_card.open()

func close_card() -> void:
	if node_card: node_card.close()
#endregion

func _ready() -> void:
	if _err_if_no_data(): return
	if node_card:
		node_card.open() # TODO Remove when testing is done.
		node_card.button_pressed.connect(node_data.button_pressed)
