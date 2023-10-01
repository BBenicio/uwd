class_name Player
extends CharacterBody3D

signal hit

enum Players { PLAYER_1, PLAYER_2, CPU }
enum Difficulty { NORMAL, HARD }

@export var player: Players
@export_range(0, 5) var movement_speed = 1.5
@export_range(1, 3) var jump_force = 2
@export_range(0, 0.4) var jab_hit_time = 0.1
@export_range(0, 1) var cross_hit_time = 0.2
@export_range(0, 1) var kick_hit_time = 0.3

@export var cpu_difficulty = Difficulty.NORMAL
@export_range(0, 1) var cpu_aggressiveness = 0

var fighting = false
var lost = false

var moving = false
var striking = false
var blocking = false
var dodging = false

var animation_tree: AnimationTree

var last_action: String = 'nothing'
var opponent: Player
var opponent_stiking = false

func reset():
	$CollisionShape.shape.size.y = 1.3
	position.y = 1.3 / 2.0
	lost = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree = $AnimationTree
	opponent = get_parent().find_child('Player', false)
	paint_character()

func paint_character():
	var mesh_instance = $character/Armature/Skeleton3D/Character
	var skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = Color.from_hsv(randf_range(0.05, 0.1), randf_range(0.15, 0.5), randf_range(0.2, 1))
	mesh_instance.set_surface_override_material(0, skin_material)
	var shorts_material = StandardMaterial3D.new()
	shorts_material.albedo_color = Color.from_hsv(randf_range(0, 1), randf_range(0.5, 1), randf_range(0.1, 0.7))
	mesh_instance.set_surface_override_material(1, shorts_material)
	var shirt_material = StandardMaterial3D.new()
	shirt_material.albedo_color = Color.from_hsv(randf_range(0, 1), randf_range(0, 1), randf_range(0.3, 1))
	mesh_instance.set_surface_override_material(4, shirt_material)
	var hair_material = StandardMaterial3D.new()
	hair_material.albedo_color = Color.from_hsv(randf_range(0, 1), randf_range(0, 0.4), randf_range(0.1, 0.8))
	mesh_instance.set_surface_override_material(5, hair_material)

func player_process(_delta):
	if not is_on_floor():
		return
	
	if not striking and Input.is_action_pressed('forward'):
		forward()
	elif not striking and Input.is_action_pressed('backward'):
		backward()
	else:
		no_move()
	
	if not striking and not dodging and Input.is_action_pressed('dodge'):
		dodge()
	
	if not moving and not striking and not dodging and Input.is_action_pressed('block'):
		block()
	else:
		no_block()
	
	if not striking and not moving and not blocking and not dodging and Input.is_action_pressed('jab'):
		jab()
	if not striking and not moving and not blocking and not dodging and Input.is_action_pressed('cross'):
		cross()
	if not striking and not moving and not blocking and not dodging and Input.is_action_pressed('kick'):
		kick()
	
	if not striking and not blocking and not dodging and Input.is_action_pressed('jump'):
		jump()

func player2_process(_delta):
	if not is_on_floor():
		return
	
	if not striking and Input.is_action_pressed('forward2'):
		forward()
	elif not striking and Input.is_action_pressed('backward2'):
		backward()
	else:
		no_move()
	
	if not striking and not dodging and Input.is_action_pressed('dodge2'):
		dodge()
	
	if not moving and not striking and not dodging and Input.is_action_pressed('block2'):
		block()
	else:
		no_block()
	
	if not striking and not moving and not blocking and not dodging and Input.is_action_pressed('jab2'):
		jab()
	if not striking and not moving and not blocking and not dodging and Input.is_action_pressed('cross2'):
		cross()
	if not striking and not moving and not blocking and not dodging and Input.is_action_pressed('kick2'):
		kick()
	
	if not striking and not blocking and not dodging and Input.is_action_pressed('jump2'):
		jump()

func forward():
	moving = true
	velocity.z = movement_speed
	if player != Players.PLAYER_1:
		velocity.z = -velocity.z
	animation_tree['parameters/MovementBlend/blend_amount'] = lerp(animation_tree['parameters/BlockBlend/blend_amount'], 1.0, 0.8)

func backward():
	moving = true
	velocity.z = -movement_speed
	if player != Players.PLAYER_1:
		velocity.z = -velocity.z
	animation_tree['parameters/MovementBlend/blend_amount'] = lerp(animation_tree['parameters/BlockBlend/blend_amount'], -1.0, 0.8)

func no_move():
	velocity.z = 0
	moving = false
	animation_tree['parameters/MovementBlend/blend_amount'] = lerp(animation_tree['parameters/BlockBlend/blend_amount'], 0.0, 0.8)

func block():
	if not blocking:
		$CollisionShape.position.y -= 0.15
		$CollisionShape.shape.size.y -= 0.3
	blocking = true
	animation_tree['parameters/BlockBlend/blend_amount'] = lerp(animation_tree['parameters/BlockBlend/blend_amount'], 1.0, 0.5)

