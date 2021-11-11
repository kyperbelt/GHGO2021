extends ViewportContainer

export(NodePath) var _target
export(NodePath) var _dialogueDisplay
export(NodePath) var _dialoguePointer
export(NodePath) var _camera

export(float) var targetRadius = 10

var rootViewSize := Vector2()
var viewportSize := Vector2()
var camera : Camera2D = null

var target = null
var dialogueDisplay = null
var dialoguePointer : Polygon2D= null

var parentScale:= Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():


	if _dialogueDisplay:
		dialogueDisplay = get_node(_dialogueDisplay)

	if _target:
		target = get_node(_target)

	var parent = get_parent()

	if _dialoguePointer:
		dialoguePointer = get_node(_dialoguePointer)

	if parent is CanvasLayer:
		var canvas = parent as CanvasLayer
		parentScale = Vector2(1,1) / canvas.scale

	else:
		printerr("parent of guiLayer not a canvas layer")

	if _camera:
		camera = get_node(_camera)

	viewportSize = rect_size
	rootViewSize.x = ProjectSettings.get("display/window/size/width")
	rootViewSize.y = ProjectSettings.get("display/window/size/height")

func _process(_delta):

	if target && dialogueDisplay && camera:
		var camPos = camera.global_position
		var ncx = camPos.x - rootViewSize.x * .5
		var ncy = camPos.y - rootViewSize.y * .5

		var tarPos = target.global_position
		var percentTargetX = ( tarPos.x - ncx ) / rootViewSize.x
		var percentTargetY = ( tarPos.y - ncy ) / rootViewSize.y

		var newTargetPos := Vector2(percentTargetX * viewportSize.x, percentTargetY * viewportSize.y)

		var scale = (rootViewSize /  viewportSize) * parentScale

		var isBottom =percentTargetY < .2

		var dpos = dialogueDisplay.rect_position
		dpos = newTargetPos * scale
		dpos.x += -dialogueDisplay.rect_size.x * .5
		dpos.y += -(dialogueDisplay.rect_size.y + targetRadius) if !isBottom else +(targetRadius * .5 + dialogueDisplay.rect_size.y * scale.y)


		dpos.x = min(max(dpos.x,0),viewportSize.x * scale.x -dialogueDisplay.rect_size.x)
		dpos.y = min(max(dpos.y,0), (viewportSize.y - dialogueDisplay.rect_size.y) * scale.y)
		# print("psx: %s " % (viewportSize.x * vscale.x *parentScale.x - dialogueDisplay.rect_size.x), "current pos: %s"% (dpos.x))


		dialogueDisplay.rect_position = dpos

		# do nothing else if there is no polygon for chat
		if !dialoguePointer:
			return

		var cornerRect := Vector2()
		if isBottom:
			cornerRect.y = dialogueDisplay.get_end().y
		else:
			cornerRect.x = dialogueDisplay.rect_position.y

		if target is Entity:
			var targetEnt = target as Entity
			var facingLeft = targetEnt.sprite.flip_h
			if facingLeft:
				cornerRect.x = dialogueDisplay.rect_position.x
			else:
				cornerRect.x = dialogueDisplay.rect_position.x + dialogueDisplay.rect_size.x
		else:
			cornerRect.x = dialogueDisplay.x


		dialoguePointer.polygon[0] = tarPos / scale
		dialoguePointer.polygon[1] = Vector2()
		dialoguePointer.polygon[2] = Vector2()

		print(dialoguePointer)
