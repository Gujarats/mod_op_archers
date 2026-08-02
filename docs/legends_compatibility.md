# Legends Ranged Compatibility

## Scope

When `mod_legends` is installed, Overpowered Archers and Crossbows uses a
separate Legends adapter. The vanilla hook module is not registered in a
Legends session.
to these player-controlled ranged attacks:

| Weapon family | Active script | Purpose |
| --- | --- | --- |
| Bow | `actives.aimed_shot` | `scripts/skills/actives/aimed_shot` | Vanilla aimed attack as modified by Legends. |
| Bow | `actives.quick_shot` | `scripts/skills/actives/quick_shot` | Vanilla quick attack as modified by Legends. |
| Bow | `actives.legend_cascade` | `scripts/skills/actives/legend_cascade_skill` | Legends three-shot bow attack. |
| Crossbow | `actives.shoot_bolt` | `scripts/skills/actives/shoot_bolt` | Vanilla bolt attack as modified by Legends. |
| Crossbow | `actives.shoot_stake` | `scripts/skills/actives/shoot_stake` | Heavy-bolt attack. |
| Crossbow | `actives.legend_piercing_bolt` | `scripts/skills/actives/legend_piercing_bolt_skill` | Legends penetrating bolt attack. |
| Crossbow | `actives.legend_sprint` | `scripts/skills/actives/legend_strafing_run_skill` | Legends move-and-fire action that delegates its shot to Bolt or Stake. |

`reload_bolt` is deliberately excluded because it does not resolve an attack.
Legends' crossbow-configured `knock_out` is also excluded: it is the melee
"Improvised Strike" butt attack, not a projectile attack.
The adapter hooks each listed active script directly and only acts when the
current skill ID is in this table. It applies the existing OP Archers hit,
diversion, and damage behavior to those entries only. Legends owns Cascade's
multi-shot behavior, Piercing Bolt's follow-through hit, and Strafing Run's
movement. The vanilla hook module remains unchanged.

## Debug Logging

With Developer Options debug logging enabled, the adapter logs its registry at
startup and logs each supported attack's active ID, actor Ranged Skill,
configured threshold, blocker count, diversion decision, and damage tier.
Strafing Run logs its delegated Bolt or Stake attack. This logging is diagnostic
only and does not alter combat behavior.

Each attack additionally emits a `[Selected]` line immediately before resolving
the attack and a `[ResolvedHit]` line from `onScheduledTargetHit` after damage
has been resolved. Both lines include the tactical target's entity ID, name,
and tile coordinates. Matching IDs confirms that the selected target received
the hit; differing IDs proves the attack resolved against another target. A
miss has a `[Selected]` line but no corresponding `[ResolvedHit]` line.

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
