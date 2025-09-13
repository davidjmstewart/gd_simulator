extends PanelContainer

signal distance_units_changed(new_units: String)
signal visual_scaling_changed(value: float)
signal vector_clamp_changed(value: float)
signal use_max_vector_size_toggled(toggled_on: bool)

@onready var animation_player = $AnimationPlayer
@onready var distance_units_input = $MarginContainer/VBoxContainer/DistanceUnitsContainer/DistanceUnitsInput
@onready var validation_label = $MarginContainer/VBoxContainer/DistanceUnitsContainer/ValidationLabel
@onready var settings_container = $MarginContainer

var is_open = false

func _ready():
	# Start closed and small
	var closed_size = Vector2(40, 40)
	custom_minimum_size = closed_size
	size = closed_size
	settings_container.hide()
	validation_label.hide()
	
	# Set initial values from the main scene if possible, or use defaults
	# This would typically be done by the parent scene calling a setup function


func _on_toggle_button_toggled(button_pressed):
	is_open = button_pressed
	if is_open:
		animation_player.play("open")
		$ToggleButton.text = "<"
	else:
		animation_player.play("close")
		$ToggleButton.text = ">"

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "close":
		settings_container.hide()

func _on_distance_units_input_text_submitted(new_text: String):
	if _validate_distance_units(new_text):
		validation_label.hide()
		distance_units_changed.emit(new_text)
	else:
		validation_label.text = "Invalid: Use letters only."
		validation_label.show()

func _validate_distance_units(units: String) -> bool:
	if units.is_empty():
		return false
	var regex = RegEx.new()
	# This regex allows letters and spaces.
	regex.compile("^[a-zA-Z ]+$")
	return regex.search(units) != null

func _on_visual_scaling_slider_value_changed(value: float):
	visual_scaling_changed.emit(value)

func _on_vector_clamp_slider_value_changed(value: float):
	vector_clamp_changed.emit(value)

func _on_use_max_vector_size_toggled(toggled_on: bool):
	use_max_vector_size_toggled.emit(toggled_on)

func _on_animation_player_animation_started(anim_name):
	if anim_name == "open":
		settings_container.show()

