//=============================================================================
// skill_IceShards.uc
//
//	IceShards skill
//
//=============================================================================


class skill_IceShards extends BaseAttackSkill;


//////////////////////////////////
// Resource imports
//

//////////////////////////////////
// Definitions
//

//////////////////////////////////
// Variables
//


//////////////////////////////////
// Functions
//
simulated function UpdateSkillForStrength()
{  

	fWarmupFXClass=class'NanoFX_iceshards_Warmup';	
	if( fStrength >= 90 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Ten';
	}
	if( fStrength >= 80 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Nine';
	}
	if( fStrength >= 70 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Eight';
	}
	if( fStrength >= 60 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Seven';
	}
	if( fStrength >= 50 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Six';
	}
	if( fStrength >= 40 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Five';
	}
	else if( fStrength >= 30 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Four';
	}
	else if( fStrength >= 20 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Three';
	}
	else if( fStrength >= 10 )
	{
		ProjectileClass=class'skill_IceShards_Projectile_Two';
	}
	else
	{
		ProjectileClass=class'skill_IceShards_Projectile_One';
	}

	fDamage			+= Max( fStrength * 0.5, 1 );
	fDamageRadius	+= fStrength;
} 
//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//

defaultproperties
{
	ProjectileClass=Class'skill_IceShards_Projectile_One'
	fWarmupFXClass=Class'B9FX.NanoFX_iceshards_Warmup'
	fActivatable=true
	fSkillName="Ice Shards"
	fUniqueID=7
	fFocusUsePerActivation=10
	fPriority=1
	fStrength=10
	Icon=Texture'B9HUD_textures.Browser_skills.iceshard_bricon'
}