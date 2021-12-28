extends KinematicBody

const MOUSE_SENSITIVITY = .1

onready var camera = $CamRoot/Camera

#Deplacement
var velocity = Vector3.ZERO
var current_vel = Vector3.ZERO
var dir = Vector3.ZERO

const SPEED = 10
const SPRINT_SPEED = 20
const ACCEL = 15.0

#Saut
const GRAVITY = -40.0
const JUMP_SPEED = 15
var jump_cnt = 0
const AIR_ACCEL = 9.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	
func _process(delta):
	if is_network_master():
		window_activity()

func _physics_process(delta):
	if is_network_master():
		#input direction 
		dir = Vector3.ZERO
		if Input.is_action_pressed("forward"):
			dir-=camera.global_transform.basis.z
		if Input.is_action_pressed("backward"):
			dir+=camera.global_transform.basis.z
		if Input.is_action_pressed("left"):
			dir-=camera.global_transform.basis.x
		if Input.is_action_pressed("right"):
			dir+=camera.global_transform.basis.x
		
		#normaliser les directions
		dir = dir.normalized()
	
	#gravity
	velocity.y += GRAVITY*delta
	
	#jump
	if is_on_floor():
		jump_cnt=0
	if is_network_master():	
		if Input.is_action_just_pressed("jump") and jump_cnt<2:
			jump_cnt+=1
			velocity.y = JUMP_SPEED
	
	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var target_vel = dir * speed
	
	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	current_vel = current_vel.linear_interpolate(target_vel, accel*delta)
	
	velocity.x = current_vel.x
	velocity.z = current_vel.z

	velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(45))


func _input(event):
	if is_network_master():
		if event is InputEventMouseMotion:
			#Rotation de la vue verticale
			$CamRoot.rotate_x(deg2rad(event.relative.y*MOUSE_SENSITIVITY*-1))
			$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x,-75,75)
			
			#Rotation horizontal
			self.rotate_y(deg2rad(event.relative.x*MOUSE_SENSITIVITY*-1))
	
#Gestion du curseur
func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
