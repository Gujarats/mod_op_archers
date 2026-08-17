::OpArchers <- {
    ID = "mod_op_archers",
    Version = "0.1.2",
    Name = "Overpowered Archers and Crossbows"
};

::OpArchers.debugLog <- function(_message)
{
    ::OpArchers.Mod.Debug.printLog("[OpArchers] " + _message);
};

::OpArchers.HookMod <- ::Hooks.register(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);
::OpArchers.HookMod.require("mod_msu >= 1.9.0");

::OpArchers.configureDebugLogging <- function()
{
    if ("GuzBluezDebugLogController" in getroottable()
        && "registerTarget" in ::GuzBluezDebugLogController)
    {
        ::GuzBluezDebugLogController.registerTarget(::OpArchers.ID, ::OpArchers.Mod);
        return;
    }

    ::OpArchers.Mod.Debug.setFlag("default", ::OpArchers.Mod.ModSettings.getSetting("DebugLogging").getValue());
};

::include("scripts/mods/op_archers/compatibility/legends_ranged_patch");
::include("scripts/mods/op_archers/compatibility/modular_vanilla_patch");

::OpArchers.HookMod.queue(">mod_msu", ">mod_legends", ">mod_reforged", ">mod_modular_vanilla", function()
{
    // Register the MSU Mod Object
    ::OpArchers.Mod <- ::MSU.Class.Mod(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);
    ::OpArchers.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Gujarats/Battle-Brother-Overpowered-Archers-and-Crossbows");
    ::OpArchers.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
    ::OpArchers.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/1076");

    // Create the Dynamic Menu Options Page
    ::OpArchers.registerSettings();
    ::OpArchers.configureDebugLogging();

    // Load the separate execution logic script
    ::include("scripts/mods/op_archers/ranged_attack_hooks");

    if (::Hooks.hasMod("mod_legends"))
    {
        ::OpArchers.Compatibility.Legends.registerHooks(::OpArchers.HookMod);
    }
     // Reforged uses modular vanilla
    else if (::Hooks.hasMod("mod_modular_vanilla"))
    {
        ::OpArchers.Compatibility.ModularVanilla.registerHooks(::OpArchers.HookMod);
    }
    else
    {
        ::OpArchers.RangedAttackHooks.registerVanillaHooks(::OpArchers.HookMod);
    }
});
