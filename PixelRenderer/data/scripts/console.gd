extends TextEdit
class_name Console

func log(message: String):
	text += message + "\n"
	scroll_vertical = get_line_count()
