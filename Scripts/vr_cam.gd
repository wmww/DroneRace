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

export var camFieldOfView=60.0
export var camZNear=0.1
export var camZFar=100
export(Environment) var camEnvironment

var leftEye
var rightEye

var prevMousePos

class EyeView:
	const LEFT=1
	const RIGHT=2
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
		setCameraMount()
	
	func setViewportPosition():
		var vpSize=OS.get_window_size()
		vpSize.x/=2
		viewportArea.set_size(vpSize)
		var vpOrigin=Vector2(0, 0)
		if eyeSide==RIGHT:
			vpOrigin.x=viewportArea.get_size().x
		viewportArea.set_pos(vpOrigin)
	
	func setCameraMount():
		var offset
		if eyeSide==LEFT:
			offset=-1
		else:
			offset=1
		cameraMount.set_translation(Vector3(offset, 0, -1))
	
	func update():
		camera.set_global_transform(cameraMount.get_global_transform())

func _ready():
	#OS.set_window_fullscreen(true)
	leftEye=EyeView.new(self, EyeView.LEFT)
	rightEye=EyeView.new(self, EyeView.RIGHT)
	
	set_process(true)

func _process(delta):
	rotateByGyro(delta)
	RotateByMouse(delta)
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
	
func RotateByMouse(delta):
	
	var mousePressed=Input.is_mouse_button_pressed(BUTTON_LEFT)
	var altPressed=Input.is_key_pressed(KEY_ALT)
	
	if (mousePressed || altPressed):
		var mousePos=get_viewport().get_mouse_pos()
		mousePos*=2.0
		mousePos/=get_viewport().get_rect().size.x
		mousePos-=Vector2(1, 1)
		if (prevMousePos!=null):
			var deltaMouse=mousePos-prevMousePos
			deltaMouse*=0.9
			global_rotate(Vector3(0, 1, 0), -deltaMouse.x)
			rotate_x(-deltaMouse.y)
		prevMousePos=mousePos
	else:
		prevMousePos=null