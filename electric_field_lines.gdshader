shader_type canvas_item;

uniform vec2 resolution = vec2(1151.0, 645.0); // make sure this matches the dimensions of the container
uniform vec3 line_color: source_color = vec3(0.2, 0.3, 0.5);
uniform float grid_resolution: hint_range(1.0, 50.0, 0.1) = 20.0;
uniform float thickness: hint_range(0.1, 10.0, 0.1) = 2.0;
uniform float brightness: hint_range(0.1, 4.0, 0.1) = 2.0;

float draw_grid(vec2 uv) {
	vec2 grid_uv = fract(uv);
	return max(grid_uv.y, grid_uv.x);
}
void fragment() {
	vec2 uv = (UV - 0.5); // shift origin to the centre (top left is now (-0.5, -0.5), bottom right is (0.5, 0.5) and centre is (0,0))
	uv.y = uv.y * resolution.y / resolution.x;
	float line_thickness = grid_resolution * thickness /resolution.y;
	vec3 color = step(1.0 - line_thickness, draw_grid(uv * grid_resolution)) * line_color;
	COLOR = vec4(color, 1.0);
}