class_name PlayerDevPanelCategory extends DevPanelCategory

@onready var select_player_node : OptionButton = $MarginContainer/VBoxContainer/TargetPlayer/VBoxContainer/SelectPlayer
@onready var select_player_display_node : Label = $MarginContainer/VBoxContainer/PlayerDisplay
@onready var select_player_confirm_node : Button = $MarginContainer/VBoxContainer/TargetPlayer/VBoxContainer/SelectPlayerConfirm

@onready var set_stat_stat_select : OptionButton = $MarginContainer/VBoxContainer/SetStat/VBoxContainer/SelectStat
@onready var set_stat_val : SpinBox = $MarginContainer/VBoxContainer/SetStat/VBoxContainer/SelectStatVal
@onready var set_stat_confirm : Button = $MarginContainer/VBoxContainer/SetStat/VBoxContainer/ConfirmSetStat
@onready var set_stat_current_val : Label = $MarginContainer/VBoxContainer/SetStat/VBoxContainer/StatCurrentVal

@onready var select_item_dropdwon : OptionButton = $MarginContainer/VBoxContainer/GiveWeapon/VBoxCointainer/SelectItem
@onready var select_item_confirm : Button = $MarginContainer/VBoxContainer/GiveWeapon/VBoxCointainer/ConfirmGiveItem

var target_player : Player
var possible_players : Array[Player]

#region Target Player
func update_select_player_dropdown() -> void:
	
	select_player_node.clear()
	possible_players.clear()
	
	for player in _get_dev_panel().get_all_players():
		select_player_node.add_item(player.name)
	
		possible_players.append(player)

func set_selected_player() -> void:
	var selected := select_player_node.selected
	
	if selected == -1: return
	if possible_players.size()-1 > selected: return
	
	target_player = possible_players[selected]
	select_player_display_node.text = "Current Player: " + target_player.name
	update_set_stat_dropdown()
	update_selected_stat_desc()
	update_give_item_dropdown()
#endregion Target Player

#region SetStat

func update_set_stat_dropdown() -> void:
	set_stat_stat_select.clear()
	if not is_instance_valid(target_player) : return
	for stat in target_player.get_property_list():
		if stat["type"] == Variant.Type.TYPE_FLOAT:
			if stat["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE: # Only exported vars
				set_stat_stat_select.add_item(stat["name"])
				set_stat_stat_select.set_item_metadata(set_stat_stat_select.item_count-1, stat)

func update_selected_stat_desc() -> void:
	var meta : Variant = set_stat_stat_select.get_selected_metadata()
	
	if not is_instance_valid(target_player) : return
	if meta["type"] != Variant.Type.TYPE_FLOAT : return
	if not (meta["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) : return
	
	var current : float = target_player.get(meta["name"])
	set_stat_current_val.text = "Current value: " + str(current)
	set_stat_val.value = current

func update_selected_player_stat(val : float) -> void:
	var meta : Variant = set_stat_stat_select.get_selected_metadata()
	
	if not is_instance_valid(target_player) : return
	if meta["type"] != Variant.Type.TYPE_FLOAT : return
	if not (meta["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) : return
	
	target_player.set(meta["name"], val)
	update_selected_stat_desc()

#endregion

#region Give Item

func update_give_item_dropdown() -> void:
	var classes := ProjectSettings.get_global_class_list()
	for clazz in classes:
		
		# Checking by names is super ugly, but there is literally no other way to do it.
		# If there is one, it's probably more ugly and requires more work.
		# If the standard is maintained, there shouldn't be an issue.
		if clazz.class == "Weapon" or clazz.class == "TestWeapon": continue
		if clazz.class.ends_with("Weapon"):
			select_item_dropdwon.add_item(clazz.class)
			select_item_dropdwon.set_item_metadata(select_item_dropdwon.item_count-1, clazz)

func confirm_give_item() -> void:
	var clazz : Variant = select_item_dropdwon.get_selected_metadata()
	if not clazz : return
	if clazz.class == "Weapon" or clazz.class == "TestWeapon": return
	if not is_instance_valid(target_player) : return
	target_player.pickup_weapon(load(clazz.path).new())

#endregion

func _ready() -> void:
	
	select_player_confirm_node.pressed.connect(set_selected_player)
	SignalBus.PlayerAdded.connect(func(_x : Player) -> void: update_select_player_dropdown())
	SignalBus.PlayerRemoved.connect(func(_x : Player) -> void: update_select_player_dropdown())
	update_select_player_dropdown()
	
	set_stat_stat_select.item_selected.connect(func(_x : float) -> void: update_selected_stat_desc())
	set_stat_confirm.pressed.connect(func() -> void: update_selected_player_stat(set_stat_val.value))
	update_selected_stat_desc()
	
	select_item_confirm.pressed.connect(confirm_give_item)
