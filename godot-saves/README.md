# Player save fixtures

One player save per save format version: `player-version-N.data` was written by a build whose
`Player.current_version` (`godot/Scripts/player.gd`) was N. They are used to check that old saves still load
after the format changes, e.g. by the `player_save` case of the zone selection test
(`godot/Features/Scripting/Scripts/zone_selection_test_script.gd`).

## Rule

Before bumping `Player.current_version`:

1. Copy a save in the current format (`user://player.data`, in Godot's user data folder for the project) to
   `godot-saves/player-version-N.data`, N being the current version.
2. Check the version in the file: bytes 8 and 9, little endian, right after the `OMFIIISH` magic.
3. Commit the file on its own, before the commit that bumps the version.

Then bump the version, and add a check that loads the new fixture.

## Gaps

Versions 9 to 13 were never saved, so there are no fixtures for them.
