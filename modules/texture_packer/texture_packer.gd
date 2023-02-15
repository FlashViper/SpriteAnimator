extends RefCounted

const SpriteFrame := AnimationGroup.SpriteFrame


func pack_textures(textures: Array[Texture2D]) -> Dictionary:
	if textures == null:
		printerr("Tried to pass a null array to pack_textures in texture_packer.gd")
		return {}
	
	var frames : Array[SpriteFrame] = crop_to_frame(textures)
	
	var rects : Array[Rect2i] = []
	for f in frames:
		rects.append(f.region)
	
	var packed := pack_rects(rects, 15)
	var data : Array[Dictionary] = []
	
	for i in frames.size():
		data.append({
			"atlas_region": packed.result[i],
			"source_texture": textures[i],
			"source_region": frames[i].region,
			"pivot": frames[i].pivot,
		})
		
		frames[i].region = packed.result[i]
	
	var tex := assemble_texture(data, packed.width, packed.height)
	
	return {
		"frames": frames,
		"texture": tex
	}


func crop_to_frame(textures : Array[Texture2D]) -> Array[SpriteFrame]:
	var frames : Array[SpriteFrame] = []
	
	# first, crop the textures into their usable rects
	for t in textures:
		var frame := SpriteFrame.new()
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


func assemble_texture(data: Array[Dictionary], width: int, height: int) -> Texture2D:
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	for d in data:
		var source := d.source_texture as Texture2D
		var source_region := d.source_region as Rect2i
		var atlas_region := d.atlas_region as Rect2i
		var pivot := d.pivot as Vector2
		
		var frame := SpriteFrame.new()
		frame.region = atlas_region
		frame.pivot = pivot
		
		img.blit_rect(source.get_image(), source_region, atlas_region.position)
	

	var tex := ImageTexture.new()
	tex.set_image(img)
	return tex
