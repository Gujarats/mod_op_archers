if (!("Compatibility" in ::OpArchers))
{
    ::OpArchers.Compatibility <- {};
}

::OpArchers.Compatibility.Legends <- {
    function registerHooks(_mod)
    {
        ::OpArchers.RangedAttackHooks.registerSkillHook(
            _mod,
            "scripts/skills/actives/legend_cascade_skill"
        );

        ::OpArchers.Mod.Debug.printLog("[OpArchers][Legends] Cascade hook registered; Piercing Bolt and Strafing Run resolve through Shoot Bolt or Shoot Stake");
    }
};
