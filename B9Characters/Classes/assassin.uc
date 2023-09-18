//===============================================================================
//  [assassin] 
//===============================================================================

class assassin extends B9_PlayerPawn;

//#exec OBJ LOAD FILE=..\animations\B9_Player_Characters.ukx PACKAGE=B9_Player_Characters


//Attach Tag - old code but sotra backwards-compatible - please leave for now - DP
//#exec MESH ATTACHNAME Mesh=B9Characters_models.AssassinGirl BONE="Bip01 R Hand" TAG="righthand" YAW=0 PITCH=0 ROLL=0 X= 29.0 Y= -2 Z= 8.0  
//#exec MESH ATTACHNAME Mesh=B9Characters_models.AssassinGirl BONE="Bip01 L Forearm" TAG="guntest" YAW=0 PITCH=0 ROLL=0 X= 29.0 Y= -2 Z= 8.0  


#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX


//var AssassinShadow		Shadow;		//for simple oval shadow
//var vector			ShadowOffset;	//for simple oval shadow
//var ShadowProjector		Shadow;		//for detailed shadow

function name GetWeaponBoneFor(Inventory I)
{
	return 'weaponbone';
}


function PlayGesture( int num, float tweenTime )
{
	if ( Weapon == None )
	{
		switch (num)
		{
		case 1:
			PlayAnim('nowpn_walk_idle_3', tweenTime );
			break;
		case 2:
			PlayAnim('nowpn_walk_idle_6', tweenTime );
			break;
		case 3:
			PlayAnim('nowpn_walk_idle_7', tweenTime );
			break;
		case 4:
			PlayAnim('nowpn_walk_idle_8', tweenTime );
			break;
		}
	}
	else
	{
		PlayAnim('rifle_run_idle_combat_taunt', tweenTime );
	}
}

//=============================================================================
// Animation playing - should be implemented in subclass, 
//
// PlayWaiting, PlayRunning, and PlayGutHit, PlayMovingAttack (if used)
// and PlayDying are required to be implemented in the subclass

function PlaySpecialAnimation( B9_Pawn.ESpecialAnimation animation )
{
	switch(animation)
	{
	case kSuddenStop:
		if ( Weapon == None )
		{
			PlayAnim( 'nowpn_run_forward_suddenstop', 1.0 );
		}
		else
		{
			PlayAnim( 'rifle_run_forward_suddenstop', 1.0 );
		}
		break;
	}
}

simulated function AnimateWalking()
{
	//Log( "AnimateWalking" );

	if ( Weapon == None )
	{
		MovementAnims[0] = 'nowpn_Walk_Forward';
		MovementAnims[1] = 'nowpn_Walk_Backward';
		MovementAnims[2] = 'nowpn_Walk_Step_Left';
		MovementAnims[3] = 'nowpn_Walk_Step_Right';
	}
	else
	{
		MovementAnims[0] = 'rifle_Walk_Forward';
		MovementAnims[1] = 'rifle_Walk_Backward';
		MovementAnims[2] = 'rifle_Walk_Step_Left';
		MovementAnims[3] = 'rifle_Walk_Step_Right';
	}



}

simulated function AnimateRunning()
{
	//Log( "AnimateRunning" );

	if ( Weapon == None )
	{
		MovementAnims[0] = 'nowpn_Run_Forward';
		MovementAnims[1] = 'nowpn_Run_Backward';
		MovementAnims[2] = 'nowpn_Run_Step_Left';
		MovementAnims[3] = 'nowpn_Run_Step_Right';
	}
	else
	{
		MovementAnims[0] = 'rifle_Run_Forward';
		MovementAnims[1] = 'rifle_Run_Backward';
		MovementAnims[2] = 'rifle_Run_Step_Left';
		MovementAnims[3] = 'rifle_Run_Step_Right';
	}


}

simulated function AnimateCrouchWalking()
{
//	Log( "AnimateCrouchWalking" );

	if ( Weapon == None )
	{
		MovementAnims[0] = 'crouch_f';
		MovementAnims[1] = 'crouch_b';
		MovementAnims[2] = 'crouch_Step_L';
		MovementAnims[3] = 'crouch_Step_R';
	}
	else
	{
		MovementAnims[0] = 'crouch_f';
		MovementAnims[1] = 'crouch_b';
		MovementAnims[2] = 'crouch_Step_L';
		MovementAnims[3] = 'crouch_Step_R';
	}


}

