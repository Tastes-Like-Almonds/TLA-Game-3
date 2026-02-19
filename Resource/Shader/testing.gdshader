shader_type canvas_item;

uniform float brightness :hint_range(0,1) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec3 clr = vec3(1,1,1);
	if (brightness < 0.5) {
		clr *= 0.0;
	}
	
	COLOR.rgb = clr;
	COLOR.a = abs(brightness-0.5)*0.4;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
