//=============================================================================
// ut_Ringexplosion.
//=============================================================================
class UT_RingExplosion extends Effects;

#exec MESH IMPORT MESH=UTRingex ANIVFILE=..\botpack\MODELS\Ring_a.3D DATAFILE=..\botpack\MODELS\Ring_d.3D ZEROTEX=1 LODSTYLE=8
#exec MESH ORIGIN MESH=UTRingex X=0 Y=0 Z=0 YAW=0 PITCH=64
#exec MESH SEQUENCE MESH=UTRingex SEQ=All   STARTFRAME=0   NUMFRAMES=9
#exec MESH SEQUENCE MESH=UTRingex SEQ=Explo STARTFRAME=0   NUMFRAMES=9
#exec TEXTURE IMPORT NAME=ASaRing FILE=..\botpack\models\ring2.pcx GROUP=Effects
#exec MESHMAP SCALE MESHMAP=UTRingex X=0.4 Y=0.4 Z=0.8 YAW=128
#exec MESHMAP SETTEXTURE MESHMAP=UTRingex  NUM=0 TEXTURE=ASaRing

var bool bExtraEffectsSpawned;

simulated function Tick( float DeltaTime )
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !bExtraEffectsSpawned )
			SpawnExtraEffects();
		AmbientGlow = (Lifespan/Default.Lifespan)*0.7 * 255;		
	}
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim( 'Explo', 0.35, 0.0 );
		SpawnEffects();
	}	
	if ( Instigator != None )
		MakeNoise(0.5);
}

simulated function SpawnEffects()
{
	 Spawn(class'shockexplo');
}

simulated function SpawnExtraEffects()
{
	bExtraEffectsSpawned = true;
}

defaultproperties
{
	bExtraEffectsSpawned=true
	DrawType=2
	RemoteRole=2
	LifeSpan=0.8
	Mesh=VertMesh'UTRingex'
	DrawScale=0.7
	AmbientGlow=255
	Style=0
}