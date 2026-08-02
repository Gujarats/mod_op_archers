if (!("DeveloperOptions" in ::OpArchers))
{
    ::OpArchers.DeveloperOptions <- null;
}

::OpArchers.DeveloperOptions = {
    function init()
    {
        ::OpArchers.DeveloperSession <- {
            HasGrantedLegendsRangedTestKit = false
        };
    }

    function isEnabled()
    {
        return ::OpArchers.Mod.ModSettings.getSetting("EnableDeveloperOptions").getValue();
    }

    function applyLegendsRangedTestKitOnce()
    {
        if (!this.isEnabled()
            || !::OpArchers.Mod.ModSettings.getSetting("DeveloperGrantLegendsRangedTestKit").getValue()
            || !::Hooks.hasMod("mod_legends")
            || ::OpArchers.DeveloperSession.HasGrantedLegendsRangedTestKit)
        {
            return;
        }

        if (!("World" in getroottable())
            || ::World == null
            || !("Assets" in ::World)
            || ::World.Assets == null)
        {
            return;
        }

        local stash = ::World.Assets.getStash();
        if (stash == null)
        {
            return;
        }

        ::OpArchers.DeveloperSession.HasGrantedLegendsRangedTestKit = true;
        stash.add(::new("scripts/items/weapons/short_bow"));
        stash.add(::new("scripts/items/weapons/crossbow"));
        stash.add(::new("scripts/items/weapons/heavy_crossbow"));
        stash.add(::new("scripts/items/ammo/large_quiver_of_arrows"));
        stash.add(::new("scripts/items/ammo/large_quiver_of_bolts"));

        ::OpArchers.Mod.Debug.printLog("[OpArchers][Developer] granted Legends ranged test kit");
    }
};
