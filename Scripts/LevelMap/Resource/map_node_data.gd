@abstract class_name MapNodeData extends Resource

#region Exports
## Title displayed on the node card
@export var title : String

## The description on the node card
@export_multiline var description : String

@export_group("Button")

## If true, a button will be displayed on  the node card
@export var has_button : bool = true

## The text on the button on the node card.
@export var button_text : String

## The color of the button on the node card
@export var button_color : Color

## The color of the text on the button on the node card.
@export var button_text_color : Color
#endregion

#region Abstract
## Trigger the effect which occurs upon the map node's button being pressed.
@abstract func button_pressed() -> void
#endregion

#region Private
func _ready() -> void:
	pass
#endregion
