extends Node

var muted = false

var players = {}
var sounds = {
	"click": "res://sound/click.wav",
	"load": "res://sound/load.mp3",
	"shot": "res://sound/shot.mp3",
	"coin": "res://sound/coin.wav",
	"over": "res://sound/over.wav"
}

func mute():
	muted = !muted
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)

func coin():
	if not muted:
		players["coin"].play()

func _ready():
	for key in sounds.keys():
		var p = AudioStreamPlayer.new()
		p.stream = load(sounds[key])
		add_child(p)
		players[key] = p

func click():
	if not muted:
		players["click"].play()

func firstshot():
	if not muted:
		players["load"].play()
		await players["load"].finished
		players["shot"].play()

func over():
	if not muted:
		players["over"].play()

func shot():
	if not muted:
		players["shot"].play()
	
