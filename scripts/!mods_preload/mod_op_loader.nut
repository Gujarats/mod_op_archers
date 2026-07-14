::OpArchers <- {
    ID = "mod_op_archers",
    Version = "0.0.3",
    Name = "Overpowered Archers and Crossbows"
};

::OpArchers.HookMod <- ::Hooks.register(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);
::OpArchers.HookMod.require("mod_msu >= 1.9.0");

::OpArchers.HookMod.queue(">mod_msu", function()
{
    // Register the MSU Mod Object
    ::OpArchers.Mod <- ::MSU.Class.Mod(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);
    ::OpArchers.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Gujarats/Battle-Brother-Overpowered-Archers-and-Crossbows");
    ::OpArchers.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
    ::OpArchers.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/1076");

    // Create the Dynamic Menu Options Page
    local page = ::OpArchers.Mod.ModSettings.addPage("General");

    // Debug log toggle option
    local debugLogSetting = page.addBooleanSetting("EnableDebugLogs", false, "Enable Debug Logs");
    debugLogSetting.setDescription("Enable detailed OpArchers debug log output via MSU.");

    // setting up this callback to ensure that the debug flag is set correctly on mod load and whenever the setting is changed
    debugLogSetting.addCallback(function(_data = null){
        ::OpArchers.Mod.Debug.setFlag("default", this.getValue());
    });
    // set the debug flag on mod load based on the current setting value
    ::OpArchers.Mod.Debug.setFlag("default", debugLogSetting.getValue());

    ::OpArchers.Mod.Debug.printLog("[OpArchers] Hook queue successfully triggered after mod_msu!");

    // 1b. Dynamic Guarantee Hit Chance Threshold
    page.addRangeSetting(
        "MinSkillForGuaranteeHit",
        70, 1, 100, 1,
        "Min Skill for Guaranteed Hit",
        "Adjust the minimum Ranged Skill required for a perfect 100% hit."
    );

    // 1c. Dynamic Damage Modifiers (Tier 1)
    page.addRangeSetting(
        "Tier1SkillMin",
        75, 1, 100, 1,
        "Tier 1 Min Skill",
        "Minimum Ranged Skill to qualify for Tier 1 damage modifier bonus."
    );
    page.addRangeSetting(
        "Tier1SkillMax",
        80, 1, 100, 1,
        "Tier 1 Max Skill",
        "Maximum Ranged Skill to qualify for Tier 1 damage modifier bonus."
    );
    page.addRangeSetting(
        "Tier1DamageMult",
        120, 100, 300, 5,
        "Tier 1 Damage Bonus (%)",
        "Damage multiplier percentage bonus for Tier 1 skill bracket (e.g., 120 = 1.20x)."
    );

    // 1c. Dynamic Damage Modifiers (Tier 2)
    page.addRangeSetting(
        "Tier2SkillMin",
        81, 1, 100, 1,
        "Tier 2 Min Skill",
        "Minimum Ranged Skill to qualify for Tier 2 damage modifier bonus."
    );
    page.addRangeSetting(
        "Tier2SkillMax",
        85, 1, 100, 1,
        "Tier 2 Max Skill",
        "Maximum Ranged Skill to qualify for Tier 2 damage modifier bonus."
    );
    page.addRangeSetting(
        "Tier2DamageMult",
        130, 100, 300, 5,
        "Tier 2 Damage Bonus (%)",
        "Damage multiplier percentage bonus for Tier 2 skill bracket (e.g., 130 = 1.30x)."
    );

    ::OpArchers.Mod.Debug.printLog("[OpArchers] Menu options fully initialized dynamically!");

    // Load the separate execution logic script
    ::include("mod_op_archers/mod_op_archers");
});