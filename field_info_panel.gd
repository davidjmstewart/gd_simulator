class_name FieldInfoPanel
extends CanvasLayer

@onready var field_strength_value_label: Label = $FieldStrengthValue

func _ready():
	hide()


func show_info(field_vector: Vector2):
	var field_strength_magnitude: float = field_vector.length()
	

	field_strength_value_label.text = "%.2f N/C" % field_strength_magnitude
	

	show()
func hide_info():
	hide()

func _process(delta: float):
	if is_visible():
		pass
		#self.position = get_global_mouse_position() + Vector2(15, 15)
