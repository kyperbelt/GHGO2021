extends Entity

const IDLE_A  := "idle"
const RUN_A   := "run"
# const ATTACK_A := "attack"
# const WALK_A := "walk"

onready var animationPlayer = $AnimationPlayer

var velocity : Vector2 = Vector2()
export(float) var speed  : float   = 10

func _ready():
	animationPlayer.play("idle")
	pass

func _process(_delta):
	var dir := Vector2()

	if Input.is_action_pressed("move_down"):
		dir.y+=1
	if Input.is_action_pressed("move_up"):
		dir.y-=1
	if Input.is_action_pressed("move_left"):
		dir.x-=1
	if Input.is_action_pressed("move_right"):
		dir.x+=1


	set_facing(int(dir.x))

	if dir == Vector2.ZERO && velocity != Vector2.ZERO:
		animationPlayer.play(IDLE_A)

	if velocity == Vector2.ZERO && dir != Vector2.ZERO:
		animationPlayer.play(RUN_A)


	velocity = dir.normalized() * speed
	pass

func _physics_process(delta):
	position+=velocity * delta


