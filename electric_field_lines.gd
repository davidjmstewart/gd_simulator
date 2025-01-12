@tool

extends Node2D

@export_group("Simulation properties")
@export var grid_width: float = 100
@export var grid_resolution: float = 100
var d = 0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var f: ShaderMaterial = $Grid.material;
	print(f)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	d+=delta
	$Grid.material.set_shader_parameter("grid_resolution", d);

	pass
