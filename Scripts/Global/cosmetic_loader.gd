## Loads player cosmetics for any given weapon, hat etc.
extends Node

const cosmetic_template : Dictionary = {
	"value"       : "",
	"obtain_time" : 0   # UNIX Timestamp
}

func _get_cosmetic_data() -> Dictionary:
	var data : Dictionary = PersistentData.get_all_save_data()
	
	if ("cosmetics" not in data):
		data["cosmetics"] = {
			"owned": {},
			"equipped": {},
		}
	
	return data["cosmetics"]

func get_weapon_visual(weapon : Weapon) -> WeaponVisual:

	if weapon is SwordWeapon:
		return load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn").instantiate()
	
	elif weapon is WoodSwordWeapon:
		var visual : WeaponVisual = load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn").instantiate()
		visual.trail_color = Color.SADDLE_BROWN
		visual.texture = load("res://Assets/Sprites/Weapon/Wooden Sword.png")
		return visual
	
	elif weapon is StaffWeapon:
		return load("res://Scenes/Visual/Weapons/Staff/staff_basic_visual.tscn").instantiate()
	
	elif weapon is HammerWeapon:
		return load("res://Scenes/Visual/Weapons/Hammer/hammer_basic_visual.tscn").instantiate()

	return load("res://Scenes/Visual/Weapons/Sword/sword_basic_visual.tscn").instantiate()

func get_body_cosmetics() -> Array[BodyCosmetic]:

	var arr : Array[BodyCosmetic] = []
	var equipped : Dictionary = _get_cosmetic_data()["equipped"]

	for c : Variant in equipped.values():
		if c is BodyCosmetic:
			arr.append(c)

	return arr

func equip_cosmetic(cosmetic:Cosmetic) -> void:
	var data := _get_cosmetic_data()
	data["equipped"][cosmetic.get_slot_name()] = cosmetic

func has_cosmetic(cosmetic : Cosmetic) -> bool:
	var data := _get_cosmetic_data()
	for c : Dictionary in data["owned"].values():
		if c["value"] == cosmetic.resource_path:
			return true
	return false

func give_cosmetic(cosmetic_path:String) -> void:

	if !ResourceLoader.exists(cosmetic_path):
		push_warning("Attempt to earn nonexistent cosmetic '" + cosmetic_path + "'")
		return
	
	var data := _get_cosmetic_data()
	
	if cosmetic_path in data["owned"]:
		print_debug("Attempt to give already-owned cosmetic '" + cosmetic_path + "'")
		return

	var dict := cosmetic_template.duplicate(true)
	dict.obtain_time = Time.get_unix_time_from_system()
	dict.value = cosmetic_path

	data["owned"][cosmetic_path] = dict
	SignalBus.CosmeticUnlocked.emit()
