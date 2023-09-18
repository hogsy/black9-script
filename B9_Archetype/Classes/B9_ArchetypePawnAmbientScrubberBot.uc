//////////////////////////////////////////////////////////////////////////
//
// Black 9 Scrubber bot
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnAmbientScrubberBot extends B9_ArchetypePawnAmbient;

defaultproperties
{
	bCanJump=false
	bAvoidLedges=true
	bStopAtLedges=true
	GroundSpeed=300
	BaseEyeHeight=10
	EyeHeight=10
	MenuName="B9_ScrubberBot"
	ControllerClass=Class'B9_AI_ControllerScrubberBot'
	MovementAnims[0]=Scrub
	MovementAnims[1]=Scrub
	MovementAnims[2]=Scrub
	MovementAnims[3]=Scrub
	Mesh=SkeletalMesh'B9AmbientCreatures_models.ScrubberBot'
	CollisionRadius=25
	CollisionHeight=16
}