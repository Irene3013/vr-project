// Shader 2D para el efecto de ola de luz en el HUD al activar un checkpoint.
shader_type canvas_item;

// Posición vertical de la ola, animada desde GDScript mediante set_shader_parameter.
// -0.2 = fuera por abajo, 1.2 = fuera por arriba.
uniform float wave_pos = -0.2;

void fragment() {
    // Distancia del píxel actual al centro de la ola.
    float dist = abs(UV.y - wave_pos);

    // smoothstep genera una banda suave: máximo en dist=0, cero en dist=0.2.
    float wave = smoothstep(0.2, 0.0, dist);

    // Color cian semitransparente, con alpha proporcional a la intensidad de la ola.
    COLOR = vec4(vec3(0.2, 1.0, 1.0) * wave, wave * 0.4);
}