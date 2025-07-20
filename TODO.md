# Todo

## In Progress



## Next

- [ ] Verify: Play X days in a row Achievement


## Todo

- [ ] Story: General cleanup pass


## Polish & Bugs
- [ ] Release: Fix MarketingScreenshots
- [ ] Bug: Remove test zone with middle rock! -> Ensure only classic zones are included in classic

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

## Done

### 2025-07-19
#### S05E17
- [x] Task: Trigger achievement completions directly
- [x] #reach Feature: Achievements V2.0
- [x] Feature: Release a classic version via CI/CD -- Note: Done earlier
- [x] Polish: Remove M key from game/fish
- [x] Polish: Add skill upgrade price to skill element

### 2025-07-18
#### S05E16
- [x] Bonus: Collect X coins in Y seconds || Collect Coins Per Second
- [x] Bug: Fixed Tester 1 Achievement should have conditions
- [x] Task: Add the second batch of Achievements
- [x] Polish: Allow hidden achievements

### 2025-07-16
#### S05E15
- [x] Bonus: Max Coins (owned) Achievement
- [x] Bonus: Upgrade X Skills Achievement
- [x] Bonus: Play X days in a row Achievement

### 2025-07-07
#### S05E14
- [x] Task: Sign and upload classic version for iOS
- [x] #offstream Task: Create provisioning profile for classic iOS
- [x] Task: Upload (and sign) all latest classic builds
- [x] Task: Move serializer et al to [omg-lib (submodule)](https://github.com/AndreasOM/omg-lib)

### 2025-07-04
#### S05E13
- [x] Task: Add export plugin to ensure name overrides are used
- [x] Task: Create minimal export plugin to check if overrides work for "application/config/name" (https://github.com/AndreasOM/godot-export-test)
- [x] Task: Extend ExportOverride plugin to support icon
- [x] Task: Classic is using wrong name in menu, but correct window title -> broken overrides on export (Godot Bug!)


### 2025-07-03
#### S05E12
- [x] Bug: v3.1.4 vs v3.2.0 - Malware? Codesigning -> Certificate was revoked, deploy new one
- [x] Task: Add Disable KidsMode to itch launcher -> Needs itch launcher fixes
- [x] Task: Ensure all functions have a return type
- [x] Task: Ensure all function names are snake_case

### 2025-07-02
#### S05E11
- [x] #offstream Task: Create itch.io page for **classic**
- [x] Task: Create export settings for -classic versions
- [x] Task: Use editor/run/main_run_args to pass launch_parameters
- [x] Task: Use EditorDebuggerSession.stopped signal to clear main_run_args
- [+] Task: Experiment with using session stopped for clearing launch parameters
- [x] Task: Build -classic version on CI system
- [x] Task: Upload classic builds to itch.io
- [x] Task: Create kidsmode.html on fiiish-v3 and fiiish-classic websites -> https://games.omnimad.net/games/fiiish-v3/kidsmode/
- [x] Task: Create **classic** loading/title-image
- [x] Task: Patch v3 -> classic in app/binary name when building classic

### 2025-07-01
#### S05E10
- [x] Task: Handle scaling < 1.0 for WindowAlignedSprite2D
- [x] Task: Add cover mode for WindowAlignedSprite2D
- [x] Fix: Use correct window size to position overlay
- [x] Task: Write Marketing Screenshot script
- [x] Feature: Marketing Screenshots
- [x] Bug: Fix Overlay z-layer
- [x] Bug: Disable window size buttons in non-Desktop build

### 2025-06-30
#### S05E09
- [x] Task: Create script to collect screenshots
- [x] Task: Upload first test screenshots to App Store Connect
- [x] Task: Close game when done with Marketing Screenshots
- [x] Task: Set window size from script
- [x] Task: Set coins from script
- [x] Task: Set distance from script
- [x] Task: Hide Toasts from script
- [x] Task: Hide Developer Dialog from script
- [x] Task: Add WindowAlignedSprite2D, and use it for Overlays

### 2025-06-26
#### S05E08
- [x] Task: Start Marketing Screenshots script via Launch Control
- [x] Task: Load zone from script
- [x] Task: Take screenshot from script
- [x] Task: Automatically keep fish in certain height range from script
- [x] Task: Add overlay from script

### 2025-06-21
#### S05E07
- [x] Task: Add more functionality to iOS lifecycle plugin.
- [x] Task: Handle custom scheme for iOS

#### S05E06
- [x] Task: Create plugin stub for iOS lifecyle handling [omg_lifecycle_plugin_ios](https://github.com/AndreasOM/omg_lifecycle_plugin_ios)

### 2025-06-21
#### S05E05
- [x] Task: Wrap LaunchButton into control to pass called in signal
- [x] Task: Configure LaunchButtons via config in config folder
- [x] Story: Handle Game-Editor communication via EngineDebugger and EditorDebuggerPlugin
- [x] Task: Clear launch parameter once it was used
- [x] Task: Register custom scheme for iOS and macOS
- [x] Task: Log launch parameters to Toast and DeveloperConsole

### 2025-06-20
#### S05E04
- [x] Task: Add KidsMode (enable) button to SettingsDialog
- [x] Story: Create KidsModeEnableDialog
- [x] Task: Abort current run when disabling KidsMode
- [x] Task: Abort current run when enabling KidsMode
- [x] Task: Leave ZoneEditor when entering KidsMode
- [x] Story: Enable KidsMode
- [x] Task: Get URL parameters for web version
- [x] Task: Create basic OMG Launch Control plugin

### 2025-06-19
#### S05E03
- [x] Task: Remember KidsMode
- [x] Task: Add 2nd player save for KidsMode
- [x] Task: Toggle developer dialog via DeveloperConsole
- [x] Task: Remember if developer dialog is enabled
- [x] Task: Enable KidsMode from KidsModeEnableDialog
- [x] Task: Move Audio settings to Settings
- [x] Task: Reload achievement state when toggling KidsMode
- [x] Task: Handle KidsMode for InGamePauseMenuDialog
- [x] Task: Close SettingsDialog when entering KidsMode
- [x] Task: Handle KidsMode for ResultDialog
- [x] Story: Handle KidsMode for all Dialogs
- [x] Task: Load KidsModeEnableDialog text based on v3 vs classic

### 2025-06-17
#### S05E02
- [x] Bug: Fix ios build
- [x] Task: Add developer dialog
- [x] Task: Create KidsModeEnableDialog
- [x] Task: Add development button to toggle KidsMode
- [x] Story: Developer dialog

### 2025-06-16
#### S05E01
- [x] Task: Cleanup and Unify build workflows
- [x] Story: Disable v3 features in classic
- [x] Task: Disable GameMode selection in classic
- [x] Task: Disable ZoneEditor selection in classic
- [x] Task: Upload web build of classic

### V3.6.0 - Released: 2025/06/16 - ZoneEditor (internal) with MiniMap, Achievements V1

### 2025-06-02
#### S04E22
- [x] CI/CD: Align both webgl build workflows
- [x] CI/CD: Bake version info into splash screen
- [x] CI/CD: Unify VERSION to not include 'v'
- [x] Assets: Add new Test Rock Middle A
- [x] Task: Create and use classic icon (placeholder)

### 2025-05-30
#### S04E21
- [x] Polish: Limit Fish movement in ZoneEditor
- [x] Add MiddleRockA
- [x] Add RockSetA (TopLeft, TopMiddle)
- [x] Add BigRockA 6x2

### 2025-05-29
#### S04E20
- [x] Cleanup: Reduce Achievement tracing
- [x] Task: Sort Achievements by sort_index
- [x] Total Distance Achievements			sort_index: 104x (1041-1045)
- [x] Total Coins Achievements				sort_index: 106x (1061-1065)
- [x] Times Played
- [x] Task: Add the first full batch of Achievements
- [x] Feature: Achievements
- [x] Polish: Make Pause Overlay visible again
- [x] Polish: Unpause when opening ZoneEditor
- [x] Epic: GameMode - Edit -> Replaced by ZoneTest
- [x] Feature: Zone Editor - Phase 1

### 2025-05-28
#### S04E19
- [x] Task: Trigger Toast via DeveloperConsole
- [x] Bug: Show ToastDialog in front of other dialogs
- [x] Task: Add special Toast for completed Achievement
- [x] Task: Add special Toast for received Rewards
- [x] Epic: Visualise Achievements
- [x] Task: Save player after collecting an Achievment (later for easier testing)
- [x] Epic: Define and configure Achievements and Rewards
- [x] Single Run Distance Achievements		sort_index: 101x (1011-1015)
- [x] Single Run Coins Achievements			sort_index: 103x
- [x] Bug: Result for last swim are wrong?!

### 2025-05-27
#### S04E18
- [x] Task: Create grid view for AchievementsDialog (top details, bottom grid)
- [x] Task: Make Achievements collectable in AchievementDialog
- [x] Task: Rework AchievementView to avoid recreating entries on update
- [x] Task: Highlight selected Achievement in AchievementDialog grid
- [x] Task: Add reward configuration to AchievementConfig
- [x] Task: Give Achievment Rewards on collection

### 2025-05-22
#### S04E017
- [x] Task: Add button to ResultDialog to go to AchievementsDialog
- [x] Polish: Reset Achievements when resetting Player view DeveloperConsole
- [x] Task: Add generic ToastDialog
- [x] Task: Increase font size in AchievementDialog

### 2025-05-21
#### S04E16
- [x] Task: Add AchievementsDialog

#### S04E15
- [x] Task: Allow Achievements to be configured
- [x] Task: Configure some example Achievements
- [x] Task: Add Counters
- [x] Task: Handle and update Achievements
- [x] Epic: Track Achievements
- [x] Task: Serialize Achievements
- [x] Task: Create SerializableString
- [x] Task: Rework AchievementConfig
- [x] Task: Use prerequisite Achievements when checking Achievements

### 2025-05-20
#### S04E14
- [x] Task: Update right ZoneBoundary in realtime in ZoneEditor
- [x] Task: Enforce ZoneBoundaries in ZoneEditor
- [x] Task: Skip Areas when selection the Entity to be spawned in ZoneEditor
- [x] Bug: Ensure unique IDs when loading a zone in ZoneEditor
- [x] Bug: Fix Redo in ZoneEditor -- ensure Redo of Spawn will reuse ID
- [x] Polish: Add Fading to ZoneEditorMenuDialog
- [x] Cleanup: Fixup background fading with new transitions
- [x] Polish: Add outline for coins and distance in HUD
- [x] Refactor: Turn InGamePauseMenu into a Dialog

### 2025-05-19
#### S04E13
- [x] Polish: Unselect object in Delete mode when clicking on _nothing_ in ZoneEditor
- [x] Task: Add Zone Properties dialog to ZoneEditor
- [x] Task: Add Save button to ZoneEditorMenuDialog
- [x] Task: Add Reload button to ZoneEditorMenuDialog
- [x] Task: Visualise Zone width in ZoneEditor
- [x] Epic: Zone Testing
- [x] Polish: Move Zone Testing quit button to Zone Properties dialog

### 2025-05-16
#### S04E12
- [x] Cleanup: Improve Fish management with FishManager

### 2025-05-15
#### S04E11
- [x] Bug: get_meta with default null throws errors when meta doesn't exist
- [x] Cleanup: Remove ResourceTables Addon
- [x] Cleanup: Check for DirAccess.get_files_at usage to find files at runtime

### 2025-05-14
#### S04E10
- [x] Task: Ensure ZoneEditorCommandHandler can handle undo of deleted objects -- use node ids instead of references
- [x] Task: Add Object rotating to ZoneEditor
- [x] Task: Add Rotation tool to ZoneEditor
- [x] Task: Allow clearing of Zone in ZoneEditor
- [x] Bug: Wipe undo buffer on zone change and clear in ZoneEditor
- [x] Task: Add 1-step Object spawning to ZoneEditor
- [x] Task: Add 2-step Object spawning to ZoneEditor
- [x] Task: Add Redo to ZoneEditor
- [x] Task: Allow to change which Object will be Spawned in ZoneEditor
- [x] Refactor: Use resources to configure entities

### 2025-05-13
#### S04E09
- [x] Task: Connect ZoneEditorToolsDialog to ZoneEditorManager
- [x] Task: Add history for tracking ZoneEditor edits to ZoneEditorCommandHandler
- [x] Task: Add delete (object) to ZoneEditorCommandHandler
- [x] Task: Add Undo to ZoneEditorCommandHandler
- [x] Refactor: Switch PickupManager to use `_process` instead of `_physics_process`
- [x] Refactor: Switch Fish to use `_process` instead of `_physics_process`
- [x] Task: Add Object moving to ZoneEditor
- [x] Epic: Minimap (with Scrolling)

### 2025-05-12
#### S04E08
- [x] Task: Create ZoneEditorToolsDialog
- [x] Task: Select objects in ZoneEditor
- [x] Task: Delete objects in ZoneEditor :HACK:
- [x] Cleanup: Add helper to ZoneManager to get pickups sorted by distance
- [x] Task: Add selection cursor offset to ZoneEditor on touch devices
- [x] Task: Re-add scrolling through zone in ZoneEditor
- [x] Task: Improve highlighting of selected object in ZoneEditor

### 2025-05-10
#### S04E07
- [x] Polish: Force enable linear mip maps on seaweed
- [x] Task: Experiment with multiple selection methods, and settle on distance (pickups) and raycast (obstacles)

### 2025-05-09
#### S04E06
- [x] Task: Dynamically fill the Zone Selection Dialog
- [x] Task: Allow entering a new filename in the ZoneSelectDialog (Save As)
- [x] Epic: Zone Selection and Loading
- [x] Task: Save current zone from ZoneEditor
- [x] Epic: Zone Saving
- [x] Task: Enable user zone in demo version
- [x] Cleanup: Remove a lot of errors and warnings
- [x] Bug: Ensure user zones folder exists

### 2025-05-08
#### S04E05
- [x] Task: Move Fish up & down in ZoneEditor
- [x] Task: Remove despawning in Zone Editor
- [x] Polish: Use MipMap for Background
- [x] Task: Make Fish goto Dying (without result) when leaving ZoneEditor
- [x] Task: Remember last offset in ZoneEditor (player save)
- [x] Task: Add name to file mapping in ZoneManager
- [x] Task: ZoneManager allow loading of specific zone
- [x] Task: Remember last edited zone in ZoneEdit
- [x] Task: Add Menu entry in ZoneEditor to Load a zone
- [x] Task: Create Zone Selection Dialog - very basic first draft

### 2025-05-07
#### S04E04
- [x] Task: Turn Minimap into Dialog
- [x] Task: Only show MiniMap in ZoneEditor
- [x] Polish: Fix Leaderboard background, and removed duplicate
- [x] Bug: Make ThemeTypeVariationTween cleanup at end
- [x] Task: Disable pickup processing in ZoneEditor
- [x] Refactor: Make GameManager movement_x/movement the actual movement, and not the speed
- [x] Task: Limit ZoneEditor movement to Zone size.
- [x] Hack: Spawn random zone when going into ZoneEditor. Probably: "I Love Fiiish" zone

### 2025-05-06
#### S04E03
- [x] Task: Rework MiniMap using world_2d
- [x] Bug: Fix background repeat (inside viewport)
- [x] Bug: Fix mouse input inside viewport

### 2025-05-01
#### S0402
- [x] Task: Create basic MiniMap rendering

### 2025-04-30
#### S04E01
- [x] Release v3.4.0
- [x] Task: Add Zone Editor to Main Menu
- [x] Task: Add Quit to Main Menu in Zone Editor (ZoneEditorMenuDialog)
- [x] Task: Hide InGamePauseMenu when in Zone Editor
- [x] Task: Add clear info about being in Zone Editor to ZoneEditorMenuDialog
- [x] Task: Add placeholder for Menu in ZoneEditorMenuDialog
- [x] Task: Move zone in Zone Editor with keys (A <- -> D). Fast scroll via SHIFT.
- [x] Task: Add drag and move to Zone Editor

### V3.4.0 - 2025-04-30

### 2025-04-28
#### S03E20
- [x] Fix iOS builds. Update runners to macos-15
- [x] Polish: Make ResultDialog Audio mutable via settings
- [x] Refactor: Split Background into Background and FiiishBackground
- [x] Bonus: Make FiiishBackground testable in editor

### 2025-04-24
#### S03E19
- [x] Polish: Improve shop and confirmation background
- [x] Tweak: Avoid clearing Leaderboard (test) entries in editor
- [x] Polish: Use AnimationPlayer for result display
- [x] Bonus: Rework Background

### 2025-04-23
#### S03E18
- [x] Animate MainMenu in and out
- [x] Minor tweaks to Dialog lifecycle
- [x] Animate Focused MainMenu entry
- [x] Feature: Main Menu

### 2025-04-17
#### S03E17
- [x] Refactor: Extract Pickup handling from GameManager
- [x] Refactor: Extract zone spawning from GameManager

### 2025-05-16
#### S03E16
- [x] Bonus: Special highlight if latest rank was first rank
- [x] Bug: Leaderboard not always receiving latest run correctly
- [x] Feature: Leaderboard (excl. backend, local only)
- [x] Polish: Use ThemeTypeVariationTween for new best on ResultDialog
- [x] Experiment: Add screen shake on death

### 2025-05-15
#### S03E15
- [x] Polish: Use drop down menu to select HighlightLabel theme type variation
- [x] Refactor: Create reusable ThemeTypeVariationTween and use it for HighlightLabels


### 2025-04-14
#### S03E14
- [x] Refactor: Move HashMap serialization into HashMap
- [x] Refactor: Create HashSet, and use it for Player Cheats
- [x] Refactor: Create SerializableArray, and use it for Leaderboards
- [x] Refactor: Add ChunkMagic handling to Serializer
- [x] Refactor: Consider using HashMap for Zone loader
- [x] Polish: Highlight latest rank on local Leaderboard

### 2025-04-06
#### S03E013
- [x] Polish: Open LeaderboardDialog from ResultDialog
- [x] Task: Add cheat to reset local highscores
- [x] Polish: Visualise new highscore in ResultDialog
- [+] ~Task: Add serialize for dictionary~ (see next below)
- [x] Task: Create custom HashMap (based on Dictionary) with serialize method

### 2025-04-05
#### S03E012
- [x] Task: Create LeaderboardElement
- [x] Task: Update scores at end of run
- [x] Task: Create Leaderboard (data/storage)
- [x] Task: Add serialize for array

### 2025-04-04
#### S03E11
- [x] Task: Create LeaderboardDialog
- [x] Task: Add https://www.keshikan.net/fonts-e.html to Credits

#### S03E10
- [x] Task: Create generic MainMenuEntry
	- Including disabled state
	- Visualise focused state
	- Bonus: Allow keyboard & gamepad(?) input
- [x] Task: Add game mode entry to MainMenu
- [x] Task: Add Zone Editor entry (disabled) to MainMenu
- [x] Task: Add Leaderboard entry to MainMenu
- [x] Task: Create wrapped job to build, archive, and upload iOS
- [x] Task: Create wrapper job to upload all latest builds



### 2025-04-03
- [x] Polish: Dim game on pause
- [x] Refactor: Move InGamePauseMenu to separate scene
- [x] Polish: Rotate on iOS
- [x] Bug: Do not open soft keyboard on startup (by disabling the DeveloperConsole)
- [x] Task: Cleanup version info in SettingDialog

### 2025-04-02
- [x] Feature: iOS version (for Testflight) (Goal: Q2 2025)

### 2025-03-31

### 2025-03-26

- [x] Task: Add mouse & touch controls for Fish
- [x] Task: Add setting to enable MainMenu
- [x] Task: Add cheat to make Fish invincible, and store in Player Prefs


### 2025-03-25 - After release
- [x] Task: Create minimal MainMenu dialog
- [x] Task: Open MainMenu
- [x] Task: Add credits entry to MainMenu
- [x] Task: Create minimal Credits dialog

### V3.3.0-rc1 - 2025-03-25

### 2025-03-25
- [x] Playtest!
- [x] Task: Change itchio upload to use signed macOS version

### 2025-03-23
- [x] Polish: Improve buy right mini button
- [x] Feature: Skill Upgrades
- [x] Story: Skill Upgrade Dialog
- [+] Task: Open Skill Upgrade Dialog from Result Dialog
- [+] Polish: Improve coin and skill point mini icons
- [x] Task: Split out ZoneManager from GameManager
- [x] Task: Add job to codesign macOS version

### 2025-03-22
- [x] Feature: Build Demo WebGL version on tag
- [x] Task: Add workflow to build WebGL on tag
- [x] Task: Add Demo variant with reduced content
- [x] Polish: Auto complete to the shared prefix of candidates
- [x] Polish: Fade items behind confirmation dialog
- [x] Polish: Improve buy right mini button a little

### 2025-03-21
- [x] Fix: Make sure front most dialog is interactable
- [x] Tweak Dialog lifecycle management
- [x] Feature: Developer Console
- [x] Cleanup: Keep focus on DeveloperConsole after submitting


### 2025-03-19 - After release
- [x] Cleanup: Remove pink frame from ResultScreen

### V3.1.2-dev - 2025-03-19

Release a quick update to itch.io.

### 2025-03-19
- [x] Update: Update to Godot 4.4
- [x] Task: Replace background

### 2024-12-23
- [x] Cleanup: Use FiiishConfirmationDialog for skill reset confirmation
- [x] Task: Start adding basic developer console

### 2024-12-10
- [x] Task: Disable buy skill points if not enough coins
- [x] Polish: Experiment with horizontal "header" flow for buying skill points with coins
- [x] Task: Add confirmation popup for skill reset
- [x] Task: Add popup when can't afford skill

### 2024-12-05
- [x] Fix: Make closed dialogs invisible
- [x] Task: Fix/Add coin and skill point icons
- [x] Task: Make buy skill points stand out as button
- [x] Polish: Turn reset into real button

### 2024-12-03
- [x] Task: Create basic DialogManager
- [x] Task: Use DialogManager to handle SkillUpgradeDialog
- [x] Task: Use DialogManager to handle SettingDialog
- [x] Task: Use DialogManager to handle ResultDialog
- [x] Story: Move all dialogs into dialog manager
- [x] Cleanup: Restructure Main Scene

### Forgot when
- [x] Story: Skills
- [x] Task: Apply remaining skill levels during play

### 2024-11-27
- [x] Polish: Drop coins on death
- [x] Task: Make close button smaller
- [x] Story: Do final balancing pass for skills
- [x] Task: Limit lucky streaks 
- [x] Task: Apply skill point costs when buying skills
- [x] Task: Apply price when buying skill points
- [x] Polish: Make fish accelerate on death

### 2024-11-28
- [x] Task: Cleanup skill handling
- [x] Task: Rebalance skills: Magnet, Magnet Boost Power & Duration
- [x] Task: Add luck skill
- [x] Task: Apply luck to coin explosion
- [x] Task: Rebalance Coin Explosion skill

### 2024-11-16
- [x] Cleanup: Replace skill effect levels with skill levels in player
- [x] Task: Define skill config for balancing
- [x] Task: Apply magnet range skill level during play

### 2024-11-13
- [x] Task: Add close button to Skill Upgrade Dialog
- [x] Task: Save skill points in player
- [x] Task: Fix hscroll of Skill Upgrade Item
- [x] Task: "Buy" skill points in Skill Upgrade Dialog
- [x] Task: Reset skill points in Skill Upgrade Dialog
- [x] Task: Save skills in player

### 2024-11-12
- [x] Task: Set up basic Skill Upgrade Dialog

### Forgot when
- [x] #godot Figure out why only top portion of music and sound buttons is clickable in settings

### 2024-11-08
- [x] #unity Load zones via http if needed

### 2024-11-07
- [x] #unity Fix Demo overlay glitch
- [x] #unity Fix audio in WebGL
- [x] #unity Fix player data storage

### 2024-11-06
- [x] #unity Add splash screen
- [x] #unity Create a demo build

## Released

### V3.0.1-rc3 - 2024-10-29

First release of the Godot version on itch.io.
[itch.io - v3.0.1-rc3-uploaded](https://omni-mad.itch.io/fiiish-v3/devlog/824500/v301-rc3-uploaded)

(### V3.0.0 - Target: 2024-10-31)


### 2024-10-29
- [x] #godot Add splash screen
- [x] #godot Add version to butler uploads for itchio

### 2024-10-28
- [x] #godot Check why zones are missing in web build
- [x] #godot Create a demo build

### 2024-10-26
- [x] #godot Fix background and game to work on all window sizes
- [x] #godot Fix game ui for all window sizes, and re-fix game scale

### 2024-10-24
- [x] #godot Add music
- [x] #godot Add SFX
- [x] Remove debug UI

### 2024-10-22
- [x] #unity Polish SFX
- [x] #unity Move setting in front of result
- [x] #unity Fix z-fighting of pickups by adding a z-bias

### 2024-10-21
- [x] #unity Set background transitions and movement
- [x] #unity Add music
- [x] #unity Start adding sound

### 2024-10-18
- [x] #godot Resize debug ui to allow clicks on settings buttons
- [x] #godot Polish result dialog
- [x] #godot Add background transitions and movement

### 2024-10-17
- [x] #godot Start adding result dialog
- [x] #godot Add player serialization

### 2024-10-16
- [x] #unity Polish result dialog
- [x] #unity Save player progress

### 2024-10-15
- [x] #unity Add player serialization
- [x] #unity Start adding result dialog

### 2024-10-10
- [x] #unity Add fading to settings button
- [x] #unity Add crossfading toggle button
- [x] #unity Refactor pause handling
- [x] #unity Add InGame Settings dialog (partially working)


### 2024-10-08
- [x] #unity Add HUD with coin and distance info
- [x] #unity Add pause menu

### 2024-10-05
- [x] #godot Add crossfading toggle buttons
- [x] #godot Add InGame Settings dialog (partially working)

### 2024-10-03
- [x] #godot Add coin rain
- [x] #godot Add coin explosion
- [x] #godot Add HUD with coin and distance info
- [x] #godot Add pause menu

### 2024-10-01
- [x] #godot Collect pickups
- [x] #godot Add remaining pickups
- [x] #godot Implement magnet effect

### 2024-09-26
- [x] #unity Add coin rain effect
- [x] #unity Add bad version of coin explosion
- [x] #unity Add improved version of coin explosion

### 2024-09-24
- [x] #unity Collect pickups
- [x] #unity Add remaining pickups
- [x] #unity Implement magnet effect

### 2024-09-17
- [x] #unity Complete simple zone management
- [x] #unity Add seaweed obstacles
- [x] #unity Start adding pickups


### 2024-09-15
- [x] #unity Add some basic debug UI
- [x] #unity Switch to local transforms
- [x] #unity Add zone debug UI
- [x] #unity Add auto spawning of zone
- [x] #unity Load, and use all legacy zones

### 2024-09-12
- [x] #unity Improve obstacle spawning, and loading
- [x] #unity Add remaining rocks

### 2024-09-10
- [x] #unity Load legacy "new" zone and spawn it

### 2024-09-06
- [x] #godot add missing seaweed
- [x] #godot More zone management

### 2024-09-04
- [x] #godot add debug ui
- [x] #godot fix collision shapes for rocks
- [x] #godot add all v2 zones

### 2024-09-03
- [x] #godot Add simple zone management
- [x] #godot Load legacy "new" zones and spawn them

### 2024-08-31
- [x] #unity Set up basic project
- [x] #unity Add fish and basic movement
- [x] #unity Set up obstacles, and collisions
- [x] #godot Add fish and basic movement

### 2024-08-30
- [x] #godot Set up basic project


## Released






## Plan

- [x] Extract all needed assets from Fiiish-rs
- [x] Setup base project
- [x] Add fish and basic movement
- [x] Add obstacles, with collisions
- [x] Add zones (including loading & ~saving~ of legacy format) and zone management
- [x] Add pickups (coins, and specials)
- [+] Handle death and restart -> improve later
- [x] Add in game hud
- [x] Add in game (pause) menu and settings
- [x] Save & Load settings and progress
- [x] Add result dialog
- [x] Add background
- [x] Add music
- [x] Add sfx
- [ ] Improve death (cleanup, etc)
- [ ] Bonus: Add basic script support -- for testing and screenshots

