shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, repeat_disable, filter_linear;

// Speed of the flame flicker and the heat shimmer
uniform float sway_speed : hint_range(0.1, 5.0) = 1.0;
// How far the air behind the zone is displaced (in screen UV units)
uniform float sway_strength : hint_range(0.0, 0.05) = 0.01;
// Scales the heat-haze waves
uniform float noise_scale : hint_range(1.0, 20.0) = 5.0;
// Per-instance time offset so several zones don't flicker in sync
uniform float time_offset : hint_range(0.0, 100.0) = 0.0;

// Number of flame tongues along the top and bottom edges
uniform float flame_count : hint_range(2.0, 40.0) = 14.0;
// Flame height as a fraction of the zone height
uniform float flame_height : hint_range(0.02, 0.5) = 0.18;
// How strongly the interior is tinted red
uniform float heat_tint : hint_range(0.0, 1.0) = 0.12;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
    return value_noise(p) * 0.6 + value_noise(p * 2.0) * 0.4;
}

// d is the distance from the flame's edge (0 at the edge, 1 at the far side of the zone).
vec4 flame(float x, float d, float t) {
    float n = fbm(vec2(x * flame_count, d * 6.0 - t * 2.5));
    float tongue = 1.0 - d / flame_height;
    float f = tongue * 1.4 - n * 0.7;
    float body = smoothstep(0.1, 0.5, f);
    // core is hot yellow-orange, the rest red, fading to dark red at the tips
    float heat = clamp(f, 0.0, 1.0);
    vec3 col = mix(vec3(0.55, 0.02, 0.02), vec3(1.0, 0.12, 0.05), smoothstep(0.1, 0.5, heat));
    col = mix(col, vec3(1.0, 0.55, 0.1), smoothstep(0.65, 1.0, heat));
    return vec4(col, body);
}

void fragment() {
    float t = TIME * sway_speed + time_offset;

    // Heat haze: wobble the screen behind the zone, fading out at the borders to avoid seams
    float edge_fade = smoothstep(0.0, 0.06, min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y)));
    vec2 haze_p = UV * noise_scale * 4.0;
    vec2 offset = vec2(
        value_noise(haze_p + vec2(0.0, -t * 2.0)) - 0.5,
        value_noise(haze_p + vec2(17.3, -t * 1.5)) - 0.5
    );
    offset.x += sin(UV.y * noise_scale * 12.0 - t * 4.0) * 0.25;
    vec3 scene = texture(screen_tex, SCREEN_UV + offset * sway_strength * 2.0 * edge_fade).rgb;
    scene = mix(scene, scene * vec3(1.3, 0.8, 0.75) + vec3(0.1, 0.0, 0.0), heat_tint * edge_fade);

    // Flames rising from the bottom edge and hanging from the top edge
    vec4 bottom = flame(UV.x, 1.0 - UV.y, t);
    vec4 top = flame(UV.x + 3.7, UV.y, t + 1.3);
    vec3 col = mix(scene, bottom.rgb, bottom.a);
    col = mix(col, top.rgb, top.a);

    COLOR = vec4(col, 1.0);
}