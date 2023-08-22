extends Area2D

@onready var collect_sound: AudioStreamPlayer2D = $CollectSound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	collect_sound.play()
	Events.heart_collected.emit()
	var hearts = get_tree().get_nodes_in_group("hearts")
	if hearts.size() == 1:
		Events.level_complete.emit()
	queue_free()
