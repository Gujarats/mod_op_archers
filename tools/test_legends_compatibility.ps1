$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

function Assert-Contains([string]$RelativePath, [string]$Token)
{
    $path = Join-Path $root $RelativePath
    if (!(Test-Path -LiteralPath $path) -or (Get-Content -Raw -LiteralPath $path).IndexOf($Token) -lt 0)
    {
        throw "Missing '$Token' in $RelativePath"
    }
}

function Assert-Matches([string]$RelativePath, [string]$Pattern)
{
    $path = Join-Path $root $RelativePath
    if (!(Test-Path -LiteralPath $path) -or (Get-Content -Raw -LiteralPath $path) -notmatch $Pattern)
    {
        throw "Missing pattern '$Pattern' in $RelativePath"
    }
}

function Assert-NotContains([string]$RelativePath, [string]$Token)
{
    $path = Join-Path $root $RelativePath
    if ((Get-Content -Raw -LiteralPath $path).IndexOf($Token) -ge 0)
    {
        throw "Unexpected '$Token' in $RelativePath"
    }
}

Assert-Contains "docs/legends_compatibility.md" "legend_cascade_skill"
Assert-Contains "docs/legends_compatibility.md" "legend_piercing_bolt_skill"
Assert-Contains "docs/legends_compatibility.md" "legend_strafing_run_skill"
Assert-Contains "docs/legends_compatibility.md" "actives.legend_piercing_bolt"
Assert-Contains "docs/legends_compatibility.md" "actives.legend_sprint"
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "scripts/skills/actives/legend_cascade_skill"
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "actives.legend_piercing_bolt"
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "actives.legend_sprint"
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" 'logAttack("Attack"'
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" 'logAttack("Selected"'
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "function registerCombatHook"
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "q.attackEntity = @(__original)"
Assert-Contains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "RangedAttackBlockedChanceMult = 0.0"
Assert-NotContains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" '_mod.hook("scripts/skills/skill"'
Assert-NotContains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "onScheduledTargetHit"
Assert-NotContains "scripts/mods/op_archers/compatibility/legends_ranged_patch.nut" "RangedAttackHooks"
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" "scripts/mods/op_archers/developer_options"
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" "scripts/mods/op_archers/compatibility/legends_ranged_patch"
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" "scripts/mods/op_archers/ranged_attack_hooks"
Assert-Contains "scripts/mods/op_archers/ranged_attack_hooks.nut" "registerVanillaHooks"
Assert-Contains "scripts/mods/op_archers/ranged_attack_hooks.nut" "this.m.IsRanged = false"
Assert-Contains "scripts/mods/op_archers/ranged_attack_hooks.nut" "[OpArchers][Selected]"
Assert-Contains "scripts/mods/op_archers/ranged_attack_hooks.nut" "[OpArchers][ResolvedHit]"
Assert-Matches "scripts/!mods_preload/mod_op_loader.nut" 'if \(::Hooks\.hasMod\("mod_legends"\)\)\s*\{\s*::OpArchers\.Compatibility\.Legends\.registerHooks'
Assert-Matches "scripts/!mods_preload/mod_op_loader.nut" 'else\s*\{\s*::OpArchers\.RangedAttackHooks\.registerVanillaHooks'
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" '">mod_msu", ">mod_legends"'
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" "EnableDeveloperOptions"
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" "DeveloperGrantLegendsRangedTestKit"
Assert-Contains "scripts/!mods_preload/mod_op_loader.nut" 'developer.addBooleanSetting("EnableDebugLogs", true'
Assert-Matches "scripts/!mods_preload/mod_op_loader.nut" '"EnableDeveloperOptions",\s*false'
Assert-Matches "scripts/!mods_preload/mod_op_loader.nut" '"DeveloperGrantLegendsRangedTestKit",\s*false'
Assert-Contains "scripts/mods/op_archers/developer_options.nut" "scripts/items/weapons/short_bow"
Assert-Contains "scripts/mods/op_archers/developer_options.nut" "scripts/items/weapons/crossbow"
Assert-Contains "scripts/mods/op_archers/developer_options.nut" "scripts/items/weapons/heavy_crossbow"
Assert-Contains "scripts/mods/op_archers/developer_options.nut" "scripts/items/ammo/large_quiver_of_arrows"
Assert-Contains "scripts/mods/op_archers/developer_options.nut" "scripts/items/ammo/large_quiver_of_bolts"

Write-Output "OP Archers Legends compatibility contract passed."
