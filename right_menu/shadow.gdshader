shader_type canvas_item;

uniform float spread = 6.0;        // fade distance inward from edge
uniform float corner_radius = 8.0; // rounded corner radius
uniform float opacity = 0.5;       // max alpha

// signed distance to a rounded rectangle
float sdRoundRect(vec2 p, vec2 b, float r) {
    vec2 d = abs(p - b*0.5) - (b*0.5 - vec2(r));
    return length(max(d, vec2(0.0))) - r;
}

void fragment() {
    // convert UV to pixel coordinates
    vec2 size_px = vec2(TEXTURE_PIXEL_SIZE.x == 0.0 ? 100.0 : 1.0 / TEXTURE_PIXEL_SIZE.x,
                        TEXTURE_PIXEL_SIZE.y == 0.0 ? 100.0 : 1.0 / TEXTURE_PIXEL_SIZE.y);
    vec2 p = UV * size_px;

    // compute distance from rounded rect boundary (negative = inside)
    float dist = -sdRoundRect(p, size_px, corner_radius); 
    // dist = 0 at edge, positive outside, negative inside

    // clamp inward fade: 1 at edge, 0 at edge-spread
    float alpha = clamp(dist / spread, 0.0, 1.0);

    COLOR = vec4(0.0, 0.0, 0.0, alpha * opacity);
}