//=============================================================================
// Bubble.
//=============================================================================
class Bubble extends Effects;
    
#exec Texture Import File=models\bubble1.pcx  Name=S_bubble1 Mips=Off MASKED=1
#exec Texture Import File=models\bubble2.pcx  Name=S_bubble2 Mips=Off MASKED=1
#exec Texture Import File=models\bubble3.pcx  Name=S_bubble3 Mips=Off MASKED=1

#exec MESH IMPORT MESH=SBubbles ANIVFILE=..\botpack\MODELS\SRocket_a.3D DATAFILE=..\botpack\MODELS\SRocket_d.3D X=0 Y=0 Z=0
#exec MESH ORIGIN MESH=SBubbles X=0 Y=0 Z=0 YAW=0 ROLL=0 PITCH=0
#exec MESH SEQUENCE MESH=SBubbles SEQ=All       STARTFRAME=0   NUMFRAMES=16
#exec MESH SEQUENCE MESH=SBubbles SEQ=Ignite    STARTFRAME=0   NUMFRAMES=3
#exec MESH SEQUENCE MESH=SBubbles SEQ=Flying    STARTFRAME=3   NUMFRAMES=13
#exec MESHMAP SCALE MESHMAP=SBubbles  X=0.3 Y=0.3 Z=0.4

function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if( !NewVolume.bWaterVolume )
		Destroy();
}

simulated function BeginPlay()
{
	Super.BeginPlay();
	if ( Level.NetMode != NM_DedicatedServer )
	{
		LifeSpan = 3 + 4 * FRand();
		if (FRand()<0.3) Texture = texture'S_Bubble2';
		else if (FRand()<0.3) Texture = texture'S_Bubble3';
		LoopAnim('Flying',0.6);
	}
}

defaultproperties
{
	Physics=2
	DrawType=2
	RemoteRole=2
	LifeSpan=2
	Mesh=VertMesh'SBubbles'
	Texture=Texture'S_bubble1'
	DrawScale=0.2
	Style=3
	Mass=3
	Buoyancy=5
}