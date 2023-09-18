//=============================================================================
// skill_HeavenBlast.uc
//
//	Heaven Blast skill
//
//=============================================================================


class skill_HeavenBlast extends BaseAttackSkill;


//////////////////////////////////
// Functions
//

simulated function UpdateSkillForStrength()
{
	if( fStrength >= 90 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Ten';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Ten';
	}
	if( fStrength >= 80 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Nine';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Nine';
	}
	if( fStrength >= 70 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Eight';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Eight';
	}
	if( fStrength >= 60 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Seven';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Seven';
	}
	if( fStrength >= 50 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Six';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Six';
	}
	if( fStrength >= 40 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Five';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Five';
	}
	else if( fStrength >= 30 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Four';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Four';
	}
	else if( fStrength >= 20 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Three';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Three';
	}
	else if( fStrength >= 10 )
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_Two';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_Two';
	}
	else
	{
		ProjectileClass=class'skill_HeavenBlast_Projectile_One';
		fWarmupFXClass=class'NanoFX_HeavenBlast_Warmup_One';
	}

	fDamage			+= Max( fStrength * 0.5, 1 );
	fDamageRadius	+= fStrength;
}



//////////////////////////////////
// Initialization
//

defaultproperties
{
	FireOffset=(X=0,Y=0,Z=0)
	ProjectileClass=Class'skill_HeavenBlast_Projectile_One'
	fWarmupFXClass=Class'B9FX.NanoFX_HeavenBlast_Warmup_One'
	fDamage=40
	fDamageRadius=210
	fActivatable=true
	fSkillName="Heaven Blast"
	fUniqueID=18
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=1
	Icon=Texture'B9HUD_textures.Browser_skills.heavenly_blast_bricon'
}