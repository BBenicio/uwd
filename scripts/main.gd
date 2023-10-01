extends Node3D

@export var wall_scene: PackedScene
@export_range(5, 50) var ring_size = 20
@export_range(1, 10) var rounds = 3

enum GameMode { CAMPAIGN, VS_CPU, VS_PLAYER }

var campaign_fight = 0
var campaign_lost = false

var walls = []
var until_fight = 4
var gamemode = GameMode.VS_CPU

var paused = false

var audio = true

# Called when the node enters the scene tree for the first time.
func _ready():
	var w = wall_scene.instantiate() as RigidBody3D
	w.position = Vector3(0, 0, ring_size / 2.0 + 0.5)
	w.body_entered.connect(_on_wall_body_entered)
	add_child(w)
	w = wall_scene.instantiate() as RigidBody3D
	w.position = Vector3(0, 0, -ring_size / 2.0 - 0.5)
	w.body_entered.connect(_on_wall_body_entered)
	add_child(w)
	$Stadium/RingWall.scale.z = ring_size + 1
	
	for i in ring_size:
		w = wall_scene.instantiate()
		w.name = 'DroppableWall_{0}'.format([i])
		w.position = Vector3(0, 5, -ring_size / 2.0 - 0.5 + (i+1))
		w.body_entered.connect(_on_wall_body_entered)
		add_child(w)

func new_fight():
	$HUD.total_rounds = rounds
	$HUD.current_round = 0
	
	$Stadium/Scoreboard.left_wins = 0
	$Stadium/Scoreboard.right_wins = 0
	
	new_round()

func new_round():
	$HUD.current_round += 1
	$HUD.winner = null
	
	$Player.position.z = -2.5
	$CPU.position.z = 2.5
	
	$Player.fighting = false
	$CPU.fighting = false
	
	$Player.reset()
	$CPU.reset()
	
	until_fight = 4
	$FightTimer.start()
	
	walls.clear()
	for w in find_children('*DroppableWall*', '', false, false):
		w.position.y = 5
		w.freeze = true
		walls.append(w)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('pause') and until_fight <= 0 and campaign_fight <= 5:
		paused = not paused
		$HUD/PausePanel.visible = paused
		$Player.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
		$CPU.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
		for w in find_children('*DroppableWall*', '', false, false):
			if w.position.y < 4.9:
				w.freeze = paused
	
	$CameraAnchor.position.z = move_toward($CameraAnchor.position.z, ($Player.position.z + $CPU.position.z) / 2.0, delta)
	$CameraAnchor/Camera3D.position.z = max(5, abs($CPU.position.z - $Player.position.z) / 2.0 * tan(PI / 4))

func _on_player_hit():
	print('Player landed a punch!')
	if audio:
		$Player/HitPlayer.play()
	if not walls.is_empty():
		walls.pop_back().freeze = false

func _on_cpu_hit():
	print('CPU landed a punch!')
	if audio:
		$CPU/HitPlayer.play()
	if not walls.is_empty():
		walls.pop_front().freeze = false

func _on_wall_body_entered(body):
	if $CPU.lost or $Player.lost:
		return
	
	if body.name == 'CPU':
		if audio:
			$WinStream.play()
		print('CPU lost!')
		$HUD.winner = 'Player 1'
		$Stadium/Scoreboard.left_wins += 1
		$CPU.lost = true
		$Player.fighting = false
		$CPU/CollisionShape.shape.size.y = 0.01
		$EndTimer.start()
	elif body.name == 'Player':
		print('Player lost!')
		if audio:
			if gamemode == GameMode.VS_CPU:
				$LoseStream.play()
			else:
				$WinStream.play()
		$HUD.winner = 'Player 2' if gamemode == GameMode.VS_PLAYER else 'CPU'
		$Stadium/Scoreboard.right_wins += 1
		$Player.lost = true
		$CPU.fighting = false
		$Player/CollisionShape.shape.size.y = 0.01
		$EndTimer.start()
	

func _on_main_menu_vs_cpu():
	$CameraAnchor/AnimationPlayer.play("begin")
	$MainMenu.visible = false
	gamemode = GameMode.VS_CPU
	$CPU.cpu_difficulty = Player.Difficulty.HARD
	$CPU.cpu_aggressiveness = randf_range(0, 1)
	new_fight()

func _on_fight_timer_timeout():
	until_fight -= 1
	if until_fight >= 0:
		$FightTimer.start()
	else:
		$Player.fighting = true
		$CPU.fighting = true
	$HUD.fight_countdown = until_fight


