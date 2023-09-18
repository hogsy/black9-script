//=============================================================================
// RifleShell.
//=============================================================================
class RifleShell extends BulletBox;

#exec MESH IMPORT MESH=RifleRoundM ANIVFILE=..\WarClassContent\MODELS\rifles_a.3D DATAFILE=..\WarClassContent\MODELS\rifles_d.3D LODSTYLE=10
#exec MESH ORIGIN MESH=RifleRoundM X=0 Y=-200 Z=0 YAW=0
#exec MESH SEQUENCE MESH=RifleRoundM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=RifleR1 FILE=..\WarClassContent\MODELS\rifles.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=RifleRoundM X=0.02 Y=0.02 Z=0.04
#exec MESHMAP SETTEXTURE MESHMAP=RifleRoundM NUM=1 TEXTURE=RifleR1

defaultproperties
{
	AmmoAmount=1
	PickupMessage="You got a rifle round."
	Mesh=VertMesh'RifleRoundM'
	CollisionHeight=15
}