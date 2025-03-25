# Todo

## In Progress

- [ ] Task: Change itchio upload to use signed macOS version

## Todo

## V3.2.0


## V3.4.0

- [ ] Feature: iOS version (for Testflight) (Goal: Q2 2025)
- [ ] Feature: Main Menu
- [ ] Feature: Leaderboard (incl. backend)

- [ ] Polish: Improve shop and confirmation background

- [ ] Polish: Extract Pickup handling from GameManager
- [ ] Polish: Extract zone spawning from GameManager

## Next release


## Later

- [ ] Fix: Weird numbers in ResultScreen

- [ ] Task: Use "recycle" icon for skill reset on SkillUpgradeDialog

- [ ] Feature: Cloud Saves
- [ ] Fix: Cleanup fadeable container with focus on z_index
- [ ] Task: Have DialogManager ensure correct z_index
- [ ] Bake version info into splash screen

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

## Done

### 2025-03-25
- [x] Playtest!

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

