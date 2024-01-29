extends Node

var current_state: State
var states: Dictionary = {}

@export var initial_state: State

func _ready():
	for c in get_children():
		if c is State:
			states[c.name.to_lower()] = c
			c.Transitioned.connect(on_child_transition)
			if c.name.to_lower() == "PlayerState":
				await c.ready

	if initial_state:
		initial_state.Enter_state()
		current_state = initial_state

func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.Exit_state()
		
	new_state.Enter_state()
	current_state = new_state
