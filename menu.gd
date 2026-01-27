extends Node2D

const MAIN_SCENE_PATH = "res://main.tscn"
const GITHUB_REPO_URL = "https://github.com/basic-bitch-foundation/shots_fired"

@onready var play_button = $play
@onready var mute_button = $mute
@onready var github_button = $gh_button

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	github_button.pressed.connect(_on_github_pressed)
	mute_button.pressed.connect(_on_mute_pressed)

func _on_play_pressed():
	SoundManager.click()
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func _on_github_pressed():
	SoundManager.click()
	OS.shell_open(GITHUB_REPO_URL)

func _on_mute_pressed():
	SoundManager.click()
	SoundManager.mute()
