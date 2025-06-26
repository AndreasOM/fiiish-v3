class_name MarketingScreenshotScript
extends Node

func run() -> bool:
	print("MarketingScreenshotScript - run()")
	await get_tree().create_timer(5.0).timeout
	print("MarketingScreenshotScript - done()")
	return true
