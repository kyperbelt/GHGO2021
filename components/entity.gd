extends Area2D

class_name Entity

onready var sprite = $Sprite

## set the facing direction of the character
## -1 = left, and 1 = right
func set_facing(facing : int):
	# the current facing direciton based on sprite flip
	var currentFacing := -1 if sprite.flip_h else 1

	# already facing the correct direction. Do nothing
	if facing == currentFacing || facing == 0:
		return

	if facing == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true
