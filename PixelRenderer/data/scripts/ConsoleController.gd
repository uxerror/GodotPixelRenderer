extends Node

@onready var console: TextEdit = %Console
@onready var console_container: HBoxContainer = %ConsoleContainer
@onready var expand_console: Button =%ExpandConsole

const LOG_FILE_PATH = "user://export.log"
var console_container_expanded = false

func _ready():
	# Initialize console
	var log_file = FileAccess.open(LOG_FILE_PATH, FileAccess.WRITE)
	if log_file:
		log_file.store_line("--- Export log started at: " + Time.get_datetime_string_from_system() + " ---")
		log_file.close() # Важно закрыть файл после записи
	_update_console_view()
	expand_console.pressed.connect(_on_expand_log_button_pressed)
	
func _update(message: String):
	# 1. Записываем сообщение в файл
	var log_file = FileAccess.open(LOG_FILE_PATH, FileAccess.READ_WRITE)
	if log_file:
		log_file.seek_end()
		log_file.store_line(message)
		log_file.close()
	_update_console_view()

func _on_expand_log_button_pressed():
	console_container_expanded = not console_container_expanded
	_update_console_view()

func _update_console_view():
	var log_file = FileAccess.open(LOG_FILE_PATH, FileAccess.READ)
	if console_container_expanded:
		if log_file:
			console.text = log_file.get_as_text()
			log_file.close()
			console.scroll_vertical = console.get_line_count()
		console_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		var lines = log_file.get_as_text().strip_edges().split("\n")
		if lines.size() > 0:
			console.text = lines[-1]
			
		console_container.size_flags_vertical = 0
		console_container.custom_minimum_size.y = 30 
