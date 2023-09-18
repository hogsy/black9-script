Class DSDoor extends DropShipVehiclePart;

#exec MESH  MODELIMPORT MESH=DSDoorMesh MODELFILE=models\HatchDoor.PSK LODSTYLE=10
#exec MESH  ORIGIN MESH=DSDoorMesh X=0 Y=0 Z=0 YAW=0 PITCH=0 ROLL=0
#exec ANIM  IMPORT ANIM=DSDoorAnims ANIMFILE=models\HatchDoor.PSA COMPRESS=1
#exec MESHMAP SCALE MESHMAP=DSDoorMesh X=2.5 Y=2.5 Z=2.5

#exec MESH  DEFAULTANIM MESH=DSDoorMesh ANIM=DSDoorAnims
#exec ANIM DIGEST  ANIM=DSDoorAnims USERAWINFO VERBOSE 

#EXEC MESHMAP SETTEXTURE MESHMAP=DSDoorMesh NUM=0 TEXTURE=DropShipTex

function BeginPlay()
{
	Super.BeginPlay();
	TweenAnim('Up', 0.01); // FIXME - this should be the default first frame
}

function InFlightModel()
{
	GotoState('Closing');
	TweenAnim('Down',0.01);
	bHidden = true;
}
	
State Closing
{
	function AnimEnd(int Channel)
	{
		AmbientSound = None;
		PlaySound(sound'DSClunk');
		GotoState('');
	}

	function BeginState()
	{
		AmbientSound = sound'DSHydraulic';
		PlayAnim('Up');
	}
}

State Opening
{
	function AnimEnd(int Channel)
	{
		AmbientSound = None;
		PlaySound(sound'DSClunk');
		TriggerEvent('DropShipDoorOpen',self,Pawn(Owner));
		GotoState('');
	}

	function BeginState()
	{
		AmbientSound = sound'DSHydraulic';
		PlayAnim('Down');
	}
}

defaultproperties
{
	DrawType=2
	Mesh=SkeletalMesh'DSDoorMesh'
	CollisionRadius=100
	CollisionHeight=100
}