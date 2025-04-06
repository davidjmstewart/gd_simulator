@tool
class_name Charge

extends Node2D
@export_group("Charge properties")
## The amount of charge (in Coulombs)
@export var Q: float = 1.0 
var _previous_position: Vector2 = Vector2(0,0)
enum UserInteractionStates {IDLE, MOVING, HOVERING}

var state: UserInteractionStates = UserInteractionStates.IDLE



func _ready() -> void:
	add_to_group("charge_group")
	$ChargeLabel.text = "Q \n %.2f C" % Q
	_previous_position = self.position
	if Q >= 0:
		# display the positive charge sprite, turn off the negative charge sprite
		$ChargeNegative.visible = false;
		$ChargePositive.visible = true;
	else:
		$ChargeNegative.visible = true;
		$ChargePositive.visible = false;

func handle_state_machine() -> void:
	var mouse_position = get_global_mouse_position()
	if state == UserInteractionStates.MOVING:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		self.position = get_global_mouse_position()

		#if mouse_position != _previous_position:
			#print('Charge has been moved, emit signal')
		
func _process(delta: float) -> void:
	handle_state_machine()



func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# This block ensures that if one charge Area2D overlaps another Area2D,
			# then we wont set both objects to being moving (i.e. only ever drag one at a time)
			var world_click_position = get_global_mouse_position()
			var space_state = viewport.world_2d.direct_space_state

			var query = PhysicsPointQueryParameters2D.new()
			query.position = world_click_position 
			query.collide_with_areas = true
			query.collide_with_bodies = false
			
			var results = space_state.intersect_point(query)

			# --- Process the results ---
			if not results.is_empty():
				
				var first_hit = results[0]
				var clicked_area = first_hit.collider 
				if clicked_area == $Area2D:
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
