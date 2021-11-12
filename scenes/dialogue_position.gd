extends ViewportContainer

export(NodePath) var _target
export(NodePath) var _dialogueDisplay
export(NodePath) var _dialoguePointer
export(NodePath) var _camera

export(float) var targetRadius = 10
export(float) var pointerThickness = 20


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
		dpos.y += -(dialogueDisplay.rect_size.y + targetRadius) if !isBottom else targetRadius * 2

		dpos.x = min(max(dpos.x,0),viewportSize.x * scale.x -dialogueDisplay.rect_size.x)
		dpos.y = min(max(dpos.y,0), (viewportSize.y - dialogueDisplay.rect_size.y) * scale.y)
		# print("psx: %s " % (viewportSize.x * vscale.x *parentScale.x - dialogueDisplay.rect_size.x), "current pos: %s"% (dpos.x))


		dialogueDisplay.rect_position = dpos

		# do nothing else if there is no polygon for chat
		if !dialoguePointer:
			return

		var top  := Vector2()
		var side := Vector2()
		# length of right triangle sides
		var thickThock :float = pointerThickness / sqrt(2)
		if isBottom:
			top.y = dialogueDisplay.get_end().y
			side.y = max(top.y - thickThock,top.y)
		else:
			top.y = dialogueDisplay.rect_position.y
			side.y = min(top.y + thickThock,top.y+dialogueDisplay.rect_size.y-2)

		var facingLeft = false

		if target is Entity:
			var targetEnt = target as Entity
			facingLeft = targetEnt.sprite.flip_h
			if facingLeft:
				side.x = dialogueDisplay.rect_position.x
				top.x = side.x + thickThock
			else:
				side.x = dialogueDisplay.rect_position.x + dialogueDisplay.rect_size.x
				top.x = side.x - thickThock

		var positionBase = newTargetPos * scale
		var dist := 20
		positionBase.x = positionBase.x + (-dist if facingLeft else dist)
		dialoguePointer.polygon[0] = positionBase

		dialoguePointer.polygon[1] = top
		dialoguePointer.polygon[2] = side

		print(dialoguePointer)
