extends Node2D

@onready var animation_player = $OpeningScene/AnimationPlayer
@onready var camera = $OpeningScene/Path2D/PathFollow2D/Camera2D

var is_opening_cutscene = false
var has_player_entered = false
var player = null
var is_path_following = false
var has_smoke_happened = false
var is_smoke_happening = false

func _physics_process(_delta):

	if is_opening_cutscene:

		var path_follower = $OpeningScene/Path2D/PathFollow2D

		if is_path_following:

			if !is_smoke_happening:
				path_follower.progress_ratio += 0.001

			if path_follower.progress_ratio >= 1.0:
				end_opening_cutscene()

			if !has_smoke_happened and path_follower.progress_ratio >= 0.78 and !is_smoke_happening:
				is_smoke_happening = true
				toggle_smoke()
				await get_tree().create_timer(1).timeout
				$OpeningScene/TileMapFinished.visible = true
				$OpeningScene/TileMapUnfinished.visible = false
				toggle_smoke()
				await get_tree().create_timer(0.5).timeout
				has_smoke_happened = true
				is_smoke_happening = false

func _on_player_detection_body_entered(body):
	if !has_player_entered:
		has_player_entered = true
		player = body
		start_opening_cutscene()

func start_opening_cutscene():
	is_opening_cutscene = true
	player.set_physics_process (false)
	animation_player.play("cover_fade")
	player.camera.enabled = false
	camera.enabled = true
	is_path_following = true

func end_opening_cutscene():
	is_path_following = false
	is_opening_cutscene = false
	camera.enabled = false
	player.camera.enabled = true
	player.set_physics_process (true)
	$OpeningScene.visible = false
	$Main.visible = true

func toggle_smoke():
	for smoke in $OpeningScene/Smoke.get_children():
		smoke.emitting = !smoke.emitting
