extends KinematicBody

const MOUSE_SENSITIVITY = .1

export(NodePath) onready var camera = get_node("CamRoot") as Spatial
export(NodePath) onready var timer_network_update = get_node("TimerNetworkUpdate") as Timer
export(NodePath) onready var tween_movement = get_node("TweenMovement") as Tween
export(NodePath) onready var detect_chest = get_node("DetectChest") as RayCast
export(NodePath) onready var ui_player = get_node("Control/VBoxContainer/Label") as Label

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

#Puppet
var puppet_position = Vector3()
var puppet_velocity = Vector3()
#var puppet_rotation = Vector2() rotation de la tete

#Chest
var collision_chest = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	window_activity()
	
	#Chest
	collision_chest = detect_chest.get_collider()
	if collision_chest:
		if collision_chest.name == "Chest":
			ui_player.text = "Ouvrir le coffre (E)"
	else: 
		ui_player.text = ""
		
func _physics_process(delta):
	#if is_network_master():
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
	#if is_network_master():	
	if Input.is_action_just_pressed("jump") and jump_cnt<2:
		jump_cnt+=1
		velocity.y = JUMP_SPEED

	var speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else SPEED
	var target_vel = dir * speed

	var accel = ACCEL if is_on_floor() else AIR_ACCEL
	current_vel = current_vel.linear_interpolate(target_vel, accel*delta)
	
	velocity.x = current_vel.x
	velocity.z = current_vel.z
	"""else:
		global_transform.origin = puppet_position
		
		velocity.x = puppet_velocity.x
		velocity.y = puppet_velocity.y"""

	velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(45))

	#chest
	if Input.is_action_just_pressed("interaction"):
		if collision_chest:
			if collision_chest.name == "Chest":
				collision_chest.emit_signal("open_chest")

func _input(event):
	#if is_network_master():
	if event is InputEventMouseMotion:
		#Rotation de la vue verticale
		$CamRoot.rotate_x(deg2rad(event.relative.y*MOUSE_SENSITIVITY*-1))
		$CamRoot.rotation_degrees.x = clamp($CamRoot.rotation_degrees.x,-75,75)
		
		#Rotation horizontal
		self.rotate_y(deg2rad(event.relative.x*MOUSE_SENSITIVITY*-1))
	
puppet func update_movement(p_position, p_velocity):#,p_rotation):
	puppet_position = p_position
	puppet_velocity = p_velocity
	#puppet_rotation = p_rotation
	
	tween_movement.interpolate_property(self, "global_transform", global_transform, Transform(global_transform.basis, p_position),.1)
	tween_movement.start()
#Gestion du curseur
func window_activity():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_TimerNetworkUpdate_timeout():
	if is_network_master():
		rpc_unreliable("update_movement",global_transform.origin, velocity)
	else:
		timer_network_update.stop()
