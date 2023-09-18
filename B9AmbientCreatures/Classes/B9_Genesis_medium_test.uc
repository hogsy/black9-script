//===============================================================================
//  [B9_Genesis_medium_test] 
//===============================================================================

class B9_Genesis_medium_test extends WarfarePawn;

#exec OBJ LOAD FILE=..\animations\B9_Genesis_characters.ukx PACKAGE=B9_Genesis_characters


function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('death',, 0.1);
}

/*
function bool IsWalking()
{
	local name curAnim;
	local float frame, rate;

	GetAnimParams(0,curAnim,frame,rate);

	return (curAnim == 'Walk');

	Log( "IsWalking()" );
}
		
function PlayMoving()
{
	if ( bIsWalking )
	{
		LoopAnim('Walk', 1.2/DrawScale);
	}
	else
	{
		LoopAnim('Run', 1.2/DrawScale);
	}

	Log( "PlayMoving()" );
}
*/

simulated function PlayMoving()
{
	if ( (Physics == PHYS_None) 
		|| ((Controller != None) && Controller.bPreparingMove) )
	{
		// bot is preparing move - not really moving 
		PlayWaiting();
		return;
	}
	if ( Physics == PHYS_Walking )
	{
		if ( bIsWalking )
			AnimateWalking();
		else
			AnimateRunning();
	}
	else
	{
		if ( bIsWalking )
			AnimateWalking();
		else
			AnimateRunning();
	}
}

simulated function AnimateWalking()
{
	TurnLeftAnim = 'Walk';
	TurnRightAnim = 'Walk';
	MovementAnims[0] = 'Walk';
	MovementAnims[2] = 'sidestep_left';
	MovementAnims[1] = 'walk_backward';
	MovementAnims[3] = 'sidestep_right';
}

simulated function AnimateRunning()
{
	TurnLeftAnim = 'Run';
	TurnRightAnim = 'Run';
	MovementAnims[0] = 'Run';
	MovementAnims[2] = 'sidestep_left';
	MovementAnims[1] = 'run_backwards';
	MovementAnims[3] = 'sidestep_right';
}


function PlayWaiting()
{
	loopanim ('idle_surveillance1');
}


defaultproperties
{
	GroundSpeed=250
	Mesh=SkeletalMesh'B9_Genesis_characters.Genesis_medium_mesh'
}