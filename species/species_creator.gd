extends Control

var species_information
var species_attributes
var species_appearance

func _ready():
	species_information = $SpeciesInformation
	species_attributes = $SpeciesAttributes
	species_appearance = $SpeciesAppearance
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
