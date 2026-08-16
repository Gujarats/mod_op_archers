if(!"OpArchers" in getroottable())
{
	::OpArchers <- {};
}

::OpArchers.registerSettings <- function()
{
	local page = ::OpArchers.Mod.ModSettings.addPage("General");
    local developer = ::OpArchers.Mod.ModSettings.addPage("Developer Options");
    local debugLogSetting = developer.addBooleanSetting("EnableDebugLogs", true, "Enable Debug Logs");
    debugLogSetting.setDescription("Enable detailed OpArchers debug log output via MSU.");
    debugLogSetting.addCallback(function(_data = null){
        ::OpArchers.Mod.Debug.setFlag("default", this.getValue());
    });
    ::OpArchers.Mod.Debug.setFlag("default", debugLogSetting.getValue());

    developer.addBooleanSetting(
        "EnableDeveloperOptions",
        false,
        "Enable Developer Options",
        "Enables developer helpers for disposable test saves."
    );
    developer.addBooleanSetting(
        "DeveloperGrantLegendsRangedTestKit",
        false,
        "Grant Legends Ranged Test Kit",
        "Adds bow and crossbow test equipment to the stash once per game session when Legends is installed."
    );
    ::OpArchers.DeveloperOptions.init();

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
}