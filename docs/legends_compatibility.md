# Legends Ranged Compatibility

## Scope

When `mod_legends` is installed, Overpowered Archers and Crossbows applies its
existing configured guaranteed-hit, projectile-diversion, and damage-multiplier logic
to these player-controlled ranged attacks:

| Weapon family | Active script | Purpose |
| --- | --- | --- |
| Bow | `scripts/skills/actives/aimed_shot` | Vanilla aimed attack. |
| Bow | `scripts/skills/actives/quick_shot` | Vanilla quick attack. |
| Bow | `scripts/skills/actives/legend_cascade_skill` | Legends three-shot bow attack. |
| Crossbow | `scripts/skills/actives/shoot_bolt` | Vanilla bolt attack. |
| Crossbow | `scripts/skills/actives/shoot_stake` | Heavy-bolt attack. |
| Crossbow | `scripts/skills/actives/legend_piercing_bolt_skill` | Legends penetrating bolt attack. |
| Crossbow | `scripts/skills/actives/legend_strafing_run_skill` | Legends move-and-fire attack. |

`reload_bolt` is deliberately excluded because it does not resolve an attack.
Legends' crossbow-configured `knock_out` is also excluded: it is the melee
"Improvised Strike" butt attack, not a projectile attack.
Legends owns Cascade's multi-shot behavior, Piercing Bolt's follow-through hit,
and Strafing Run's movement. This mod only changes the attack properties used
by those skills. The compatibility patch does not change the existing OP
Archers attack behavior.

## Load Order

The adapter lives at
`scripts/mods/op_archers/compatibility/legends_ranged_patch.nut` so it cannot
collide with another mod's script. It is loaded before the OP Archers queue,
which waits for `mod_msu` and `mod_legends`. The adapter only registers its
Legends hooks when `::Hooks.hasMod("mod_legends")` is true.

## Developer Test Kit

Developer options are disabled by default. When enabled with the Legends test
kit option, the mod adds one short bow, crossbow, heavy crossbow, large quiver
of arrows, and large quiver of bolts to the player stash once per game session.

The test kit gives weapons rather than detached active skills. Legends binds
these skills to their weapon and requires the equipped weapon, ammunition, and
loaded state to test them correctly.

## Runtime Verification

For each listed attack, verify a player character below and above
`MinSkillForGuaranteeHit`. With debug logging enabled, `log.html` must show one
`[OpArchers]` modifier line for each resolved attack. Piercing Bolt and
Strafing Run must retain their Legends effects and must not receive the OP
damage multiplier twice.
