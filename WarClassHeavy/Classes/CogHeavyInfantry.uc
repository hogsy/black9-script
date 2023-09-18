// ====================================================================
//  CogHeavyInfantry :
//
//
//  (C) 2001. Epic Games, Inc. All Rights Reserved.
// ====================================================================

class CogHeavyInfantry extends WarfarePawn
	Abstract;


var bool bJets;				// Player is jetting
var Emitter JetEffect;		// Holds the effects for a jet

replication
{
	reliable if (role==Role_Authority)
		bJets;
}

function PlayLanded(float impactVel)
{	
	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( impactVel > 0.17 )
	{
		if (!bJets)
			PlayOwnedSound(LandGrunt, SLOT_Talk, FMin(5, 5 * impactVel),false,384,FRand()*0.4+0.8);	// 1200
	}
	if ( (impactVel > 0.01) && !TouchingWaterVolume() )
	{
		if (!bJets)
			PlayOwnedSound(Land, SLOT_Interact, FClamp(4 * impactVel,0.5,5), false,256, 1.0);	// 1000
	}
}

event Destroyed()
{
	if (JetEffect!=None)
	{	
		DetachFromBone(JetEffect);
		JetEffect.Destroy();
	}
	
	Super.Destroyed();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( (Role==Role_Authority) && (bJets) )
	{
		DetachFromBone(JetEffect);
		JetEffect.Destroy();
	}
		
	Super.Died(Killer, DamageType, HitLocation);
}
	
function Timer()
{

	if (ROLE==Role_Authority)
	{
		if (bJets)
		{
			Energy -= 10;
			if (Energy<=0)
			{
				ToggleJets(False);
			}
		}
		else if (Energy<Default.Energy)
		{
			Energy += 10;
			if (Energy>Default.Energy)
			{
				Energy=Default.Energy;
				SetTimer(0.0,false);
			}
		}
	}

}		

function bool DoJump( bool bUpdating )
{

	if (ROLE==ROLE_Authority)
	{
		if ( !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Falling) ) 
		{
			ToggleJets(!bJets);
		}
	}
	
	if (bJets)
		return Super.DoJump(bUpdating);
	return false;	
}

function ToggleJets(bool JetsOn)
{
	local vector v;
	if ( JetsOn )
	{
	    GroundSpeed=400;
    	AirSpeed=400;
	    WaterSpeed=400;

		if (Role==Role_Authority)
		{
			JetEffect = spawn(class 'PCLCOGJets',self,,location,rotation);
			AttachToBone(JetEffect,'canopy');
			v.z = 350;
			ConstantAcceleration = v;
			
			
		}
		
	}
	else
	{
	    GroundSpeed=default.GroundSpeed;
    	AirSpeed=default.AirSpeed;
	    WaterSpeed=default.WaterSpeed;

		Velocity.Z = 60;
		SetPhysics(PHYS_Falling);
		
		if (Role==Role_Authority)
		{
			AmbientSound = none;;

			DetachFromBone(JetEffect);
			JetEffect.Destroy();
			ConstantAcceleration = vect(0,0,0);
		}
		AnimateRunning();
	}

	// On the server. turn on the timer
	
	if (ROLE==ROLE_AUTHORITY)	
		SetTimer(0.5,true);
		
	bJets = JetsOn;
}



simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	local name  AnimSequence;
	local float AnimFrame;
	local float AnimRate;

	GetAnimParams( 0, AnimSequence, AnimFrame, AnimRate );

	if ( AnimSequence!='deploy' && AnimSequence!='undeploy' && AnimSequence!='Deploy_cyc' )
		PlayAnim('death_temp1',1.0, 0.1);

}
	
simulated event PlayJump()
{
	PlayOwnedSound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
	CurrentDir = DCLICK_None;
	LoopIfNeeded('Hover',1.0,0.1);	
}

simulated function PlayFiring(float Rate, name FiringMode)
{
	AnimBlendParams(FIRINGCHANNEL,1.0,0,0,FIRINGBLENDBONE,true);
	LoopAnim('shoot_auto',Rate,0.05,FIRINGCHANNEL);

}

simulated function AnimateWalking()			// Should be moved to WarfarePawn when all meshes have walks
{
	if (!bJets)
	{
		MovementAnims[0] = 'Walk';
		MovementAnims[2] = 'Walk_Left';
		MovementAnims[1] = 'Walk_Back';
		MovementAnims[3] = 'Walk_Right';
	}
	else
	{
		MovementAnims[0] = 'Hover_forward';
		MovementAnims[2] = 'Hover_Left';
		MovementAnims[1] = 'Hover_Back';
		MovementAnims[3] = 'Hover_Right';
	}
}

/* AnimateStanding()
standing/waiting 
*/
simulated function AnimateStanding()
{
	if ( (PlayerController(Controller) != None) && PlayerController(Controller).bIsTyping )
	{
		// FIXME - play chatting animation
		return;
	}

	if (!bJets)
		LoopIfNeeded('Stand_Rdy',1.0,0.1);
	else
		LoopIfNeeded('Hover',1.0,0.1);
		
}
simulated function AnimateRunning()
{
	AnimateWalking();
}

/*	
simulated function AnimateRunning()
{
	if (!bJets)
	{
		MovementAnims[0] = 'Run';
		MovementAnims[2] = 'Run_Left';
		MovementAnims[1] = 'Run_Back';
		MovementAnims[3] = 'Run_Right';
	}
	else
	{
		MovementAnims[0] = 'Hover_forward';
		MovementAnims[2] = 'Hover_Left';
		MovementAnims[1] = 'Hover_Back';
		MovementAnims[3] = 'Hover_Right';
	}
}
*/
simulated function AnimateLanding()
{
	if (!bJets)
		LoopIfNeeded('Stand_Rdy',1.0,0.1);
	else
		LoopIfNeeded('Hover',1.0,0.1);
}

simulated function PlayDeployIn();
simulated function PlayDeployOut();


