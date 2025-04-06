shader_type canvas_item;

uniform vec2 resolution = vec2(1151.0, 645.0); // make sure this matches the dimensions of the container
uniform vec3 line_color: source_color = vec3(0.2, 0.3, 0.5);
//uniform float grid_resolution: hint_range(1.0, 512.0, 0.1) = 20.0;
uniform int grid_resolution: hint_range(1, 512, 1) = 1;

uniform float thickness: hint_range(0.001, 0.01, 0.001) = 0.02;
uniform float brightness: hint_range(0.1, 4.0, 0.1) = 2.0;
const int MAX_GRID_RESOLUTION = 512;
uniform float horizontal_lines_UV[MAX_GRID_RESOLUTION];
uniform float vertical_lines_UV[MAX_GRID_RESOLUTION];

float draw_grid(vec2 uv, float line_thickness) {
	float line = 0.0;
	bool within_distance = false;
    for (int i = 0; i < grid_resolution; i++) {

    	float distance_to_vertical_line = abs(uv.x - vertical_lines_UV[i]);
		if (distance_to_vertical_line < line_thickness) {
			within_distance = true;
			break;
		}

    	float distance_to_horizontal_line = abs(uv.y - horizontal_lines_UV[i]);
		if (distance_to_horizontal_line  < line_thickness*resolution.x/resolution.y) {
			within_distance = true;
			break;
		}
    }
	if (within_distance) {
		return 1.0;
	}

	return line;
}
void fragment() {

	//vec2 uv = (UV - 0.5); // shift origin to the centre (top left is now (-0.5, -0.5), bottom right is (0.5, 0.5) and centre is (0,0))
	//uv.y = uv.y * resolution.y / resolution.x;
	//draw_grid(UV, thickness);
	//float line_thickness = grid_resolution * thickness /resolution.y;
	vec3 color = draw_grid(UV, thickness) * line_color;
	COLOR = vec4(color, 1.0);
}