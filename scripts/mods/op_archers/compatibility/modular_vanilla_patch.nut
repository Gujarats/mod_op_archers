if (!("Compatibility" in ::OpArchers))
{
    ::OpArchers.Compatibility <- {};
}

// For Reforged Compatibility
::OpArchers.Compatibility.ModularVanilla <- {
    SupportedSkillIDs = {
        ["actives.aimed_shot"] = true,
        ["actives.quick_shot"] = true,
        ["actives.shoot_bolt"] = true,
        ["actives.shoot_stake"] = true
    },

    // Making sure if the target is correct by checking the target itselft and the activated skill
    // return false if not correct target, and check if the actor/users attribute meets the guaranteed hit threshold
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