func _on_end_timer_timeout():
	if $HUD.current_round < rounds and $Stadium/Scoreboard.left_wins <= rounds / 2 and $Stadium/Scoreboard.right_wins <= rounds / 2:
		new_round()
	else:
		if gamemode == GameMode.CAMPAIGN:
			if $Stadium/Scoreboard.left_wins < $Stadium/Scoreboard.right_wins:
				print('Player lost')
				campaign_lost = true
			else:
				campaign_fight += 1
			
			$Stadium/Scoreboard.left_wins = 0
			$Stadium/Scoreboard.right_wins = 0
			$HUD.current_round = 0
			
			$HUD.winner = null
			$HUD/PausePanel.visible = false
			paused = false
	
			$Player.position.z = -2.5
			$CPU.position.z = 2.5
			
			$Player.fighting = false
			$CPU.fighting = false
			
			$Player.reset()
			$CPU.reset()
			for w in find_children('*DroppableWall*', '', false, false):
				w.position.y = 5
				w.freeze = true
			
			if campaign_fight <= 5 and not campaign_lost:
				$CPU.cpu_aggressiveness = campaign_fight / 5.0
				$CPU.paint_character()
				$HUD/PausePanel.visible = true
				$HUD/PausePanel/CampaignControl.visible = true
				if campaign_fight < 5:
					$HUD/PausePanel/CampaignControl/CampaignRemainingLabel.text = '{0} fights until you are the UWD'.format([5 - campaign_fight])
				else:
					$HUD/PausePanel/CampaignControl/CampaignRemainingLabel.text = 'Ultimate Wall Dropper Final!'
				$HUD/PausePanel/PauseLabel.visible = false
				paused = true
			elif campaign_fight > 5:
				$HUD/PausePanel.visible = true
				$HUD/PausePanel/ChampionLabel.visible = true
				$HUD/PausePanel/CampaignControl.visible = false
				$HUD/PausePanel/PauseLabel.visible = false
				paused = true
			else:
				$CameraAnchor/AnimationPlayer.play_backwards('begin')
				$MainMenu.visible = true
		else:
			$Stadium/Scoreboard.left_wins = 0
			$Stadium/Scoreboard.right_wins = 0
			$HUD.current_round = 0
			
			$HUD.winner = null
			$HUD/PausePanel.visible = false
			paused = false
	
			$Player.position.z = -2.5
			$CPU.position.z = 2.5
			
			$Player.fighting = false
			$CPU.fighting = false
			
			$Player.reset()
			$CPU.reset()
			for w in find_children('*DroppableWall*', '', false, false):
				w.position.y = 5
				w.freeze = true
			
			$CameraAnchor/AnimationPlayer.play_backwards('begin')
			$MainMenu.visible = true


func _on_hud_main_menu():
	$CameraAnchor/AnimationPlayer.play_backwards('begin')
	$Stadium/Scoreboard.left_wins = 0
	$Stadium/Scoreboard.right_wins = 0
	$HUD.current_round = 0
	
	$HUD.winner = null
	$HUD/PausePanel.visible = false
	paused = false
	
	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	$CPU.process_mode = Node.PROCESS_MODE_INHERIT
	
	$Player.position.z = -2.5
	$CPU.position.z = 2.5
	
	$Player.fighting = false
	$CPU.fighting = false
	
	$Player.reset()
	$CPU.reset()
	for w in find_children('*DroppableWall*', '', false, false):
		w.position.y = 5
		w.freeze = true
		
	$HUD/PausePanel/ChampionLabel.visible = false
	$HUD/PausePanel/PauseLabel.visible = true
	$MainMenu.visible = true

func _on_main_menu_campaign():
	$CameraAnchor/AnimationPlayer.play("begin")
	$MainMenu.visible = false
	gamemode = GameMode.CAMPAIGN
	campaign_fight = 1
	campaign_lost = false
	$CPU.cpu_difficulty = Player.Difficulty.HARD
	$CPU.cpu_aggressiveness = campaign_fight / 5.0
	new_fight()

func _on_main_menu_vs_player():
	$CameraAnchor/AnimationPlayer.play("begin")
	$MainMenu.visible = false
	gamemode = GameMode.VS_PLAYER
	$CPU.player = Player.Players.PLAYER_2
	new_fight()

func _on_hud_next_fight():
	new_fight()
	$HUD/PausePanel.visible = false
	$HUD/PausePanel/CampaignControl.visible = false
	$HUD/PausePanel/PauseLabel.visible = true


func _on_main_menu_mute_music(muted):
	if muted:
		$BackgroundMusic.stop()
	else:
		$BackgroundMusic.play()

func _on_main_menu_mute_audio(muted):
	audio = not muted
