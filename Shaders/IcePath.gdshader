shader_type canvas_item;

// mipmaps are needed for textureLod (blur)
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear_mipmap;

// Frosted glass
uniform vec4 tint_color: source_color = vec4(0.5, 0.87, 0.945, 1.0);
uniform float tint_amount: hint_range(0.0, 1.0) = 0.4;
uniform float frost_scale: hint_range(1.0, 200.0) = 30.0;
uniform float frost_refraction_px: hint_range(0.0, 30.0) = 4.0;
uniform float frost_blur_lod: hint_range(0.0, 6.0) = 3.0;
uniform float frost_whiteness: hint_range(0.0, 0.5) = 0.12;
uniform float noise_amount: hint_range(0.0, 0.2) = 0.03;

// Crack generation
uniform float crack_depth : hint_range(0.0, 10.0) = 2.236;
uniform float crack_scale : hint_range(1.0, 10.0) = 4.0;
uniform float crack_zebra_scale : hint_range(0.0, 10.0) = 2.67;
uniform float crack_zebra_amp : hint_range(0.0, 10.0) = 1.3;
uniform float crack_profile : hint_range(0.0, 10.0) = 1.0;
uniform float crack_slope : hint_range(0.0, 50.0) = 45.8;
uniform float crack_width : hint_range(0.0, 1.0) = 0.001;

uniform float crack_clarity: hint_range(0.0, 1.0) = 0.9;
uniform float crack_refraction_px: hint_range(0.0, 60.0) = 12.0;
uniform float crack_edge_light: hint_range(0.0, 3.0) = 0.6;
uniform float crack_darkness: hint_range(0.0, 1.0) = 0.08;

const vec4 background_color = vec4(0.0, 0.0, 0.0, 0.0);
const vec4 crack_color = vec4(0.0, 0.0, 0.0, 1.0);



vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), f.x),
               mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), f.x), f.y);
}

vec3 voronoi(vec2 u) {
    vec2 p = floor(u);
    vec2 f = fract(u);
    float res = 8.0;
    vec2 b = vec2(0.0);
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = hash(p + g);
            vec2 r = g - f + o;
            float d = dot(r, r);
            if (d < res) {
                res = d;
                b = r;
            }
        }
    }
    return vec3(sqrt(res), b);
}

vec3 voronoiB(vec2 u) {
    vec2 p = floor(u);
    vec2 f = fract(u);
    float res = 8.0;
    vec2 C = vec2(0.0);
    vec2 P = vec2(0.0);
    for (int j = -1; j <= 1; j++) {
        for (int i = -1; i <= 1; i++) {
            vec2 g = vec2(float(i), float(j));
            vec2 o = hash(p + g);
            vec2 r = g - f + o;
            float d = dot(r, r);
            if (d < res) {
                res = d;
                C = g;
                P = r;
            }
        }
    }
    res = 8.0;
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 g = C + vec2(float(i), float(j));
            vec2 o = hash(p + g);
            vec2 r = g - f + o;
            if (dot(P - r, P - r) > 1e-5) {
                res = min(res, 0.5 * dot((P + r), normalize(r - P)));
            }
        }
    }
    return vec3(res, P + f);
}

float fbm(vec2 n) {
    float total = 0.0, amp = 1.0;
    for (int i = 0; i < 7; i++) {
        total += noise(n) * amp;
        n += n;
        amp *= 0.5;
    }
    return total;
}

vec4 generate_cracks(vec2 uv) {
	vec2 U = uv * crack_scale;
    vec2 I = floor(U / 2.0);
    bool vert = mod(I.x + I.y, 2.0) == 0.0;
    vec3 H0;
    vec4 color = background_color;
    for (float i = 0.0; i < crack_depth; i++) {
        vec2 V = U;
        vec2 D = vec2(crack_zebra_amp * fbm(U / crack_zebra_scale) * crack_zebra_scale);
        vec3 H = voronoiB(V + D);
        float d = H.x;
        d = min(1.0, crack_slope * pow(max(0.0, d - crack_width), crack_profile));
        color += vec4(1.0 - d) / exp2(i);
        U *= 1.5;
    }
    color *= crack_color;
	
	return color;
}


void fragment() {
	float crack = clamp(generate_cracks(UV).a, 0.0, 1.0);
	// Slope of the crack
	vec2 crack_grad = vec2(dFdx(crack), dFdy(crack));

	// Whole glass frosted and clear cracks
	float frost = 1.0 - crack * crack_clarity;

	// Procedural frost warp
	vec2 frost_uv = UV * frost_scale;
	vec2 frost_warp = vec2(noise(frost_uv), noise(frost_uv + vec2(17.3, 91.7)));

	// Refract the backdrop, frost scatters while cracks bend
	vec2 offset_px = frost_warp * frost_refraction_px * frost + crack_grad * crack_refraction_px;
	vec2 uv = SCREEN_UV + offset_px * SCREEN_PIXEL_SIZE;

	// Blur the backdrop based on frost amount
	vec3 screen = textureLod(screen_texture, uv, frost_blur_lod * frost).rgb;

	// Tint and whiten our image
	screen = mix(screen, tint_color.rgb, tint_amount * frost);
	screen += frost_whiteness * frost;

	// Get a random-ish value for some speckle noise
	float noise = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
	// Apply speckle noise based on amount and frost
	screen += noise * noise_amount * frost;

	// Crack edge lighting and darkening giving some depth
	screen += crack_edge_light * length(crack_grad);
	screen *= 1.0 - crack_darkness * crack;

	COLOR = vec4(screen, 1.0);
}
