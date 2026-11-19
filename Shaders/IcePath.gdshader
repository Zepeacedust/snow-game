shader_type canvas_item;

uniform sampler2D line_texture : hint_default_white;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
//uniform vec2 lineTextureSize;

uniform float blur : hint_range(0.0, 8.0) = 3.5;
uniform float warp_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float strength_x : hint_range(0.0, 50.0) = 12.0;
uniform float strength_y : hint_range(0.0, 50.0) = 12.0;
uniform float offset_x : hint_range(-1.0, 1.0) = 0.0;
uniform float offset_y : hint_range(-1.0, 1.0) = 0.0;

uniform float corner_radius : hint_range(0.0, 1.0) = 0.3;
uniform float edge_smoothness : hint_range(0.5, 3.0) = 1.0;

uniform vec4 tint : source_color = vec4(0.95, 0.97, 1.0, 0.12);
uniform vec4 edge_highlight : source_color = vec4(1.0, 1.0, 1.0, 0.3);
uniform float edge_width : hint_range(0.0, 10.0) = 1.5;
uniform float chromatic_strength : hint_range(0.0, 5.0) = 5.0;

// Crack generation
uniform float crack_depth : hint_range(0.0, 10.0) = 2.236;
uniform float crack_scale : hint_range(1.0, 10.0) = 4.0;
uniform float crack_zebra_scale : hint_range(0.0, 10.0) = 2.67;
uniform float crack_zebra_amp : hint_range(0.0, 10.0) = 1.3;
uniform float crack_profile : hint_range(0.0, 10.0) = 1.0;
uniform float crack_slope : hint_range(0.0, 50.0) = 45.8;
uniform float crack_width : hint_range(0.0, 1.0) = 0.001;

const vec4 background_color = vec4(0.0, 0.0, 0.0, 0.0);
const vec4 crack_color = vec4(0.0, 0.0, 0.0, 1.0);

// Glass effect
//uniform vec2 refraction_offset = vec2(25.0,25.0);
//uniform vec2 reflection_offset = vec2(1.0,1.0);
//uniform vec4 reflection_color : source_color = vec4(0.588,0.588,0.588,0.5);

float rounded_box(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

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
	// Called for every pixel the material is visible on.
	// Liquid glass 
	float dx = dFdx(UV.x);
    float dy = dFdy(UV.y);

    dx = sign(dx) * max(abs(dx), 0.0001);
    dy = sign(dy) * max(abs(dy), 0.0001);

    vec2 size = abs(vec2(1.0 / dx, 1.0 / dy));

    size = clamp(size, vec2(1.0), vec2(4096.0));

    vec2 half_size = size * 0.5;
    vec2 pixel = UV * size;
    vec2 centered = pixel - half_size;

    float max_r = min(half_size.x, half_size.y);
    float r = corner_radius * max_r;

    float sdf = rounded_box(centered, half_size, r);
    float alpha = 1.0 - smoothstep(-edge_smoothness, edge_smoothness, sdf);

    if (alpha < 0.001) {
        discard;
    }

    float max_dist = min(half_size.x, half_size.y) * 0.5;
    float w = clamp(-sdf / max_dist, 0.0, 1.0);

    vec2 uv_dir = length(centered) > 0.001 ? normalize(centered) : vec2(0.0, 1.0);

    float exp_x = exp(-strength_x * pow(w + offset_x, 2.0));
    float exp_y = exp(-strength_y * pow(w + offset_y, 2.0));
    vec2 warp_offset = uv_dir * vec2(exp_x, exp_y) * warp_intensity / 10.0;
    vec2 warped_uv = SCREEN_UV - warp_offset;

    float edge_proximity = 1.0 - w;
    vec2 chroma_offset = uv_dir * edge_proximity * chromatic_strength * SCREEN_PIXEL_SIZE;

    float bg_r = textureLod(screen_texture, warped_uv - chroma_offset, blur).r;
    float bg_g = textureLod(screen_texture, warped_uv, blur).g;
    float bg_b = textureLod(screen_texture, warped_uv + chroma_offset, blur).b;
    vec3 bg = vec3(bg_r, bg_g, bg_b);

    vec3 color = mix(bg, tint.rgb, tint.a);

    float edge = 1.0 - smoothstep(0.0, edge_width, -sdf);
    edge *= step(sdf, 0.0);
    color = mix(color, edge_highlight.rgb, edge * edge_highlight.a);

    color += vec3(smoothstep(0.4, 0.0, UV.y) * 0.08 * w);
	vec4 ref = texture(screen_texture, vec2(SCREEN_UV.x, 1.0 - SCREEN_UV.y - 0.13));
	
	// Crack
	vec4 cracks = generate_cracks(UV);
	//vec4 orig_color = COLOR;
	//vec4 adjacent_color = generate_cracks(UV + TEXTURE_PIXEL_SIZE * reflection_offset);
	//if (adjacent_color.a >= 1.0) {
		//COLOR = reflection_color;
	//} else {
		//COLOR = texture(screen_texture, SCREEN_UV + COLOR.a*(SCREEN_PIXEL_SIZE * refraction_offset));
	//}

    COLOR = vec4(color, alpha) + ref/2.0 + cracks;
	
	//vec4 ice = texture(line_texture, UV);

// Output:0
	//COLOR = ice/2.0 + ref/2.0;
}
//void vertex() {
	// Called for every vertex the material is visible on.
//}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
