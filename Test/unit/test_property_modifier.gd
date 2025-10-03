extends GutTest

func test_apply_all() -> void:
	
	var add_mod := PropertyModifier.new(1, PropertyModifier.ModiferType.ADD)
	var add_scalar_mod := PropertyModifier.new(1, PropertyModifier.ModiferType.ADD_SCALAR)
	var multiply_mod := PropertyModifier.new(2, PropertyModifier.ModiferType.MULTIPLY)
	
	assert_almost_eq(PropertyModifier.apply_all([add_mod], 1.0), 2.0, 0.1, "Add mod of 1 should add 1e")
	assert_almost_eq(PropertyModifier.apply_all([add_scalar_mod], 1.0), 2.0, 0.1, "Add scalar of 1 multiply by 2")
	assert_almost_eq(PropertyModifier.apply_all([multiply_mod], 1.0), 2.0, 0.1, "Multiply mod of 2 should multiply by 2")
