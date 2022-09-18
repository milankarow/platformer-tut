extends Area2D

export(String, FILE, "*.tscn") var target_level_path = ""


func _on_Door_body_entered(body):
	if not body is Player: return
	if target_level_path.empty(): return
	Transitions.play_exit_transition()
	yield(Transitions, "transition_completed")
	Transitions.play_enter_transition()
	get_tree().change_scene(target_level_path)
