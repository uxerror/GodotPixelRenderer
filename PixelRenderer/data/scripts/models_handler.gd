extends Node3D

@onready var x_pos_spin: SpinBox = %XPosSpin
@onready var y_pos_spin: SpinBox = %YPosSpin
@onready var z_pos_spin: SpinBox = %ZPosSpin

@onready var camera: Camera3D = %Camera
@onready var zoom_spin: SpinBox = %CameraZoomSpin
@onready var reset_button: Button = %PosResetButton

@onready var x_rot_spin: SpinBox = %XRotSpin
@onready var y_rot_spin: SpinBox = %YRotSpin
@onready var z_rot_spin: SpinBox = %ZRotSpin
@onready var button_up: Button = %Button_Up
@onready var button_down: Button = %Button_Down
@onready var button_left: Button = %Button_Left
@onready var button_right: Button = %Button_Right
@onready var rot_reset_button: Button = %RotResetButton
@onready var zoom_reset_button: Button = %ZoomResetButton



func _ready():
	# Set default values
	_reset_to_defaults()
	
	# Connect spinbox value changes to update position and camera
	x_pos_spin.value_changed.connect(_on_position_changed)
	y_pos_spin.value_changed.connect(_on_position_changed)
	z_pos_spin.value_changed.connect(_on_position_changed)
	zoom_spin.value_changed.connect(_on_zoom_changed)
	reset_button.pressed.connect(_reset_to_defaults)
	zoom_reset_button.pressed.connect(_reset_zoom)
	
	# Connect rotation spinboxes to update rotation
	x_rot_spin.value_changed.connect(_on_rotation_changed)
	y_rot_spin.value_changed.connect(_on_rotation_changed)
	z_rot_spin.value_changed.connect(_on_rotation_changed)
	
	# Connect preset rotation buttons
	button_up.pressed.connect(_on_rotate_up)
	button_down.pressed.connect(_on_rotate_down)
	button_left.pressed.connect(_on_rotate_left)
	button_right.pressed.connect(_on_rotate_right)
	rot_reset_button.pressed.connect(_reset_rotation)

func _on_position_changed(_value):
	# Update position when any spinbox value changes
	position = Vector3(x_pos_spin.value, y_pos_spin.value, z_pos_spin.value)

func _on_rotation_changed(_value):
	# Update rotation when any rotation spinbox value changes
	rotation_degrees = Vector3(x_rot_spin.value, y_rot_spin.value, z_rot_spin.value)

func _on_rotate_up():
	# Rotate up by 90 degrees on X axis
	x_rot_spin.value += 90.0
	_on_rotation_changed(0)

func _on_rotate_down():
	# Rotate down by 90 degrees on X axis
	x_rot_spin.value -= 90.0
	_on_rotation_changed(0)

func _on_rotate_left():
	# Rotate left by 90 degrees on Y axis
	y_rot_spin.value -= 90.0
	_on_rotation_changed(0)

func _on_rotate_right():
	# Rotate right by 90 degrees on Y axis
	y_rot_spin.value += 90.0
	_on_rotation_changed(0)

func _reset_rotation():
	# Reset rotation to (0,0,0)
	x_rot_spin.value = 0.0
	y_rot_spin.value = 0.0
	z_rot_spin.value = 0.0
	rotation_degrees = Vector3(0.0, 0.0, 0.0)

func _on_zoom_changed(value):
	# Update camera size when zoom spinbox changes
	camera.size = value

func _reset_to_defaults():
	# Set default values: position (0,0,0)
	x_pos_spin.value = 0.0
	y_pos_spin.value = 0.0
	z_pos_spin.value = 0.0

	# Update position
	position = Vector3(0.0, 0.0, 0.0)


func _reset_zoom():
	# Reset zoom to default value
	zoom_spin.value = 4.0
	camera.size = 4.0
