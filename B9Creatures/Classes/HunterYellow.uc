//=============================================================================
// Black9 Hunter Robot (Yellow) for Unreal Warfare -- version 2
//=============================================================================
class HunterYellow extends Hunter;

//-----------------------------------------------------------------------------
// B9_Hunter animation and sound data.

#exec OBJ LOAD FILE=..\animations\B9Creatures_models.ukx PACKAGE=B9Creatures

//Commented out sound notifiers - done in .ukx packages now - DP

//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=run_forward TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=run_forward TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=run_forward_fire TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=run_forward_fire TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=walk_step_left TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=walk_step_left TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=walk_step_right TIME=0.25 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=walk_step_right TIME=0.75 FUNCTION=PlayFootStep
//#exec ANIM NOTIFY ANIM=HunterYellowAnims SEQ=death_fall_backwards TIME=0.7 FUNCTION=LandThump


// Attach tags
#exec MESH ATTACHNAME Mesh=B9Creatures.HunterYellowModel BONE="HunterGun" TAG="HunterGunTag" YAW=0 PITCH=64 ROLL=0 X=140 Y=20 Z=0  

defaultproperties
{
	MenuName="Hunter Eradicator XLM48"
	Mesh=SkeletalMesh'HunterYellowModel'
	CollisionHeight=95
}