@tool
class_name VisualVector
extends Node2D

enum UserInteractionState {IDLE, HOVERING}
var state: UserInteractionState = UserInteractionState.IDLE
# When the user hovers over this vector, signal out the magnitude of it
signal vector_hovered(vec: Vector2)

# We have two ways of descring the vector: with coordinates from and to
# where from is where the vector starts and to is where the vector ends
# alternatively, we can set vec, which describes the vector in the classical sense,
# as though it is starting from the origin, and then we can change its position to move it to
# the appropriate starting point

var from: Vector2 = Vector2(100,100);
var to: Vector2 = Vector2(200,200);


var vec: Vector2 = Vector2(100,100): set = _set_vec;


@onready
var VectorHead: Polygon2D = $VectorHead
@onready
var VectorLine: Line2D = $VectorLine

@export_range(0.1, 100, 0.1) var width: float = 50;

var use_from_to: bool = true;

var from_to = {
	from: Vector2(100,100), 
	to: Vector2(200,200)
}: set = _set_from_to, get = _get_from_to

func _set_vec(new_vec: Vector2):
	use_from_to = false;
	vec = new_vec
	self.position = from
	

func _set_from_to(new_from_to):
	use_from_to = true;
	from_to = new_from_to
	
func _get_from_to():
	return from_to;
	
func update_vector() -> void:
		
	# This section creates the vector head (a triangle) out of a polygon2d
	# then rotates the head an places it at the end of the vector line
	# Initially, the vector will be created pointing to the right
	# i.e. the vector as constructed by this code, before rotating, will
	# look like ---->

	# Calculate the 3 points of the triangle that from the VectorHead. 
	# Make it horizontally centred at x = 0, y = 0
	# This is an isoceles triangle where the base has width=width
	var a = Vector2(0,-width/2,)
	var b = Vector2(0,width/2,)
	var c = Vector2(width, 0)
	VectorHead.polygon = [a,b,c]
	VectorHead.color = Color.GREEN

	var vector_magnitude = (from - to).length() if use_from_to else vec.length();
	
	# the entire vector ----> needs to be as long as the vector
	# calculated by from - to. The triangle head contributes
	# to this length, so we need to subtract it from the vector
	# magnitude to find how long the line portion needs to be
	var vector_line_magnitude = vector_magnitude - width;
	var angle = from.angle_to_point(to) if use_from_to else vec.angle()

	VectorLine.width = width/10
	
	VectorHead.position = Vector2(vector_line_magnitude, 0)
	
	var first_line_point = Vector2(0,0);
	var second_line_point = Vector2(vector_line_magnitude, 0)
	
	VectorLine.clear_points()
	VectorLine.add_point(first_line_point)
	VectorLine.add_point(second_line_point)
	VectorLine.default_color = Color.GREEN;
	$Area2D/CollisionPolygon2D.polygon = VectorHead.polygon
	$Area2D/CollisionPolygon2D.position = VectorHead.position
	self.position = from;
	self.rotation = angle;
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_vector()


#func _draw() -> void:
	#draw_circle(pivot_point, 10, Color.PURPLE)


func _on_area_2d_mouse_entered() -> void:
	print('entered')
	state = UserInteractionState.HOVERING
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	vector_hovered.emit(vec)
	
func _on_area_2d_mouse_exited() -> void:
	print('exited')
	state = UserInteractionState.IDLE
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	vector_hovered.emit(vec)
