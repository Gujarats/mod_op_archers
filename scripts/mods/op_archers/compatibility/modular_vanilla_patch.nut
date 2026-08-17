if (!("Compatibility" in ::OpArchers))
{
    ::OpArchers.Compatibility <- {};
}

::OpArchers.Compatibility.ModularVanilla <- {
    SupportedSkillIDs = {
        ["actives.aimed_shot"] = true,
        ["actives.quick_shot"] = true,
        ["actives.shoot_bolt"] = true,
        ["actives.shoot_stake"] = true,
        ["actives.legend_cascade"] = true,
        ["actives.legend_piercing_bolt"] = true
    },

    function shouldPreserveTarget( _skill, _user )
    {
        if (_user == null
            || !_user.isPlayerControlled()
            || !_user.isAlive()
            || !(_skill.getID() in this.SupportedSkillIDs)
            || !_skill.isRanged())
        {
            return false;
        }

        return ::OpArchers.RangedAttackHooks.meetsGuaranteedHitThreshold(_user);
    }

    function registerHooks( _mod )
    {
        _mod.hook("scripts/skills/skill", function(q)
        {
            q.MV_getDiversionTarget = @(__original) function( _user, _targetEntity, _propertiesForUse = null )
            {
                if (::OpArchers.Compatibility.ModularVanilla.shouldPreserveTarget(this, _user))
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
