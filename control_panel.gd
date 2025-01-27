extends CanvasLayer
signal point_charge_created(charge: float)

var _charge: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_add_charge_button_button_up() -> void:
	print('Adding charge!')
	point_charge_created.emit(_charge)

	pass # Replace with function body.


func _on_charge_entry_field_text_changed() -> void:
	var val: String = $ChargeEntryField.get_text()

	_charge = val.to_float()
	pass # Replace with function body.
