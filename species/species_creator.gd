extends Control

var species_information
var species_attributes
var species_appearance
var humanizer
var humanizer_skins_options

func _ready():
	species_information = $SpeciesInformation
	species_attributes = $SpeciesAttributes
	species_appearance = $SpeciesAppearance
	humanizer = $SubViewportContainer/SubViewport/Humanizer
	#var body_parts = []
	#var leftEye = HumanBodyPart.new()
	#leftEye.slot = 'LeftEye'
	#leftEye.textures = {
		#'LeftEyeBall-LowPoly': 'eyeball_albedo.png'
	#}
	#humanizer.set_body_part_material('Hair', 'ponytail01_diffuse.png')
	#var body_parts = {
	#: HumanBodyPart.new({'slot': 'RightEye'}),
	#'LeftEye': HumanBodyPart.new(),
	#'RightEyebrow': HumanBodyPart.new(),
	#'LeftEyebrow': HumanBodyPart.new(),
	#'RightEyelash': HumanBodyPart.new(),
	#'LeftEyelash': HumanBodyPart.new(),
	#'Hair': HumanBodyPart.new(),
	#'Tongue': HumanBodyPart.new(),
	#'Teeth': HumanBodyPart.new(),
#}

		
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
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
