extends MeshInstance3D

const _BASE_MESH_NAME: String = 'Human'
const _DEFAULT_SKIN_COLOR = Color.WHITE
const _DEFAULT_EYE_COLOR = Color.SKY_BLUE
const _DEFAULT_HAIR_COLOR = Color.WEB_MAROON
## Vertex ids
const shoulder_id: int = 16951 
const waist_id: int = 17346
const hips_id: int = 18127
const feet_ids: Array[int] = [15500, 16804]

static var body_parts := {}
static var clothes := {}
static var skin_textures := {}
static var skin_normals := {}
static var overlays := {}
static var rigs := {}

enum AssetType {
	BodyPart,
	Clothes
}

@export var mh_json_path: String
@export var mh_weights_path: String
@export var bone_weights_json_path: String
var config_json_path: String ="res://addons/humanizer/data/assets/rigs/default/skeleton_config.json"
var skeleton_path: String ="res://addons/humanizer/data/assets/rigs/default/skeleton.tscn"
var skeleton_retargeted_path: String = "res://addons/humanizer/data/assets/rigs/default/skeleton.tscn"
@export var rigged_mesh_path: String

func load_skeleton() -> Skeleton3D:
	return load(skeleton_path).instantiate()

func load_retargeted_skeleton() -> Skeleton3D:
	return load(skeleton_retargeted_path).instantiate()

func load_bone_weights() -> Dictionary:
	var weights: Dictionary = HumanizerUtils.read_json(mh_weights_path).weights
	for in_name:String in weights.keys():
		if ':' not in in_name:
			continue
		var out_name = in_name.replace(":", "_")
		weights[out_name] = weights[in_name]
		weights.erase(in_name)
	return weights

func _enter_tree() -> void:
	load_all()

static func load_all() -> void:
	_get_rigs()
	_load_body_parts()
	_load_clothes()
	_get_skin_textures()

static func add_body_part_asset(asset: HumanBodyPart) -> void:
	#print('Registering body part ' + asset.resource_name)
	if not body_parts.has(asset.slot):
		body_parts[asset.slot] = {}
	if body_parts[asset.slot].has(asset.resource_name):
		body_parts[asset.slot].erase(asset.resource_name)
	body_parts[asset.slot][asset.resource_name] = asset

static func add_clothes_asset(asset: HumanClothes) -> void:
	#print('Registering clothes ' + asset.resource_name)
	if clothes.has(asset.resource_name):
		clothes.erase(asset.resource_name)
	clothes[asset.resource_name] = asset

static func filter_clothes(filter: Dictionary) -> Array[HumanClothes]:
	var filtered_clothes: Array[HumanClothes]
	for cl in clothes.values():
		for key in filter:
			if key == &'slot':
				if filter[key] in cl.slots:
					filtered_clothes.append(cl)
	return filtered_clothes

static func _get_rigs() -> void:
	#  Create and/or cache rig resources
	for folder in HumanizerGlobalConfig.config.asset_import_paths:
		var rig_path = folder.path_join('rigs')
		for dir in OSPath.get_dirs(rig_path):
			var name = dir.get_file()
			rigs[name] = HumanizerRig.new()
			rigs[name].resource_name = name
			for file in OSPath.get_files(dir):
				if file.get_extension() == 'json' and file.get_file().begins_with('rig'):
					rigs[name].mh_json_path = file
				elif file.get_extension() == 'json' and file.get_file().begins_with('weights'):
					rigs[name].mh_weights_path = file
				elif file.get_file() == 'skeleton_config.json':
					rigs[name].config_json_path = file
				elif file.get_file() == 'bone_weights.json':
					rigs[name].bone_weights_json_path = file
				elif file.get_extension() == 'tscn' and file.get_file().begins_with('general'):
					rigs[name].skeleton_retargeted_path = file
				elif file.get_extension() == 'tscn':
					rigs[name].skeleton_path = file
				elif file.get_extension() == 'res':
					rigs[name].rigged_mesh_path = file

static func _get_skin_textures() -> void:
	## load texture paths
	overlays['skin'] = {}
	skin_textures = {}
	for path in HumanizerGlobalConfig.config.asset_import_paths:
		for dir in OSPath.get_dirs(path.path_join('skins')):
			if dir.get_file() == '_overlays':
				for file in OSPath.get_files(dir):
					overlays['skin'][file.get_basename()] = file
			else:
				var filename: String
				for file in OSPath.get_files(dir):
					if file.get_extension() == 'png':
						if 'diffuse' in file.get_file().to_lower():
							filename = file.get_file().get_basename().replace('_diffuse', '')
							skin_textures[filename] = file
		for fl in OSPath.get_files(path.path_join('skin_normals')):
			if fl.get_extension() == 'png':
				skin_normals[fl.get_file().get_basename()] = fl

