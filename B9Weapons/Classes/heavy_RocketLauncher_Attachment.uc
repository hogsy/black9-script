//=============================================================================
// heavy_RocketLauncher_Attachment.uc
//
// Attachment for Assault Rifle weapon
//
// 
//=============================================================================


class heavy_RocketLauncher_Attachment extends B9_WeaponAttachment;

var FX_Dummy_Position	fExhaustDummy;

//////////////////////////////////
// Functions
//

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}


simulated function SpawnEffect()
{
	local Emitter	fx;
	
	Super.SpawnEffect();

	fx = spawn(class'WeaponFX_RocketExhaust',Self,, GetBoneCoords( 'exhaust' ).Origin, GetBoneRotation( 'exhaust' ) );
	AttachToBone( fx, 'exhaust' );
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
	FiringMode=MODE_Grenade
	fAnimKind=3
	Mesh=SkeletalMesh'B9Weapons_models.RocketLauncher_mesh'
}