extends Node

const MAX_TEXTURE_SIZE := 2048

var source_size : Vector2
var free_rects : Array[Rect2]
var used_rects : Array[Rect2]

func _ready() -> void:
	const SRC_DIR := "res://test/cast"
	const SRC_TEX := "res://test/player.png"
	
	var textures := DirAccess.get_files_at(SRC_DIR)
	
	source_size = Vector2.ONE * MAX_TEXTURE_SIZE
	free_rects = [Rect2(Vector2(), source_size)]
	used_rects = []
	
	var rect_data : Array[Rect2] = []
	var texture_data : Array[Texture2D] = []
	for t in textures:
		if t.get_extension() != "png":
			continue
		
		var tex := load(SRC_DIR + "/" + t) as Texture2D
		if tex:
			rect_data.append(get_cropped_rect(tex))
			texture_data.append(tex)
	
	var result := pack_rects(rect_data)
	
	var img := Image.create(MAX_TEXTURE_SIZE, MAX_TEXTURE_SIZE, false, Image.FORMAT_RGBA8)
	for i in texture_data.size():
		var t := texture_data[i]
		var r := result[i]
		img.fill_rect(r, Color.RED)
		for x in t.get_width():
			for y in t.get_height():
				img.set_pixel(r.position.x + x, r.position.y + y, t.get_image().get_pixelv(Vector2(x,y)))
	
	var tex := ImageTexture.create_from_image(img)
	
	var s := TextureRect.new()
	add_child(s)
	s.texture = tex

func get_cropped_rect(tex: Texture2D, padding := 0) -> Rect2:
	var img := tex.get_image()
	var bitmap := BitMap.new()
	bitmap.create_from_image_alpha(img)
	
	var min_x := 0
	var min_y := 0
	var max_x := 0
	var max_y := 0
	
	for x in bitmap.get_size().x:
		for y in bitmap.get_size().y:
			if bitmap.get_bit(x, y):
				min_x = x
				break
	
	for y in bitmap.get_size().y:
		for x in bitmap.get_size().x:
			if bitmap.get_bit(x, y):
				min_y = y
				break
	
	for x in range(bitmap.get_size().x - 1, -1, -1):
		for y in bitmap.get_size().y:
			if bitmap.get_bit(x, y):
				max_x = x
				break
	
	for y in range(bitmap.get_size().y - 1, -1, -1):
		for x in bitmap.get_size().x:
			if bitmap.get_bit(x, y):
				max_y = y
				break
	
	prints(tex.get_size(), Vector2(max_x - min_x, max_y - min_y).abs())
	return Rect2(Vector2(), Vector2(max_x - min_x, max_y - min_y).abs())


func pack_rects(rects : Array[Rect2]) -> Array[Rect2]:
	var result : Array[Rect2] = []
	var current_rects := rects.duplicate() as Array[Rect2]
	
	while current_rects.size() > 0:
		var best_score_1 := INF
		var best_score_2 := INF
		var best_index := -1
		var best_rect : Rect2
		
		for i in rects.size():
			var score1 := {value=0}
			var score2 := {value=0}
			var new_rect := score_rect(rects[i].size, score1, score2)
			
			if score1.value < best_score_1 or (score1.value == best_score_1 and score2.value < best_score_2):
				best_score_1 = score1.value
				best_score_2 = score2.value
				best_rect = new_rect
				best_index = i
		
		if best_index == -1:
			return result
		
		var rect := best_rect
		place_rectangle(best_rect)
		current_rects.remove_at(best_index)
		
		rect.position = best_rect.position
		result.append(rect)
	
	return result

func place_rectangle(rect: Rect2) -> void:
	var rects_remaining := free_rects.size()
	var i := 0
	while i < rects_remaining:
		if split_free_rect(free_rects[i], rect):
			free_rects.remove_at(i)
			i -= 1
			rects_remaining -= 1
		
		i += 1
	
	prune_free_list()
	used_rects.append(rect)

func prune_free_list() -> void:
	for i in free_rects.size():
		for j in range(i + 1, free_rects.size()):
			if free_rects[i].intersects(free_rects[j]):
				free_rects.remove_at(i)
				break

func split_free_rect(free_rect: Rect2, used_rect: Rect2) -> bool:
	if !used_rect.intersects(free_rect):
		return false
	
	var new_rect : Rect2
	if used_rect.position.x < free_rect.end.x and used_rect.end.x > free_rect.position.x:
		if used_rect.position.y > free_rect.position.y and used_rect.position.y < free_rect.end.y:
			new_rect = free_rect
			new_rect.size.y = used_rect.position.y - new_rect.position.y
			free_rects.append(new_rect)
		
		if used_rect.position.y + used_rect.size.y < free_rect.position.y + free_rect.size.y:
			new_rect = free_rect
			new_rect.position.y = used_rect.end.y
			new_rect.size.y = free_rect.end.y - (used_rect.end.y)
			free_rects.append(new_rect)
	
	if used_rect.position.y < free_rect.end.y and used_rect.end.y > free_rect.position.y:
		if used_rect.position.x > free_rect.position.x and used_rect.position.x < free_rect.end.x:
			new_rect = free_rect
			new_rect.size.x = used_rect.position.x - new_rect.position.x
			free_rects.append(new_rect)
		
		if used_rect.position.x + used_rect.size.x < free_rect.position.x + free_rect.size.x:
			new_rect = free_rect
			new_rect.position.x = used_rect.end.x
			new_rect.size.x = free_rect.end.x - (used_rect.end.x)
			free_rects.append(new_rect)
	
	return true

func score_rect(size: Vector2, score1: Dictionary, score2: Dictionary) -> Rect2:
	var result := Rect2()
	score1.value = INF
	score2.value = INF
	
	result = find_best_area_fit(size, score1, score2)
	if result.size.y == 0:
		score1.value = INF
		score2.value = INF
	
	return result

func find_best_area_fit(size: Vector2, score_area: Dictionary, score_short_side: Dictionary) -> Rect2:
	var result := Rect2()
	score_area.value = INF
	score_short_side.value = INF
	
	var rect : Rect2
	var leftover_horiz : float
	var leftover_vert : float
	var short_side_fit : float
	var area_fit : float
	
	for i in free_rects.size():
		rect = free_rects[i]
		area_fit = rect.size.x * rect.size.y - size.x * size.y
		
		if rect.size.x >= size.x and rect.size.y >= size.y:
			leftover_horiz = absf(rect.size.x - size.x)
			leftover_vert = absf(rect.size.y - size.y)
			short_side_fit = minf(leftover_horiz, leftover_vert)
			
			if area_fit < score_area.value or (area_fit == score_area.value and short_side_fit < score_short_side.value):
				result.position = rect.position
				result.size = size
				score_area.value = area_fit
				score_short_side.value = short_side_fit
	
	return result
