//=============================================================================
// B9_AutomationPartGun
//
// 
//	
//=============================================================================



class B9_AutomationPartGun extends B9_AutomationPart
	notplaceable;

var name	fAttachBoneName;

function name GetWeaponBoneFor(Inventory I)
{
	return fAttachBoneName;
}

// Cause any damage taken by this object to inflict it upon it's parent
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	fParent.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType );

	//log( "ALEX: GunPart, Sent damage to fParent: " $fParent $" fParent has health: " $B9_AutomationSentryTurret( fParent ).Health );
}

//////////////////////////////////
// Initialization
//
defaultproperties
{
	Mesh=SkeletalMesh'B9Vehicles_models.sentrygun_gun_mesh'
	CollisionRadius=60
	CollisionHeight=40
	bCollideWorld=false
}