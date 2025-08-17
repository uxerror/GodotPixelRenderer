extends Node3D

signal added_checkpoint(index: int)

# --- Constants ---
const DEFAULT_ROTATION_DELTA := 45.0
const DEFAULT_CAMERA_POS := Vector3(0, 1, 55)
const DEFAULT_CAMERA_ROT := Vector3.ZERO
const DEFAULT_ZOOM := 4.0

## Camera presets (position + rotation)
const CAMERA_PRESETS := {
	"Default":   { pos = DEFAULT_CAMERA_POS, rot = DEFAULT_CAMERA_ROT },
	"Front":     { pos = Vector3(0, 1, 55),  rot = Vector3(0, 0, 0) },
	"Left":      { pos = Vector3(-55, 1, 0), rot = Vector3(0, -90, 0) },
	"Right":     { pos = Vector3(55, 1, 0),  rot = Vector3(0, 90, 0) },
	"Top":       { pos = Vector3(0, 55, 0),  rot = Vector3(-90, 0, 0) },
	"Isometric": { pos = Vector3(0, 56, 55), rot = Vector3(-45, 0, 0) }
}

# --- UI groups (model + camera controls) ---
@onready var model := {
	pos = { x = %XPosSpin, y = %YPosSpin, z = %ZPosSpin },
	rot = { x = %XRotSpin, y = %YRotSpin, z = %ZRotSpin },
	buttons = { up = %Button_Model_Up, down = %Button_Model_Down, left = %Button_Model_Left, right = %Button_Model_Right },
	delta_spin = %RotationModelDeltaSpinBox,
	rot_reset = %RotResetButton,
	pos_reset = %PosResetButton
}

@onready var camera_ctl := {
	pos = { x = %XPosCameraSpin, y = %YPosCameraSpin, z = %ZPosCameraSpin },
	rot = { x = %XRotCameraSpin, y = %YRotCameraSpin, z = %ZRotCameraSpin },
	buttons = { up = %Button_Camera_Up, down = %Button_Camera_Down, left = %Button_Camera_Left, right = %Button_Camera_Right },
	delta_spin = %RotationCameraDeltaSpinBox,
	rot_reset = %RotCameraResetButton,
	pos_reset = %PosCameraResetButton,
	zoom_spin = %CameraZoomSpin,
	zoom_reset = %ZoomResetButton,
	preset_select = %CameraConfigOptionButton
}

@onready var camera: Camera3D = %Camera
@onready var add_checkpoint_button: Button = %AddModelCameraConfigButton   # кнопка для сохранения конфигурации

# --- Exported properties ---
@export var rotation_model_delta: float = DEFAULT_ROTATION_DELTA
@export var rotation_camera_delta: float = DEFAULT_ROTATION_DELTA

# --- Data storage ---
var checkpoints: Array = []   # массив точек сохранения

# --- Delta getters/setters ---
func _get_rotation_model_delta() -> float: return rotation_model_delta
func _set_rotation_model_delta(v: float) -> void: rotation_model_delta = v

func _get_rotation_camera_delta() -> float: return rotation_camera_delta
func _set_rotation_camera_delta(v: float) -> void: rotation_camera_delta = v

# --- Ready ---
func _ready() -> void:
	# Init model controls
	_init_controls(model, _update_model_position, _update_model_rotation,
		Callable(self, "_get_rotation_model_delta"), Callable(self, "_set_rotation_model_delta"),
		_reset_model_position, _reset_model_rotation)

	# Init camera controls
	_init_controls(camera_ctl, _update_camera_position, _update_camera_rotation,
		Callable(self, "_get_rotation_camera_delta"), Callable(self, "_set_rotation_camera_delta"),
		_reset_camera_position, _reset_camera_rotation)

	# Zoom and presets
	camera_ctl.zoom_spin.value_changed.connect(_update_zoom)
	camera_ctl.zoom_reset.pressed.connect(_reset_zoom)
	_setup_camera_presets()
	camera_ctl.preset_select.item_selected.connect(_on_camera_preset_selected)

	# Save button
	add_checkpoint_button.pressed.connect(_on_add_checkpoint_pressed)

	reset_all()

# --- Initialize a control group (model or camera) ---
func _init_controls(group, update_pos, update_rot, get_delta: Callable, set_delta: Callable, reset_pos, reset_rot) -> void:
	for axis in group.pos: group.pos[axis].value_changed.connect(update_pos)
	for axis in group.rot: group.rot[axis].value_changed.connect(update_rot)

	group.buttons.up.pressed.connect(func(): _rotate_spinbox(group.rot.x,  get_delta.call(), update_rot))
	group.buttons.down.pressed.connect(func(): _rotate_spinbox(group.rot.x, -get_delta.call(), update_rot))
	group.buttons.left.pressed.connect(func(): _rotate_spinbox(group.rot.y, -get_delta.call(), update_rot))
	group.buttons.right.pressed.connect(func(): _rotate_spinbox(group.rot.y,  get_delta.call(), update_rot))

	group.delta_spin.value_changed.connect(set_delta)
	group.pos_reset.pressed.connect(reset_pos)
	group.rot_reset.pressed.connect(reset_rot)

