if (!("Compatibility" in ::OpArchers))
{
    ::OpArchers.Compatibility <- {};
}

::OpArchers.Compatibility.Legends <- {
    SupportedSkills = {
        ["actives.aimed_shot"] = {
            Script = "scripts/skills/actives/aimed_shot",
            IsAttack = true
        },
        ["actives.quick_shot"] = {
            Script = "scripts/skills/actives/quick_shot",
            IsAttack = true
        },
        ["actives.legend_cascade"] = {
            Script = "scripts/skills/actives/legend_cascade_skill",
            IsAttack = true
        },
        ["actives.shoot_bolt"] = {
            Script = "scripts/skills/actives/shoot_bolt",
            IsAttack = true
        },
        ["actives.shoot_stake"] = {
            Script = "scripts/skills/actives/shoot_stake",
            IsAttack = true
        },
        ["actives.legend_piercing_bolt"] = {
            Script = "scripts/skills/actives/legend_piercing_bolt_skill",
            IsAttack = true
        },
        ["actives.legend_sprint"] = {
            Script = "scripts/skills/actives/legend_strafing_run_skill",
            IsAttack = false
        }
    },

    function getPolicy(_skill)
    {
        local id = _skill.getID();
        return id in this.SupportedSkills ? this.SupportedSkills[id] : null;
    }

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
        local threshold = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
        return _actor.getCurrentProperties().RangedSkill >= threshold;
    }

    function logAttack(_event, _skill, _message)
    {
        ::OpArchers.Mod.Debug.printLog("[OpArchers][Legends][" + _event + "] " + _skill.getID() + " " + _message);
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

    function applyDamageMultiplier(_skill, _properties)
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
            this.logAttack("Damage", _skill, "applied Tier 1 multiplier");
        }
        else if (rangedSkill >= tier2Min && rangedSkill <= tier2Max)
        {
            _properties.RangedDamageMult *= tier2Mult;
            this.logAttack("Damage", _skill, "applied Tier 2 multiplier");
        }
    }

    function registerCombatHook(_mod, _skillPath)
    {
        _mod.hook(_skillPath, function(q)
        {
            q.onUse = @(__original) function(_user, _targetTile)
            {
                local policy = ::OpArchers.Compatibility.Legends.getPolicy(this);
                if (policy != null)
                {
                    ::OpArchers.Compatibility.Legends.logAttack("Use", this, "registered skill path " + policy.Script);
                }

                return __original(_user, _targetTile);
            };

            q.isUsingHitchance = @(__original) function()
            {
                local policy = ::OpArchers.Compatibility.Legends.getPolicy(this);
                local actor = ::OpArchers.Compatibility.Legends.getEligibleActor(this);

                if (policy != null && policy.IsAttack && actor != null)
                {
                    local threshold = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
                    local rangedSkill = actor.getCurrentProperties().RangedSkill;
                    local qualifies = ::OpArchers.Compatibility.Legends.meetsGuaranteedHitThreshold(actor);
                    ::OpArchers.Compatibility.Legends.logAttack("Hit", this, "ranged skill " + rangedSkill + ", threshold " + threshold + ", qualifies " + qualifies);

                    if (qualifies)
                    {
                        return false;
                    }
                }

                return __original();
            };

            q.attackEntity = @(__original) function(_user, _targetEntity, _allowDiversion = true)
            {
                local policy = ::OpArchers.Compatibility.Legends.getPolicy(this);
                if (policy == null || !policy.IsAttack || _user == null || !_user.isPlayerControlled() || !_user.isAlive())
                {
                    return __original(_user, _targetEntity, _allowDiversion);
                }

                ::OpArchers.Compatibility.Legends.logAttack("Selected", this, ::OpArchers.Compatibility.Legends.describeTarget(_targetEntity));
                local qualifies = ::OpArchers.Compatibility.Legends.meetsGuaranteedHitThreshold(_user);
                local blockerCount = 0;
                if (_targetEntity != null && _targetEntity.isAlive() && this.m.IsRanged)
                {
                    blockerCount = this.Const.Tactical.Common.getBlockedTiles(_user.getTile(), _targetEntity.getTile(), _user.getFaction()).len();
                }

                ::OpArchers.Compatibility.Legends.logAttack("Attack", this, "qualifies " + qualifies + ", blockers " + blockerCount + ", allow diversion " + _allowDiversion);

                if (!qualifies || !("IsRanged" in this.m))
                {
                    return __original(_user, _targetEntity, _allowDiversion);
                }

                local originalIsRanged = this.m.IsRanged;
                this.m.IsRanged = false;
                local result = __original(_user, _targetEntity, _allowDiversion);
                this.m.IsRanged = originalIsRanged;
                ::OpArchers.Compatibility.Legends.logAttack("Attack", this, "applied original OP Archers diversion behavior");
                return result;
            };

            q.onScheduledTargetHit = @(__original) function(_info)
            {
                local result = __original(_info);
                local policy = ::OpArchers.Compatibility.Legends.getPolicy(this);

                if (policy != null && policy.IsAttack && _info != null && "TargetEntity" in _info)
                {
                    ::OpArchers.Compatibility.Legends.logAttack("ResolvedHit", this, "confirmed " + ::OpArchers.Compatibility.Legends.describeTarget(_info.TargetEntity));
                }

                return result;
            };

            q.onAnySkillUsed = @(__original) function(_skill, _targetEntity, _properties)
            {
                __original(_skill, _targetEntity, _properties);

                local policy = ::OpArchers.Compatibility.Legends.getPolicy(this);
                if (policy != null && policy.IsAttack && _skill == this)
                {
                    ::OpArchers.Compatibility.Legends.applyDamageMultiplier(this, _properties);
                }
            };
        });
    }

    function registerHooks(_mod)
    {
        foreach (id, policy in this.SupportedSkills)
        {
            this.registerCombatHook(_mod, policy.Script);
            ::OpArchers.Mod.Debug.printLog("[OpArchers][Legends][Register] " + id + " -> " + policy.Script);
        }

        ::OpArchers.Mod.Debug.printLog("[OpArchers][Legends][Register] explicit active-skill adapters registered");
    }
};
