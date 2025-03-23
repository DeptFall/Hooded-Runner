extends Node

var rock1 = preload("res://Endless Runner Game Files/Scenes/rock_1.tscn")
var rock2 = preload("res://Endless Runner Game Files/Scenes/rock_2.tscn")
var rock3 = preload("res://Endless Runner Game Files/Scenes/rock_3.tscn")
var rocket = preload("res://Endless Runner Game Files/Scenes/rocket_1.tscn")
var obstacle_types := [rock1, rock2, rock3]
var obstacles : Array
var rocket_heights := [250, 485]

const HOODED_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2

var speed : float
var score : int
const SCORE_MODIFIER : int = 10
const START_SPEED : float = 9.0
const MAX_SPEED : int = 13
const SPEED_MODIFIER : int = 5000
var high_score : int
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	
func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Hooded.position = HOODED_START_POS
	$Hooded.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,0)
	
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()
	
func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = rocket.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = rocket_heights[randi() % rocket_heights.size()]
				add_obs(obs, obs_x, obs_y)
	
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Hooded":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score 
		$HUD.get_node("HighScoreLabel").text = "HIGHSCORE: " + str(high_score / SCORE_MODIFIER)

func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		
		generate_obs()
		
		$Hooded.position.x += speed
		$Camera2D.position.x +=  speed
		
		score += speed
		show_score()
	
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
		if Input.is_action_pressed("ui_up"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
		
	
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x
		
	for obs in obstacles:
		if obs.position.x < ($Camera2D.position.x - screen_size.x):
			remove_obs(obs)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
