extends Node
# regular volume of main theme
var norm_vol = -1.5
# amount we decrease by in fade_down() in percentage (converted to decimals)
var percDecreaseBy = 0.2
var twene
var audio_bus = AudioServer.get_bus_index("main_theme")
@onready var low_vol = norm_vol + norm_vol * percDecreaseBy

func _ready():
	tweens_are_strange(norm_vol)

func fade_down():
	if AudioServer.get_bus_volume_db(audio_bus) != norm_vol:
		return
	if twene:
		await twene.finished
	twene = create_tween()
	twene.tween_method(tweens_are_strange, norm_vol, low_vol, 0.2)
	tweens_are_strange(low_vol)

func fade_up():
	if AudioServer.get_bus_volume_db(audio_bus) == norm_vol:
		return
	if twene:
		await twene.finished
	twene = create_tween()
	twene.tween_method(tweens_are_strange, low_vol, norm_vol, 0.2)
	tweens_are_strange(norm_vol)

func tweens_are_strange(vol):
	AudioServer.set_bus_volume_db(audio_bus, vol)
	#print(AudioServer.get_bus_volume_db(audio_bus))
