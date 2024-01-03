extends BaseItem

func get_rarity():
	return Rarity.RARITY_RARE

func get_use_options(_node, _context_kind:int, _context)->Array:
	return [{"label":"ITEM_BOOTLEG_RITUAL_CANDLE_USE", "arg":null}]

func _use_in_world(_node, _context, _arg):
	
	GlobalMessageDialog.clear_state()
	
	if not start_ritual_species_candle():
		yield (GlobalMessageDialog.show_message("ITEM_BOOTLEG_RITUAL_CANDLE_ERROR"), "completed")
		return false
	
	yield (GlobalMessageDialog.show_message("ITEM_BOOTLEG_RITUAL_CANDLE_BURNED"), "completed")
	
	return true

func start_ritual_species_candle()->bool:
	if SaveState.other_data.has("bootleg_ritual_species_candle") or SaveState.other_data.has("bootleg_ritual_candle"):
		return false
	SaveState.other_data.bootleg_ritual_species_candle = {}
	return true
