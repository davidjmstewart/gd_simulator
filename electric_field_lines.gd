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

	# This section calculates the grid for displaying in a shader
	var step_width_x_UV: float = 1.0/grid_resolution;
	var grid_size = $Grid.transform.get_scale();
	var step_width_y: float = step_width_x_UV * grid_size.x / grid_size.y;
	for i in range(grid_resolution):
		horizontal_lines[i] = i*step_width_y
		vertical_lines[i] = i*step_width_x_UV
	
	# Update the shader with our grid points to display a square grid
	$Grid.material.set_shader_parameter("horizontal_lines_UV", horizontal_lines)
	$Grid.material.set_shader_parameter("vertical_lines_UV", vertical_lines)
	$Grid.material.set_shader_parameter("grid_resolution", grid_resolution)
	$Grid.material.set_shader_parameter("resolution", grid_size)	
	
	# This section calculates all of the points at which we want to calculate
	# electro static forces. N.B. the previous section was about creating a visual grid
	# and it was convenient to use UV coordinates for that purpose. This section
	# uses pixel coordinates as it is more convenient for the calculations we will be doing
	var simulation_points = []
	for i in range(grid_resolution):
		for j in range(grid_resolution):
			simulation_points.append(Vector2(vertical_lines[j] * grid_size.x, horizontal_lines[i]*grid_size.y))

	var simulation_charges = get_tree().get_nodes_in_group("charge_group")

	calculate_electro_static_forces(simulation_charges, simulation_points)

func calculate_electro_static_forces(charges: Array[Node], simulation_points: Array):
	for p in range(simulation_points.size()):
		if p > 3 and p < 8:
			
			var visual_vec: VisualVector = VisualVectorScene.instantiate()
			visual_vec.to = simulation_points[p]
			visual_vec.from = simulation_points[p+12]

			add_child(visual_vec)
	for charge in charges:
		if not (charge is Charge):
			push_error("Node is not of Charge type")
		else:
			print('VALID TYPE GIVEN')
	print(charges)
	print(charges[0].Q)
	
	pass

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

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		# Check for left mouse button (button index 1)
		if event.button_index == MOUSE_BUTTON_LEFT:
			var click_position = event.position
			print("Mouse clicked at: ", click_position)
