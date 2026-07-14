::OpArchers <- {
    ID = "mod_op_archers",
    Version = "0.0.1",
    Name = "Overpowered Archers and Crossbows",

    Config = {
        MinSkillForGuaranteeHit = 70,

        Tier1SkillMin = 70,
        Tier1SkillMax = 75,
        Tier1DamageMult = 1.20,

        Tier2SkillMin = 80,
        Tier2SkillMax = 85,
        Tier2DamageMult = 1.30
    }
};

::logInfo("[OpArchers] Preload script initializing early boot phase.");

local mod = ::Hooks.register(::OpArchers.ID, ::OpArchers.Version, ::OpArchers.Name);

mod.queue(">mod_msu", function()
{
    ::logInfo("[OpArchers] Hook queue successfully triggered after mod_msu!");

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
                    if (actor.getCurrentProperties().RangedSkill > ::OpArchers.Config.MinSkillForGuaranteeHit)
                    {
                        return false;
                    }
                }
                return __original();
            };

            // RULE 2: Keep the Melee flip here to bypass the physical "astray" target switching block
            q.attackEntity = @(__original) function( _user, _targetEntity, _allowDiversion = true )
            {
                if (_user != null && _user.isPlayerControlled() && _user.isAlive() && _user.getCurrentProperties().RangedSkill > ::OpArchers.Config.MinSkillForGuaranteeHit)
                {
                    local backupIsRanged = this.m.IsRanged;
                    this.m.IsRanged = false;

                    local ret = __original(_user, _targetEntity, _allowDiversion);

                    this.m.IsRanged = backupIsRanged;
                    return ret;
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