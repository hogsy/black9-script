//////////////////////////////////////////////////////////////////////////
//
// Black 9 Civilian Thug Pawn.  Probably temp code.
//
//////////////////////////////////////////////////////////////////////////
class B9_AI_CivilianThug extends B9_ArchetypePawnCombatant placeable;



// Animations



function PlayNanoAttack()
{
	PlayAnim('nano');
//	fSelectedSkill.FireNano();
}


function AnimateWalking()
{
	MovementAnims[ 0 ] = 'walk_f';
	MovementAnims[ 1 ] = 'walk_sidestep_l';
	MovementAnims[ 2 ] = 'walk_b';
	MovementAnims[ 3 ] = 'walk_sidestep_r';
}

function AnimateRunning()
{
	MovementAnims[ 0 ] = 'run_f';
	MovementAnims[ 1 ] = 'run_sidestep_l';
	MovementAnims[ 2 ] = 'run_b';
	MovementAnims[ 3 ] = 'run_sidestep_r';
}

simulated function AnimateSwimming()
{
	MovementAnims[0] = 'swim_f';
	MovementAnims[1] = 'swim_f';
	MovementAnims[2] = 'swim_f';
	MovementAnims[3] = 'swim_f';
}

simulated function AnimateTreading()
{
	MovementAnims[0] = 'swim_f';
	MovementAnims[1] = 'swim_f';
	MovementAnims[2] = 'swim_f';
	MovementAnims[3] = 'swim_f';
}

simulated function AnimateCrouchingWalking()
{
	MovementAnims[0] = 'crouch_f';
	MovementAnims[1] = 'crouch_b';
	MovementAnims[2] = 'crouch_step_l';
	MovementAnims[3] = 'crouch_step_r';
}

simulated function AnimateClimbing()
{
	MovementAnims[0] = 'climb_up';
	MovementAnims[1] = 'climb_up';
	MovementAnims[2] = 'climb_down';
	MovementAnims[3] = 'climb_up';
}

simulated function AnimateCowering()
{
	MovementAnims[0] = 'Cower';
	MovementAnims[1] = 'Cower';
	MovementAnims[2] = 'Cower';
	MovementAnims[3] = 'Cower';
}

defaultproperties
{
	MenuName="B9_Civilian_Combatant"
	Mesh=SkeletalMesh'B9_Civilian_Characters.Civilian_variant_d_mesh'
}