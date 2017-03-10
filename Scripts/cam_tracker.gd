extends Camera

export var enabled = true
export (NodePath) var target

func _ready():
	if !enabled:
		queue_free()
	
	if !target:
		print("please give tracking camera a target")
	
	set_process(true)

func _process(delta):
	if !target:
		return
	
	var targetObj = get_node(target)
	look_at(targetObj.get_global_transform().origin, Vector3(0, 1, 0))
	var distToTarget = (get_global_transform().origin - targetObj.get_global_transform().origin).length()
	var fov = 50/sqrt(distToTarget)
	fov = min(fov, 100)
	fov = max(fov, 10)
	set_perspective(fov, get_znear(), get_zfar())
