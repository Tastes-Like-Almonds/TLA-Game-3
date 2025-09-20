extends GutTest

func test_angle_roughly_vertical():
	assert_false(Helper.is_angle_roughly_vertical( 0,     PI/4), "Angle 0 mistreated as vertical")
	assert_true(Helper.is_angle_roughly_vertical ( PI/2,  PI/4), "Angle PI/2 mistreated as horizontal")
	assert_false(Helper.is_angle_roughly_vertical( PI,    PI/4), "Angle PI mistreated as vertical")
	assert_true(Helper.is_angle_roughly_vertical ( -PI/2, PI/4), "Angle -PI/2 mistreated as horizontal")
