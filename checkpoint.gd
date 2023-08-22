extends Area2D
@onready var checkpoint_sound: AudioStreamPlayer2D = $CheckpointSound
@onready var rays: ColorRect = $Rays

var entered = false
var entered_color = Vector4(0.365,0.973,0.651,1.0)

func _on_body_entered(body: Node2D) -> void:
	if not entered:
		rays.material.set_shader_parameter("color", entered_color)
		checkpoint_sound.play()
		Events.checkpoint_entered.emit()
		entered = true
