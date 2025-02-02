extends Node2D
enum CameraInteractionState {IDLE, MOVING}

@export_group("Simulation properties")
@export var grid_width: float = 100
@export var grid_resolution: int = 20
@export var visual_scaling_factor = 100000;
@export var max_visual_vector_size = 10;

var horizontal_lines = zero_out_array(512);
var vertical_lines = zero_out_array(512);
var VisualVectorScene = preload("res://visual_vector.tscn")
var PointChargeScene = preload("res://charge.tscn")
var state: CameraInteractionState = CameraInteractionState.IDLE
var camera_movement_start = Vector2(0,0);
var simulation_points = []
var use_vector_clamping: bool =  false;
var d = 0;
var permittivity = 8.8541878188e-12 # e_0, epsilon nought, the absolute dieletric permittivity of a classical vacuum

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
	initialise_visual_vectors(simulation_points)

	#calculate_electro_static_forces(simulation_charges, simulation_points)
	#$VectorInfoPanel.visible = false;
func charge_node_hover_state_changed(is_hovered: bool) -> void:
	if (is_hovered):
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func initialise_visual_vectors(simulation_points: Array):
	for p in simulation_points:
		var visual_vec: VisualVector = VisualVectorScene.instantiate()
		visual_vec.add_to_group("visual_vector")
		add_child(visual_vec)

func calculate_electro_static_forces(point_charges: Array[Node], simulation_points: Array) -> Array[Vector2]:
	
	var forces: Array[Vector2];
	# VALIDATION SECTION
	# Basic valdiation to make sure the Nodes are actually charges
	for charge in point_charges:
		if not (charge is Charge):
			push_error("Node is not of Charge type")
	# Ensure that there are many visual vectors as simulation points
	for p in simulation_points:
		var super_position_resultant_vector = Vector2(0,0)

		for charge in point_charges:
			var point_charge = charge as Charge

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
				
			super_position_resultant_vector += magnitude * r_hat;
		forces.append(super_position_resultant_vector)

	return forces;
		

func draw_vector(from: Vector2, to: Vector2, colour: Color) -> void:
	draw_line(from, to, colour, 20.0)
	
func _draw():
	# draw_vector(Vector2(1.5, 1.0), Vector2(10.5, 40.0), Color.GREEN)
	# Draw a dot at each grid intersection point, to mark the spot in which we will calculate the electric field
	var grid_size = $Grid.transform.get_scale();
	for i in range(grid_resolution):
		for j in range(grid_resolution):
			var cen = Vector2(vertical_lines[j]*grid_size.x, horizontal_lines[i]*grid_size.y)
			var rad = 20/(grid_resolution * 0.2)
			var col = Color (1,0,0)
			draw_circle(cen, rad,col)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var visual_vectors: Array = get_tree().get_nodes_in_group("visual_vector")
	# Do some basic sanity checking to make sure that each node in this group is
	# actually a visual_vector
	for vec in visual_vectors:
		if not (vec is VisualVector):
			push_error("Node is not a VisualVector")
			
	const zoom_speed = Vector2(0.2, 0.2);
	const min_zoom = Vector2(0.4, 0.4);
	const max_zoom = Vector2(3,3);
	
	if Input.is_action_just_pressed("scroll_up"):
		
		var mouse_pos := get_global_mouse_position()
		
		$Camera2D.zoom = clamp($Camera2D.zoom + zoom_speed, min_zoom, max_zoom);
		if $Camera2D.zoom < max_zoom:
			var new_mouse_pos := get_global_mouse_position()
			$Camera2D.position += mouse_pos - new_mouse_pos
			print (  "mouse_pos:  %v \t new_mouse_pos: %v " % [mouse_pos, new_mouse_pos])
	elif Input.is_action_just_pressed("scroll_down"):
		var mouse_pos := get_global_mouse_position()

		$Camera2D.zoom = clamp($Camera2D.zoom - zoom_speed, min_zoom, max_zoom);
		if $Camera2D.zoom > min_zoom:
			#$Camera2D.position = ($Camera2D.position + get_local_mouse_position()) / 2.0;
			var new_mouse_pos := get_global_mouse_position()
			$Camera2D.position += mouse_pos - new_mouse_pos
			print (  "mouse_pos:  %v \t new_mouse_pos: %v " % [mouse_pos, new_mouse_pos])

	var simulation_charges = get_tree().get_nodes_in_group("charge_group")
	var existing_force_vectors = get_tree().get_nodes_in_group("visual_vector")

	var forces: Array[Vector2] = calculate_electro_static_forces(simulation_charges, simulation_points)
	for i in forces.size():
		var force = forces[i]
		var simulation_point = simulation_points[i]
		var from = simulation_point;
		visual_vectors[i].from = from
		visual_vectors[i].width = 25
		
		if (force.length() > max_visual_vector_size and use_vector_clamping):
			var theta = force.angle()
			visual_vectors[i].vec.x = cos(theta) * max_visual_vector_size
			visual_vectors[i].vec.y = sin(theta) * max_visual_vector_size
		else:
			visual_vectors[i].vec = force
		visual_vectors[i].update_vector()


func zero_out_array(size: int) -> Array:
	var array = []
	array.resize(size)
	array.fill(0.0)
	return array

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_button_event: InputEventMouseButton = event
		if mouse_button_event.button_index == MOUSE_BUTTON_MIDDLE:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)

			state = CameraInteractionState.MOVING
			camera_movement_start = get_global_mouse_position()
		# Check for left mouse button (button index 1)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			var click_position = event.position
			print("Mouse clicked at: ", click_position)
			print("Mouse position at: ", get_global_mouse_position())
	if event is InputEventMouseButton and not event.pressed:
		state = CameraInteractionState.IDLE
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if event is InputEventMouseMotion and state == CameraInteractionState.MOVING:
		$Camera2D.position -= (event.relative / $Camera2D.zoom.x)

func _on_control_panel_point_charge_created(charge: float) -> void:
	print (charge)
	var point_charge: Charge = PointChargeScene.instantiate()
	point_charge.Q = charge;
	var grid_size = $Grid.transform.get_scale();
	var bounds =   $Grid.transform.get_scale()  # Get Rect2 for the area
	var random_position = Vector2(
		randf_range(0, bounds.x ),
		randf_range(0, bounds.y)
	)
	point_charge.position = random_position
	add_child(point_charge)
	
func _on_visual_scaling_slider_value_changed(value: float) -> void:
	visual_scaling_factor = value;

func _on_vector_clamp_slider_value_changed(value: float) -> void:
	max_visual_vector_size = value

func _on_use_max_vector_size_toggled(toggled_on: bool) -> void:
	use_vector_clamping = toggled_on;
