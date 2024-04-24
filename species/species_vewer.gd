extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready():
	var character = preload("res://character/character.tscn").instantiate()
	add_child(character)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
