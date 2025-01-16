extends Node2D

@export_group("Simulation properties")
@export var grid_width: float = 100
@export var grid_resolution: int = 10
var horizontal_lines = zero_out_array(512);
var vertical_lines = zero_out_array(512);

var VisualVectorScene = preload("res://visual_vector.tscn")

#float horizontal_lines
var d = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

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
	
	var visual_vec: VisualVector = VisualVectorScene.instantiate()
	visual_vec.from = Vector2(100,100);
	visual_vec.to = Vector2(200,200);

	add_child(visual_vec)
	pass # Replace with function body.

func draw_vector(from: Vector2, to: Vector2, colour: Color) -> void:
	draw_line(from, to, colour, 20.0)
	
func _draw():
	# draw_vector(Vector2(1.5, 1.0), Vector2(10.5, 40.0), Color.GREEN)
	# Draw a dot at each grid intersection point, to mark the spot in which we will calculate the electric field
	var grid_size = $Grid.transform.get_scale();
	for i in range(grid_resolution):
		for j in range(grid_resolution):
			
			var cen = Vector2(vertical_lines[j]*grid_size.x, horizontal_lines[i]*grid_size.y)
			var rad= 20
			var col = Color (1,0,0)
			draw_circle(cen, rad,col)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var simulation_charges = get_tree().get_nodes_in_group("charge_group")
	queue_redraw();

	pass
	
func zero_out_array(size: int) -> Array:
	var array = []
	array.resize(size)
	array.fill(0.0)
	return array
