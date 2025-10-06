extends GutTest

func test_apply_all() -> void:
	
	var add_mod := PropertyModifier.new(1, PropertyModifier.ModiferType.ADD)
	var add_scalar_mod := PropertyModifier.new(1, PropertyModifier.ModiferType.ADD_SCALAR)
	var multiply_mod := PropertyModifier.new(2, PropertyModifier.ModiferType.MULTIPLY)
	
	assert_almost_eq(PropertyModifier.apply_all([add_mod], 1.0), 2.0, 0.1, "(float) Add mod of 1 should add 1")
	assert_almost_eq(PropertyModifier.apply_all([add_scalar_mod], 1.0), 2.0, 0.1, "(float) Add scalar of 1 multiply by 2")
	assert_almost_eq(PropertyModifier.apply_all([multiply_mod], 1.0), 2.0, 0.1, "(float) Multiply mod of 2 should multiply by 2")
	
	assert_eq(PropertyModifier.apply_all([add_mod], 1), 2, "(int) Add mod of 1 should add 1")
	assert_eq(PropertyModifier.apply_all([add_scalar_mod], 1), 2,  "(int) Add scalar of 1 multiply by 2")
	assert_eq(PropertyModifier.apply_all([multiply_mod], 1), 2, "(int) Multiply mod of 2 should multiply by 2")
	
	assert_almost_eq(PropertyModifier.apply_all([add_mod], Vector2(1,1)), Vector2(2,2), Vector2(0.1,0.1), "(Vector2) Add mod of 1 should add 1")
	assert_almost_eq(PropertyModifier.apply_all([add_scalar_mod], Vector2(1,1)), Vector2(2,2), Vector2(0.1,0.1), "(Vector2) Add scalar of 1 multiply by 2")
	assert_almost_eq(PropertyModifier.apply_all([multiply_mod], Vector2(1,1)), Vector2(2,2), Vector2(0.1,0.1), "(Vector2) Multiply mod of 2 should multiply by 2")
