//=============================================================================
// pistol_SawedOffShotgun_Attachment.uc
//
// Attachment for SawedOffShotgun Pistol weapon
//
// 
//=============================================================================


class pistol_SawedOffShotgun_Attachment extends B9_WeaponAttachment;


//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}

simulated function SpawnEffect()
{
	local vector Start;
	local rotator Rot;

	Super.SpawnEffect();

	if( FlashCount % 2 == 0 )
	{
		GetEffectStart(Start,Rot);
		spawn(class'B9FX.proj_TracerRound_TypeTwo',Instigator,,Start,rotator(HitLoc - Start));
	}
}


simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();
	      
	SpawnEffect();
}

//////////////////////////////////
// Initialization
//

defaultproperties
{
	fAnimKind=1
	Mesh=SkeletalMesh'B9Weapons_models.BigRedGun_mesh'
}