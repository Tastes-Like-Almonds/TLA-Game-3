class_name ChatWindow extends HBoxContainer

@onready var label    := $ScrollContainer/VBoxContainer/RichTextLabel
@onready var edit     := $ScrollContainer/VBoxContainer/LineEdit
@onready var animator := $AnimationPlayer

const MAX_MESSAGES = 50
const MAX_TIME     = 5.0
const DEFAULT_USER_PREFIX = "[color=green][{name}]:[/color] "

var message_time : float = MAX_TIME

var messages : Array[String]

func push_message(msg : String) -> void:
	
	message_time = 0
	animator.play("open")
	
	messages.append(msg)
	
	if messages.size() > MAX_MESSAGES:
		messages.remove_at(0)
	
	label.text = "\n".join(messages)

func _player_messaged(id: int, msg : String) -> void:
	
	# Get player info
	var user_dict : Dictionary = Lobby.players.get(id)
	var username  : String     = "Unknown"
	if user_dict: username = user_dict["name"]
	
	# Create message
	var message   : String     = DEFAULT_USER_PREFIX.format({"name": username})
	message += msg
	push_message(message)

func _send_current_message(new_text : String) -> void:
	if new_text != "":
		$ScrollContainer/VBoxContainer/LineEdit.release_focus()
		Lobby.send_message.rpc(new_text)
		edit.text = ""

func _open_chat() -> void:
	animator.play("open") 
	message_time = 0.0
	$ScrollContainer/VBoxContainer/LineEdit.grab_focus()
	$ScrollContainer/VBoxContainer/LineEdit.edit()

func _input(event: InputEvent) -> void:
	if event.is_action("open_chat") and event.is_released():
		_open_chat()

func _process(delta: float) -> void:
	visible = !get_tree().paused
	if !edit.has_focus():
		message_time += delta
	if message_time > MAX_TIME:
		if animator.current_animation != "close" and modulate.a > 0.0:
			animator.play("close")

func _ready() -> void:
	label.text = ""
	Lobby.message_sent.connect(_player_messaged)
	edit.text_submitted.connect(_send_current_message)
