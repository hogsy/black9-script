//=============================================================================
// Miniammo.
//=============================================================================
class MiniAmmo extends TournamentAmmo;

#exec MESH IMPORT MESH=MiniAmmom ANIVFILE=..\WarClassContent\MODELS\Miniammo_a.3D DATAFILE=..\WarClassContent\MODELS\Miniammo_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=MiniAmmom X=-50 Y=-40 Z=0 YAW=0
#exec MESH SEQUENCE MESH=MiniAmmom SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JM21 FILE=..\WarClassContent\MODELS\miniammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=MiniAmmom X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=MiniAmmom NUM=1 TEXTURE=JM21

defaultproperties
{
	AmmoAmount=300
	InventoryType=Class'MinigunAmmo'
	PickupMessage="You picked up 300 bullets."
	Mesh=VertMesh'MiniAmmom'
	CollisionHeight=11
}