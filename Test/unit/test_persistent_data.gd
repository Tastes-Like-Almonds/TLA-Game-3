extends GutTest

const test_save_path : String = "test_save.dat"

# For testing data serialization
const sample_dict = {
	"float": 1.02,
	"int": 5,
	"str": "Hello, world!",
	"array": [1,2,3.3,"test",{"str2": "MyString"}],
	"dict": {
		"float": 1.02,
		"int": 5,
		"str": "Hello, world!",
		"array": [1,2,3.3,"test",{"str2": "MyString"}],
	}
}

func before_each() -> void:
	
	# Delete any save data from this test.
	if FileAccess.file_exists(test_save_path):
		var storage : DirAccess = DirAccess.open("user://")
		storage.remove(test_save_path)

## Ensure files are properly created and loaded
func test_save_and_load() -> void:
	
	PersistentData.save_game(test_save_path)
	var loaded_data : Dictionary = PersistentData.get_all_save_data()
	assert_true(FileAccess.file_exists(test_save_path), "save_game() should create a file at given path.")
	
	PersistentData.load_game(test_save_path)
	assert_eq(loaded_data, PersistentData.get_all_save_data(), "Loaded data should equal previous save data.")

## Serializing then unserializing the data should return the same result.
func test_json_converstion() -> void:
	
	# This test is somewhat done in test_save_and_load, though this one will only trigger if the issue
	# lies within the json serializer.
	
	var data : Dictionary = PersistentData._get_base_data()
	var json : String = PersistentData._save_to_json(data)

	# Check for error in loading/saving	
	assert_eq_deep(PersistentData._load_from_json(json), data)

	# Check for error in typeifying godot objects into JSON
	assert_eq_deep(sample_dict, PersistentData._untypeify(PersistentData._typeify(sample_dict)))

func after_each() -> void:
	
	# Delete after the tests complete. This is done before and after to ensure
	# the files exist only within tests and not outside.
	if FileAccess.file_exists(test_save_path):
		var storage : DirAccess = DirAccess.open("user://")
		storage.remove(test_save_path)
