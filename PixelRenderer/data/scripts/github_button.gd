extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	OS.shell_open("https://github.com/bukkbeek/GodotPixelRenderer")
