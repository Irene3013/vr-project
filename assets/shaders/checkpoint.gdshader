// Shader espacial para el holograma del checkpoint.
// Usa blend_add para efecto de luz aditiva y cull_disabled para verse desde ambos lados.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

// Color del holograma, configurable desde el inspector o por código (set_shader_parameter).
uniform vec4 color : source_color = vec4(0.2, 0.8, 1.0, 0.7);

void fragment() {
	// UV.y va de 0 (abajo) a 1 (arriba), creando un gradiente vertical.
	float gradient = UV.y;
	// Pulso suave que oscila entre 0.7 y 1.0 a una frecuencia de 3 ciclos/segundo.
	float pulse = sin(TIME * 3.0) * 0.15 + 0.85;//sin(TIME * 4.0) * 0.4 + 0.6;
	//float flicker = sin(TIME * 15.0) * 0.05 + 0.95;  // titileo sutil

	ALBEDO = color.rgb;
	// Emisión amplificada x4 para efecto de brillo/glow.
	EMISSION = color.rgb * 4.0;
	// Alpha combinado: gradiente vertical * transparencia del color * pulso animado.
	ALPHA = gradient * color.a * pulse * 1.5;//flicker;
}