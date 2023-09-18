//===============================================================================
//  [B9_standin_player_mut_female] 
//===============================================================================

class B9_standin_player_mut_female extends WarfarePawn;

#exec OBJ LOAD FILE=..\animations\B9_Player_Characters.ukx PACKAGE=B9_Player_Characters

#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX


function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim('knockdown_f',1.0,0.1);
	GotoState('Dying');
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
		{
			AnimateWalking();
			//PlaySound( sound'mech_running_loopable', SLOT_Misc, 1.0 );
		}
		else
			AnimateRunning();
	}
	else
	{
		if ( bIsWalking )
		{
			AnimateWalking();
			//PlaySound( sound'mech_running_loopable', SLOT_Misc, 1.0 );
		}
		else
			AnimateRunning();
	}
}

simulated function AnimateWalking()
{
	TurnLeftAnim = 'Walk';
	TurnRightAnim = 'Walk';
	MovementAnims[0] = 'Walk';
	MovementAnims[2] = 'Walk';
	MovementAnims[1] = 'Walk';
	MovementAnims[3] = 'Walk';
}

simulated function AnimateRunning()
{
	TurnLeftAnim = 'Walk';
	TurnRightAnim = 'Walk';
	MovementAnims[0] = 'Walk';
	MovementAnims[2] = 'Walk';
	MovementAnims[1] = 'Walk';
	MovementAnims[3] = 'Walk';
}


function PlayWaiting()
{
	loopanim ('idle');
}


defaultproperties
{
	Helmet=none
	HelmetBone=Bip 01 Head
	GroundSpeed=215
	WalkingPct=0.64
	Mesh=SkeletalMesh'B9_Player_Characters.mutant_female_standin_mesh'
}