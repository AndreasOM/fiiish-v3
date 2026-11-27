class_name FiiishDialogManager
extends DialogManager

func _init() -> void:
	self._dialog_configs = {
		DialogIds.Id.RESULT_DIALOG: preload("res://Dialogs/result_dialog.tscn"),
#		DialogIds.Id.SETTING_DIALOG: preload("res://Dialogs/setting_dialog.tscn"),
		DialogIds.Id.SKILL_UPGRADE_DIALOG: preload("res://Dialogs/skill_upgrade_dialog.tscn"),
		DialogIds.Id.SKILL_RESET_CONFIRMATION_DIALOG: preload("res://Dialogs/fiiish_confirmation_dialog.tscn"),
		DialogIds.Id.SKILL_NOT_AFFORDABLE_DIALOG: preload("res://Dialogs/fiiish_confirmation_dialog.tscn"),
		DialogIds.Id.SETTING_DIALOG: preload("res://Dialogs/setting_dialog.tscn"),
		DialogIds.Id.DEVELOPER_CONSOLE_DIALOG: preload("res://Dialogs/developer_console_dialog.tscn"),
		DialogIds.Id.MAIN_MENU_DIALOG: preload("res://Dialogs/main_menu_dialog.tscn"),
		DialogIds.Id.CREDITS_DIALOG: preload("res://Dialogs/credits_dialog.tscn"),
		DialogIds.Id.LEADERBOARD_DIALOG: preload("res://Dialogs/leaderboard_dialog.tscn"),
		DialogIds.Id.ZONE_EDITOR_MENU_DIALOG: preload("res://Dialogs/zone_editor_menu_dialog.tscn"),
		DialogIds.Id.MINI_MAP_DIALOG: preload("res://Dialogs/mini_map_dialog.tscn"),
		DialogIds.Id.ZONE_SELECT_DIALOG: preload("res://Dialogs/zone_select_dialog.tscn"),
		DialogIds.Id.ZONE_EDITOR_TOOLS_DIALOG: preload("res://Dialogs/ZoneEditor/zone_editor_tools_dialog.tscn"),
		DialogIds.Id.ZONE_PROPERTY_DIALOG: preload("res://Dialogs/ZoneEditor/zone_property_dialog.tscn"),
		DialogIds.Id.IN_GAME_PAUSE_DIALOG: preload("res://Scenes/in_game_pause_menu.tscn"),
		DialogIds.Id.ACHIEVEMENTS_DIALOG: preload("res://Features/Achievements/Dialogs/achievement_dialog.tscn"),
#		DialogIds.Id.ACHIEVEMENTS_DIALOG: preload("res://Features/Achievements/Dialogs/achievement_dialog_v1.tscn"),
		DialogIds.Id.TOAST_DIALOG: preload("res://Features/Toasts/Dialogs/toast_dialog.tscn"),
		DialogIds.Id.DEVELOPER_DIALOG: preload("res://Features/DeveloperDialog/developer_dialog.tscn"),
		DialogIds.Id.KIDS_MODE_ENABLE_DIALOG: preload("res://Features/KidsMode/kidsmode_enable_dialog.tscn"),
		DialogIds.Id.ABOUT_DEMO_DIALOG: preload("res://Dialogs/fiiish_confirmation_dialog.tscn"),
		DialogIds.Id.DEVELOPER_OVERLAY_DIALOG: preload("res://Dialogs/DeveloperOverlay/developer_overlay_dialog.tscn"),
	}
