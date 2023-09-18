//=============================================================================
// BulletBox.
//=============================================================================
class BulletBox extends TournamentAmmo;

#exec MESH IMPORT MESH=BulletBoxM ANIVFILE=..\WarClassContent\MODELS\rifleammo_a.3D DATAFILE=..\WarClassContent\MODELS\rifleammo_d.3D LODSTYLE=10
#exec MESH ORIGIN MESH=BulletBoxM X=0 Y=-200 Z=0 YAW=0
#exec MESH SEQUENCE MESH=BulletBoxM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=BulletBoxT FILE=..\WarClassContent\MODELS\rifleammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=BulletBoxM X=0.035 Y=0.035 Z=0.07
#exec MESHMAP SETTEXTURE MESHMAP=BulletBoxM NUM=0 TEXTURE=BulletBoxT

defaultproperties
{
	AmmoAmount=10
	MaxDesireability=0.24
	InventoryType=Class'BulletAmmo'
	PickupMessage="You got a box of rifle rounds."
	Mesh=VertMesh'BulletBoxM'
	Skins=/* Array type was not detected. */
	CollisionRadius=15
	CollisionHeight=10
}