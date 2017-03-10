extends RigidBody

export var props = [
	Vector3(1, 0, 1),
	Vector3(-1, 0, 1),
	Vector3(1, 0, -1),
	Vector3(-1, 0, -1)
	]

export (NodePath) var controllerNode

const PID = preload("../Scripts/PID.gd")

var propPidControllers = []
var rotPidController
var targetUpVec = Vector3(0, 1, 0)
var rotTarget = 0

func _ready():
	
	for i in range(0, props.size()):
		propPidControllers.append(PID.new(0.8, 0, 4))
	rotPidController = PID.new(0.6, 0, 12)
	set_process(true)
	set_fixed_process(true)
	set_linear_damp(0.5)
	#set_friction(0)
	#set_angular_damp(2)

func _process(delta):
	if Input.is_key_pressed(KEY_Q):
		get_tree().quit()
	
	#controlByKb()
	#controlByControllerNode()
	
func controlByKb():
	var tiltAmount = 0.4
	var myBasis = get_global_transform().basis
	targetUpVec = Vector3(0, 1, 0)
	
	if (Input.is_key_pressed(KEY_UP)):
		targetUpVec -= myBasis.z*tiltAmount
	if (Input.is_key_pressed(KEY_DOWN)):
		targetUpVec += myBasis.z*tiltAmount
	if (Input.is_key_pressed(KEY_RIGHT)):
		targetUpVec += myBasis.x*tiltAmount
	if (Input.is_key_pressed(KEY_LEFT)):
		targetUpVec -= myBasis.x*tiltAmount
	
	targetUpVec = targetUpVec.normalized()

func controlByControllerNode():
	if !controllerNode:
		print("controllerNode null")
		return
	
	var control = get_node(controllerNode).get_global_transform().basis
	targetUpVec = control.y
	var rot = Vector3(0, 1, 0).cross(control.x)
	rotTarget = atan2(rot.x, -rot.z)

func _fixed_process(delta):
	controlByControllerNode()
	
	var myOrigin = get_global_transform().origin
	var myBasis = get_global_transform().basis
	
	var propDist = 0.1
	
	for i in range(0, props.size()):
		var propLoc = props[i].x*myBasis.x + props[i].y*myBasis.y + props[i].z*myBasis.z
		var error = acos(targetUpVec.dot(propLoc.normalized()))-PI/2;
		var pidOut = propPidControllers[i].iter(error)
		var force = 2.6+pidOut
		apply_impulse(propLoc, myBasis.y*force*delta)
	
	var rotCurrent = atan2(-myBasis.z.x, myBasis.z.z)
	var rotError = rotTarget-rotCurrent
	var rotMove = rotPidController.iter(rotError)
	
	apply_impulse(myOrigin + myBasis.z, -myBasis.x*rotMove*delta)
	apply_impulse(myOrigin - myBasis.z, myBasis.x*rotMove*delta)
	
	print(rad2deg(rotMove))