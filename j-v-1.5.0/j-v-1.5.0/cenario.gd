extends Node2D

const ENEMY := preload("res://jubis.tscn")

@onready var enemy_spawn: Node2D = $EnemySpawn


func _ready():
	#_spawn_enemy()
	pass


#func _spawn_enemy():
	#var enemy := ENEMY.instantiate()
	#add_child(enemy)
	#enemy.global_position = enemy_spawn.global_position
