extends SubViewportContainer

var entered = false

func _ready():
	set_process_input(true)

func _input(event):
	if not entered:
		return
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		# Calculate rotation
		var delta = event.relative
		var rotation_speed = 0.5  # Adjust rotation speed as needed
		
		var rotation = Vector3(delta.y, 0, 0) * rotation_speed
		# Determine dominant axis of mouse movement
		if abs(delta.x) > abs(delta.y):
			rotation = Vector3(0, delta.x, 0) * rotation_speed
		# Apply rotation to mesh
		$SubViewport/Humanizer.rotation_degrees += rotation
	elif event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		var movementSpeed = 0.01
		var delta = event.relative
		$SubViewport/Humanizer.position += Vector3(delta.x, -delta.y, 0) * movementSpeed
	elif event is InputEventPanGesture:
		var zoom_speed = 0.01
		var zoom_direction = 0
		if event.delta.y > 0:
			zoom_direction = zoom_speed
		elif event.delta.y < 0:
			zoom_direction = -zoom_speed
		var new_scale = $SubViewport/Humanizer.scale + Vector3(zoom_direction, zoom_direction, zoom_direction)
		new_scale = new_scale.clamp(Vector3.ONE, Vector3.INF)  # Clamp to prevent negative scale
		$SubViewport/Humanizer.scale = new_scale



func _on_mouse_entered():
	entered = true

func _on_mouse_exited():
	entered = false
