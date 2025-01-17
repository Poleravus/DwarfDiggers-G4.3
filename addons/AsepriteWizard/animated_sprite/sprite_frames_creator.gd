@tool
extends RefCounted

var result_code = preload("../config/result_codes.gd")
var _aseprite = preload("../aseprite/aseprite.gd").new()

enum {
	FILE_EXPORT_MODE,
	LAYERS_EXPORT_MODE
}

var _config
var _file_system: EditorFileSystem


func init(config, editor_file_system: EditorFileSystem = null):
	_config = config
	_file_system = editor_file_system
	_aseprite.init(config)


func _initial_checks(source: String, options: Dictionary) -> int:
	if not _aseprite.test_command():
		return result_code.ERR_ASEPRITE_CMD_NOT_FOUND

	var dir = DirAccess.new()
	if not dir.file_exists(source):
		return result_code.ERR_SOURCE_FILE_NOT_FOUND

	if not dir.dir_exists(options.output_folder):
		return result_code.ERR_OUTPUT_FOLDER_NOT_FOUND

	return result_code.SUCCESS


func create_animations(sprite: Node, options: Dictionary) -> void:
	var input_check = _initial_checks(options.source, options)

	if input_check != result_code.SUCCESS:
		printerr(result_code.get_error_message(input_check))
		return

	var result = _create_animations_from_file(sprite, options)

	if result is GDScriptFunctionState:
		result = await result.completed

	if result != result_code.SUCCESS:
		printerr(result_code.get_error_message(result))


func _create_animations_from_file(animated_sprite: Node, options: Dictionary) -> int:
	var output = _export_aseprite_file(options)

	if not output.is_ok:
		return output.code

	if _config.is_import_preset_enabled():
		_config.create_import_file(output.content)

	await _scan_filesystem().completed

	var sprite_frames_result = _create_sprite_frames(output.content, options)
	if not sprite_frames_result.is_ok:
		return sprite_frames_result.code

	animated_sprite.frames = sprite_frames_result.content


	if _config.should_remove_source_files():
		var dir = DirAccess.new()
		dir.remove(output.content.data_file)

	return result_code.SUCCESS


func _export_aseprite_file(options: Dictionary) -> Dictionary:
	var output

	if options.get("layer", "") == "":
		output = _aseprite.export_file(options.source, options.output_folder, options)
	else:
		output = _aseprite.export_layer(options.source, options.layer, options.output_folder, options)

	if output.is_empty():
		return result_code.error(result_code.ERR_ASEPRITE_EXPORT_FAILED)

	return result_code.result(output)


func create_and_save_resources(source_file: String, options: Dictionary) -> int:
	var resources = await create_resources(source_file, options).completed

	if resources.is_ok:
		return _save_resources(resources.content)

	return resources.code


func create_resources(source_file: String, options = {}) -> Dictionary:
	var input_check = _initial_checks(source_file, options)

	if input_check != result_code.SUCCESS:
		return result_code.error(input_check)

	var output = _create_aseprite_output_files(source_file, options)
	if not output.is_ok:
		return output

	await _scan_filesystem().completed

	var result = _create_sprite_frames_from_source(output.content, options)

	if not result.is_ok:
		return result

	var should_remove_source = _config.should_remove_source_files()

	if should_remove_source:
		_remove_source_files(result.content)

	return result


func _remove_source_files(source_files: Array):
	var dir = DirAccess.new()
	for s in source_files:
		dir.remove(s.data_file)

	await _scan_filesystem().completed


func _create_aseprite_output_files(source_file: String, options: Dictionary):
	match options.get('export_mode', FILE_EXPORT_MODE):
		FILE_EXPORT_MODE:
			return result_code.result(
				[_aseprite.export_file(source_file, options.output_folder, options)]
			)
		LAYERS_EXPORT_MODE:
			var output = _aseprite.export_layers(source_file, options.output_folder, options)
			if output.is_empty():
				return result_code.error(result_code.ERR_NO_VALID_LAYERS_FOUND)
			return result_code.result(output)
		_:
			return result_code.error(result_code.ERR_UNKNOWN_EXPORT_MODE)


func _create_sprite_frames_from_source(source_files: Array, options: Dictionary) -> Dictionary:
	var should_remove_source = _config.should_remove_source_files()

	var resources = []

	for o in source_files:
		if o.is_empty():
			return result_code.error(result_code.ERR_ASEPRITE_EXPORT_FAILED)

		var resource = _create_sprite_frames(o, options)

		if not resource.is_ok:
			return resource

		resources.push_back({
			"data_file": o.data_file,
			"resource": resource.content,
		})

	return result_code.result(resources)


func _create_sprite_frames(data, options) -> Dictionary:
	var aseprite_resources = _load_aseprite_resources(data)
	if not aseprite_resources.is_ok:
		return aseprite_resources

	return result_code.result(
		_create_sprite_frames_with_animations(
			aseprite_resources.content.metadata,
			aseprite_resources.content.texture,
			options
		)
	)


func _load_aseprite_resources(aseprite_data: Dictionary):
	var content_result = _load_json_content(aseprite_data.data_file)

	if not content_result.is_ok:
		return content_result

	var texture = _parse_texture_path(aseprite_data.sprite_sheet)

	return result_code.result({
		"metadata": content_result.content,
		"texture": texture
	})


