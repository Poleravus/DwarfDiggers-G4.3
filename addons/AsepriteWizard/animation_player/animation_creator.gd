extends RefCounted

var result_code = preload("../config/result_codes.gd")
var _aseprite = preload("../aseprite/aseprite.gd").new()

var _config
var _file_system


func init(config, editor_file_system: EditorFileSystem = null):
	_config = config
	_file_system = editor_file_system
	_aseprite.init(config)


func create_animations(target_node: Node, player: AnimationPlayer, options: Dictionary):
	if not _aseprite.test_command():
		return result_code.ERR_ASEPRITE_CMD_NOT_FOUND

	var dir = DirAccess.new()
	if not dir.file_exists(options.source):
		return result_code.ERR_SOURCE_FILE_NOT_FOUND

	if not dir.dir_exists(options.output_folder):
		return result_code.ERR_OUTPUT_FOLDER_NOT_FOUND

	var result = _create_animations_from_file(target_node, player, options)
	if result is GDScriptFunctionState:
		result = await result.completed

	if result != result_code.SUCCESS:
		printerr(result_code.get_error_message(result))


func _create_animations_from_file(target_node: Node, player: AnimationPlayer, options: Dictionary):
	var output

	if options.get("layer", "") == "":
		output = _aseprite.export_file(options.source, options.output_folder, options)
	else:
		output = _aseprite.export_layer(options.source, options.layer, options.output_folder, options)

	if output.is_empty():
		return result_code.ERR_ASEPRITE_EXPORT_FAILED

	if _config.is_import_preset_enabled():
		_config.create_import_file(output)

	await _scan_filesystem().completed

	var result = _import(target_node, player, output, options)

	if _config.should_remove_source_files():
		var dir = DirAccess.new()
		dir.remove(output.data_file)

	return result


func _import(target_node: Node, player: AnimationPlayer, data: Dictionary, options: Dictionary):
	var source_file = data.data_file
	var sprite_sheet = data.sprite_sheet

	var file = File.new()
	var err = file.open(source_file, File.READ)
	if err != OK:
			return err

	var test_json_conv = JSON.new()
	test_json_conv.parse(file.get_as_text())
	var content =  test_json_conv.get_data()

	if not _aseprite.is_valid_spritesheet(content):
		return result_code.ERR_INVALID_ASEPRITE_SPRITESHEET

	var context = {}

	_setup_texture(target_node, sprite_sheet, content, context, options.slice != "")
	var result = _configure_animations(target_node, player, content, context, options)
	if result != result_code.SUCCESS:
		return result

	return _cleanup_animations(target_node, player, content, options)


func _load_texture(sprite_sheet: String) -> Texture2D:
	var texture = ResourceLoader.load(sprite_sheet, 'Image', true)
	texture.take_over_path(sprite_sheet)
	return texture


func _configure_animations(target_node: Node, player: AnimationPlayer, content: Dictionary, context: Dictionary, options: Dictionary):
	var frames = _aseprite.get_content_frames(content)
	var slice_rect = null
	if options.slice != "":
		options["slice_rect"] = _aseprite.get_slice_rect(content, options.slice)

	if content.meta.has("frameTags") and content.meta.frameTags.size() > 0:
		var result = result_code.SUCCESS
		for tag in content.meta.frameTags:
			var selected_frames = frames.slice(tag.from, tag.to)
			result = _add_animation_frames(target_node, player, tag.name, selected_frames, context, options, tag.direction, int(tag.get("repeat", -1)))
			if result != result_code.SUCCESS:
				break
		return result
	else:
		return _add_animation_frames(target_node, player, "default", frames, context, options)


func _add_animation_frames(target_node: Node, player: AnimationPlayer, anim_name: String, frames: Array, context: Dictionary, options: Dictionary, direction = 'forward', repeat = -1):
	var animation_name = anim_name
	var is_loopable = _config.is_default_animation_loop_enabled()
	var slice_rect = options.get("slice_rect")
	var is_importing_slice: bool = slice_rect != null

	if animation_name.begins_with(_config.get_animation_loop_exception_prefix()):
		animation_name = anim_name.substr(_config.get_animation_loop_exception_prefix().length())
		is_loopable = not is_loopable

	if not player.has_animation(animation_name):
		player.add_animation(animation_name, Animation.new())

	var animation = player.get_animation(animation_name)
	_cleanup_tracks(target_node, player, animation)
	_create_meta_tracks(target_node, player, animation)
	var frame_track = _get_property_track_path(player, target_node, _get_frame_property(is_importing_slice))
	var frame_track_index = _create_track(target_node, animation, frame_track)

	if direction == "reverse" or direction == "pingpong_reverse":
		frames.invert()

	var animation_length = 0
	var repetition = 1

	if repeat != -1:
		is_loopable = false
		repetition = repeat

	for i in range(repetition):
		for frame in frames:
			var frame_key = _get_frame_key(target_node, frame, context, slice_rect)
			animation.track_insert_key(frame_track_index, animation_length, frame_key)
			animation_length += frame.duration / 1000

		if direction.begins_with("pingpong"):
			var working_frames = frames.duplicate()
			working_frames.remove(working_frames.size() - 1)
			if is_loopable or (repetition > 1 and i < repetition - 1):
				working_frames.remove(0)
			working_frames.invert()

			for frame in working_frames:
				var frame_key = _get_frame_key(target_node, frame, context, slice_rect)
				animation.track_insert_key(frame_track_index, animation_length, frame_key)
				animation_length += frame.duration / 1000

	animation.length = animation_length
	animation.loop = is_loopable

	return result_code.SUCCESS


