//=============================================================================
// HandToHand_collision
//
// 
//
// 
//=============================================================================

class HandToHand_collision extends Actor
	notplaceable;


var private sound fHitWallSound;
var private sound fHitActorSound;
var class<DamageType> MyDamageType;
var public int Damage;


simulated singular function Touch(Actor Other)
{
//	if( Role < ROLE_Authority || Other == Owner )
//	{
//		return;
//	}

	log( "## TOUCHED "$Other );

	/*
	local actor HitActor;
	local vector HitLocation, HitNormal, VelDir;
	local bool bBeyondOther;
	local float BackDist, DirZ;

	if ( Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers) )
	{
		if ( Velocity == vect(0,0,0) )
		{
			ProcessTouch(Other,Location);
			return;
		}
		
		//get exact hitlocation - trace back along velocity vector
		bBeyondOther = ( (Velocity Dot (Location - Other.Location)) > 0 );
		VelDir = Normal(Velocity);
		DirZ = sqrt(VelDir.Z);
		BackDist = Other.CollisionRadius * (1 - DirZ) + Other.CollisionHeight * DirZ;
		if ( bBeyondOther )
			BackDist += VSize(Location - Other.Location);
		else
			BackDist -= VSize(Location - Other.Location);

	 	HitActor = Trace(HitLocation, HitNormal, Location, Location - 1.1 * BackDist * VelDir, true);
		if (HitActor == Other)
			ProcessTouch(Other, HitLocation); 
		else if ( bBeyondOther )
			ProcessTouch(Other, Other.Location - Other.CollisionRadius * VelDir);
		else
			ProcessTouch(Other, Location);
	}
	*/
}

simulated function ProcessTouch( Actor Other, vector HitLocation )
{
	if( Role < ROLE_Authority || Other == Instigator )
	{
		return;
	}

	if( !Other.bWorldGeometry )
	{
		log( "### Punching someone in the face." );
		PlaySound( fHitActorSound, SLOT_None, 1.0 );
		Other.TakeDamage( Damage, Instigator, HitLocation, Vector(Rotation), MyDamageType );	
	}
	else
	{
		log( "### Punching wall." );
		PlaySound( fHitWallSound, SLOT_None, 1.0 );
	}

	Destroy();
}


//////////////////////////////////
// Initialization
//



defaultproperties
{
	fHitWallSound=Sound'B9SoundFX.Bullet_Impacts.bullet_hitting_metal'
	fHitActorSound=Sound'B9SoundFX.Bullet_Impacts.bullet_hitting_flesh'
	Damage=10
	DrawType=0
	CollisionRadius=10
	CollisionHeight=10
	bCollideActors=true
	bCollideWorld=true
}