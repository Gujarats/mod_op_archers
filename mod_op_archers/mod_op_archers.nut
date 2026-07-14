::logInfo("[OpArchers] Injecting runtime gameplay hook logic execution...");

local mod = ::OpArchers.HookMod;

// 1a. Whitelisted Range Skills managed elegantly via programmatic definitions
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
        // RULE 1: Dynamic 100% hit chance evaluation
        q.isUsingHitchance = @(__original) function()
        {
            local actor = this.getContainer().getActor();
            if (actor != null && actor.isPlayerControlled() && actor.isAlive())
            {
                local minSkill = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
                if (actor.getCurrentProperties().RangedSkill >= minSkill)
                {
                    return false;
                }
            }
            return __original();
        };

        // RULE 2: Dynamic Projectile scatter pathing bypass
        q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
        {
            if (_user != null && _user.isPlayerControlled() && _user.isAlive())
            {
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

        // RULE 3: Fully Dynamic Multiplier Scale checking directly against configuration UI fields
        q.onAnySkillUsed = @(__original) function( _skill, _targetEntity, _properties )
        {
            __original(_skill, _targetEntity, _properties);

            if (_skill == this)
            {
                local actor = this.getContainer().getActor();
                if (actor != null && actor.isPlayerControlled() && actor.isAlive())
                {
                    local rSkill = actor.getCurrentProperties().RangedSkill;
                    local settings = ::OpArchers.Mod.ModSettings;

                    // Fetch values directly from user config frame state
                    local t1Min = settings.getSetting("Tier1SkillMin").getValue();
                    local t1Max = settings.getSetting("Tier1SkillMax").getValue();
                    local t1Mult = settings.getSetting("Tier1DamageMult").getValue() / 100.0; // convert integer % to float multiplier

                    local t2Min = settings.getSetting("Tier2SkillMin").getValue();
                    local t2Max = settings.getSetting("Tier2SkillMax").getValue();
                    local t2Mult = settings.getSetting("Tier2DamageMult").getValue() / 100.0; // convert integer % to float multiplier

                    if (rSkill >= t1Min && rSkill <= t1Max)
                    {
                        _properties.RangedDamageMult *= t1Mult;
                    }
                    else if (rSkill >= t2Min && rSkill <= t2Max)
                    {
                        _properties.RangedDamageMult *= t2Mult;
                    }
                }
            }
        };
    });
}

::logInfo("[OpArchers] All gameplay hooks successfully registered.");