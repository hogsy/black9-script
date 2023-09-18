// ====================================================================
//  Class:  WarClassHeavy.PclCOGJets
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class PclCOGJets extends Emitter;

#exec OBJ LOAD FILE=..\animations\COGHeavySoldiers.ukx PACKAGE=COGHeavySoldiers

defaultproperties
{
	Emitters=/* Array type was not detected. */
	AutoDestroy=true
	AutoReset=true
	bNoDelete=false
	RemoteRole=2
	AmbientSound=Sound'HeavyGunner.JetPack.jp_Constant'
	SoundRadius=1024
}