class_name Cosmetic extends Resource

enum EquipSlot {
	HAT
}

@export var name : String = ""
@export var hint : String = ""
@export var desc : String = ""

@export var equip_slot : EquipSlot

static func get_equip_slot_name(slot:EquipSlot) -> StringName:
	match slot:
		EquipSlot.HAT:
			return &"hat"
	return &"none"

func get_slot_name() -> StringName:
	return Cosmetic.get_equip_slot_name(equip_slot)

func is_unlocked() -> bool:
	return true
