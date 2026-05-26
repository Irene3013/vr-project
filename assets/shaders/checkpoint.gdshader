shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform vec4 color : source_color = vec4(0.2, 0.8, 1.0, 0.7);

void fragment() {
	float gradient = UV.y;
	float pulse = sin(TIME * 3.0) * 0.15 + 0.85;//sin(TIME * 4.0) * 0.4 + 0.6;
	//float flicker = sin(TIME * 15.0) * 0.05 + 0.95;  // titileo sutil

	ALBEDO = color.rgb;
	EMISSION = color.rgb * 4.0;
	ALPHA = gradient * color.a * pulse * 1.5;//flicker;
}