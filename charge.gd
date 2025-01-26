@tool
class_name Charge

extends Node2D
@export_group("Charge properties")
## The amount of charge (in Coulombs)
@export var Q: float = 1.0 

enum UserInteractionStates {IDLE, MOVING, HOVERING}

var state: UserInteractionStates = UserInteractionStates.IDLE
func _ready() -> void:
	add_to_group("charge_group")
	$ChargeLabel.text = "Q \n %.2f C" % Q
	pass # Replace with function body.

func handle_state_machine() -> void:
	if state == UserInteractionStates.MOVING:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		self.position = get_global_mouse_position()
func _process(delta: float) -> void:
	handle_state_machine()
	if Q >= 0:
		# display the positive charge sprite, turn off the negative charge sprite
		$ChargeNegative.visible = false;
		$ChargePositive.visible = true;
	else:
		$ChargeNegative.visible = true;
		$ChargePositive.visible = false;


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			state = UserInteractionStates.MOVING
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
				state = UserInteractionStates.IDLE
		# Optional: Handle other mouse buttons
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Right mouse button clicked on Area2D!")


func _on_area_2d_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_area_2d_mouse_exited() -> void:
	if (state != UserInteractionStates.MOVING):
		state = UserInteractionStates.IDLE
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
