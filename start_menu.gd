extends CenterContainer

@onready var start_button: Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.grab_focus()
	RenderingServer.set_default_clear_color(Color.BLACK)

func _on_start_button_button_down() -> void:
	get_tree().change_scene_to_file("res://level1.tscn")

func _on_quit_button_button_down() -> void:
	get_tree().quit()
