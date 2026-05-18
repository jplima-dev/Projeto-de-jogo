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
	player.global_position = player_spawn.global_position
	
	
#func _spawn_enemy():
	#var enemy := ENEMY.instantiate()
	#add_child(enemy)
	#enemy.global_position = enemy_spawn.global_position
