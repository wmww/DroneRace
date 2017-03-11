extends Position3D

# node higharchy

# VR_Root (Position3D) (has this script):
#	cameraMount (Spacial) (owned by left eye)
#	viewportArea (Control) (owned by left eye):
#		viewport (Viewport):
#			camera (Camera)
#	cameraMount (Spacial) (owned by right eye)
#	viewportArea (Control) (owned by right eye):
#		viewport (Viewport):
#			camera (Camera)

# cameras are automatically moved to the traansform of their mounts each cycle

export var enabled = true
export var useFixedProcess = false
export var camFieldOfView = 60.0
export var camZNear = 0.1
export var camZFar = 100
export var eyeDist = 0.06 # the distance between the two eyes
export var eyeOffset = Vector3(0.0, 0.0, 0.0) # the offset of each eye (in local cords) from the pivot point
export(Environment) var camEnvironment

var leftEye
var rightEye

var prevMousePos

func _ready():
	#OS.set_window_fullscreen(true)
	if (enabled):
		setup()
	else:
		disable()

func setup():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	leftEye=EyeView.new(self, EyeView.LEFT)
	rightEye=EyeView.new(self, EyeView.RIGHT)
	set_process(!useFixedProcess)
	set_fixed_process(useFixedProcess)

func disable():
	leftEye = null
	rightEye = null
	set_process(false)
	set_fixed_process(false)

func _process(delta):
	update(delta)

func _fixed_process(delta):
	update(delta)

func update(delta):
	rotateByGyro(delta)
	rotateByMouse(delta)
	#rotateByAccl(delta)
	
	leftEye.update()
	rightEye.update()

func rotateByGyro(delta):
	var gyro = Input.get_gyroscope()
	rotate(Vector3(1, 0, 0), -delta*gyro.x)
	rotate(Vector3(0, 1, 0), delta*gyro.y)
	rotate(Vector3(0, 0, 1), -delta*gyro.z)

func rotateByAccl(delta):
	var accl=Input.get_accelerometer()
	set_rotation(accl)
	
func rotateByMouse(delta):
	
	var mousePressed=Input.is_mouse_button_pressed(BUTTON_LEFT)
	var altPressed=Input.is_key_pressed(KEY_ALT)
	
	if (mousePressed || altPressed):
		var mousePos=get_viewport().get_mouse_pos()
		mousePos/=get_viewport().get_rect().size.x
		if (prevMousePos!=null):
			var deltaMouse=mousePos-prevMousePos
			deltaMouse*=1.8
			global_rotate(Vector3(0, 1, 0), -deltaMouse.x)
			rotate_x(-deltaMouse.y)
		#print(get_viewport().get_mouse_pos())
		#Input.warp_mouse_pos(get_viewport().get_mouse_pos())
		#print(get_viewport().get_mouse_pos())
		#mousePos=get_viewport().get_mouse_pos()
		#mousePos*=2.0
		#mousePos/=get_viewport().get_rect().size.x
		#mousePos-=Vector2(1, 1)
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		prevMousePos=mousePos
	else:
		prevMousePos=null


class EyeView:
	const LEFT = 1
	const RIGHT = 2
	var viewportArea
	var viewport
	var camera
	var cameraMount
	var eyeSide
	
	func _init(root, sideIn):
		eyeSide=sideIn
		viewportArea=Control.new()
		root.add_child(viewportArea)
		viewport=Viewport.new()
		viewportArea.add_child(viewport)
		camera=Camera.new()
		viewport.add_child(camera)
		camera.set_perspective(root.camFieldOfView, root.camZNear, root.camZFar)
		camera.set_environment(root.camEnvironment)
		cameraMount=Spatial.new()
		root.add_child(cameraMount)
		setViewportPosition()
		setCameraMount(root.eyeDist, root.eyeOffset)
	
	func setViewportPosition():
		var vpSize=OS.get_window_size()
		vpSize.x/=2
		viewportArea.set_size(vpSize)
		var vpOrigin=Vector2(0, 0)
		if eyeSide==RIGHT:
			vpOrigin.x=viewportArea.get_size().x
		viewportArea.set_pos(vpOrigin)
	
	func setCameraMount(eyeDist, eyeOffset):
		var offset = eyeOffset
		if eyeSide==LEFT:
			offset.x -= eyeDist/2.0
		else:
			offset.x += eyeDist/2.0
		cameraMount.set_translation(offset)
	
	func update():
		camera.set_global_transform(cameraMount.get_global_transform())
