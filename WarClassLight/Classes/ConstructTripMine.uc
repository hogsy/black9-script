// ====================================================================
//  Class:  WarClassLight.ConstructTripMine
//  Parent: WarfareGame.Constructions
//
//  <Enter a description here>
// ====================================================================

class ConstructTripMine extends Constructions;

#exec OBJ LOAD FILE=..\textures\COG_Hud.utx PACKAGE=COG_Hud

defaultproperties
{
	MyConstructClass=Class'TripMines'
	bAlignToNormal=true
	StatusIcon=Texture'COG_Hud.Icons.C_TripMineTemp_T_JW'
	ItemName="Laser Trip Mine"
}