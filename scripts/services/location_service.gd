extends Node

enum Location {
	CABIN,
	FOREST,
}

var current_location: Location = Location.CABIN


## Returns the current location as an enum value
func get_location() -> Location:
	return current_location


## Sets the current location
func set_location(location: Location) -> void:
	current_location = location
