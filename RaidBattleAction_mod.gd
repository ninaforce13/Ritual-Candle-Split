static func patch():
	var script_path = "res://nodes/actions/RaidBattleAction.gd"
	var patched_script : GDScript = preload("res://nodes/actions/RaidBattleAction.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var class_name_index = code_lines.find("class_name RaidBattleAction")
	if class_name_index >= 0:
		code_lines.remove(class_name_index)

	var code_index = code_lines.find("		quest.bootleg_modifier = SaveState.end_ritual_candle()")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("has_candles"))
	code_index = code_lines.find("		BattleSetupUtil.apply_bootleg_modifier(rand, SaveState.get_ritual_candle(), config)")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("candle_check"))

	code_lines.insert(code_lines.size()-1,get_code("new_functions"))

	patched_script.source_code = ""
	for line in code_lines:
		patched_script.source_code += line + "\n"
	RaidBattleAction.source_code = patched_script.source_code
	var err = RaidBattleAction.reload()
	if err != OK:
		push_error("Failed to patch %s." % script_path)
		return


static func get_code(block:String)->String:
	var code_blocks:Dictionary = {}
	code_blocks["candle_check"] = """
	elif quest and has_ritual_species_candle() and SaveState.start_ritual_candle():
		print("Species Ritual Fusion Encountered")
		SaveState.other_data.bootleg_ritual_candle = SaveState.other_data.bootleg_ritual_species_candle
		if has_ritual_type_candle():
			SaveState.other_data.bootleg_ritual_candle["type"] = SaveState.other_data.bootleg_ritual_type_candle["type"]
		BattleSetupUtil.apply_bootleg_modifier(rand, SaveState.get_ritual_candle(), config)

	elif quest and has_ritual_type_candle() and SaveState.start_ritual_candle():
		print("Type Ritual Fusion Encountered")
		SaveState.other_data.bootleg_ritual_candle = SaveState.other_data.bootleg_ritual_type_candle
		if has_ritual_species_candle():
			SaveState.other_data.bootleg_ritual_candle["species"] = SaveState.other_data.bootleg_ritual_species_candle["species"]
		BattleSetupUtil.apply_bootleg_modifier(rand, SaveState.get_ritual_candle(), config)
"""

	code_blocks["has_candles"] = """
	if has_ritual_species_candle():
		end_ritual_species_candle()

	if has_ritual_type_candle():
		end_ritual_type_candle()
"""
	code_blocks["new_functions"] = """
func has_ritual_species_candle()->bool:
	return SaveState.other_data.has("bootleg_ritual_species_candle") and SaveState.other_data.bootleg_ritual_species_candle.has("species")

func get_ritual_species_candle():
	if SaveState.other_data.has("bootleg_ritual_species_candle"):
		var ritual = SaveState.other_data.bootleg_ritual_species_candle
		if ritual.has("species"):
			return ritual
	return null

func end_ritual_species_candle():
	var result = get_ritual_species_candle()
	if result:
		SaveState.other_data.erase("bootleg_ritual_species_candle")

func end_ritual_type_candle():
	var result = get_ritual_type_candle()
	if result:
		SaveState.other_data.erase("bootleg_ritual_type_candle")

func has_ritual_type_candle()->bool:
	return SaveState.other_data.has("bootleg_ritual_type_candle") and SaveState.other_data.bootleg_ritual_type_candle.has("type")

func get_ritual_type_candle():
	if SaveState.other_data.has("bootleg_ritual_type_candle"):
		var ritual = SaveState.other_data.bootleg_ritual_type_candle
		if ritual.has("type"):
			return ritual
	return null
"""

	return code_blocks[block]










