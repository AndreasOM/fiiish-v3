# Economy Design

How coins, skill points and skills fit together in Fiiish! Classic, plus the planned Legacy and Ascension layers.

Status: proposal. Hours come from a simulation of a typical player (inputs under [Pacing](#pacing-first-cycle-casual)). Confirm them in playtests before tuning further. Plain bullets are the design; checkboxes are work still to do or decide.

## Goals

- A casual player maxes every skill in about **15 hours** on the first playthrough.
- An optimized player needs about 9 hours. **Floor: never under 2 hours.** The floor is checked in the simulation, not enforced in the game.
- Upgrades come often early on. Later waits are longer but always end in a big reward.
- Swimming stays calm. The economy never pushes players into risky play.
- Legacy (10 rebirths) and Ascension carry the long-term game.

## Words used

| Term | Meaning |
|---|---|
| Coin | Collected while swimming. Spent on skill points. |
| Skill point | Bought with coins, or earned from achievements. Spent on skill levels. |
| Skill level | L0 (start) to L5 (max). |
| Cycle | Playing from L0 until every skill is at L5. |
| Legacy level (R) | Number of rebirths: R0 on the first cycle, up to R10. |
| Ascension | A full reset after R10 that pays a cosmetic currency. |

## Skills

Six skills. Values per level at R0 (today's values unless marked **new**):

| Skill | Unit | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|---|
| Magnet | range in px | 146 | 171 | 205 | 256 | 341 |
| Coin Explosion | coins per Explosion pickup | 6 | 12 | 24 | 48 | 96 |
| Coin Rain | coins/s | 11 | 15 | 18 | 22 | 33 |
| ↳ Coin Rain duration | s (part of Coin Rain; doesn't scale with Legacy) | 1.1 | 1.5 | 2 | 2.5 | 3 |
| Luck | chance in 10 000, per roll (**new**) | 5 | 10 | 20 | 30 | 45 |
| Magnet Boost Power | % bonus to Magnet range and pull speed while a Magnet pickup is active | 10 | 50 | 100 | 150 | 200 |
| Magnet Boost Duration | % bonus on how long that lasts (base 1 s) | 10 | 30 | 60 | 100 | 150 |

At L0: Magnet 128 px, Explosion 3 coins, Rain 10 coins/s for 1 s, no Luck. Without Boost Power a Magnet pickup has no effect.

- **Luck:** every coin spawned by an Explosion or Rain gets two rolls, as today: first a chance to become an Explosion pickup, then (if not) the same chance to become a Rain pickup. The table gives that chance per roll, in 10 000. Today's values are 10 / 25 / 50 / 75 / 150 in the same unit, which is too high: at L5 one Explosion sets off more than one new special on average, so chains only stop at the built-in cooldown. With the new values chains die out on their own. The cooldown stays as a safety net.
- [ ] Magnet Boost Power and Duration need a bigger L5 (the step from L4 is too small for a capstone) and need to earn more. They only help when a Magnet pickup appears. Decide new L5 values and whether Magnet pickups should appear more often.

## Levels and skill points

Every skill uses the same level structure:

| Level | Skill points | Role | Should feel like |
|---|---|---|---|
| L1 | 1 | Teaser | First minutes: "oh, this does something" |
| L2 | 2 | Teaser | |
| L3 | 5 | Valuable | Real power, first hour |
| L4 | 12 | Valuable | Worth saving for, first hours |
| L5 | 30 | Capstone | A big goal you clearly worked for |

- 50 points per skill, 300 points to max everything.
- **Capstone lock:** buying any L5 needs **every** skill at L4 or higher. It applies to every purchase, also after a skill reset.
- Skill reset (already in the game) refunds all spent points.
- [ ] Skill screen: show a locked L5 with its reason ("All skills at L4 first: 2 skills to go"), and already show its effect and price as a goal.
- [ ] While saving for a capstone, show progress (e.g. "18 / 30 points").
- [ ] Buying the last capstone of a cycle unlocks the rebirth. Celebrate it as the end of the cycle.
- [ ] Point players who get stuck to the free skill reset.

### Price of a skill point

**Price = ceil( (100 + 0.551 × n^1.472) × (1 + 0.7 × R) )**

- **n** = skill points received so far in this cycle, bought or from achievements (the game already counts these). The first point has n = 0.
- n goes back to 0 on rebirth.
- A skill reset doesn't change n.
- Prices at R0:

| n | 0 | 10 | 50 | 100 | 200 | 299 |
|---|---|---|---|---|---|---|
| Coins | 100 | 117 | 275 | 585 | 1 444 | 2 529 |

- Buying all 300 points costs about 325 000 coins at R0. On the first cycle achievements cover 56 points, so players pay about 315 000.
- Today's price is 20 + 0.1138 × n^1.472. The higher start price spreads the first upgrades out: about one per run, instead of seven in the first minute.

### Pacing (first cycle, casual)

| Milestone | When |
|---|---|
| All L1–L2 | ≈ 25 min |
| All L3 | ≈ 1 h |
| All L4 | ≈ 3 h |
| First capstone | ≈ 5 h |
| All L5 | ≈ 15 h |

| Tier | Wait between upgrades |
|---|---|
| L1–L2 | 1 per run or two |
| L3 | 5–10 min |
| L4 | 20–35 min |
| L5 | 1.5–2 h (the last one ≈ 3 h; its reward is the rebirth) |

Simulation inputs (casual):
- 55 % of zone coins collected, plus 5 % per Magnet level.
- 60 % of Explosion and Rain coins collected.
- 3 % chance to die per zone, more in harder zones.
- 37 s per run for the start zone and menus.

Simulated income per minute of swimming:

| Phase | Zone coins | Explosion and Rain | Total |
|---|---|---|---|
| 0–1 h | ≈ 50 | ≈ 60 | ≈ 110 |
| 1–3 h | ≈ 60 | ≈ 130 | ≈ 190 |
| 3–8 h | ≈ 65 | ≈ 220 | ≈ 285 |
| 8–15 h | ≈ 70 | ≈ 420 | ≈ 490 |

Explosion and Rain carry most of the income, and that share grows with their levels.

Buy order:
- Players who buy in a bad order (weak skills first) still finish in about **24 h**, with no wait longer than about 5 h.
- Without the capstone lock that was 39 h, with a 10 h wait.

## Income

- Coins in zones: about 1 coin/s or less (see `ZONE_RULES.md`).
- Achievements: about 14 000 coins and 56 skill points in total, paid **once per save**. Not repeated after rebirth or Ascension.
- Skilled players earn more by surviving longer and taking brave lines. They're never forced into danger.
- [ ] Dying on purpose early must not pay better than surviving. Add a check to the simulation (coins per minute for short vs. long runs).

## Legacy (rebirth)

Available when every skill is at L5. Up to 10 times.

| Lost | Kept |
|---|---|
| Skills, unused skill points, coins | Achievements, leaderboards, statistics, Legacy level, Pearls, cosmetics |

Each Legacy level R changes three things:

| What | Rule | R0 | R1 | R2 | R5 | R10 |
|---|---|---|---|---|---|---|
| Skill values | ceil(R0 value × min(1 + 0.15 × R, max multiplier)) | ×1 | ×1.15 | ×1.3 | max | max |
| Coin value | each coin picked up adds 1 + R to the wallet | 1 | 2 | 3 | 6 | 11 |
| Point price | the (1 + 0.7 × R) factor above | ×1 | ×1.7 | ×2.4 | ×4.5 | ×8 |

- Skill values scale at every level (L1–L5), in the unit shown in the skills table, rounded up (also percentages: 10 % × 1.15 → 12 %).
- Rain scales coins/s; its duration stays.
- Luck doesn't scale.
- Skill points per level stay the same (1, 2, 5, 12, 30).
- **Coin value applies to every coin picked up** (zone coins, Explosion and Rain coins). Achievement coin rewards stay flat.
- Everything that shows coins shows the value earned: the in-game HUD, the run result, statistics, leaderboards and coin achievements. A coin at R2 counts as 3 everywhere.
- No visual changes to coins or pickups.
- [ ] The in-game HUD shows a small multiplier next to the coin counter when coin value is above 1 (e.g. "3x").
- Leaderboards: coin scores grow with R (an R10 run scores about 11× an R0 run). Distance leaderboards aren't affected.

Max multiplier per skill (keeps the game calm; the same multiplier for all levels, so L4 always stays below L5):

| Skill | Max multiplier | L5 at max | Reached at |
|---|---|---|---|
| Magnet | ×1.4 | 478 px | R3 |
| Coin Explosion | ×1.6 | 154 coins | R4 |
| Coin Rain | ×1.5 | 50 coins/s | R4 |
| Luck | ×1 (no growth) | 45 | – |
| Boost Power / Duration | ×1.4 | 280 % / 210 % (today's L5; recalculate when it changes) | R3 |

After the caps, coin value carries the progress.

Cycle length (casual):

| R | 0 | 1 | 2 | 3 | 4 | 5–10 |
|---|---|---|---|---|---|---|
| Hours | 15 | 14 | 11 | 9 | 8 | 7–8 |

About **100 hours** from a new save to the end of R10.

- Every rebirth feels clearly better: bigger effects first, then more coin value and shorter cycles.
- Tuning: skill growth (0.15) and coin value set how much faster cycles get. Price growth (0.7) sets where they level off.

## Ascension

Available when every skill is at L5 on R10.

| Lost | Kept |
|---|---|
| Everything Legacy loses, plus the Legacy level (back to R0) | Achievements, leaderboards, statistics, Pearls, cosmetics, Ascension count |

- No power carries over; n resets as on a rebirth. Each Ascension loop takes about as long as the first (≈ 100 h).
- Pays a cosmetic currency (placeholder name: **Pearls**). Pearls buy cosmetics only.

| Pearls earned for | Amount |
|---|---|
| Each rebirth | 1 (proposal) |
| Each Ascension | TBD, bigger (instead of the rebirth Pearl) |

Both Legacy and Ascension:
- [ ] A confirmation lists exactly what is lost (including the number of unused points and coins) and what is kept.
- [ ] The save stores the Legacy level, the Ascension count and Pearls.

## Existing players

Players with saves from before this change. Only their current (first) cycle is affected; the first rebirth resets everything anyway.

Old skill point cost per level:

| Skill | L1 | L2 | L3 | L4 | L5 |
|---|---|---|---|---|---|
| Magnet, Rain, Boost Power, Boost Duration | 1 | 2 | 3 | 4 | 5 |
| Coin Explosion | 1 | 3 | 10 | 25 | 100 |
| Luck | 1 | 5 | 10 | 25 | 100 |

Rules:
- Keep skill levels (old L3 stays L3), unused skill points and coins.
- **Never punish:** after the update, unused points are the same or more, never fewer.
- Compare the old and new point cost of all owned levels together. If the new total is lower, refund the difference as unused points. If it's higher, change nothing.
- n doesn't change. The refund doesn't add to n. The next point costs the **new** price formula at the player's current n.
- Capstones already owned stay, even if not every skill is at L4. After a skill reset the lock applies again.
- Players who already maxed everything can rebirth right away. Welcome them back.
- Achievement rewards already collected aren't paid again.
- The migration runs once per save. The save stores that it ran.

Early and mid players need about as long as a new save (≈ 16 h vs 15 h): their old purchases were the cheap early tiers, and part of their achievement rewards is already used up.

| Player before the update | Unused points before → after | Time left to all L5 |
|---|---|---|
| Early (Explosion L1, Rain L1, Magnet L2) | 5 → 5 | ≈ 16 h |
| Mid (all L2, Explosion and Rain L3) | 15 → 22 | ≈ 16 h |
| Late (all L3, Explosion L5, Luck L4) | 40 → 142 | ≈ 4 h |
| Hoarder (nothing bought, 120 points) | 120 → 120 | ≈ 12 h |
| Everything maxed | – | rebirth right away |

## Before shipping a change

- [ ] Rerun the simulation: time to all L5 (casual and optimized) and the longest wait.
- [ ] Check that a bad buy order still finishes within about 24 h.
- [ ] Playtest a fresh save for the first hour: an upgrade every run or two.
- [ ] Log real coins per minute and run length in playtests, and update the simulation with them.

## Open questions

- [ ] Name of the cosmetic currency.
- [ ] Pearls per Ascension, the cosmetics catalogue and Pearl prices.
- [ ] Magnet Boost Power and Duration: new L5 values and Magnet pickup frequency (see Skills).
