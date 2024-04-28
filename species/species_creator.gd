extends Control

var species_information
var species_attributes
var species_appearance
var humanizer
var humanizer_skins_options
var registry

func _ready():
	species_information = $SpeciesInformation
	species_attributes = $SpeciesAttributes
	species_appearance = $ScrollContainer
	humanizer = $SubViewportContainer/SubViewport/Humanizer
	registry = HumanizerRegistry
	var options_by_registry_slot = {
		'RightEye': $ScrollContainer/SpeciesAppearance/RightEyeOptions,
		'LeftEye': $ScrollContainer/SpeciesAppearance/LeftEyeOptions,
		'RightEyebrow': $ScrollContainer/SpeciesAppearance/RightEyeBrowOptions,
		'LeftEyebrow': $ScrollContainer/SpeciesAppearance/LeftEyeBrowOptions,
		'RightEyelash': $ScrollContainer/SpeciesAppearance/RightEyeLashOptions,
		'LeftEyelash': $ScrollContainer/SpeciesAppearance/LeftEyeLashOptions,
		'Hair': $ScrollContainer/SpeciesAppearance/HairStyleOptions,
		'Tongue': $ScrollContainer/SpeciesAppearance/TongueOptions,
		'Teeth': $ScrollContainer/SpeciesAppearance/TeethOptions,
	}

	for body_part_name in registry.body_parts:
		var body_part_set = false
		for body_part_asset_name in registry.body_parts[body_part_name]:
			if not body_part_set:
				humanizer.set_body_part(registry.body_parts[body_part_name][body_part_asset_name])
				body_part_set = true
			if (body_part_name in options_by_registry_slot):
				options_by_registry_slot[body_part_name].add_item(body_part_asset_name)
			else:
				print("Missing configurable body part UI for", body_part_name)

func _on_species_information_tab_pressed():
	# Implement your logic here
	print("Species Information tab pressed")
	species_information.visible = true
	species_attributes.visible = false
	species_appearance.visible = false

func _on_species_attributes_tab_pressed():
	# Implement your logic here
	print("Species Attributes tab pressed")
	species_information.visible = false
	species_attributes.visible = true
	species_appearance.visible = false
	
func _on_species_appearance_tab_pressed():
	# Implement your logic here
	print("Species Appearance tab pressed")
	species_information.visible = false
	species_attributes.visible = false
	species_appearance.visible = true

func _on_humanizer_skins_options_item_selected(index):
	humanizer.set_skin_texture($ScrollContainer/SpeciesAppearance/HumanizerSkinsOptions.get_item_text(index))

func _on_skin_color_picker_color_changed(color):
	humanizer.skin_color = color

func _on_hair_color_picker_color_changed(color):
	humanizer.hair_color = color

func _on_hair_style_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['Hair'][$ScrollContainer/SpeciesAppearance/HairStyleOptions.get_item_text(index)])

func _on_eye_color_picker_color_changed(color):
	humanizer.eye_color = color

func _on_left_eye_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['LeftEye'][$ScrollContainer/SpeciesAppearance/LeftEyeOptions.get_item_text(index)])

func _on_right_eye_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['RightEye'][$ScrollContainer/SpeciesAppearance/RightEyeOptions.get_item_text(index)])

func _on_left_eye_brow_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['LeftEyebrow'][$ScrollContainer/SpeciesAppearance/LeftEyeBrowOptions.get_item_text(index)])

func _on_right_eye_brow_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['RightEyebrow'][$ScrollContainer/SpeciesAppearance/RightEyeBrowOptions.get_item_text(index)])

func _on_eye_brow_color_picker_color_changed(color):
	humanizer.eyebrow_color = color

func _on_left_eye_lash_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['LeftEyelash'][$ScrollContainer/SpeciesAppearance/LeftEyeLashOptions.get_item_text(index)])

func _on_right_eye_lash_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['RightEyelash'][$ScrollContainer/SpeciesAppearance/RightEyeLashOptions.get_item_text(index)])

func _on_tongue_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['Tongue'][$ScrollContainer/SpeciesAppearance/TongueOptions.get_item_text(index)])

func _on_teeth_options_item_selected(index):
	humanizer.set_body_part(registry.body_parts['Teeth'][$ScrollContainer/SpeciesAppearance/TeethOptions.get_item_text(index)])

func _on_save_pressed():
	humanizer.save_human_scene(true)

func _on_species_name_text_edit_text_set():
	humanizer.human_name = $SpeciesInformation/SpeciesNameTextEdit.text

func _on_species_name_text_edit_text_changed():
	humanizer.human_name = $SpeciesInformation/SpeciesNameTextEdit.text
