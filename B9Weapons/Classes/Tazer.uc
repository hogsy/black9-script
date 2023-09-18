//=============================================================================
// Tazer.uc
//
// melee weapon
//
// 
//=============================================================================


class Tazer extends B9MeleeWeapon;


//////////////////////////////////
// Resource imports
//



//////////////////////////////////
// Variables
//

//////////////////////////////////
// Functions
//

/*
simulated function Fire( float Value )
{
	local Pawn targetPawn;
	local vector targetDir, X, Y, Z;

	// Search for B9_Pawn
	foreach RadiusActors( class 'Pawn', targetPawn, fDamageRadius, Instigator.Location )
	{
		if ( targetPawn != Instigator )
		{
			// Need to check if the target is infront of us
			targetDir = targetPawn.Location - Instigator.Location;
			GetAxes( Rotation, X, Y, Z );

			if ( X Dot targetDir > 0 )	// Smack him!
			{
				X = Normal(X);
				// Be back --> Need damage and momentum
				targetPawn.TakeDamage( fMeleeDamage, Instigator, targetPawn.Location, 
					fMomentumTransfer * X, class'Impact' );
			}
		}
	}

	Super.Fire(Value);
}
*/

//////////////////////////////////
// States
//



//////////////////////////////////
// Initialization
//

defaultproperties
{
	fDamageRadius=100
	fMomentumTransfer=100
	fROF=1000
	fUniqueID=4
	fMeleeWeapon=true
	fMeleeDamage=10
	fIniLookupName="Tazer"
	AmmoName=Class'Tazer_Ammunition'
	PickupAmmoCount=30
	ReloadCount=15
	TraceDist=100
	MaxRange=100
	FireSound=Sound'B9SoundFX.Bullet_Impacts.p9mm_fire'
	PickupClass=Class'Tazer_Pickup'
	AttachmentClass=Class'Tazer_Attachment'
	Icon=Texture'B9HUD_textures.Browser_weapons.stun_gun_bricon'
	ItemName="Tazer"
	DrawType=8
}