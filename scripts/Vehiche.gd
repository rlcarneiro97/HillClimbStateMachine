extends RigidBody2D

enum {IDLE, ACELERAR, FREAR, TRACAO}
var current_state := 0
var enterState := true

# O Medidor de RPM do jogo é o valor da var Pitch.
# O Medidor de Boost do jogo é a angular_velocity.

# Motor (Torque) 1/13
export var torqueMotor: int = 600

# Suspensao 1/14
var suspension := 1.0

# Rodas 1/16
var friccao := 1.0

# Tração 1/10
var tracao := 0
var TORQUE_TRASEIRO := 0.50
var TORQUE_DIANTEIRO := 0.50

# Transmissão
var transmissao := 1
var lim_conta_giro := 20.0

# -----------------------------------------------------------

# Som
var pitch = 0.8
const PITCH_TIME_IN = 0.05
const PITCH_TIME_OUT = 2

# Inclinação
const CONST_INCLINACAO = 500

# Referências
onready var frontWheel = get_node("FrontWheel")
onready var backWheel = get_node("BackWheel")
onready var frontSuspension = get_node("PinFront")
onready var backSuspension = get_node("PinBack")

func _ready():
	frontWheel.set_friction(friccao)
	backWheel.set_friction(friccao)
	
	frontSuspension.set_softness(suspension)
	backSuspension.set_softness(suspension)

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
	
	if tracao == 0 and frontWheel.angular_velocity < lim_conta_giro:
		frontWheel.apply_torque_impulse(torqueMotor)
		_inclinarParaEsquerda()
		print(frontWheel.angular_velocity)
	elif tracao == 1 and backWheel.angular_velocity < lim_conta_giro:
		backWheel.apply_torque_impulse(torqueMotor)
		_inclinarParaEsquerda()
		print(backWheel.angular_velocity)
	elif tracao == 2 and frontWheel.angular_velocity < lim_conta_giro and backWheel.angular_velocity < lim_conta_giro:
		frontWheel.apply_torque_impulse(torqueMotor * TORQUE_DIANTEIRO)
		backWheel.apply_torque_impulse(torqueMotor * TORQUE_TRASEIRO)
		print(frontWheel.angular_velocity, " | ", backWheel.angular_velocity)
		_inclinarParaEsquerda()

	_aceleracaoSomTorque()
	_setState(_checkAcelerarState())
	
func _frearState():
	
	_inicializaSom()
	
	if tracao == 0 and frontWheel.angular_velocity > -lim_conta_giro:
		frontWheel.apply_torque_impulse(-torqueMotor)
		print(frontWheel.angular_velocity)
		_inclinarParaDireita()
	elif tracao == 1 and backWheel.angular_velocity > -lim_conta_giro:
		backWheel.apply_torque_impulse(-torqueMotor)
		print(backWheel.angular_velocity)
		_inclinarParaDireita()
	elif tracao == 2 and frontWheel.angular_velocity > -lim_conta_giro and backWheel.angular_velocity > -lim_conta_giro:
		frontWheel.apply_torque_impulse(-(torqueMotor * TORQUE_DIANTEIRO))
		backWheel.apply_torque_impulse(-(torqueMotor * TORQUE_TRASEIRO))
		print(frontWheel.angular_velocity, " | ", backWheel.angular_velocity)
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
