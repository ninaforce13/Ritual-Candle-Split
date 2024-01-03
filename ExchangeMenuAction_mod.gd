static func patch():
	var script_path = "res://nodes/actions/ExchangeMenuAction.gd"
	var patched_script : GDScript = preload("res://nodes/actions/ExchangeMenuAction.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name ExchangeMenuAction")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("func _ready():")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("add_items"))
		code_lines.insert(code_index-1,get_code("add_preloads"))
	else:
		code_index = code_lines.find("func _run():")
		if code_index > 0:
			code_lines.insert(code_index-1,get_code("add_ready"))


	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	ExchangeMenuAction.source_code = patched_script.source_code
	var err = ExchangeMenuAction.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["add_preloads"] = """
var element_candle = preload("res://mods/ritual_candle_split/ranger_trader/bootleg_ritual_element_candle.tres")
var species_candle = preload("res://mods/ritual_candle_split/ranger_trader/bootleg_ritual_species_candle.tres")
"""

	code_blocks["add_items"] = """
	if title == "{pawn}":
		if not exchanges.has(element_candle):
			exchanges.append(element_candle)
		if not exchanges.has(species_candle):
			exchanges.append(species_candle)
"""
	code_blocks["add_ready"] = """
var element_candle = preload("res://mods/ritual_candle_split/ranger_trader/bootleg_ritual_element_candle.tres")
var species_candle = preload("res://mods/ritual_candle_split/ranger_trader/bootleg_ritual_species_candle.tres")
func _ready():
	if title == "{pawn}":
		if not exchanges.has(element_candle):
			exchanges.append(element_candle)
		if not exchanges.has(species_candle):
			exchanges.append(species_candle)
"""

	return code_blocks[block]

