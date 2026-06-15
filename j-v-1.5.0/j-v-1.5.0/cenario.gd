extends Node2D

const ENEMY := preload("res://jubis.tscn")
var pause_scene = preload ("res://pause.tscn")

@onready var enemy_spawn: Node2D = $EnemySpawn


func _ready():
	#_spawn_enemy()
	
	pause_scene = pause_scene.instantiate()
	add_child(pause_scene)

	pause_scene.visible = false
	pause_scene.get_node("CanvasLayer").visible = false
	pause_scene.resume_requested.connect(_on_resume_requested)


#func _spawn_enemy():
	#var enemy := ENEMY.instantiate()
	#add_child(enemy)
	#enemy.global_position = enemy_spawn.global_position
	
func toggle_pause():
	var state = !pause_scene.visible

	pause_scene.visible = state
	pause_scene.get_node("CanvasLayer").visible = state

	get_tree().paused = state
		
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		
func _on_resume_requested():
	toggle_pause()
