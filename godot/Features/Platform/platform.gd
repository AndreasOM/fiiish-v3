class_name Platform

## Returns true for an editor run and for a developer account of the platform.
static func is_developer() -> bool:
	var developer_enabled = false
	if FeatureTags.has_feature("editor_runtime"):
		developer_enabled = true

	if SteamWrapper.is_developer():
		developer_enabled = true

	return developer_enabled
