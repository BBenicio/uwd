extends Node3D

@export_range(0, 9) var digit = 0:
	set = _set_digit


func _set_digit(value):
	digit = value
	$Top.visible = digit != 1 and digit != 4
	$Mid.visible = digit != 0 and digit != 1 and digit != 7
	$Bottom.visible = digit != 1 and digit != 4 and digit != 7
	$TopRight.visible = digit != 5 and digit != 6
	$BottomRight.visible = digit != 2
	$TopLeft.visible = digit != 1 and digit != 2 and digit != 3 and digit != 7
	$BottomLeft.visible = digit != 1 and digit != 3 and digit != 4 and digit != 5 and digit != 7
