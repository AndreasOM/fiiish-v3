# TODO  - S06 leftovers

## In Progress



- [ ] Bug: Check missing input actions for Steam


## Next



- [x] Polish: Fix focus previous handling across the board
	- [x] Bug: Fix focus previous handling in ResultScreenDialog

- [x] Demo: Add 1 new zone
- [x] Demo: Don't repeat same zone back to back -- unless no other zone exists


## Todo

- [ ] Steam: Handle BigPicture mode

- [x] Feature: Rework ResultDialog for dpad control
	- [x] Task: Add Play Button to ResultDialog
	- [x] Task: Ensure correct focus handling
- [ ] Story: General cleanup pass

- [x] Feature: Clean up UX to allow better gamepad navigation
	- [x] Task: Adapt DeveloperConsole to new input scheme
	- [x] Task: Adapt ZoneEditor to new input scheme


## Todo Steam Demo
- [x] Steam: Automate uploading of new version via github action.
- [x] Steam: Improve controls
	- [x] Task: Make A-Button confirm only, and dive in game

## Todo Steam Store 
- [x] Steam: Get rid of macOS 10.15 warning -> Replaced by "no Intel" warning
- [ ] Steam: Add note about english only to description
- [ ] Steam: Store Asset - Page Background -> Use blue swirl

- [x] Steam: Finalise godotsteam addon integration


## Polish & Bugs
- [ ] Bug: Remove test zone with middle rock! -> Ensure only classic zones are included in classic
- [ ] Polish: Rebake loading screen with version for local development

## After steam demo
- [ ] #postponed Add keyboard/gamepad support to KidsModeEnableDialog

## V3.8.0 (revised) - ETA: 07/11





## V3.8.0 (original) - ETA: 06/25 - ZoneEditor (external), Achievements V2, new Zones & Campaigns

- [ ] Feature: "Campaign" configuration
- [ ] Polish: Ensure "I Love Fiiish" zone only appears rarely (once per day at least!)

- [ ] Feature: Zone Editor - Phase 2
	- [ ] Epic: Zone Editing
		- [ ] Task: Add better Spawn Object selection to ZoneEditor
		- [ ] Task: Add Select tool to ZoneEditor -> show Entity Properties
	- [ ] Epic: Zone Properties
		- [ ] Task: Add Entity Properties dialog to ZoneEditor
	- [ ] * Epic: Zone Management (deleting & renaming?!)
	- [ ] * Epic: Zone Sharing
	- [ ] * Epic: Zone Importing
	- [ ] * Polish: Visualise magnet range in ZoneEditor

- [ ] Task: Unlock Zone Editor in MainMenu via Achievements?

- [+] Task: Add the second batch of Achievements
	- [+] Bonus: Collect X coins in Y seconds || Collect Coins Per Second
	- [+] Bonus: Upgrade X Skills
	- [+] Bonus: Play X days in a row
	- [+] Bonus: Max Coins (owned) Achievement

- [+] Release: Build classic version of game via CI/CD

- [+] Bonus: Automate creation of Marketing Screenshots
- [+] Reach: Add KidsMode


### after steam next fest
- [ ] Add some performance tooling
- [?] Bug: Fix screen/window resizing from script -> Works on other machines

### postponed

- [ ] #reach Feature: Zone Editor (external v0.1)

- [ ] Task: Create 1 v3 zone for testing
- [ ] Task: Confirm only classic zones load in classic

- [ ] Task: Create some new zones!
- [ ] Bonus: Create some new (middle/center!) Rocks 
- [ ] Task: Position the fish from script
- [?] Task: Wait X frames from script
- [ ] Task: Disable achievement progress from script
- [ ] Task: Sort Launch Buttons by their sort order
- [ ] #reach Task: Set skill level from script
- [ ] #reach Task: Create Marketing Screenshots on CI system

- [ ] Feature: OMG Launch Control
	- [+] Task: Remember main_run_args when overwriting them
- [ ] #polish Bug: Ensure InGamePauseMenu Play/Pause button always shows correct state
- [ ] #polish Task: Improve and cleanup url parsing, and handling
- [ ] Feature: KidsMode
	- [ ] Story: Implement external KidsMode enabling & disabling
		- [?] Task: Handle custom scheme for macOS - maybe already done?!!!!
	- [?] Story: Plugin for iOS lifecycle handling
		- [?] Task: Get actual command line parameters, and handle them??
- [+] Task: Verify all entities used in classic zones exist

## V3.10.0 - ETA: 07/25 <-- "Fiiish!-V3 [classic]"


## -> SteamFest September'25 -> Release Classic

## Next release


## Later

- [ ] Task: Improve build action to compare tag commit with actual commit
- [ ] Feature: Fix pause handling
- [ ] Task: Create generic FrameDialog (e.g. SkillUpgrade and Leaderboard)
- [ ] 😭 Refactor: Create reusable FramedDialog 
- [ ] Polish: Unify theme to have consistent style
- [ ] Polish: Use queue to handle background transitions
- [ ] Cleanup: Ensure consistent naming of Entities
- [ ] Task: Add confirmation to Clear in ZoneEditor
- [ ] Bug: Fix MiniMap scaling
- [ ] Task: Add Minimap offset
- [x] Bug: Did the fish get slower?
- [ ] Task: Add solid hover to ZoneEditor
- [ ] Polish: Cleanup ZoneSelectDialog
- [+] Polish: Add better sound loops for ResultDialog
- [ ] Polish: Create sound loop for distance counting
- [ ] Polish: Create sound loop for coin counting

- [ ] Polish: ThemeTypeVariationTween should remove overrides when finished
- [ ] Task: Allow opening of DeveloperConsole without keyboard

- [?] Task: Add job to trigger all builds on tag (Maybe not?!) -- already done?

- [ ] Task: Document and refactor Dialog lifecycle
- [?] Fix: Weird numbers in ResultScreen -- fixed already?!


- [ ] Feature: Cloud Saves
- [ ] Fix: Cleanup fadeable container with focus on z_index
- [ ] Task: Have DialogManager ensure correct z_index
- [ ] Feature: Polish ResultDialog

## Future
- [+] Task: Have DialogManager create dialogs on the fly
- [+] Create explosion path editor
- [?] #godot crossfade toggle buttons
- [+] #godot Fix debug camera frame
- [ ] Add volume slider?
- [ ] Bonus: Animate Seaweed in code
- [+] ☠️ #unity Fix WebGL html wrapper template
- [ ] Decide if ConfirmationDialog should block all other input
- [?] Cleanup: Move pause/resume handling fully into game
- [?] Refactor: Create generic SerializableU16

## Obsolete / Won't do
- [+] Polish: Check collsion for hover mode even when not moving the mouse (e.g. a/d left/right)
- [+] Polish: Replace Leaderboard background
- [+] Polish: Fix rotation in minimap renderer
- [+] Task: Create consistent style for Achievement Icons (e.g. Bronze, Silver, Gold, Diamond, Ruby) -- kind of done (pending art pass)
- [?] Cleanup: Avoid leaving zone test mode while still dying from ZoneEditor
- [?] Task: Handle Zone Edit enabled where needed
- [?] Task: Hide Game HUD in Zone Editor ?! (After minimap)
- [?] Task: Handle Pause correctly in Zone Editor -> Do not pause in ZoneEditor
- [+] Epic: Create new button style for ZoneEditor
- [+] Epic: Create new button style for ZoneEditor
- [+] Task: Use "recycle" icon for skill reset on SkillUpgradeDialog -> Art pass
- [+] Task: Handle KidsMode for SettingsDialog? -> Settings Dialog will not be reachable
