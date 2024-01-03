static func patch():
	var script_path = "res://data/item_scripts/BootlegRitualCandleItem.gd"
	var patched_script : GDScript = preload("res://data/item_scripts/BootlegRitualCandleItem.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("	GlobalMessageDialog.clear_state()")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("ritual_candle_checks"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"

	var err = patched_script.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}

	code_blocks["ritual_candle_checks"] = """
	if SaveState.other_data.has("bootleg_ritual_species_candle") or SaveState.other_data.has("bootleg_ritual_type_candle"):
		yield (GlobalMessageDialog.show_message("ITEM_BOOTLEG_RITUAL_CANDLE_ERROR"), "completed")
		return false
"""


	return code_blocks[block]

