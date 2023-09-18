//=============================================================================
// SmallSpark.
//=============================================================================
class SmallSpark extends Effects;

#exec MESH IMPORT MESH=SmallSparkM ANIVFILE=..\botpack\MODELS\Spark_a.3D DATAFILE=..\botpack\MODELS\Spark_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SmallSparkM X=0 Y=0 Z=0 PITCH=-64
#exec MESH SEQUENCE MESH=SmallSparkM SEQ=All       STARTFRAME=0   NUMFRAMES=2
#exec MESH SEQUENCE MESH=SmallSparkM SEQ=Explosion STARTFRAME=0   NUMFRAMES=2
#exec TEXTURE IMPORT NAME=JSmlSpark1 FILE=..\botpack\MODELS\Spark.PCX GROUP=Skins
#exec MESHMAP SCALE MESHMAP=SmallSparkM X=0.06 Y=0.06 Z=0.12
#exec MESHMAP SETTEXTURE MESHMAP=SmallSparkM NUM=1 TEXTURE=JSmlSpark1


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim  ( 'Explosion', 0.2 );
	}
}

simulated function AnimEnd(int Channel)
{	
  	Destroy();
}

defaultproperties
{
	DrawType=2
	RemoteRole=2
	LifeSpan=4
	Mesh=VertMesh'SmallSparkM'
	AmbientGlow=223
}