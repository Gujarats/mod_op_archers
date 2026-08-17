::OpArchers.RangedAttackLogic <- {
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
        return _actor.getCurrentProperties().getRangedSkill() >= minSkill;
    }

    function getDamageMultiplierTier(_skill, _properties)
    {
        local actor = this.getEligibleActor(_skill);
        if (actor == null)
        {
            return 0;
        }

        local rangedSkill = actor.getCurrentProperties().getRangedSkill();
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
            return 1;
        }

        if (rangedSkill >= tier2Min && rangedSkill <= tier2Max)
        {
            _properties.RangedDamageMult *= tier2Mult;
            return 2;
        }

        return 0;
    }

    function applyGuaranteedHitProperties(_skill, _properties)
    {
        local actor = this.getEligibleActor(_skill);
        if (actor == null || !this.meetsGuaranteedHitThreshold(actor))
        {
            return false;
        }

        _properties.RangedAttackBlockedChanceMult = 0.0;
        return true;
    }
};
