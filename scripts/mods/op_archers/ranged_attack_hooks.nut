::OpArchers.RangedAttackHooks <- {
    function getEligibleActor(_skill)
    {
        local actor = _skill.getContainer().getActor();

        if (actor == null || !actor.isPlayerControlled() || !actor.isAlive())
        {
            return null;
        }

        return actor;
    }

    function meetsGuaranteedHitThreshold(_actor)
    {
        local minSkill = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
        return _actor.getCurrentProperties().RangedSkill >= minSkill;
    }

    function describeTarget(_targetEntity)
    {
        if (_targetEntity == null)
        {
            return "target <none>";
        }

        local tile = _targetEntity.getTile();
        return "target \"" + _targetEntity.getName() + "\" id " + _targetEntity.getID() + " tile " + tile.X + "," + tile.Y;
    }

    function applyDamageMultiplier(_skill, _targetEntity, _properties)
    {
        local actor = this.getEligibleActor(_skill);
        if (actor == null)
        {
            return;
        }

        local rangedSkill = actor.getCurrentProperties().RangedSkill;
        local settings = ::OpArchers.Mod.ModSettings;
        local tier1Min = settings.getSetting("Tier1SkillMin").getValue();
        local tier1Max = settings.getSetting("Tier1SkillMax").getValue();
        local tier1Mult = settings.getSetting("Tier1DamageMult").getValue() / 100.0;
        local tier2Min = settings.getSetting("Tier2SkillMin").getValue();
        local tier2Max = settings.getSetting("Tier2SkillMax").getValue();
        local tier2Mult = settings.getSetting("Tier2DamageMult").getValue() / 100.0;

        if (rangedSkill >= tier1Min && rangedSkill <= tier1Max)
        {
            _properties.RangedDamageMult *= tier1Mult;
            ::OpArchers.Mod.Debug.printLog("[OpArchers] applied Tier 1 damage multiplier to " + _skill.getID());
        }
        else if (rangedSkill >= tier2Min && rangedSkill <= tier2Max)
        {
            _properties.RangedDamageMult *= tier2Mult;
            ::OpArchers.Mod.Debug.printLog("[OpArchers] applied Tier 2 damage multiplier to " + _skill.getID());
        }
    }

    function registerSkillHook(_mod, _skillPath)
    {
        _mod.hook(_skillPath, function(q)
        {
            q.isUsingHitchance = @(__original) function()
            {
                local actor = ::OpArchers.RangedAttackHooks.getEligibleActor(this);
                if (actor != null && ::OpArchers.RangedAttackHooks.meetsGuaranteedHitThreshold(actor))
                {
                    ::OpArchers.Mod.Debug.printLog("[OpArchers] guaranteed hit enabled for " + this.getID());
                    return false;
                }

                return __original();
            };

            q.attackEntity = @(__original) function(_user, _targetEntity, _allowDiversion = true)
            {
                if (_user != null && _user.isPlayerControlled())
                {
                    ::OpArchers.Mod.Debug.printLog("[OpArchers][Selected] " + this.getID() + " " + ::OpArchers.RangedAttackHooks.describeTarget(_targetEntity));
                }

                if (_user != null
                    && _user.isPlayerControlled()
                    && _user.isAlive()
                    && ::OpArchers.RangedAttackHooks.meetsGuaranteedHitThreshold(_user)
                    && "IsRanged" in this.m)
                {
                    local originalIsRanged = this.m.IsRanged;
                    this.m.IsRanged = false;
                    local result = __original(_user, _targetEntity, _allowDiversion);
                    this.m.IsRanged = originalIsRanged;
                    ::OpArchers.Mod.Debug.printLog("[OpArchers] projectile diversion disabled for " + this.getID());
                    return result;
                }

                return __original(_user, _targetEntity, _allowDiversion);
            };

            q.onScheduledTargetHit = @(__original) function(_info)
            {
                local result = __original(_info);

                if (_info != null && "TargetEntity" in _info && "User" in _info && _info.User != null && _info.User.isPlayerControlled())
                {
                    ::OpArchers.Mod.Debug.printLog("[OpArchers][ResolvedHit] " + this.getID() + " confirmed " + ::OpArchers.RangedAttackHooks.describeTarget(_info.TargetEntity));
                }

                return result;
            };

            q.onAnySkillUsed = @(__original) function(_skill, _targetEntity, _properties)
            {
                __original(_skill, _targetEntity, _properties);

                if (_skill == this)
                {
                    ::OpArchers.RangedAttackHooks.applyDamageMultiplier(this, _targetEntity, _properties);
                }
            };
        });
    }

    function registerVanillaHooks(_mod)
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

        ::OpArchers.Mod.Debug.printLog("[OpArchers] vanilla ranged hooks registered");
    }
};
