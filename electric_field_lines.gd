@tool

extends Node2D

@export_group("Simulation properties")
@export var grid_width: float = 100
@export var grid_resolution: int = 10

#float horizontal_lines
var d = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var horizontal_lines = zero_out_array(512);
	var vertical_lines = zero_out_array(512);

	var step_width_x: float = 1.0/grid_resolution;
	var grid_size = $Grid.transform.get_scale();
	var step_width_y: float = step_width_x * grid_size.x / grid_size.y;
	
	for i in range(grid_resolution):
		horizontal_lines[i] = i*step_width_y
		vertical_lines[i] = i*step_width_x
	#material.set_shader_param("horizontal_lines", horizontal_lines)
	$Grid.material.set_shader_parameter("horizontal_lines_UV", horizontal_lines)
	$Grid.material.set_shader_parameter("vertical_lines_UV", vertical_lines)
	$Grid.material.set_shader_parameter("grid_resolution", grid_resolution)
	$Grid.material.set_shader_parameter("resolution", grid_size)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func zero_out_array(size: int) -> Array:
	var array = []
	array.resize(size)
	array.fill(0.0)
	return array
