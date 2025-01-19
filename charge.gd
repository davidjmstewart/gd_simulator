@tool
class_name Charge

extends Node2D
@export_group("Charge properties")
## The amount of charge (in Coulombs)
@export var Q: float = 1.0 

func _ready() -> void:
	add_to_group("charge_group")
	$ChargeLabel.text = "Q \n %.2f C" % Q
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Q >= 0:
		# display the positive charge sprite, turn off the negative charge sprite
		$ChargeNegative.visible = false;
		$ChargePositive.visible = true;
	else:
		$ChargeNegative.visible = true;
		$ChargePositive.visible = false;
