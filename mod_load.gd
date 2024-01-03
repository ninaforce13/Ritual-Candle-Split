extends ContentInfo

var exchangemenu_patch = preload("res://mods/ritual_candle_split/ExchangeMenuAction_mod.gd")
var tapestorage_patch = preload("res://mods/ritual_candle_split/TapeStorageMenu_mod.gd")
var raid_patch = preload("res://mods/ritual_candle_split/RaidBattleAction_mod.gd")
var ritualitem_patch = preload("res://mods/ritual_candle_split/BootlegRitualCandleItem_mod.gd")
func _init():
	exchangemenu_patch.patch()
	tapestorage_patch.patch()
	raid_patch.patch()
	ritualitem_patch.patch()
