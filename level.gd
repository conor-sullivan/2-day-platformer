extends Node2D

@onready var level_complete: ColorRect = $CanvasLayer/LevelComplete
@onready var hearts_collected_label: Label = $HUD/HeartsCollectedLabel
@onready var music: AudioStreamPlayer2D = $Music

@export var next_level: PackedScene

var hearts_collected = 0
var total_hearts = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	total_hearts = get_tree().get_nodes_in_group("hearts").size()
	Events.level_complete.connect(show_level_complete)
	Events.heart_collected.connect(set_hearts_collected_ui)
	set_hearts_collected_ui()
	music.play()
	
func set_hearts_collected_ui():
	hearts_collected_label.text = str(hearts_collected, "/", total_hearts)
	hearts_collected += 1

func show_level_complete():
	level_complete.show()
	get_tree().paused = true
	await get_tree().create_timer(1.0).timeout
	
	if next_level:
		await LevelTransition.fade_to_black()
		get_tree().paused = false
		get_tree().change_scene_to_packed(next_level)
		await LevelTransition.fade_from_black()
	else:
		print("no next level")
	
