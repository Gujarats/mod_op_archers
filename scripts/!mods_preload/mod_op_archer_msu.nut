::OpArchers <- {
    ID = "mod_op_archers",
    Version = "0.0.2",
    Name = "Overpowered Archers and Crossbows",

    Config = {
        Tier1SkillMin = 75,
        Tier1SkillMax = 80,
        Tier1DamageMult = 1.20,

        Tier2SkillMin = 81,
        Tier2SkillMax = 85,
        Tier2DamageMult = 1.30
    }
};

::logInfo("[OpArchers] Preload script initializing early boot phase.");

::OpArchers.HookMod <- ::Hooks.register(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);
::OpArchers.HookMod.require("mod_msu >= 1.9.0");

::OpArchers.HookMod.queue(">mod_msu", function()
{
    ::logInfo("[OpArchers] Hook queue successfully triggered after mod_msu!");

    local mod = ::OpArchers.HookMod;

    ::OpArchers.Mod <- ::MSU.Class.Mod(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);
    ::OpArchers.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, "https://github.com/Gujarats/Battle-Brother-Overpowered-Archers-and-Crossbows");
    ::OpArchers.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
    ::OpArchers.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.NexusMods, "https://www.nexusmods.com/battlebrothers/mods/1076");

    // Creating menu options for the mod
    local page = ::OpArchers.Mod.ModSettings.addPage("General");
    page.addRangeSetting(
        "MinSkillForGuaranteeHit",                  // setting key
        70,                                         // default value
        1,                                          // min value
        100,                                        // max value
        1,                                          // step
        "Minimal Ranged Skill for Guaranteed Hit",  // display name
        "Adjust the minimum value required for a guaranteed 100% hit."
    );
    ::logInfo("[OpArchers] Menu options initialized!");

    local rangedSkills = [
        "scripts/skills/actives/aimed_shot",
        "scripts/skills/actives/quick_shot",
        "scripts/skills/actives/shoot_bolt",
        "scripts/skills/actives/shoot_stake"
    ];

    foreach (skillPath in rangedSkills)
    {
        mod.hook(skillPath, function (q)
        {
            ::logInfo("[OpArchers] Successfully attached hooks to: " + skillPath);

            // RULE 1: Override isUsingHitchance to return false (forces 100% in UI & hit rolls)
            q.isUsingHitchance = @(__original) function()
            {
                local actor = this.getContainer().getActor();
                if (actor != null && actor.isPlayerControlled() && actor.isAlive())
                {
                    // FIXED: Correct way to fetch settings directly from your Mod instance
                    local minSkill = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
                    if (actor.getCurrentProperties().RangedSkill >= minSkill)
                    {
                        return false;
                    }
                }
                return __original();
            };

            // RULE 2: Keep the Melee flip here to bypass the physical "astray" target switching block
            q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
            {
                if (_user != null && _user.isPlayerControlled() && _user.isAlive())
                {
                    // FIXED: Correct way to fetch settings directly from your Mod instance
                    local minSkill = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
                    if (_user.getCurrentProperties().RangedSkill >= minSkill)
                    {
                        local backupIsRanged = this.m.IsRanged;
                        this.m.IsRanged = false;

                        local ret = __original(_user, _targetEntity, _allowDiversion);

                        this.m.IsRanged = backupIsRanged;
                        return ret;
                    }
                }
                return __original(_user, _targetEntity, _allowDiversion);
            };

            // RULE 3: Damage Modifiers
            q.onAnySkillUsed = @(__original) function( _skill, _targetEntity, _properties )
            {
                __original(_skill, _targetEntity, _properties);

                if (_skill == this)
                {
                    local actor = this.getContainer().getActor();
                    if (actor != null && actor.isPlayerControlled() && actor.isAlive())
                    {
                        local rSkill = actor.getCurrentProperties().RangedSkill;
                        local cfg = ::OpArchers.Config;

                        if (rSkill >= cfg.Tier1SkillMin && rSkill <= cfg.Tier1SkillMax)
                        {
                            _properties.RangedDamageMult *= cfg.Tier1DamageMult;
                        }
                        else if (rSkill >= cfg.Tier2SkillMin && rSkill <= cfg.Tier2SkillMax)
                        {
                            _properties.RangedDamageMult *= cfg.Tier2DamageMult;
                        }
                    }
                }
            };
        });
    }
});