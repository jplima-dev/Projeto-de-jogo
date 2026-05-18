extends Node2D

const PLAYER := preload("res://leandro.tscn")
const ENEMY := preload("res://jubis.tscn")

@onready var player_spawn: Node2D = $PlayerSpawn
@onready var enemy_spawn: Node2D = $EnemySpawn

func _ready():
	_spawn_player()
	#_spawn_enemy()

func _spawn_player():
	var player := PLAYER.instantiate()

	add_child(player)

	player.position = $PlayerSpawn.position

	print(player.position)
	print($PlayerSpawn.position)
	
	
	
#func _spawn_enemy():
	#var enemy := ENEMY.instantiate()
	#enemy.global_position = enemy_spawn.global_position
	#add_child(enemy)
	
	


func _on_proximacena_body_entered(body):
		if body.is_in_group("player"):
			get_tree().change_scene_to_file("res://cenario2.tscn")
			
			print("nada nao man")
