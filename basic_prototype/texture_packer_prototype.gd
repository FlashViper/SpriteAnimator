extends Node

const DIR := "res://test/variety/"
const AnimationGroup := preload("animation_group.gd")
var debug_rects : Array[AnimationGroup.SpriteFrame] = []
var debug_textures : Array[String]= []

var textures : Array[Texture2D]

func _ready() -> void:
	var dir := DirAccess.open(DIR)
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if filename.ends_with(".png"):
			debug_textures.append(filename)
		filename = dir.get_next()
	dir.list_dir_end()
	
	textures = []
	for t in debug_textures:
		textures.append(load(DIR + t))
	var frames : Array[AnimationGroup.SpriteFrame] = pack(textures)
#	var thing2 := thing.map(func(a: AnimationGroup.SpriteFrame): return a.region)
	
	var rects : Array[Rect2i] = []
	for f in frames:
		rects.append(f.region)
	
	var packed := pack_rects(rects, 15)
	var data : Array[Dictionary] = []
	for i in rects.size():
		data.append({
			"atlas_region": packed.result[i],
			"source_texture": textures[i],
			"source_region": frames[i].region,
			"pivot": frames[i].pivot,
		})
	
	var animation := AnimationGroup.new()
	animation.assemble(data, packed.width, packed.height)
	
#	var packed := await pack_rects(rects, 5) as Array[Rect2i]
#	$RectDrawer.update_rects(packed)
	
#	for i in range(1000, 10000, 100):
#		unit_test(i)
#		await get_tree().process_frame
	
#	$Sprite.textures = textures
#	$Sprite.animation_set = debug_rects


func unit_test(num_rects : int) -> void:
	var rects : Array[Rect2i] = []
	for i in num_rects:
		rects.append(Rect2i(
			Vector2i(),
			Vector2i(randi() % 512, randi() % 512)
		))
	
	var t_i := Time.get_ticks_usec()
	
	pack_rects(rects)
	
	var t_f := Time.get_ticks_usec()
	print("Unit test on %04d rects: %s usec" % [num_rects, t_f - t_i])


func intersection_test(num_rects: int) -> void:
	var rects : Array[Rect2i] = []
	for i in num_rects:
		rects.append(Rect2i(
			Vector2i(),
			Vector2i(randi() % 512, randi() % 512)
		))
	
	pack_rects(rects)
	
	for r in rects:
		for r2 in rects:
			if r.intersects(r2):
				print("Test with %04d rects FAILED" % num_rects)
				return
	
	print("Test with %04d rects SUCCEDED" % num_rects)

func pack(textures : Array[Texture2D]) -> Array[AnimationGroup.SpriteFrame]:
#	var result := {}
	var frames : Array[AnimationGroup.SpriteFrame] = []
	
	# first, crop the textures into their usable rects
	for t in textures:
		var frame := AnimationGroup.SpriteFrame.new()
		frame.region = crop_rect(t)
		frame.pivot = (t.get_size() * 0.5) - Vector2(frame.region.position)
		frames.append(frame)
	
	return frames


func pack_rects(rects: Array[Rect2i], padding := 0) -> Dictionary:
	var remapped : Array[int] = []
	for i in rects.size():
		remapped.append(i)
	var result : Array[Rect2i] = rects.duplicate()
	var availible_points : Array[Vector2i] = [Vector2i.ZERO]
	var max_x := 0
	var max_y := 0
	
	# sort in order of ascending area
	remapped.sort_custom(func(a: int, b: int): return rects[a].get_area() < rects[b].get_area())
	
	for i in remapped.size():
		var index := remapped.pop_back()
		var rect : Rect2i = rects[index] # get the rect with the next most area
		var placed_rect := Rect2i(Vector2i(), rect.size)
		var min_area := INF
		var min_ratio := INF
		var min_dist_to_home := INF
		var min_index := -1
		
		for n in availible_points.size():
			var a := availible_points[n]
			var new_max_x := maxi(max_x, a.x + rect.size.x)
			var new_max_y := maxi(max_y, a.y + rect.size.y)
			var area := Vector2(new_max_x, new_max_y).length_squared()
#			var area := absf(1 - (float(new_max_x) / new_max_y))
#			var area := absf(1 - (float(new_max_x) / new_max_y))
#			prints(a, area)
			
			if area < min_area:
				var overlaps := false
				for r in result:
					if r.intersects(Rect2i(a, rect.size)):
						overlaps = true
						break
				
				if overlaps:
					continue
				
				placed_rect.position = a
				min_area = area
				min_index = n
#				prints("GOING WITH:", area)
#		print(placed_rect.position)
#		print("")
		max_x = maxi(max_x, placed_rect.end.x)
		max_y = maxi(max_y, placed_rect.end.y)
		
		# do I even need this? probably?
		# turn on if you ever see problems with this script
		var expanded := placed_rect.grow(padding)
		for ii in range(availible_points.size(), 0, -1):
			if expanded.has_point(availible_points[ii - 1]):
				availible_points.remove_at(ii - 1)
		availible_points.shuffle()
		
		availible_points.append(placed_rect.end + Vector2i.ONE * padding)
		availible_points.append(Vector2i(placed_rect.position.x, placed_rect.end.y) + Vector2i(0, padding))
		availible_points.append(Vector2i(placed_rect.end.x, placed_rect.position.y) + Vector2i(padding, 0))
#		availible_points.append(Vector2i(max_x, max_y))
		
		result[index] = placed_rect
#		result.append(placed_rect)
#		$RectDrawer.update_rects(result)
#		$RectDrawer.update_vertices(availible_points)
#		await $Button.pressed
	
	return {
		"result": result,
		"width": max_x,
		"height": max_y,
	}


func crop_rect(texture: Texture2D, alpha_threshold := 0.2, padding := 0) -> Rect2i:
	var result := Rect2i(Vector2i(), texture.get_size())
	var img := texture.get_image()
	
	for x in texture.get_width():
		var texture_starts := false
		for y in texture.get_height():
			if img.get_pixel(x, y).a > alpha_threshold:
				texture_starts = true
				break
		if texture_starts:
			result.position.x = x - padding
			result.size.x -= x
			break
	
	for x in range(texture.get_width() - 1, -1, -1):
		var texture_starts := false
		for y in range(texture.get_height() - 1, -1, -1):
			if img.get_pixel(x, y).a > alpha_threshold:
				texture_starts = true
				break
		if texture_starts:
			result.size.x = x - result.position.x
			break
	
	for y in texture.get_height():
		var texture_starts := false
		for x in texture.get_width():
			if img.get_pixel(x, y).a > alpha_threshold:
				texture_starts = true
				break
		if texture_starts:
			result.position.y = y - padding
			result.size.y -= y
			break
	
	for y in range(texture.get_height() - 1, -1, -1):
		var texture_starts := false
		for x in range(texture.get_width() - 1, -1, -1):
			if img.get_pixel(x, y).a > alpha_threshold:
				texture_starts = true
				break
		if texture_starts:
			result.size.y = y - result.position.y
			break
	
	return result
