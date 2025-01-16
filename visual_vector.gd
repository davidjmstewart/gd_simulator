@tool
class_name VisualVector
extends Node2D

var my_property: int = 1;
var from: Vector2 = Vector2(1,0);
var to: Vector2 = Vector2(0,1);

@onready
var VectorHead: Polygon2D = $VectorHead
@onready
var VectorLine: Line2D = $VectorLine

var width = 50
var pivot_point: Vector2;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# This section creates the vector head (a triangle) out of a polygon2d
	# then rotates the head an places it at the end of the vector line


	var a = Vector2(0,0)
	var b = Vector2(width, 0)
	var c = Vector2((a.x + b.x)/2, width)
	VectorHead.polygon = [a,b,c]
	VectorHead.color = Color.GREEN
	VectorLine.default_color = Color.GREEN;
	VectorHead.position.x -= c.x
	var vector_magnitude = (from - to).length();
	var angle = from.angle_to_point(to)
	var first_line_point = Vector2(0,0);
	var second_line_point = Vector2(0, 0 - vector_magnitude)
	
	VectorLine.clear_points()
	VectorLine.add_point(first_line_point)
	VectorLine.add_point(second_line_point)
	VectorLine.width = 1
	self.position = from
	print('Angle is %f' % angle)
	print(from)
	print(to)
	#self.position.x -= c.x;
	
	#pivot_point =  Vector2(c.x, 0)

	#self.position = Vector2(400,300);
	#$VectorHead.offset = pivot_point
	
	#$VectorHead.rotation = -angle
	#$VectorHead.position = to

	pass # Replace with function body.

func _draw() -> void:
	draw_circle(pivot_point, 10, Color.PURPLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	#$VectorHead.offset = pivot_point

	#$VectorHead.rotate(delta/10.0)
	queue_redraw();
	pass
