extends Node2D

@export_group("Simulation properties")
@export var grid_width: float = 100
@export var grid_resolution: int = 10
var horizontal_lines = zero_out_array(512);
var vertical_lines = zero_out_array(512);

var VisualVectorScene = preload("res://visual_vector.tscn")
var simulation_points = []
#float horizontal_lines
var d = 0;
var permittivity = 8.8541878188e-12 # e_0, epsilon nough, the absolute dieletric permittivity of a classical vacuum
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

	for i in range(grid_resolution):
		for j in range(grid_resolution):
			simulation_points.append(Vector2(vertical_lines[j] * grid_size.x, horizontal_lines[i]*grid_size.y))

	var simulation_charges = get_tree().get_nodes_in_group("charge_group")

	calculate_electro_static_forces(simulation_charges, simulation_points)

func calculate_electro_static_forces(point_charges: Array[Node], simulation_points: Array):

	# Basic valdiation to make sure the Nodes are actually charges
	for charge in point_charges:
		if not (charge is Charge):
			push_error("Node is not of Charge type")
			
	var visual_scaling_factor = 10000 * grid_resolution;
	
	for charge in point_charges:
		var point_charge = charge as Charge
		var super_position_resultant_vector = Vector2(0,0)
		point_charge = point_charges[0]
		for p in simulation_points:
			# v_diff is a vector pointing from the point charge to the simulation point
			var v_diff = (p - point_charge.position) as Vector2
			var r_hat = v_diff.normalized() # the unit vector pointing from charge to simulation point
			var distance = v_diff.length() # distance between the charge and the simulation point
			var Q = point_charge.Q
			
			# Calculate the magnitude of the vector we are going to display. This is straight
			# out of Coulomb's Law, however we also reduce the mangitude here by visual_scaling_factor
			# otherwise the mangitude of the vectors would be enormous in some cases, and we would
			# not be able to display them in any sensible/legible manner
			var magnitude = (1/(4 * PI * permittivity) * Q) / (visual_scaling_factor * distance * distance)
			
			var from = p;
			var vec = magnitude * r_hat;

			var visual_vec: VisualVector = VisualVectorScene.instantiate()
			visual_vec.from = from
			visual_vec.width = 25
			visual_vec.vec = vec

			visual_vec.add_to_group("visual_electro_static_force_vectors")
			add_child(visual_vec)

func draw_vector(from: Vector2, to: Vector2, colour: Color) -> void:
	draw_line(from, to, colour, 20.0)
	
func _draw():
	# draw_vector(Vector2(1.5, 1.0), Vector2(10.5, 40.0), Color.GREEN)
	# Draw a dot at each grid intersection point, to mark the spot in which we will calculate the electric field
	var grid_size = $Grid.transform.get_scale();
	for i in range(grid_resolution):
		for j in range(grid_resolution):
			
			var cen = Vector2(vertical_lines[j]*grid_size.x, horizontal_lines[i]*grid_size.y)
			var rad = 20
			var col = Color (1,0,0)
			draw_circle(cen, rad,col)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$charge2.position = get_global_mouse_position()
	var simulation_charges = get_tree().get_nodes_in_group("charge_group")
	var existing_force_vectors = get_tree().get_nodes_in_group("visual_electro_static_force_vectors")
	for vector in existing_force_vectors:
		vector.queue_free()
	calculate_electro_static_forces([simulation_charges[0]], simulation_points)
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
