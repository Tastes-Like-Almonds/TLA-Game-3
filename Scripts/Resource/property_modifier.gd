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

## ID used to distinguish modifiers which should only be applied once. If multiple are present
## with the same ID, their modifiers will not add together.
var id : String

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

static func apply_all(mods : Array[PropertyModifier], val : Variant) -> Variant:
	
	if val is int:
		return int(apply_all(mods, float(val)))
	elif val is Vector2:
		return Vector2(apply_all(mods, val.x), apply_all(mods, val.y))
	
	var mod_types := get_type_of_mods(mods)
	if mod_types == ModiferType.NULL: return val
	
	var ids : Array = []
	
	match mod_types:
		
		ModiferType.ADD:
			var total : float = 0.0
			for mod in mods:
				
				if mod.id in ids: continue
				ids.append(mod.id)
				
				total += mod.value
				
			return val+total
			
		ModiferType.ADD_SCALAR:
			var scalar : float = 1.0
			for mod in mods:
				
				if mod.id in ids: continue
				ids.append(mod.id)
				
				scalar += mod.value
			
			return val*scalar
		
		ModiferType.MULTIPLY:
			for mod in mods:
				
				if mod.id in ids: continue
				ids.append(mod.id)
				
				val *= mod.value
				
			return val
	
	return val

func _init(val : float, modifier_type : ModiferType, time : float = 0.0) -> void:
	value = val
	mod_type = modifier_type
	timer = time
	time_left = time

func set_id(s: String) -> void:
	id = s

func update(delta : float) -> void:
	if timer != 0.0:
		timer -= delta
		if (timer <= 0):
			deactivate()

func deactivate() -> void:
	active = false

func is_active() -> bool:
	return active