func _load_json_content(source_file: String) -> Dictionary:
	var file = File.new()
	var err = file.open(source_file, File.READ)
	if err != OK:
		return result_code.error(err)

	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	var content =  test_json_conv.get_data()

	if not _aseprite.is_valid_spritesheet(content):
		return result_code.error(result_code.ERR_INVALID_ASEPRITE_SPRITESHEET)

	return result_code.result(content)


func _save_resources(resources: Array) -> int:
	for resource in resources:
		var code = _save_resource(resource.resource, resource.data_file)
		if code != OK:
			return code
	return OK


func _save_resource(resource, source_path: String) -> int:
	var save_path = "%s.%s" % [source_path.get_basename(), "res"]
	var code = ResourceSaver.save(save_path, resource, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	resource.take_over_path(save_path)
	return code


func _create_sprite_frames_with_animations(content, texture, options) -> SpriteFrames:
	var frame_cache = {}
	var frames = _aseprite.get_content_frames(content)
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation_library("default")

	var frame_rect = null

	if options.get("slice", "") != "":
		frame_rect = _aseprite.get_slice_rect(content, options.slice)

	if content.meta.has("frameTags") and content.meta.frameTags.size() > 0:
		for tag in content.meta.frameTags:
			var selected_frames = frames.slice(tag.from, tag.to)
			_add_animation_frames(sprite_frames, tag.name, selected_frames, texture, frame_rect, tag.direction, int(tag.get("repeat", -1)), frame_cache)
	else:
		_add_animation_frames(sprite_frames, "default", frames, texture, frame_rect)

	return sprite_frames


func _add_animation_frames(
	sprite_frames: SpriteFrames,
	anim_name: String,
	frames: Array,
	texture,
	frame_rect,
	direction = 'forward',
	repeat = -1,
	frame_cache = {}
):

	var animation_name := anim_name
	var is_loopable = _is_loop_config_enabled()

	var loop_prefix := _loop_config_prefix()
	if animation_name.begins_with(loop_prefix):
		animation_name = anim_name.trim_prefix(loop_prefix)
		is_loopable = not is_loopable

	sprite_frames.add_animation(animation_name)

	var min_duration = _get_min_duration(frames)
	var fps = _calculate_fps(min_duration)

	if direction == "reverse" or direction == "pingpong_reverse":
		frames.invert()

	var repetition = 1

	if repeat != -1:
		is_loopable = false
		repetition = repeat


	for i in range(repetition):
		for frame in frames:
			_add_to_sprite_frames(sprite_frames, animation_name, texture, frame, min_duration, frame_cache, frame_rect)

		if direction.begins_with("pingpong"):
			var working_frames = frames.duplicate()
			working_frames.remove(frames.size() - 1)
			if is_loopable or (repetition > 1 and i < repetition - 1):
				working_frames.remove(0)
			working_frames.invert()

			for frame in working_frames:
				_add_to_sprite_frames(sprite_frames, animation_name, texture, frame, min_duration, frame_cache, frame_rect)

	sprite_frames.set_animation_loop(animation_name, is_loopable)
	sprite_frames.set_animation_speed(animation_name, fps)


func _calculate_fps(min_duration: int) -> float:
	return ceil(1000.0 / min_duration)


func _get_min_duration(frames) -> int:
	var min_duration = 100000
	for frame in frames:
		if frame.duration < min_duration:
			min_duration = frame.duration
	return min_duration


func _parse_texture_path(path):
	return ResourceLoader.load(path, 'Image', true)


func _add_to_sprite_frames(
	sprite_frames,
	animation_name: String,
	texture,
	frame: Dictionary,
	min_duration: int,
	frame_cache: Dictionary,
	frame_rect
):
	var atlas : AtlasTexture = _create_atlastexture_from_frame(texture, frame, sprite_frames, frame_cache, frame_rect)

	var number_of_sprites = ceil(frame.duration / min_duration)
	for _i in range(number_of_sprites):
		sprite_frames.add_frame(animation_name, atlas)


func _create_atlastexture_from_frame(
	image,
	frame_data,
	sprite_frames: SpriteFrames,
	frame_cache: Dictionary,
	frame_rect
) -> AtlasTexture:
	var frame = frame_data.frame
	var region := Rect2(frame.x, frame.y, frame.w, frame.h)

	if frame_rect != null:
		region.position.x += frame_rect.position.x
		region.position.y += frame_rect.position.y
		region.size.x = frame_rect.size.x
		region.size.y = frame_rect.size.y

	var key := "%s_%s_%s_%s" % [frame.x, frame.y, frame.w, frame.h]

	var texture = frame_cache.get(key)

	if texture != null and texture.atlas == image:
		return texture

	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = image
	atlas_texture.region = region

	frame_cache[key] = atlas_texture

	return atlas_texture


func _scan_filesystem():
	_file_system.scan()
	await _file_system.filesystem_changed


func list_layers(file: String, only_visibles = false) -> Array:
	return _aseprite.list_layers(file, only_visibles)


func list_slices(file: String) -> Array:
	return _aseprite.list_slices(file)


func _get_file_basename(file_path: String) -> String:
	return file_path.get_file().trim_suffix('.%s' % file_path.get_extension())


func _loop_config_prefix() -> String:
	return _config.get_animation_loop_exception_prefix()


func _is_loop_config_enabled() -> String:
	return _config.is_default_animation_loop_enabled()