# --- Reset all state ---
func reset_all() -> void:
	_reset_model_position(); _reset_model_rotation()
	_reset_camera_position(); _reset_camera_rotation()
	_reset_zoom()

# --- Helpers ---
func _rotate_spinbox(spinbox: SpinBox, delta: float, callback: Callable) -> void:
	spinbox.value += delta
	callback.call(0)

func _vector_from_spinboxes(spin_group: Dictionary) -> Vector3:
	return Vector3(spin_group.x.value, spin_group.y.value, spin_group.z.value)

# --- Model logic ---
func _update_model_position(_v: float = 0) -> void: position = _vector_from_spinboxes(model.pos)
func _update_model_rotation(_v: float = 0) -> void: rotation_degrees = _vector_from_spinboxes(model.rot)
func _reset_model_position() -> void: for a in model.pos: model.pos[a].value = 0; _update_model_position()
func _reset_model_rotation() -> void: for a in model.rot: model.rot[a].value = 0; _update_model_rotation()

# --- Camera logic ---
func _update_camera_position(_v: float = 0) -> void:
	camera.position = DEFAULT_CAMERA_POS + _vector_from_spinboxes(camera_ctl.pos)

func _update_camera_rotation(_v: float = 0) -> void:
	camera.rotation_degrees = DEFAULT_CAMERA_ROT + _vector_from_spinboxes(camera_ctl.rot)

func _reset_camera_position() -> void: for a in camera_ctl.pos: camera_ctl.pos[a].value = 0; _update_camera_position()
func _reset_camera_rotation() -> void: for a in camera_ctl.rot: camera_ctl.rot[a].value = 0; _update_camera_rotation()

# --- Zoom logic ---
func _update_zoom(v: float) -> void: if v > 0: camera.size = v
func _reset_zoom() -> void: camera_ctl.zoom_spin.value = DEFAULT_ZOOM; camera.size = DEFAULT_ZOOM

# --- Camera presets ---
func _setup_camera_presets() -> void:
	camera_ctl.preset_select.clear()
	for n in CAMERA_PRESETS: camera_ctl.preset_select.add_item(n)

func _on_camera_preset_selected(i: int) -> void:
	var p = CAMERA_PRESETS[camera_ctl.preset_select.get_item_text(i)]
	camera.position = p.pos
	camera.rotation_degrees = p.rot
	_sync_camera_ui()

func _sync_camera_ui() -> void:
	var pos_offset = camera.position - DEFAULT_CAMERA_POS
	camera_ctl.pos.x.value = pos_offset.x
	camera_ctl.pos.y.value = pos_offset.y
	camera_ctl.pos.z.value = pos_offset.z

	var rot_offset = camera.rotation_degrees - DEFAULT_CAMERA_ROT
	camera_ctl.rot.x.value = rot_offset.x
	camera_ctl.rot.y.value = rot_offset.y
	camera_ctl.rot.z.value = rot_offset.z

# --- Save/Load state ---
func get_state() -> Dictionary:
	return {
		"model": {
			"position": get_model_position(),
			"rotation": get_model_rotation()
		},
		"camera": {
			"position": get_camera_position(),
			"rotation": get_camera_rotation(),
			"zoom": camera.size
		}
	}

func set_state(state: Dictionary) -> void:
	if state.has("model"):
		if state.model.has("position"):
			position = state.model.position
			for axis in model.pos:
				model.pos[axis].value = position[axis]
		if state.model.has("rotation"):
			rotation_degrees = state.model.rotation
			for axis in model.rot:
				model.rot[axis].value = rotation_degrees[axis]

	if state.has("camera"):
		if state.camera.has("position"):
			camera.position = state.camera.position
			var pos_offset = camera.position - DEFAULT_CAMERA_POS
			camera_ctl.pos.x.value = pos_offset.x
			camera_ctl.pos.y.value = pos_offset.y
			camera_ctl.pos.z.value = pos_offset.z

		if state.camera.has("rotation"):
			camera.rotation_degrees = state.camera.rotation
			var rot_offset = camera.rotation_degrees - DEFAULT_CAMERA_ROT
			camera_ctl.rot.x.value = rot_offset.x
			camera_ctl.rot.y.value = rot_offset.y
			camera_ctl.rot.z.value = rot_offset.z

		if state.camera.has("zoom"):
			camera.size = state.camera.zoom
			camera_ctl.zoom_spin.value = state.camera.zoom

# --- Button logic ---
func _on_add_checkpoint_pressed() -> void:
	checkpoints.append(get_state())
	var index = checkpoints.size() - 1
	added_checkpoint.emit(index)
	print("Checkpoint saved! Total:", checkpoints.size())

# --- Simple getters ---
func get_model_position() -> Vector3: return position
func get_model_rotation() -> Vector3: return rotation_degrees
func get_camera_position() -> Vector3: return camera.position
func get_camera_rotation() -> Vector3: return camera.rotation_degrees
