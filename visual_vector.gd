@tool
class_name VisualVector
extends Node2D

var from: Vector2 = Vector2(100,100);
var to: Vector2 = Vector2(200,200);

@onready
var VectorHead: Polygon2D = $VectorHead
@onready
var VectorLine: Line2D = $VectorLine

@export_range(0.1, 100, 0.1) var width: float = 50;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
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

	var vector_magnitude = (from - to).length();
	
	# the entire vector ----> needs to be as long as the vector
	# calculated by from - to. The triangle head contributes
	# to this length, so we need to subtract it from the vector
	# magnitude to find how long the line portion needs to be
	var vector_line_magnitude = vector_magnitude - width;
	var angle = from.angle_to_point(to)

	VectorLine.width = width/10
	
	VectorHead.position = Vector2(vector_line_magnitude, 0)
	
	var first_line_point = Vector2(0,0);
	var second_line_point = Vector2(vector_line_magnitude, 0)
	
	VectorLine.clear_points()
	VectorLine.add_point(first_line_point)
	VectorLine.add_point(second_line_point)
	VectorLine.default_color = Color.GREEN;

	self.position = from;
	self.rotation = angle;


#func _draw() -> void:
	#draw_circle(pivot_point, 10, Color.PURPLE)
