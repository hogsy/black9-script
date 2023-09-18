//=============================================================================
// GrapplingHookTarget.uc
//=============================================================================

class GrapplingHookTarget extends Actor
	Placeable;

defaultproperties
{
	DrawType=2
	Mesh=SkeletalMesh'B9Weapons_models.SG_rocket'
	bCollideActors=true
	bCollideWorld=true
	bBlockActors=true
	bBlockPlayers=true
	bProjTarget=true
}