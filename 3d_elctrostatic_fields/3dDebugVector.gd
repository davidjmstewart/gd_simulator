# DebugVector3D.gd
# Attach this script to a MeshInstance3D node to create a 3D debug vector.
# The script procedurally generates a mesh that always orients itself
# towards the camera for maximum clarity, mimicking a 2D-drawn style.
@tool
class_name DebugVector3D
extends MeshInstance3D

# --- Public Properties ---

@export var origin: Vector3:
	set(value):
		origin = value
		if is_inside_tree():
			_update_transform()
			_draw()

@export var target: Vector3 = Vector3.UP:
	set(value):
		target = value
		if is_inside_tree():
			_update_transform()
			_draw()

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if is_inside_tree():
			_draw()

@export var line_width: float = 0.05:
	set(value):
		line_width = value
		if is_inside_tree():
			_draw()

@export var arrowhead_length: float = 0.2:
	set(value):
		arrowhead_length = value
		if is_inside_tree():
			_draw()

@export var arrowhead_width: float = 0.15:
	set(value):
		arrowhead_width = value
		if is_inside_tree():
			_draw()

var _immediate_mesh: ImmediateMesh
var _material: StandardMaterial3D


func _enter_tree() -> void:
	# Use an ImmediateMesh for dynamically creating the geometry.
	_immediate_mesh = ImmediateMesh.new()
	self.mesh = _immediate_mesh

	# Create a basic material that uses vertex colors and is unshaded.
	_material = StandardMaterial3D.new()
	_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	_material.vertex_color_use_as_albedo = true
	_material.albedo_color = Color(1, 1, 1, 1)
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	self.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Initial draw and transform update.
	_update_transform()
	_draw()


# Creates and places a colored debug sphere in the scene.
func create_debug_sphere(position: Vector3, color: Color, radius: float = 0.1):
	var sphere_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0

	var sphere_material = StandardMaterial3D.new()
	sphere_material.albedo_color = color
	sphere_material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED

	sphere_instance.mesh = sphere_mesh
	sphere_instance.material_override = sphere_material
	add_child(sphere_instance)
	sphere_instance.global_position = position


func _process(_delta: float) -> void:
	# In the editor or when the game is running, redraw if needed.
	if Engine.is_editor_hint() or get_viewport().get_camera_3d():
		_draw()


func _update_transform() -> void:
	self.global_position = origin
	

func _draw() -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return

	# --- Vector Calculations ---
	var start_pos := Vector3.ZERO
	var end_pos := target - origin
	var direction := end_pos.normalized()
	var length := end_pos.length()
	var angle = Vector3.RIGHT.angle_to(direction)
	
	# --- Geometry Generation ---
	_immediate_mesh.clear_surfaces()
	_immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, _material)
	
	var delta_x = sin(angle) * line_width / 2.0
	var delta_y = cos(angle) * line_width / 2.0
	var x1 = start_pos.x + delta_x
	var y1 = start_pos.y - delta_y
	var x2 = start_pos.x - delta_x
	var y2 = start_pos.y + delta_y
	var x3 = end_pos.x - delta_x
	var y3 = end_pos.y + delta_y
	var x4 = end_pos.x + delta_x
	var y4 = end_pos.y - delta_y

	var l1 = Vector3(x1, y1, start_pos.z)
	var l2 = Vector3(x2, y2, start_pos.z)
	var l3 = Vector3(x3, y3, end_pos.z)
	var l4 = Vector3(x4, y4, end_pos.z)

	# --- Triangles with flat colors ---
	# First triangle: red
	_immediate_mesh.surface_set_color(Color.RED)
	_immediate_mesh.surface_add_vertex(l1)
	_immediate_mesh.surface_add_vertex(l2)
	_immediate_mesh.surface_add_vertex(l4)

	# Second triangle: green
	_immediate_mesh.surface_set_color(Color.GREEN)
	_immediate_mesh.surface_add_vertex(l2)
	_immediate_mesh.surface_add_vertex(l3)
	_immediate_mesh.surface_add_vertex(l4)

	_immediate_mesh.surface_end()
