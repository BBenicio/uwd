extends Node3D

@export var person_scene: PackedScene
@export_range(0, 1) var occupancy = 0.75
@export_color_no_alpha var skin_color = Color.BISQUE

# Called when the node enters the scene tree for the first time.
func _ready():
	section(Vector3(-5, 0, 5))
	section(Vector3(1, 0, 5))
	section(Vector3(-5, 1, -0.5))
	section(Vector3(1, 1, -0.5))

func section(base: Vector3):
	var animations = ['Cheer1', 'Cheer2', 'Cheer3']
	var curr_base = Vector3(base)
	curr_base.z += 0.5
	for i in 4:
		curr_base.x = base.x - 0.5
		curr_base.z -= 1
		curr_base.y += 0.2
		for j in 4:
			curr_base.x += 1
			if randf() < occupancy:
				var p = person_scene.instantiate()
				var animation_player = p.find_child('*Animation*', false) as AnimationPlayer
				var anim = animations.pick_random()
				animation_player.get_animation(anim).loop_mode = Animation.LOOP_LINEAR if randf() < 0.6 else Animation.LOOP_PINGPONG
				animation_player.autoplay = anim
				paint_character(p.find_child('Character', true))
				
				add_child(p)
				p.position = curr_base + Vector3(randf_range(-0.2, 0.2), 0, randf_range(-0.2, 0.2))
				p.scale *= randfn(1, 0.1)

func paint_character(mesh_instance: MeshInstance3D):
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
