extends Node3D

const OUT := "C:/Users/marth/AppData/Local/Temp/claude/C--Users-marth-Documents-astria-mmo/2ad9a570-eb21-4fe6-9c63-2ade67980637/scratchpad/"

var player: Node3D
var ap: AnimationPlayer
var cam: Camera3D

func _ready() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.18, 0.19, 0.22)
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color(0.55, 0.57, 0.62)
	e.ambient_light_energy = 0.7
	env.environment = e
	add_child(env)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, 35, 0)
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	add_child(sun)

	player = (load("res://game/player/player.tscn") as PackedScene).instantiate()
	player.set_script(null)
	add_child(player)
	if player.has_node("Scripts"):
		player.get_node("Scripts").queue_free()
	ap = player.get_node("AnimationPlayer")

	cam = Camera3D.new()
	cam.fov = 34
	add_child(cam)
	cam.make_current()

	await get_tree().process_frame
	call_deferred("shoot")

func place(angle_deg: float) -> void:
	var r := deg_to_rad(angle_deg)
	cam.position = Vector3(sin(r) * 4.4, 0.15, cos(r) * 4.4)
	cam.look_at(Vector3(0, 0.05, 0), Vector3.UP)

func grab() -> Image:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()

func sheet(name: String, frames: Array) -> void:
	var out: Image = null
	for i in frames.size():
		var img: Image = frames[i]
		if out == null:
			out = Image.create(img.get_width() * frames.size(), img.get_height(), false, img.get_format())
		out.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(img.get_width() * i, 0))
	out.save_png(OUT + "sheet_%s.png" % name)
	print("wrote sheet_%s.png" % name)

func shoot() -> void:
	# the rest pose from four angles: front, 3/4, side, back
	ap.play("RESET")
	ap.seek(0.0, true)
	var views: Array = []
	for ang in [180.0, 135.0, 90.0, 0.0]:
		place(ang)
		views.append(await grab())
	sheet("REST", views)

	for job in [["WalkF", 90.0], ["WalkB", 90.0], ["WalkR", 180.0]]:
		var a := ap.get_animation(job[0])
		place(job[1])
		var frames: Array = []
		for i in 4:
			ap.play(job[0])
			ap.seek(a.length * float(i) / 4.0, true)
			frames.append(await grab())
		sheet(str(job[0]), frames)
	get_tree().quit()