simulated function AnimateSwimming()
{
//	Log( "AnimateSwimming" );
// swimming, breaststroke, overhand

	if ( Weapon == None )
	{
		MovementAnims[0] = 'breaststroke';
		MovementAnims[1] = 'breaststroke';
		MovementAnims[2] = 'breaststroke';
		MovementAnims[3] = 'breaststroke';
	}
	else
	{
		MovementAnims[0] = 'breaststroke';
		MovementAnims[1] = 'breaststroke';
		MovementAnims[2] = 'breaststroke';
		MovementAnims[3] = 'breaststroke';
	}


}

simulated function AnimateFlying()
{
//	Log( "AnimateSwimming" );
// swimming, breaststroke, overhand

	if ( Weapon == None )
	{
		MovementAnims[0] = 'swimming';
		MovementAnims[1] = 'swimming';
		MovementAnims[2] = 'swimming';
		MovementAnims[3] = 'swimming';
	}
	else
	{
		MovementAnims[0] = 'swimming';
		MovementAnims[1] = 'swimming';
		MovementAnims[2] = 'swimming';
		MovementAnims[3] = 'swimming';
	}


}

simulated function AnimateClimbing()
{
//	Log( "AnimateClimbing" );
// climb_down

	if ( Weapon == None )
	{
		MovementAnims[0] = 'climb';
		MovementAnims[1] = 'climb_down';
		MovementAnims[2] = 'climb';
		MovementAnims[3] = 'climb';
	}
	else
	{
		MovementAnims[0] = 'climb';
		MovementAnims[1] = 'climb_down';
		MovementAnims[2] = 'climb';
		MovementAnims[3] = 'climb';
	}


}

function AnimateStoppedOnLadder()
{
	PlayAnim( 'climb_down', 0 );
}


function PlayRunning()
{
	PlayMoving();
}


function PlayFlying()
{
	Log( "PlayFlying: " $ GetStateName() );
	
	PlayMoving();
}

simulated function AnimateTreading()
{
	LoopIfNeeded('overhand', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded('crouch_idle', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
	{
		// FIXME - play chatting animation
		return;
	}

	if( Weapon == None )
	{
		LoopIfNeeded('nowpn_walk_idle_1', 1.0, 0.0 );
	}
	else
	{
		LoopIfNeeded('rifle_run_idle', 1.0, 0.0 );
	}
}

function PlayMovingAttack()
{
	Log( "PlayerWalking: " $ GetStateName() );
	//Note - must restart attack timer when done with moving attack
	
	PlayMoving();
}

function PlayWaitingAmbush()
{
	PlayWaiting();
}

function PlayThreatening()
{
	PlayMoving();
}

function PlayPatrolStop()
{
	PlayWaiting();
}

function PlayTurning(bool bTurningLeft)
{
	PlayMoving();
/*
	if ( Weapon == None )
	{
		LoopAnim('nowpn_walk_turn');
	}
	else
	{
		LoopAnim('rifle_walk_turn');
	}
*/

}


simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_death_slump');
	}
	else
	{
		PlayAnim('nowpn_death_slump');
	}

	Super.PlayDying( DamageType, HitLoc );
}

/*
function PlayBigDeath(class<DamageType> DamageType)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_death_slump');
	}
	else
	{
		PlayAnim('nowpn_death_slump');
	}
}

function PlayHeadDeath(class<DamageType> DamageType)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_death_slump');
	}
	else
	{
		PlayAnim('nowpn_death_slump');
	}
}

function PlayLeftDeath(class<DamageType> DamageType)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_death_slump');
	}
	else
	{
		PlayAnim('nowpn_death_slump');
	}
}

function PlayRightDeath(class<DamageType> DamageType)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_death_slump');
	}
	else
	{
		PlayAnim('nowpn_death_slump');
	}
}

function PlayGutDeath(class<DamageType> DamageType)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_death_slump');
	}
	else
	{
		PlayAnim('nowpn_death_slump');
	}
}
*/

