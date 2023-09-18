//=============================================================================
// UTTeleEffect.
//=============================================================================
class UTTeleEffect extends Effects;

#exec MESH IMPORT MESH=Tele2 ANIVFILE=..\botpack\MODELS\Tele2_a.3d DATAFILE=..\botpack\MODELS\Tele2_d.3d X=0 Y=0 Z=0

#exec MESH SEQUENCE MESH=Tele2 SEQ=All                      STARTFRAME=0 NUMFRAMES=100
#exec MESH SEQUENCE MESH=Tele2 SEQ=Teleport                 STARTFRAME=0 NUMFRAMES=100
#exec MESHMAP NEW   MESHMAP=Tele2 MESH=Tele2
#exec MESHMAP SCALE MESHMAP=Tele2 X=0.1 Y=0.1 Z=0.2

#exec TEXTURE IMPORT NAME=JTele2_01 FILE=..\botpack\Textures\Trail.PCX GROUP=Skins
#exec MESHMAP SETTEXTURE MESHMAP=Tele2 NUM=1 TEXTURE=JTele2_01


function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('Teleport', 2.0, 0.0);
}

defaultproperties
{
	DrawType=2
	LifeSpan=1
	Mesh=VertMesh'Tele2'
	Style=3
}