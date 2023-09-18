// ====================================================================
//  Class:  WarEffects.PclCOGExplosion
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class PclCOGExplosion extends Emitter;

#exec OBJ LOAD FILE=..\Sounds\WarfareExplosion.uax PACKAGE=WarfareExplosion

simulated function PostBeginPlay()
{
	MakeSound();
	Super.PostBeginPlay();		
}

function MakeSound()
{
	PlaySound(Sound'explosion_small2',,12.0,,120);
}


defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	Physics=10
	bNoDelete=false
	bTrailerSameRotation=true
	RemoteRole=1
	Mass=4
}