func _create_track(target_node: Node, animation: Animation, track: String):
	var track_index = animation.find_track(track)

	if track_index != -1:
		animation.remove_track(track_index)

	track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_index, track)
	animation.track_set_interpolation_loop_wrap(track_index, false)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)

	return track_index


func _get_property_track_path(player: AnimationPlayer, target_node: Node, prop: String) -> String:
		var node_path = player.get_node(player.root_node).get_path_to(target_node)
		return "%s:%s" % [node_path, prop]


func _cleanup_animations(target_node: Node, player: AnimationPlayer, content: Dictionary, options: Dictionary):
	if not (content.meta.has("frameTags") and content.meta.frameTags.size() > 0):
		return result_code.SUCCESS

	_remove_unused_animations(content, player)

	if options.get("cleanup_hide_unused_nodes", false):
		_hide_unused_nodes(target_node, player, content)

	return result_code.SUCCESS


func _remove_unused_animations(content: Dictionary, player: AnimationPlayer):
	pass # FIXME it's not removing unused animations anymore. Sample impl bellow
#	var tags = ["RESET"]
#	for t in content.meta.frameTags:
#		var a = t.name
#		if a.begins_with(_config.get_animation_loop_exception_prefix()):
#			a = a.substr(_config.get_animation_loop_exception_prefix().length())
#		tags.push_back(a)

#   var track = _get_frame_track_path(player, sprite)
#	for a in player.get_animation_list():
#		if tags.has(a):
#			continue
#
#		var animation = player.get_animation(a)
#		if animation.get_track_count() != 1:
#			var t = animation.find_track(track)
#			if t != -1:
#				animation.remove_track(t)
#			continue
#
#		if animation.find_track(track) != -1:
#			player.remove_animation(a)


func _hide_unused_nodes(target_node: Node, player: AnimationPlayer, content: Dictionary):
	var root_node := player.get_node(player.root_node)
	var all_animations := player.get_animation_list()
	var all_sprite_nodes := []
	var animation_sprites := {}

	for a in all_animations:
		var animation := player.get_animation(a)
		var sprite_nodes := []

		for track_idx in animation.get_track_count():
			var raw_path := animation.track_get_path(track_idx)
			if "visible" in raw_path as String:
				continue

			var path := _remove_properties_from_path(raw_path)
			var sprite_node := root_node.get_node(path)

			if !(sprite_node is Sprite2D || sprite_node is Sprite3D):
				continue

			if sprite_nodes.has(sprite_node):
				continue
			sprite_nodes.append(sprite_node)

		animation_sprites[animation] = sprite_nodes
		for sn in sprite_nodes:
			if all_sprite_nodes.has(sn):
				continue
			all_sprite_nodes.append(sn)

	for animation in animation_sprites:
		var sprite_nodes : Array = animation_sprites[animation]
		for node in all_sprite_nodes:
			if sprite_nodes.has(node):
				continue
			var visible_track = _get_property_track_path(player, node, "visible")
			if animation.find_track(visible_track) != -1:
				continue
			var visible_track_index = _create_track(node, animation, visible_track)
			animation.track_insert_key(visible_track_index, 0, false)


func _scan_filesystem():
	_file_system.scan()
	await _file_system.filesystem_changed


func list_layers(file: String, only_visibles = false) -> Array:
	return _aseprite.list_layers(file, only_visibles)


func list_slices(file: String) -> Array:
	return _aseprite.list_slices(file)


func _remove_properties_from_path(path: NodePath) -> NodePath:
	var string_path := path as String
	if !(":" in string_path):
		return string_path as NodePath

	var property_path := path.get_concatenated_subnames() as String
	string_path.erase((string_path).length() - property_path.length() - 1, property_path.length() + 1)
	return string_path as NodePath


func _setup_texture(target_node: Node, sprite_sheet: String, content: Dictionary, context: Dictionary, is_importing_slice: bool):
	push_error("_setup_texture not implemented!")


func _get_frame_property(is_importing_slice: bool) -> String:
	push_error("_get_frame_property not implemented!")
	return ""


func _get_frame_key(target_node: Node, frame: Dictionary, context: Dictionary, slice_info):
	push_error("_get_frame_key not implemented!")


func _create_meta_tracks(target_node: Node, player: AnimationPlayer, animation: Animation):
	push_error("_create_meta_tracks not implemented!")


func _cleanup_tracks(target_node: Node, player: AnimationPlayer, animation: Animation):
	for track_key in ["texture", "hframes", "vframes", "region_rect", "frame"]:
		var track = _get_property_track_path(player, target_node, track_key)
		var track_index = animation.find_track(track)
		if track_index != -1:
			animation.remove_track(track_index)
