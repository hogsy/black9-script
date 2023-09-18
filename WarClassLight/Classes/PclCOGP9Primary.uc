// ====================================================================
//  Class:  WarClassLight.PclCOGP9Primary
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class PclCOGP9Primary extends Emitter;

function Activate(int team)
{
	Emitters[Team].Disabled=false;
}


defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	bNoDelete=false
	bDynamicLight=true
	RemoteRole=1
}