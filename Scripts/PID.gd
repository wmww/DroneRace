
var Kp
var Ki
var Kd
var Derivator
var Integrator
var Integrator_max
var Integrator_min

func _init(P, I, D):
	Kp=P
	Ki=I
	Kd=D
	Derivator=0
	Integrator=0
	Integrator_max=20
	Integrator_min=-20
	
func iter(error):
	var P_value = Kp * error
	var D_value = Kd * ( error - Derivator)
	Derivator = error
	
	Integrator = Integrator + error

	if Integrator > Integrator_max:
		Integrator = Integrator_max
	elif Integrator < Integrator_min:
		Integrator = Integrator_min

	var I_value = Integrator * Ki

	var out = P_value + I_value + D_value

	return out

func reset():
	Integrator=0
	Derivator=0
