extends Resource
class_name ParticleData

# =========================
# Aparência
# =========================

@export var texture: Texture2D

@export var start_color: Color = Color.WHITE
@export var end_color: Color = Color(1,1,1,0)

@export var start_scale := 1.0
@export var end_scale := 0.0

@export var rotation_speed := 0.0

# =========================
# Vida
# =========================

@export var lifetime := 0.5

# =========================
# Movimento
# =========================

@export var speed := 300.0
@export var gravity := 0.0
@export var spread := 20.0

# =========================
# Emissão
# =========================

@export var amount := 10
@export var spawn_interval := 0.08
@export var spawn_randomness := 2.0

# =========================
# Posição inicial
# =========================

@export var offset_right := Vector2.ZERO
@export var offset_left := Vector2.ZERO
@export var offset_up := Vector2.ZERO
@export var offset_down := Vector2.ZERO

@export var direction_randomness := 0.0
