class_name PropertyModifier extends Resource

enum ModiferType {
	NULL, # Do not use this one.
	ADD, # Add values together, then add them to val.
	ADD_SCALAR, # Add values to 1.0, then multiply the val.
	MULTIPLY # Multiply val, compounding with other modifiers.
}

## The value of the modifier. What this does depends on mod_type.
@export var value : float

## The way which value is applied to a given value.
@export var mod_type : ModiferType

## The time before this property expires. If set to zero, it will never expire.
## This does not impact function, and must be manually checked via is_active() to remove the
## modifier.
@export var timer : float = 0.0

## The remaining time on the timer.
var time_left := timer

## If true, the modifier is still active. Whether or not it is active has no impact on function.
var active : bool = true

static func get_type_of_mods(mods : Array[PropertyModifier]) -> ModiferType:
	if mods.size() == 0: return ModiferType.NULL
	var first_type := mods[0].mod_type
	for mod in mods:
		if mod.mod_type != first_type: 
			print_debug("Inconsistent mod types found! \nmod Array: " + str(mods))
			return ModiferType.NULL
	return first_type

static func apply_all(mods : Array[PropertyModifier], val : float) -> float:
	
	var mod_types := get_type_of_mods(mods)
	if mod_types == ModiferType.NULL: return val
	
	match mod_types:
		
		ModiferType.ADD:
			var total : float = 0.0
			for mod in mods:
				total += mod.value
			return val+total
			
		ModiferType.ADD_SCALAR:
			var scalar : float = 1.0
			for mod in mods:
				scalar += mod.value
			return val*scalar
		
		ModiferType.MULTIPLY:
			for mod in mods:
				val *= mod.value
			return val
	
	return val

func _init(val : float, modifier_type : ModiferType, time : float = 0.0) -> void:
	value = val
	mod_type = modifier_type
	timer = time
	time_left = time

func update(delta : float) -> void:
	if timer != 0.0:
		timer -= delta
		if (timer <= 0):
			deactivate()

func deactivate() -> void:
	active = false

func is_active() -> bool:
	return active
