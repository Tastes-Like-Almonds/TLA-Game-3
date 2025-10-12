extends AnimatableBody2D

@export_custom(PROPERTY_HINT_RESOURCE_TYPE, "Shape2D", PROPERTY_USAGE_EDITOR) var shape : Shape2D
#
#func _validate_property(property: Dictionary) -> void:
	#if property.name

func _ready() -> void:
	$CollisionShape2D.shape = shape