func no_block():
	if blocking:
		$CollisionShape.position.y += 0.15
		$CollisionShape.shape.size.y += 0.3
	blocking = false
	animation_tree['parameters/BlockBlend/blend_amount'] = lerp(animation_tree['parameters/BlockBlend/blend_amount'], 0.0, 0.8)

func jab():
	$JabRayCast.enabled = true
	striking = true
	$JabTimer.start()
	animation_tree['parameters/JabOneShot/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func cross():
	$CrossRayCast.enabled = true
	striking = true
	$CrossTimer.start()
	animation_tree['parameters/CrossOneShot/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func kick():
	$KickRayCast.enabled = true
	striking = true
	$KickTimer.start()
	animation_tree['parameters/KickOneShot/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func dodge():
	dodging = true
	$CollisionShape.position.y -= 0.15
	$CollisionShape.shape.size.y -= 0.3
	$DodgeTimer.start()
	animation_tree['parameters/DodgeOneShot/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func jump():
	velocity.y = jump_force
	animation_tree['parameters/JumpOneShot/request'] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func simple():
	var choices = ['forward', 'backward', 'block', 'jab', 'cross', 'kick', 'dodge', 'jump', 'nothing']
	var action
	if $CPUActionTimer.time_left > 0:
		action = last_action
	else:
		$CPUActionTimer.start()
		if randf() < 0.2:
			action = last_action
		else:
			action = choices.pick_random()
	
	return action

func hard():
	var distance = position.distance_to(opponent.position)
	if distance > max(1 * (1 - cpu_aggressiveness), 0.3):
		return 'forward'
	if distance < max(0.5 * (1 - cpu_aggressiveness), 0.2):
		return 'backward'
	
	if last_action == 'block' and opponent.striking:
		return 'block'
	
	if opponent.striking and not opponent_stiking and randf() < 0.4:
		return ['block', 'dodge', 'jump'].pick_random()
	
	opponent_stiking = opponent.striking
	
	if randf() < cpu_aggressiveness:
		return ['jab', 'cross', 'kick'].pick_random()
		
	return 'nothing'

func choose_action():
	if cpu_difficulty == Difficulty.NORMAL:
		return simple()
	elif cpu_difficulty == Difficulty.HARD:
		return hard()

func cpu_process():
	if not is_on_floor():
		return
	
	var action = choose_action()
	
	last_action = action
	
	if not striking and action == 'forward':
		forward()
	elif not striking and action == 'backward':
		backward()
	else:
		no_move()
	
	if not moving and not striking and not dodging and action == 'block':
		block()
	else:
		no_block()
	
	if not striking and not moving and not blocking and not dodging and action == 'jab':
		jab()
	if not striking and not moving and not blocking and not dodging and action == 'cross':
		cross()
	if not striking and not moving and not blocking and not dodging and action == 'kick':
		kick()
	if not striking and not dodging and action == 'dodge':
		dodge()
	if not striking and not blocking and not dodging and action == 'jump':
		jump()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= 8 * delta
	
	if fighting and not lost:
		if player == Players.PLAYER_1:
			player_process(delta)
		elif player == Players.PLAYER_2:
			player2_process(delta)
		elif player == Players.CPU:
			cpu_process()
	else:
		no_move()
		no_block()
	
	move_and_slide()
	
	if $JabRayCast.is_colliding() and $JabTimer.time_left >= $JabTimer.wait_time - 2 * jab_hit_time and $JabTimer.time_left <= $JabTimer.wait_time - jab_hit_time:
		if ($JabRayCast.get_collider() as Node).is_in_group('fighters'):
			hit.emit()
		$JabRayCast.enabled = false
	elif $CrossRayCast.is_colliding() and $CrossTimer.time_left >= $CrossTimer.wait_time - 2 * cross_hit_time and $CrossTimer.time_left <= $CrossTimer.wait_time - cross_hit_time:
		if ($CrossRayCast.get_collider() as Node).is_in_group('fighters'):
			hit.emit()
		$CrossRayCast.enabled = false
	elif $KickRayCast.is_colliding() and $KickTimer.time_left >= $KickTimer.wait_time - 2 * kick_hit_time and $KickTimer.time_left <= $KickTimer.wait_time - kick_hit_time:
		if ($KickRayCast.get_collider() as Node).is_in_group('fighters'):
			hit.emit()
		$KickRayCast.enabled = false

func _on_jab_timer_timeout():
	striking = false
	$JabRayCast.enabled = false

func _on_cross_timer_timeout():
	striking = false
	$CrossRayCast.enabled = false

func _on_kick_timer_timeout():
	striking = false
	$KickRayCast.enabled = false

func _on_dodge_timer_timeout():
	$CollisionShape.position.y += 0.15
	$CollisionShape.shape.size.y += 0.3
	dodging = false
