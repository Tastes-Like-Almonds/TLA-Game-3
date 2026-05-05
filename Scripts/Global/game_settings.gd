## Set/get game settings such as volume, resolution, etc.
extends Node

signal SettingChanged(key:String, value:Variant)

const DEFAULTS = {
	"music_volume_perc" = 2,
	"sfx_volume_perc" = 2,
	"brightness" = 0.5,
	"mouse_sens" = 1.0,
	"disable_crt" = true,
	"fullscreen" = false
}

## Emit SettingChanged for all settings. Called when new player data is loaded.
func _signal_settings() -> void:
	var data : Dictionary = get_settings_data()
	
	for setting:String in data.keys():
		SettingChanged.emit(setting, data[setting])

func get_settings_data() -> Dictionary:
	var data : Dictionary = PersistentData.get_all_save_data()
	
	if ("settings" not in data):
		data["settings"] = {}
	
	return data["settings"]

func get_default_setting(key:String) -> Variant:
	if key in DEFAULTS:
		return DEFAULTS[key]
	push_warning("No default setting for '" + key + "'!")
	return null

func get_setting(key:String) -> Variant:
	
	var val : Variant = get_default_setting(key)
	var data := get_settings_data()
	
	if (data):
		if (key in data): val = data[key]
		
	return val

func set_setting(key:String, value:Variant) -> void:
	var data := get_settings_data()
	
	if key not in data:
		data[key] = null
	
	if (data[key] != value): SettingChanged.emit(key, value)
	data[key] = value

func _ready() -> void:
	if !PersistentData.is_loaded:
		await PersistentData.DataLoaded
	PersistentData.DataLoaded.connect(_signal_settings)
	#print(get_settings_data())
	_signal_settings()