function PlayGutHit(float tweentime)
{
	if ( Weapon == None )
	{
		PlayAnim('nowpn_run_idle_brief');
	}
	else
	{
		PlayAnim('rifle_run_idle_brief');
	}
}

function PlayHeadHit(float tweentime)
{
	PlayGutHit(tweentime);
}

function PlayLeftHit(float tweentime)
{
	PlayGutHit(tweentime);
}

function PlayRightHit(float tweentime)
{
	PlayGutHit(tweentime);
}
			
function PlayVictoryDance()
{
	PlayMoving();
}


function PlayOutOfWater()
{
	PlayFalling();
}

function PlayDive()
{
	PlayAnim( 'overhand' );
}

simulated event PlayJump()
{
	// Actually off the ground now
	//ANF@@@
	local float temp;
	temp = 0;
}

function PlayJumpAnimation()
{
	local vector X,Y,Z, Dir;
	local float f, TweenTime;

	SetAnimRate( 0, 1 );
	SetAnimRate( 1, 1 );
	SetAnimRate( 2, 1 );
	SetAnimRate( 3, 1 );

	if ( (Acceleration.X != 0) || (Acceleration.Y != 0) )
	{
		if ( Weapon == None )
		{
			PlayAnim('nowpn_jump_forward');
		}
		else
		{
			PlayAnim('rifle_jump_forward');
		}
	}
	else
	{
		if ( Weapon == None )
		{
			PlayAnim('nowpn_jump_standing');
		}
		else
		{
			PlayAnim('rifle_jump_standing');
		}
	}
}

function PlayDuck()
{
	PlayAnim('nowpn_run_idle_brief');
}

function PlayCrawling()
{
	if ( Weapon == None )
	{
		LoopAnim('nowpn_crouch_forward');
	}
	else
	{
		LoopAnim('rifle_crouch_forward');
	}
}

function WeaponHit()
{
//	log( "WeaponHit!!!!!" );
//	bMeleeAttack=false;
//	ChangeAnimation();
}

function PlayFiring(float Rate, name FiringMode)
{
	AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE,true);

	bSteadyFiring = false;

	log( "PlayFiring(float Rate, name FiringMode) FiringMode "$FiringMode );
	if ( FiringMode == 'MODE_Overhand' || FiringMode == 'MODE_Slash' )
	{
		PlayAnim('sword_run_forward_fire',,,FIRINGCHANNEL);
	}
	else
	{		
		LoopAnim('rifle_run_idle_fire',,,FIRINGCHANNEL);
	}
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
	// Ensure the proper animation state is set when changing weapons.
	Log( "Chaning animation state" );
	ChangeAnimation();
}


function Touch( Actor Other )
{
	PlayerController(Controller).Touch( Other );
}

function UnTouch( Actor Other )
{
	PlayerController(Controller).UnTouch( Other );
}

auto state BaseState
{
	function BeginState()
	{
		SetTimer(0.1, false);
	}

	function EndState()
	{
		SetTimer(0.0, false);
	}
	


}

// !!!! TEST CODE: immunity to unclassified damage
function bool ImmuneToDamage( Pawn instigatedBy, Vector hitlocation, class<DamageType> damageType )
{
	/* AFSNOTE: Taken out to do play testing - replace with actual immunites to reinstate.
	Log("Assassin hit by " $ damageType.Name);
	return (damageType == class'DamageType');
	*/
	
	return false;
}
// END TEST CODE


  
defaultproperties
{
	fCharacterName="Sahara"
	AirSpeed=1000
	JumpZ=540
	WalkingPct=0.25
	CrouchedPct=0.25
	bPhysicsAnimUpdate=true
	MovementAnims[0]=nowpn_run_forward
	MovementAnims[1]=nowpn_run_backward
	MovementAnims[2]=nowpn_run_step_left
	MovementAnims[3]=nowpn_run_step_right
	Mesh=SkeletalMesh'B9_Player_Characters.Demo_Female_mesh'
}