static func _load_body_parts() -> void:
	body_parts = {}
	for path in HumanizerGlobalConfig.config.asset_import_paths:
		for dir in OSPath.get_dirs(path.path_join('body_parts')):
			_scan_dir(dir, AssetType.BodyPart)
			
static func _load_clothes() -> void:
	clothes = {}
	for path in HumanizerGlobalConfig.config.asset_import_paths:
		for dir in OSPath.get_dirs(path.path_join('clothes')):
			_scan_dir(dir, AssetType.Clothes)

static func _scan_dir(path: String, asset_type: AssetType) -> void:
	var contents := OSPath.get_contents(path)
	for folder in contents.dirs:
		_scan_dir(folder, asset_type)
	for file in contents.files:
		if file.get_extension() not in ['tres', 'res']:
			continue
		var suffix: String = file.get_file().rsplit('.', true, 1)[0].split('_')[-1]
		if suffix in ['material', 'mhclo', 'mesh']:
			continue
		if asset_type == AssetType.BodyPart:
			var asset = load(file)
			if asset is HumanClothes:
				printerr(file.get_file() + ' was imported as clothes but should be a body part.  Please Re-import.')
				continue
			add_body_part_asset(asset)
		else:
			add_clothes_asset(load(file))

func get_base_motion_scale():
	return load_retargeted_skeleton().motion_scale

func _ready():
	var skeleton: Skeleton3D
	var body_mesh: MeshInstance3D
	var baked := false
	var scene_loaded: bool = false
	var main_collider: CollisionShape3D
	var animator: Node
	var _base_motion_scale: float = get_base_motion_scale()
			
	var _base_hips_height: float = shapekey_data.basis[hips_id].y
	var shapekey_data: Dictionary = shapekey_data
	var _helper_vertex: PackedVector3Array = []
	var human_name: String = 'MyHuman'
	var save_path: String = "res://data/humans".path_join(human_name)

	var _save_path_valid: bool = not FileAccess.file_exists(save_path.path_join(human_name + '.tscn'))

	var bake_surface_name: String
	var new_shapekey_name: String = ''

	var skin_color: Color = _DEFAULT_SKIN_COLOR
	#:
		#set(value):
			#skin_color = value
			#if body_mesh == null or (body_mesh as HumanizerMeshInstance) == null:
				#return
			#if scene_loaded and body_mesh.material_config.overlays.size() == 0:
				#return
			#human_config.skin_color = skin_color
			#if body_mesh.material_config.overlays.size() > 0:
				#body_mesh.material_config.overlays[0].color = skin_color
	var hair_color: Color = _DEFAULT_HAIR_COLOR
	#:
		#set(value):
			#hair_color = value
			#if human_config == null or not scene_loaded:
				#return
			#human_config.hair_color = hair_color
			#var slots: Array = [&'RightEyebrow', &'LeftEyebrow', &'Eyebrows', &'Hair']
			#for slot in slots:
				#if not human_config.body_parts.has(slot):
					#continue
				#var mesh = get_node(human_config.body_parts[slot].resource_name)
				#(mesh as MeshInstance3D).get_surface_override_material(0).albedo_color = hair_color
	var eye_color: Color = _DEFAULT_EYE_COLOR
	#:
		#set(value):
			#eye_color = value
			#if human_config == null or not scene_loaded:
				#return
			#human_config.eye_color = eye_color
			#var slots: Array = [&'RightEye', &'LeftEye', &'Eyes']
			#for slot in slots:
				#if not human_config.body_parts.has(slot):
					#continue
				#var mesh = get_node(human_config.body_parts[slot].resource_name)
				#mesh.material_config.overlays[1].color = eye_color

	var _bake_meshes: Array[MeshInstance3D]

#requires that the mh_id already be set in the Custom0 array, which happens in the obj_to_mesh importer
static func get_mh2gd_index_from_mesh(input_mesh:ArrayMesh):
	var mh2gd_index = []
	var sf_arrays = input_mesh.surface_get_arrays(0)
	for gd_id in sf_arrays[Mesh.ARRAY_VERTEX].size():
		var mh_id = sf_arrays[Mesh.ARRAY_CUSTOM0][gd_id]
		if not mh_id < mh2gd_index.size():
			mh2gd_index.resize(mh_id + 1)
		if mh2gd_index[mh_id] == null:
			mh2gd_index[mh_id] = PackedInt32Array()
		mh2gd_index[mh_id].append(gd_id)
	return mh2gd_index

