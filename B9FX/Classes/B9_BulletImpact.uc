//=============================================================================
// BulletImpact.
//=============================================================================
class B9_BulletImpact extends Effects;


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
	Mesh=VertMesh'WarEffects.BulletImpact'
	DrawScale=0.28
	AmbientGlow=255
	Style=3
}