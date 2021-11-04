extends AnimationPlayer

func _ready():
	play("flicker")

func _on_AnimationPlayer_animation_finished(anim_name):
	play("flicker")
	pass # Replace with function body.
