shader_type canvas_item;

uniform float wave_pos = -0.2;

void fragment() {
    float dist = abs(UV.y - wave_pos);

    float wave = smoothstep(0.2, 0.0, dist);

    COLOR = vec4(vec3(0.2, 1.0, 1.0) * wave, wave * 0.4);
}
