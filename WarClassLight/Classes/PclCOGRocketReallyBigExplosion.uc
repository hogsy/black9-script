// ====================================================================
//  Class:  WarClassLight.PclCOGRocketReallyBigExplosion
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class PclCOGRocketReallyBigExplosion extends Emitter;

event PostBeginPlay()
{
	PlaySound(sound'wareffects.explo1',SLOT_Misc,1.0);
}

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	Physics=10
	bNoDelete=false
	bDynamicLight=true
	bTrailerSameRotation=true
	RemoteRole=2
}