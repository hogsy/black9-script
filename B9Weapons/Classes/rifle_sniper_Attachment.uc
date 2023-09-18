//=============================================================================
// rifle_sniper_Attachment.uc
//
// Attachment for 9mm Pistol weapon
//
// 
//=============================================================================


class rifle_sniper_Attachment extends B9_WeaponAttachment;


var EjectedBrass_A	fBulletFX;
var vector			fBulletFXOffset;


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
	fMuzzleOffset=(X=40,Y=0,Z=2)
	FiringMode=MODE_Burst
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.SniperRifle_mesh'
}