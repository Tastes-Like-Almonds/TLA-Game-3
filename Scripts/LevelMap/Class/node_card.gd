class_name NodeCard extends PanelContainer

static var INSTANCE_PATH : StringName = "res://Scenes/LevelMap/Class/node_card.tscn"

signal button_pressed

@onready var button : Button = $VBoxContainer/Button
@onready var title_label : Label = $VBoxContainer/Title
@onready var description_label : Label = $VBoxContainer/ScrollContainer/Description

## The title of the node card, displayed at the top.
@export var title : String = "Untitled" :
	set(new):
		if title_label: title_label.text = new
		title = new

## The information text displayed below the title.
@export var description : String = "N/A" :
	set(new):
		if description_label: description_label.text = new
		description = new

## Text shown on the button
@export var button_text : String = "Select" :
	set(new):
		if button: button.text = new
		button_text = new

## Create a new NodeCard.
static func new() -> NodeCard:
	var scn := load(INSTANCE_PATH)
	if scn is not PackedScene: printerr("Invalid instance path for NodeCard; loaded object is not PackedScene")
	var card : NodeCard = scn.instantiate()
	return card

## Opens the node card. Should generally be done after it is created.
func open() -> void:
	show()

## Closes the node card, deleting itself at the end. Should generally be done in place of queue_free()
func close() -> void:
	hide()
	queue_free()

func _ready() -> void:
	
	title_label.text = title
	description_label.text = description
	button.text = button_text
	
	if button: button.pressed.connect(button_pressed.emit)
