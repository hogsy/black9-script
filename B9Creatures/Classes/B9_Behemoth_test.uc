//===============================================================================
//  [B9_Behemoth_test] 
//===============================================================================

class B9_Behemoth_test extends WarfarePawn;

#exec OBJ LOAD FILE=..\animations\B9_Zubrin_characters.ukx PACKAGE=B9_Zubrin_characters

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
		LoopAnim('walk', 1.2/DrawScale);
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
			//PlaySound( sound'mech_walkning_loopable', SLOT_Misc, 1.0 );
		}
		else
			AnimateRunning();
	}
	else
	{
		if ( bIsWalking )
		{
			AnimateWalking();
			//PlaySound( sound'mech_walkning_loopable', SLOT_Misc, 1.0 );
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
	MovementAnims[2] = 'walk';
	MovementAnims[1] = 'walk';
	MovementAnims[3] = 'walk';
}

simulated function AnimateRunning()
{
	TurnLeftAnim = 'Walk';
	TurnRightAnim = 'Walk';
	MovementAnims[0] = 'walk';
	MovementAnims[2] = 'walk';
	MovementAnims[1] = 'walk';
	MovementAnims[3] = 'walk';
}


function PlayWaiting()
{
	loopanim ('idle');
}


defaultproperties
{
	Helmet=none
	HelmetBone=None
	Footstep[0]=Sound'B9SoundFX.Mech.mech_running'
	Footstep[1]=Sound'B9SoundFX.Mech.mech_running'
	Footstep[2]=Sound'B9SoundFX.Mech.mech_running'
	Footstep[3]=Sound'B9SoundFX.Mech.mech_running'
	GroundSpeed=250
	WalkingPct=1
	Mesh=SkeletalMesh'B9_Zubrin_characters.behemoth_test_mesh_2'
}