// ====================================================================
//  Class:  WarfareGame.WarCTFBase
//
//  <Enter a description here>
//
// (c) 2001, Epic Games, Inc - All Rights Reserved
// ====================================================================

class WarCTFBase extends CTFBase;

var WaypointBeacon MyBeacon;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('newflag');
	SimAnim.bAnimLoop = true;  

	MyBeacon = Spawn(class 'WaypointBeacon',self,,Location+(Vect(0,0,1)*64));
	MyBeacon.Team = DefenderTeamIndex;
}

defaultproperties
{
	Mesh=VertMesh'Decorations.NewFlag'
}