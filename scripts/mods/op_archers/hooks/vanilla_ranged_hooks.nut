if (!("Hooks" in ::OpArchers))
{
    ::OpArchers.Hooks <- {};
}

::OpArchers.Hooks.Vanilla <- {
    function registerSkillHook(_mod, _skillPath)
    {
        _mod.hook(_skillPath, function(q)
        {
            q.isUsingHitchance = @(__original) function()
            {
                local actor = ::OpArchers.RangedAttackLogic.getEligibleActor(this);
                if (actor != null && ::OpArchers.RangedAttackLogic.meetsGuaranteedHitThreshold(actor))
                {
                    ::OpArchers.debugLog("Guaranteed hit enabled for " + this.getID());
                    return false;
                }

                return __original();
            };

            q.attackEntity = @(__original) function(_user, _targetEntity, _allowDiversion = true)
            {
                if (_user != null
                    && _user.isPlayerControlled()
                    && _user.isAlive()
                    && ::OpArchers.RangedAttackLogic.meetsGuaranteedHitThreshold(_user)
                    && "IsRanged" in this.m)
                {
                    local originalIsRanged = this.m.IsRanged;
                    this.m.IsRanged = false;
                    local result = __original(_user, _targetEntity, _allowDiversion);
                    this.m.IsRanged = originalIsRanged;
                    ::OpArchers.debugLog("Projectile diversion disabled for " + this.getID());
                    return result;
                }

                return __original(_user, _targetEntity, _allowDiversion);
            };

            q.onAnySkillUsed = @(__original) function(_skill, _targetEntity, _properties)
            {
                __original(_skill, _targetEntity, _properties);

                if (_skill == this)
                {
                    local tier = ::OpArchers.RangedAttackLogic.getDamageMultiplierTier(this, _properties);
                    if (tier > 0)
                    {
                        ::OpArchers.debugLog("Applied Tier " + tier + " damage multiplier to " + this.getID());
                    }
                }
            };
        });
    }

    function registerHooks(_mod)
    {
        local skillPaths = [
            "scripts/skills/actives/aimed_shot",
            "scripts/skills/actives/quick_shot",
            "scripts/skills/actives/shoot_bolt",
            "scripts/skills/actives/shoot_stake"
        ];

        foreach (skillPath in skillPaths)
        {
            this.registerSkillHook(_mod, skillPath);
        }

        ::OpArchers.debugLog("Vanilla ranged hooks registered");
    }
};
