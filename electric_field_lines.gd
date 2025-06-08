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
var last_hovered_vector = null;

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
		visual_vec.vector_hovered.connect(_on_vector_hovered)
		visual_vec.vector_exited.connect(_on_vector_exited)

		add_child(visual_vec)
			
func _draw():
	
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
	#print(is_node_type_hovered())
	print(_is_vector_hovered())
	
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
	
	var nodes_in_group: Array[Node] = get_tree().get_nodes_in_group("charge_group")
	
	# Create a new, correctly typed array
	var charges_array: Array[Charge]
	for node in nodes_in_group:
		# It's good practice to double-check the type, even though we know it should be correct
		if node is Charge:
			charges_array.append(node)
	#var forcesA: Array[Vector2] = calculate_electro_static_forces(simulation_charges, simulation_points)
	var forces: Array[Vector2] = Electrostatics.calculate_field_at_points(charges_array, simulation_points)

	#var forces: Array[Vector2] = calculate_electro_static_forces(simulation_charges, simulation_points)
	for i in forces.size():
		var force = forces[i] / visual_scaling_factor
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

			print("Event.position: ", event.position)
			print("Event.global_position: ", event.global_position)
			print("get_global_mouse_position: ",get_global_mouse_position())
			print("")
	if event is InputEventMouseButton and not event.pressed:
		state = CameraInteractionState.IDLE
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if event is InputEventMouseMotion and state == CameraInteractionState.MOVING:
		$Camera2D.position -= (event.relative / $Camera2D.zoom.x)

func _on_control_panel_point_charge_created(charge: float) -> void:
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

func _on_vector_hovered(vec: VisualVector):
	print('vector hovered!')
	print(vec.vec)
	_is_vector_hovered()

	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	if (vec):
		last_hovered_vector = vec
		#
func is_node_type_hovered(target_identifier = "VisualVector") -> bool: # Defaulting to string name
	# --- Input Validation ---
	if target_identifier == null:
		printerr("is_node_type_hovered: target_identifier cannot be null.")
		return false
	# Prevent empty strings, as is_class("") might behave unexpectedly
	if target_identifier is String and target_identifier.is_empty():
		printerr("is_node_type_hovered: target_identifier string cannot be empty.")
		return false

	# --- Physics Query Setup (Same as before) ---
	var viewport_mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var global_mouse_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * viewport_mouse_pos
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_mouse_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	var results: Array[Dictionary] = space_state.intersect_point(query)

	# --- Check Results ---
	for result in results:
		var collider_node = result.get("collider")
		var current_node_to_check = collider_node

		while current_node_to_check:
			var match_found = false
			var node_script = current_node_to_check.get_script()

			# --- Final Check Logic ---

			# 1. Check if target is a String (path or class name) - Handles MOST cases
			if target_identifier is String or target_identifier is StringName:
				var target_str = str(target_identifier)
				if target_str.begins_with("res://"): # Script path check
					if node_script != null and node_script.resource_path == target_str:
						match_found = true
				else: # Class name check (engine type or registered script name)
					# is_class() reliably checks inheritance chain for the given name
					if current_node_to_check.is_class(target_str):
						match_found = true

			# 2. Check if target is a Script resource - Handles load("res://path.gd")
			elif target_identifier is Script:
				if node_script == target_identifier:
					match_found = true

			# 3. No longer attempting the 'typeof(target_identifier) == TYPE_OBJECT' check
			#    using 'is target_identifier', as it causes parsing errors.

			else:
				# Handle only clearly unsupported types if necessary
				# This condition might now be unreachable if only Strings/Scripts are expected
				printerr("is_node_type_hovered: Unsupported target_identifier type provided: ", typeof(target_identifier), ". Please use a String (class name/script path) or a loaded Script resource.")
				# Optionally 'return false' or 'break' here if strict type checking is desired

			# --- End of Final Check Logic ---

			if match_found:
				return true

			# Move up the hierarchy (owner then parent) - same as before
			var owner = current_node_to_check.get_owner()
			if owner and owner != current_node_to_check:
				current_node_to_check = owner
			else:
				var parent = current_node_to_check.get_parent()
				if parent == null or parent == current_node_to_check:
					current_node_to_check = null
				else:
					current_node_to_check = parent

	return false
func _get_hovered_colliders():
	# N.B. Gemini created
	# 1. Get mouse position in viewport coordinates
	var viewport_mouse_pos: Vector2 = get_viewport().get_mouse_position()

	# 2. Get the viewport's transform (World -> Viewport)
	var canvas_transform: Transform2D = get_viewport().get_canvas_transform()

	# 3. Calculate the inverse transform (Viewport -> World)
	var inverse_canvas_transform: Transform2D = canvas_transform.affine_inverse()

	# 4. Convert viewport mouse position to global world coordinates
	var global_mouse_pos: Vector2 = inverse_canvas_transform * viewport_mouse_pos
	# Note: If this script is on a CanvasItem (like Node2D, Control, etc.),
	# you could potentially use get_global_mouse_position(), but the transform
	# method above is more universally applicable regardless of where this
	# function resides.

	# 5. Get the direct space state
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state

	# 6. Set up the query using GLOBAL coordinates
	var query := PhysicsPointQueryParameters2D.new()
	query.position = global_mouse_pos # Use the CORRECT coordinate space!
	query.collide_with_areas = true
	query.collide_with_bodies = true
	# query.collision_mask = YOUR_VECTOR_LAYER_MASK # Optional: Filter by physics layer

	# 7. Perform the query
	var results: Array[Dictionary] = space_state.intersect_point(query)
	
	return results
func _is_vector_hovered():

	var results = _get_hovered_colliders()
	# 8. Check results
	for result in results:
		var collider_node = result.get("collider")

		# IMPORTANT: The collider might be the CollisionShape2D or the body node
		# itself (Area2D/PhysicsBody2D) if it's a child of VisualVector.
		# We need to check if the collider OR its owner/parent is the VisualVector.
		# Using owner is generally preferred if the scene is packed correctly.
		var potential_vector_node = collider_node
		while potential_vector_node:
			if potential_vector_node is VisualVector:
				# Optional: Check visibility if needed
				# if potential_vector_node.is_visible_in_tree():
				return true # Found it!

			# Try owner first (if scene instance is packed correctly)
			var owner = potential_vector_node.get_owner()
			if owner and owner is VisualVector:
				# if owner.is_visible_in_tree():
				return true # Found via owner!

			# If owner didn't work or wasn't the VisualVector, try parent
			# But stop if we reach the root or loop infinitely
			var parent = potential_vector_node.get_parent()
			if parent == potential_vector_node: # Should not happen, but safeguard
				break
			potential_vector_node = parent

	# If loop finishes without finding a VisualVector
	return false

func _on_vector_exited(vec: VisualVector):
	if (vec == last_hovered_vector):
		print('The last hovered vector has been exited - update UI')
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
