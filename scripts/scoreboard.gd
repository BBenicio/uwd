extends MeshInstance3D

@export var left_wins = 0:
	set(value):
		left_wins = value
		$Left.digit = value

@export var right_wins = 0:
	set(value):
		right_wins = value
		$Right.digit = value

func reset():
	left_wins = 0
	right_wins = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
