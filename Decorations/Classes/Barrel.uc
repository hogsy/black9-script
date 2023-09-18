//=============================================================================
// Barrel.
//=============================================================================
class Barrel extends WarDecoration;

#exec MESH IMPORT MESH=BarrelM ANIVFILE=..\botpack\MODELS\Barrel_a.3D DATAFILE=..\botpack\MODELS\Barrel_d.3D ZEROTEX=1
#exec MESH LODPARAMS MESH=BarrelM STRENGTH=0.5 
#exec MESH ORIGIN MESH=BarrelM X=320 Y=160 Z=95 YAW=64
#exec MESH SEQUENCE MESH=BarrelM SEQ=All    STARTFRAME=0   NUMFRAMES=1
#exec MESH SEQUENCE MESH=BarrelM SEQ=Still  STARTFRAME=0   NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JBarrel1 FILE=..\botpack\MODELS\Barrel.PCX GROUP=Skins MASKED=1
#exec MESHMAP SCALE MESHMAP=BarrelM X=0.18 Y=0.18 Z=0.36
#exec MESHMAP SETTEXTURE MESHMAP=BarrelM NUM=0 TEXTURE=JBarrel1 TLOD=10

defaultproperties
{
	NumFrags=12
	FragType=Class'WarEffects.WoodFragments'
	Health=50
	Mesh=VertMesh'BarrelM'
	Skins=/* Array type was not detected. */
	Buoyancy=60
}