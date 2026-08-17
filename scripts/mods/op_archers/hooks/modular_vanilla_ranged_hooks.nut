if (!("Hooks" in ::OpArchers))
{
    ::OpArchers.Hooks <- {};
}

::OpArchers.Hooks.ModularVanilla <- {
    SupportedSkillIDs = {
        ["actives.aimed_shot"] = true,
        ["actives.quick_shot"] = true,
        ["actives.shoot_bolt"] = true,
        ["actives.shoot_stake"] = true
    },

    // Preserve the selected target only for an eligible player using a supported ranged skill.
    // this will make the arrow hit the target without diversion
    function shouldPreserveTarget(_skill, _user)
    {
        if (_user == null
            || !_user.isPlayerControlled()
            || !_user.isAlive()
            || !(_skill.getID() in this.SupportedSkillIDs)
            || !_skill.isRanged())
        {
            return false;
        }

        return ::OpArchers.RangedAttackLogic.meetsGuaranteedHitThreshold(_user);
    }

    function registerHooks(_mod)
    {
        _mod.hook("scripts/skills/skill", function(q)
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

            q.MV_getDiversionTarget = @(__original) function(_user, _targetEntity, _propertiesForUse = null)
            {
                if (::OpArchers.Hooks.ModularVanilla.shouldPreserveTarget(this, _user))
                {
                    ::OpArchers.debugLog("[ModularVanilla] diversion disabled for " + this.getID());
                    return null;
                }

                return __original(_user, _targetEntity, _propertiesForUse);
            };
        });

        ::OpArchers.debugLog("[ModularVanilla] diversion compatibility hook registered");
    }
};
