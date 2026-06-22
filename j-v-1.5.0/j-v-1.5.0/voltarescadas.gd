extends Area2D

@onready var destino: Marker2D = $corredorbaixo

var camera: Camera2D
var can_tp := true


func get_camera() -> Camera2D:
	return get_tree().get_first_node_in_group("camera")


func _on_body_entered(body: Node2D) -> void:
	
	if body.is_in_group("player") and can_tp and destino:
		
		camera = get_camera()
		
		print(camera)
		
		if camera:
			if camera.has_method("camera_normal"):
				camera.camera_normal()
		
		can_tp = false
		
		body.global_position = destino.global_position
		
		await get_tree().create_timer(0.5).timeout
		
		can_tp = true
