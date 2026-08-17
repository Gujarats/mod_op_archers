if (!("Hooks" in ::OpArchers))
{
    ::OpArchers.Hooks <- {};
}

::OpArchers.Hooks.Legends <- {
    SupportedSkills = {
        ["actives.aimed_shot"] = { Script = "scripts/skills/actives/aimed_shot", IsAttack = true },
        ["actives.quick_shot"] = { Script = "scripts/skills/actives/quick_shot", IsAttack = true },
        ["actives.legend_cascade"] = { Script = "scripts/skills/actives/legend_cascade_skill", IsAttack = true },
        ["actives.shoot_bolt"] = { Script = "scripts/skills/actives/shoot_bolt", IsAttack = true },
        ["actives.shoot_stake"] = { Script = "scripts/skills/actives/shoot_stake", IsAttack = true },
        ["actives.legend_piercing_bolt"] = { Script = "scripts/skills/actives/legend_piercing_bolt_skill", IsAttack = true },
        ["actives.legend_sprint"] = { Script = "scripts/skills/actives/legend_strafing_run_skill", IsAttack = false }
    },

    function getPolicy(_skill)
    {
        local id = _skill.getID();
        return id in this.SupportedSkills ? this.SupportedSkills[id] : null;
    }

    // I know It's bad and generated from AI...
    // too lazy to refactor it but it works
    function logAttack(_event, _skill, _message)
    {
        ::OpArchers.debugLog("[Legends][" + _event + "] " + _skill.getID() + " " + _message);
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

    function registerCombatHook(_mod, _skillPath)
    {
        _mod.hook(_skillPath, function(q)
        {
            q.onUse = @(__original) function(_user, _targetTile)
            {
                local policy = ::OpArchers.Hooks.Legends.getPolicy(this);
                if (policy != null)
                {
                    ::OpArchers.Hooks.Legends.logAttack("Use", this, "registered skill path " + policy.Script);
                }

                return __original(_user, _targetTile);
            };

            q.isUsingHitchance = @(__original) function()
            {
                local policy = ::OpArchers.Hooks.Legends.getPolicy(this);
                local actor = ::OpArchers.RangedAttackLogic.getEligibleActor(this);

                if (policy != null && policy.IsAttack && actor != null)
                {
                    local threshold = ::OpArchers.Mod.ModSettings.getSetting("MinSkillForGuaranteeHit").getValue();
                    local rangedSkill = actor.getCurrentProperties().getRangedSkill();
                    local qualifies = ::OpArchers.RangedAttackLogic.meetsGuaranteedHitThreshold(actor);
                    ::OpArchers.Hooks.Legends.logAttack("Hit", this, "ranged skill " + rangedSkill + ", threshold " + threshold + ", qualifies " + qualifies);

                    if (qualifies)
                    {
                        return false;
                    }
                }

                return __original();
            };

            q.attackEntity = @(__original) function(_user, _targetEntity, _allowDiversion = true)
            {
                local policy = ::OpArchers.Hooks.Legends.getPolicy(this);
                if (policy == null || !policy.IsAttack || _user == null || !_user.isPlayerControlled() || !_user.isAlive())
                {
                    return __original(_user, _targetEntity, _allowDiversion);
                }

                ::OpArchers.Hooks.Legends.logAttack("Selected", this, ::OpArchers.Hooks.Legends.describeTarget(_targetEntity));
                local qualifies = ::OpArchers.RangedAttackLogic.meetsGuaranteedHitThreshold(_user);
                local blockerCount = 0;
                if (_targetEntity != null && _targetEntity.isAlive() && this.m.IsRanged)
                {
                    blockerCount = this.Const.Tactical.Common.getBlockedTiles(_user.getTile(), _targetEntity.getTile(), _user.getFaction()).len();
                }

                ::OpArchers.Hooks.Legends.logAttack("Attack", this, "qualifies " + qualifies + ", blockers " + blockerCount + ", allow diversion " + _allowDiversion);

                return __original(_user, _targetEntity, _allowDiversion);
            };

            q.onAnySkillUsed = @(__original) function(_skill, _targetEntity, _properties)
            {
                __original(_skill, _targetEntity, _properties);

                local policy = ::OpArchers.Hooks.Legends.getPolicy(this);
                if (policy != null && policy.IsAttack && _skill == this)
                {
                    if (::OpArchers.RangedAttackLogic.applyGuaranteedHitProperties(this, _properties))
                    {
                        ::OpArchers.Hooks.Legends.logAttack("Blockage", this, "set RangedAttackBlockedChanceMult to 0");
                    }

                    local tier = ::OpArchers.RangedAttackLogic.getDamageMultiplierTier(this, _properties);
                    if (tier > 0)
                    {
                        ::OpArchers.Hooks.Legends.logAttack("Damage", this, "applied Tier " + tier + " multiplier");
                    }
                }
            };
        });
    }

    function registerHooks(_mod)
    {
        foreach (id, policy in this.SupportedSkills)
        {
            this.registerCombatHook(_mod, policy.Script);
            ::OpArchers.debugLog("[Legends][Register] " + id + " -> " + policy.Script);
        }

        ::OpArchers.debugLog("[Legends][Register] Explicit active-skill adapters registered");
    }
};
