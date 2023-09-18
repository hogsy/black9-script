//=============================================================================
// BulletImpact.
//=============================================================================
class BulletImpact extends Effects;

#exec MESH IMPORT MESH=BulletImpact ANIVFILE=..\botpack\MODELS\bulletimpact_a.3d DATAFILE=..\botpack\MODELS\bulletimpact_d.3d X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=BulletImpact X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=BulletImpact SEQ=All          STARTFRAME=0 NUMFRAMES=1
#exec MESH SEQUENCE MESH=BulletImpact SEQ=hit          STARTFRAME=0 NUMFRAMES=1
#exec MESHMAP NEW   MESHMAP=BulletImpact MESH=BulletImpact
#exec MESHMAP SCALE MESHMAP=BulletImpact X=0.12 Y=0.12 Z=0.3
#exec OBJ LOAD FILE=..\botpack\Textures\HitFx.utx  PACKAGE=WarEffects.HitFx
#exec MESHMAP SETTEXTURE MESHMAP=BulletImpact NUM=1 TEXTURE=WarEffects.HitFx.Impact_A00

simulated function PostBeginPlay()
{	
	Super.PostBeginPlay();
	PlayAnim('Hit',0.5);	
}

simulated function AnimEnd( int Channel )
{
	Destroy();
}		

defaultproperties
{
	DrawType=2
	Mesh=VertMesh'BulletImpact'
	DrawScale=0.28
	AmbientGlow=255
	Style=3
}