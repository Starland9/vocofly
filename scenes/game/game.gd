extends Node2D


@onready var hud = $GameHUD
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_hud_on_record(value: float):
	player.velocity.y = -value * 20
	player.move_and_slide()
