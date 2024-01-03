static func patch():
	var script_path = "res://menus/tape_storage/TapeStorageMenu.gd"
	var patched_script : GDScript = preload("res://menus/tape_storage/TapeStorageMenu.gd")

	if !patched_script.has_source_code():
		var file : File = File.new()
		var err = file.open(script_path, File.READ)
		if err != OK:
			push_error("Check that %s is included in Modified Files"% script_path)
			return
		patched_script.source_code = file.get_as_text()
		file.close()

	var code_lines:Array = patched_script.source_code.split("\n")

	var code_index = code_lines.find("		yield (GlobalMessageDialog.show_message(\"ITEM_BOOTLEG_RITUAL_CANDLE_SACRIFICED\"), \"completed\")")
	if code_index > 0:
		code_lines.insert(code_index+1,get_code("ritual_candle_checks"))

	code_lines.insert(code_lines.size()-1,get_code("new_functions"))
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
	elif complete_ritual_species_candle(tape):
		yield (GlobalMessageDialog.show_message("ITEM_BOOTLEG_RITUAL_CANDLE_SACRIFICED"), "completed")
	elif complete_ritual_type_candle(tape):
		yield (GlobalMessageDialog.show_message("ITEM_BOOTLEG_RITUAL_CANDLE_SACRIFICED"), "completed")

"""
	code_blocks["new_functions"] = """
func complete_ritual_type_candle(tape:MonsterTape)->bool:
	if SaveState.other_data.has("bootleg_ritual_type_candle"):
		var ritual = SaveState.other_data.bootleg_ritual_type_candle
		if ritual.has("species") or ritual.has("type"):
			return false
		if tape.get_types().size() > 0:
			ritual.type = Datatables.get_db_key(tape.get_types()[0])

		if Net.status_connected():
			Net.activity.broadcast("ONLINE_NOTIFICATION_RITUAL_CANDLE1")
			Net.broadcast_rpc(self, "_remote_ritual_candle", [ritual.get("species", ""), ritual.get("type", "")])
		return true
	return false

func complete_ritual_species_candle(tape:MonsterTape)->bool:
	if SaveState.other_data.has("bootleg_ritual_species_candle"):
		var ritual = SaveState.other_data.bootleg_ritual_species_candle
		if ritual.has("species") or ritual.has("type"):
			return false
		ritual.species = Datatables.get_db_key(tape.form)

		if Net.status_connected():
			Net.activity.broadcast("ONLINE_NOTIFICATION_RITUAL_CANDLE1")
			Net.broadcast_rpc(self, "_remote_ritual_candle", [ritual.get("species", ""), ritual.get("type", "")])
		return true
	return false
"""

	return code_blocks[block]





