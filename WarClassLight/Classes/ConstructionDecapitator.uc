// ====================================================================
//  Class:  WarClassLight.ConstructionDecapitator
//  Parent: WarfareGame.Constructions
//
//  <Enter a description here>
// ====================================================================

class ConstructionDecapitator extends Constructions;

#exec OBJ LOAD FILE=..\textures\COG_Hud.utx PACKAGE=COG_Hud

defaultproperties
{
	MyConstructClass=Class'Decapitator'
	bAlignToNormal=true
	StatusIcon=Texture'COG_Hud.Icons.C_TripMineTemp_T_JW'
	ItemName="Decapitator"
}