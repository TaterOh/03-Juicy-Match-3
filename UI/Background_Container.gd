extends Node2D

var score_threshold = 25
var b = 0
var backgrounds = [
	preload("res://Assets/backgroundColorForest.png"),
	preload("res://Assets/backgroundColorGrass.png"),
	preload("res://Assets/backgroundColorFall.png"),
	preload("res://Assets/backgroundColorDesert.png"),
	preload("res://Assets/backgroundCastles.png")
]

var tran = false
var t_value = 0.0
var t_step = 0.01

func _ready():
	pass

func _physics_process(_delta):
	if tran:
		t_value -= t_step
		$Background.get_material().set_shader_param("dissolve_value", t_value)
		if t_value <= 0:
			$Background.texture = backgrounds[b % backgrounds.size()]
			$Background.get_material().set_shader_param("dissolve_value", 1.0)
			$B2.queue_free()
			b += 1
			t_value = 1.0
			tran = false
	elif Global.score > score_threshold*(b+1):
		var B2 = Sprite.new()
		B2.centered = false
		B2.texture = backgrounds[b % backgrounds.size()]
		B2.name = "B2"
		add_child(B2)
		move_child(B2, 0)
		tran = true
