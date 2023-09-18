//=============================================================================
// B9_AutomationPartShaft
//
// 
//	
//=============================================================================



class B9_AutomationPartShaft extends B9_AutomationPart
	notplaceable;

// Cause any damage taken by this object to inflict it upon it's parent
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType)
{
	fParent.TakeDamage( Damage, instigatedBy, hitlocation, momentum, damageType );

	//log( "ALEX: Sent damage to fParent: " $fParent $" fParent has health: " $B9_AutomationSentryTurret( fParent ).Health );
}

//////////////////////////////////
// Initialization
//
defaultproperties
{
	Mesh=SkeletalMesh'B9Vehicles_models.sentrygun_shaft_mesh'
	CollisionRadius=20
	CollisionHeight=10
	bCollideWorld=false
}