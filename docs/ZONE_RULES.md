# Zone Rules

Checklist for designing classic zones (`godot/Resources/Zones/*.nzne`).
Numbers come from building and playtesting the `30NN_martin_*` zones.
Existing zones don't follow all of these yet; they'll be adjusted later.

Basics: the world scrolls at 240 px/s, so a 4096 px zone lasts about 17 s. The visible screen is y −512..+512.

## Feel

- [ ] Casual and chill. Nothing harder than `3012_martin_SeaSerpent`.
- [ ] Higher difficulty comes from variety and choices, not from narrower gaps.
- [ ] The zone feels like part of one connected world, not like a separate level.

## File

- [ ] The zone name inside the file matches the filename (`NNNN_Name.nzne`).
- [ ] The `difficulty` field fits the actual feel (zones are picked when difficulty ≤ run level).
- [ ] The width ends right after the zone's last obstacle plus its lead out. Pickups beyond the width overlap the next zone.
- [ ] Only the `Obstacles`, `Obstacles_01` and `Pickups_00` layers spawn.

## Lead in / lead out

The next zone spawns exactly at this zone's width, so the empty gap at a seam is the previous zone's lead out plus this zone's lead in.

- [ ] Starts with a middle passage (both edges closed): lead in about 350–400 px.
- [ ] Starts with open edges or a wide field: a short lead in is fine.
- [ ] Ends with a middle passage: lead out about 250–450 px.
- [ ] Ends with a closed middle and only edge lanes (e.g. `D0015_MIDDLE_03`): keep a longer lead out. The next zone may start with a middle gate.
- [ ] Never leave 600+ px empty at both ends. That reads as "level over".
- [ ] The first obstacle that closes both edges sits at x ≥ ~400. Edge riders need about 500 px to reach the middle.
- [ ] Test the seams against the whole pool. Joining two zones must not create a spot tighter than both zones' own tightest spot, unless the join is still ≥ 120 px wide.

## Clearance

Clearance = the narrowest gap the fish must swim through, measured as the best path.

- [ ] Easy (d ≤ 30): clearance ≥ 120 px.
- [ ] Medium (d 30–45): clearance ≥ 100 px.
- [ ] Spicy (d 45+): clearance ≥ 90 px. A short gate may go down to about 88 px.
- [ ] Long corridors (1000+ px) stay at ≥ 90 px. 84 px over 2000 px felt "too tight" in playtest.
- [ ] Points under 100 px make up less than about 5 % of the zone.
- [ ] Sloped channels: the fish's turn rate is limited, so keep slopes gentle.

## Top edge

- [ ] There is a soft barrier: a fish that isn't pressing sits at about y −396 after 5 s, −414 after 8 s, and never reaches −440.
- [ ] An open top lane must clear the lowest idle path by 50+ px, or be clearly closed by a big visible rock.
- [ ] Never leave a small nub that just reaches the idle band (e.g. a ceiling RockA tip at −432). That's a hidden death trap.
- [ ] Top and bottom don't behave the same: the top edge is easier to reach than the bottom.

## Bottom edge

- [ ] A fish holding the button rides the bottom. The same rule applies: either clearly open or clearly closed.
- [ ] Close the floor with kelp or flush rocks, not a lone thin spike.
- [ ] Floating off-centre boulders leave skim-or-die edge lanes. Close them with sunk crags that visibly touch the boulder's line (tip about ±340).

## Rocks & visuals

- [ ] RockA–F and SeaWeed have a flat cut base. Put the cut on y = ±512 (flush or sunk) or cover it with another rock that comes later in the file.
- [ ] Only `RockMiddleB` floats free.
- [ ] Flush |y| puts the cut exactly on the screen edge. Use a larger |y| to sink the rock further; a smaller |y| shows the cut. Ceiling pieces use −y and rotation 180.

  | Rock | flush \|y\| | | Kelp | flush \|y\| |
  |---|---|---|---|---|
  | RockA | 467.5 | | SeaWeedA | 455 |
  | RockB | 402 | | SeaWeedB | 421.5 |
  | RockC | 325.5 | | SeaWeedC | 393 |
  | RockD | 294 | | SeaWeedD | 364 |
  | RockE | 234 | | SeaWeedE | 347 |
  | RockF | 243 | | | |
- [ ] Rotated (tilted) rocks move their cut edge. Re-check every tilt.
- [ ] A cover rock only hides a cut edge if it comes later in the file, because all obstacles share the same draw layer.
- [ ] To set a rock's tip height, sink a bigger rock instead of floating a small one.
- [ ] Ceiling pieces use rotation 180. Use few tilts and keep the look natural.
- [ ] No identical rocks repeated at even spacing. Mix sizes and sink depths, and vary the gaps.
- [ ] Gaps and jaws have shoulders, so tips don't stand alone as bare needles.

## Coins

The game is about swimming. Coins are a bonus. Surviving is what has to feel chill; not getting every coin is fine.

- [ ] **No coin-lure death traps.** A coin, or the line between coins, must never pull a player into a crash they can't see coming or get out of. This is the one hard rule.
- [ ] Zones without coins are fine.
- [ ] Not every coin has to be reachable without upgrades. Coins that only a bigger magnet can pull in are fine.
- [ ] Coin lines don't have to be swimmable in one go. Missing coins is OK. Dying because you went for them is not.
- [ ] Keep coins light. The martin pack (about 2–2.8 coins/s, ≈30 per 4096 px) is too coin heavy. Aim for roughly 1 coin/s (≈15 per 4096 px) or less, closer to the old zones. Short groups beat long unbroken lines.
- [ ] A jackpot zone can go clearly higher, but only rarely. Harder zones put more of their coins on brave lines, not more coins overall.
- [ ] Coin centres are ≥ ~35 px from rock and kelp pixels (include kelp sway). Coins draw under obstacles, so they hide otherwise.
- [ ] Brave coins sit in valleys about 190 px past the safe line. The magnet makes coins near tips free.

### Coin caches (teasers)

- [ ] Coins may be boxed in by rocks so they can't be swum to: a teaser.
- [ ] The magnet works on distance only and pulls through rocks. Caches become reachable with magnet upgrades or a Magnet pickup, which makes them a hint at upgrades.
- [ ] A cache must be clearly closed. It can't have a gap that looks like you could swim in, and it can't sit right next to the safe line, so nobody dives at it and dies.
- [ ] Place caches so the base magnet just misses them from the safe line and an upgraded magnet or Magnet boost reaches them.
- [ ] Use them sparingly: one cache per zone at most.

## Specials (Magnet / Explosion / Rain)

- [ ] 0–1 per zone. A jackpot zone may have 3.
- [ ] Forks: the harder route carries the bigger reward. Never put the Explosion on the easy route.
- [ ] Rain works as a finale: the coin rhythm leads into it.
- [ ] Explosion spawns its coins 50 px ahead of the fish with forward speed, so leave open water after it.

## Before shipping

- [ ] Check clearance and difficulty in the simulator.
- [ ] Check that no rock's cut edge is visible on screen.
- [ ] Check coin visibility and check for lures: nothing that leads into a crash.
- [ ] Check what an idle rider and an edge rider hit, from every entry height.
- [ ] Check the seams against the pool.
- [ ] Playtest.
