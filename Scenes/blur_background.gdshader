shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float radius : hint_range(0, 20) = 6.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 col = vec4(0.0);
    float count = 0.0;

    // simple box blur
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * radius / float(TEXTURE_PIXEL_SIZE.x);
            col += textureLod(screen_tex, uv + offset, 0.0);
            count += 1.0;
        }
    }
    col /= count;

    // overlay your gradient color
    vec4 grad = mix(vec4(1,1,1,0.0), vec4(1,1,1,0.5), uv.y);
    COLOR = col * (1.0 - grad.a) + grad;
}
