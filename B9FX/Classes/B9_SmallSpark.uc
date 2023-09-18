//=============================================================================
// B9_SmallSpark.
//=============================================================================
class B9_SmallSpark extends Effects;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		PlayAnim  ( 'Explosion', 0.2 );
		PlaySound (EffectSound1);
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
	LifeSpan=0.2
	Mesh=VertMesh'WarEffects.SmallSparkM'
	AmbientGlow=223
}