static func read_json(file_name:String):
	var json_as_text = FileAccess.get_file_as_string(file_name)
	var json_as_dict = JSON.parse_string(json_as_text)
	return json_as_dict
	
static func save_json(file_path, data):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(data))

static func get_shapekey_data() -> Dictionary:
	var shapekey_data: Dictionary
	var file := FileAccess.open("res://addons/humanizer/data/resources/shapekeys.dat", FileAccess.READ)	
	shapekey_data = file.get_var(true)
	file.close()
	return shapekey_data

static var _shapekey_data: Dictionary = {}
static var shapekey_data: Dictionary:
	get:
		if _shapekey_data.size() == 0:
			_shapekey_data = get_shapekey_data()
		return _shapekey_data

static func get_shapekey_categories(shapekeys=null) -> Dictionary:
	if shapekeys == null:
		shapekeys = get_shapekey_data()
	var categories := {
		'Macro': [],
		'Race': [],
		'Head': [],
		'Eyes': [],
		'Mouth': [],
		'Nose': [],
		'Ears': [],
		'Face': [],
		'Neck': [],
		'Chest': [],
		'Breasts': [],
		'Hips': [],
		'Arms': [],
		'Legs': [],
		'Misc': [],
	}
	for name in shapekeys.shapekeys:
		if 'penis' in name.to_lower():# or name.ends_with('firmness'):
			continue
		if name in shapekeys.macro_shapekeys:
			continue
		elif 'head' in name.to_lower() or 'brown' in name.to_lower() or 'top' in name.to_lower():
			categories['Head'].append(name)
		elif 'eye' in name.to_lower():
			categories['Eyes'].append(name)
		elif 'mouth' in name.to_lower():
			categories['Mouth'].append(name)
		elif 'nose' in name.to_lower():
			categories['Nose'].append(name)
		elif 'ear' in name.to_lower():
			categories['Ears'].append(name)
		elif 'jaw' in name.to_lower() or 'cheek' in name.to_lower() or 'temple' in name.to_lower() or 'chin' in name.to_lower():
			categories['Face'].append(name)
		elif 'arm' in name.to_lower() or 'hand' in name.to_lower() or 'finger' in name.to_lower() or 'wrist' in name.to_lower():
			categories['Arms'].append(name)
		elif 'leg' in name.to_lower() or 'calf' in name.to_lower() or 'foot' in name.to_lower() or 'butt' in name.to_lower() or 'ankle' in name.to_lower() or 'thigh' in name.to_lower() or 'knee' in name.to_lower():
			categories['Legs'].append(name)
		elif 'cup' in name.to_lower() or 'bust' in name.to_lower() or 'breast' in name.to_lower() or 'nipple' in name.to_lower():
			categories['Breasts'].append(name)
		elif 'torso' in name.to_lower() or 'chest' in name.to_lower() or 'shoulder' in name.to_lower():
			categories['Chest'].append(name)
		elif 'hip' in name.to_lower() or 'trunk' in name.to_lower() or 'pelvis' in name.to_lower() or 'waist' in name.to_lower() or 'pelvis' in name.to_lower() or 'stomach' in name.to_lower() or 'bulge' in name.to_lower():
			categories['Hips'].append(name)
		elif 'hand' in name.to_lower() or 'finger' in name.to_lower():
			categories['Hands'].append(name)
		elif 'neck' in name.to_lower():
			categories['Neck'].append(name)
		else:
			categories['Misc'].append(name)
	
	categories['Macro'] = MeshOperations.get_macro_options()
	categories['Race'].append_array(MeshOperations.get_race_options())
	categories['Macro'].erase('cupsize')
	categories['Macro'].erase('firmness')
	categories['Breasts'].append('cupsize')
	categories['Breasts'].append('firmness')
	return categories
	
static func show_window(interior, closeable: bool = true, size=Vector2i(500, 500)) -> void:
	if not Engine.is_editor_hint():
		return
	var window = Window.new()
	if interior is PackedScene:
		interior = interior.instantiate()
	window.add_child(interior)	
	if closeable:
		window.close_requested.connect(func(): window.queue_free())
	window.size = size
	EditorInterface.popup_dialog_centered(window)
