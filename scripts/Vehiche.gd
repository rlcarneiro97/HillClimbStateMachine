extends RigidBody2D

enum {IDLE, ACELERAR, FREAR, TRACAO}
var current_state := 0
var enterState := true

export var torque: int = 1800

var tracao := 0
var pitch = 0.8
const PITCH_TIME_IN = 0.05
const PITCH_TIME_OUT = 2

const CONST_INCLINACAO = 1500

func _process(delta):
	
	if Input.is_action_just_pressed("ui_reload"):
		get_tree().reload_current_scene()
	
	match current_state:
		IDLE:
			_idleState()
		ACELERAR:
			_acelerarState()
		FREAR:
			_frearState()
		TRACAO:
			_tracaoState()

# CHECK FUNCTIONS
func _checkIdleState():
	var newState = current_state
	
	newState = IDLE
	
	if Input.is_action_just_pressed("ui_right"):
		newState = ACELERAR
	elif Input.is_action_just_pressed("ui_left"):
		newState = FREAR
	elif Input.is_action_just_pressed("ui_select"):
		newState = TRACAO
		
	return newState

func _checkAcelerarState():
	var newState = current_state
	
	newState = IDLE
	
	if Input.is_action_pressed("ui_right"):
		newState = ACELERAR
	elif Input.is_action_pressed("ui_left"):
		newState = FREAR
	elif Input.is_action_just_pressed("ui_select"):
		newState = TRACAO
		
	return newState
	
func _checkFrearState():
	var newState = current_state
	
	newState = IDLE
	
	if Input.is_action_pressed("ui_right"):
		newState = ACELERAR
	elif Input.is_action_pressed("ui_left"):
		newState = FREAR
	elif Input.is_action_just_pressed("ui_select"):
		newState = TRACAO
		
	return newState
	
func _checkTracaoState():
	var newState = current_state
	
	newState = IDLE
	
	if Input.is_action_pressed("ui_right"):
		newState = ACELERAR
	elif Input.is_action_pressed("ui_left"):
		newState = FREAR
	elif Input.is_action_just_pressed("ui_select"):
		newState = TRACAO
		
	return newState

# STATE FUNCTIONS
func _idleState():
	_inicializaSom()
	_desaceleracaoSomTorque()
	_setState(_checkIdleState())

func _acelerarState():
	
	_inicializaSom()
	
	if tracao == 0:
		get_node("FrontWheel").apply_torque_impulse(torque)
		_inclinarParaEsquerda()
	elif tracao == 1:
		get_node("BackWheel").apply_torque_impulse(torque)
		_inclinarParaEsquerda()
	elif tracao == 2:
		get_node("FrontWheel").apply_torque_impulse(torque/2)
		get_node("BackWheel").apply_torque_impulse(torque/2)
		_inclinarParaEsquerda()
	
	_aceleracaoSomTorque()
	_setState(_checkAcelerarState())
	
func _frearState():
	
	_inicializaSom()
	
	if tracao == 0:
		get_node("FrontWheel").apply_torque_impulse(-torque)
		_inclinarParaDireita()
	elif tracao == 1:
		get_node("BackWheel").apply_torque_impulse(-torque)
		_inclinarParaDireita()
	elif tracao == 2:
		get_node("FrontWheel").apply_torque_impulse(-torque/2)
		get_node("BackWheel").apply_torque_impulse(-torque/2)
		_inclinarParaDireita()
	
	_aceleracaoSomTorque()
	_setState(_checkFrearState())
	
func _tracaoState():
	
	_inicializaSom()
	
	if tracao == 2:
		tracao = 0
	elif tracao < 2:
		tracao += 1
		
	_setState(_checkTracaoState())

# HELPERS
func _aceleracaoSomTorque():
	if pitch < 3.3:
		pitch += PITCH_TIME_IN

func _desaceleracaoSomTorque():
	if pitch > 0.8:
		pitch -= PITCH_TIME_IN * PITCH_TIME_OUT

func _inicializaSom():
	get_node("SomMotor").set_pitch_scale(pitch)
	
func _inclinarParaEsquerda():
	apply_torque_impulse(-CONST_INCLINACAO)

func _inclinarParaDireita():
	apply_torque_impulse(CONST_INCLINACAO)

func _setState(state):
	if state != current_state:
		enterState = true
	current_state = state
