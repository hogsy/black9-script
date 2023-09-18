class B9_AutomationSecurityCameraController extends B9_AutomationSentryTurretController;

var	float	fTimeJammed;
var	float	fJammCamTime;
var	float	fMinimumJamTime;
var bool	fbJammed;

var float fTimeIDingTarget;
var bool  fIDTargetMode;	// AMBER LIGHT if true unless it should be RED
var Pawn  fLastTargetIDing;
var float   fCurrentYaw;
var float fTimeToResetCamera;
var float fResetCameraTicks;	// RED LIGHT is != 0.0f

var bool  fSwingingRight;
var Rotator	fDefaultRotation;



var fx_CamJamCameraSparkle fSparkle;

const CosHalf45Deg = 0.924f;

function Trigger( actor Other, pawn EventInstigator )
{
	local int  CamJamSkillStrength;
//	log("Camera Triggered");
	if( B9_Skill( Other ) != none )
	{
		// Check to see if the trigger is the CamJam Skill
		if( B9_Skill( Other ).fUniqueID == skillID_CamJam )
		{
//			log("Camera was triggered by CamJam");
			CamJamSkillStrength = B9_Skill( Other ).SkillFeedBack(self,skillResponse_GetCamJamStrength,0,B9_AutomationSecurityCamera(Pawn).fLocksKeyCode);
			fJammCamTime = (FRand() * CamJamSkillStrength) + fMinimumJamTime;
//			log("Jammed For "$fJammCamTime$" seconds!");
			fbJammed = true;
			if( fSparkle != None )
			{
				fSparkle.Destroy();
				fSparkle = None;
			}
			fSparkle = Spawn( class'fx_CamJamCameraSparkle', self, , Location, Rotation );

			SetGreenLight();
			fResetCameraTicks = 0.0f;
		}
	}
}

function SlowRotationToYaw(float DesiredYaw ,float timeDelta )
{
	local Rotator Direction;
	local int CurrentPositionAbs;

	Direction.Pitch = B9_AutomationSecurityCamera( Pawn ).fCameraPitch & 65535;
//	log("Pitch"$Direction.Pitch);

	if( fbJammed == true )
		return;
	CurrentPositionAbs = fCurrentYaw+ B9_Automation( Pawn ).Rotation.Yaw;
	CurrentPositionAbs = CurrentPositionAbs & 65535;
	//Log("Enemy Rotation"$DesiredYaw);
	//Log("CurrentPositionAbs:"$CurrentPositionAbs);
	//Log("OffsetRotation"$fCurrentYaw);
	if( DesiredYaw > CurrentPositionAbs )
	{
		fCurrentYaw += (timeDelta*(B9_AutomationSecurityCamera( Pawn ).fYawRate));
		if( fCurrentYaw > B9_AutomationSecurityCamera( Pawn ).fRight)
		{
			// Hit the Max reach of Camera 
			//Log("Max Right at:"$fCurrentYaw);
			fCurrentYaw = B9_AutomationSecurityCamera( Pawn ).fRight;
		}
	}
	else
	{
		fCurrentYaw -= (timeDelta*(B9_AutomationSecurityCamera( Pawn ).fYawRate));
		if( fCurrentYaw < B9_AutomationSecurityCamera( Pawn ).fLeft)
		{
			//Log("Max Left at:"$fCurrentYaw);
			fCurrentYaw = B9_AutomationSecurityCamera( Pawn ).fLeft;
		}
	}

	Direction.Yaw = ( fCurrentYaw + B9_Automation( Pawn ).Rotation.Yaw);
	B9_Automation( Pawn ).Orient( Direction );
}
// Functions
function AcquireTarget()
{
	local B9_BasicPlayerPawn assailPawn;
	local vector HitNormal, HitLocation; //, Location, extent,finalPoint;
//	local actor HitActor;
	local vector targetVector;
	local float dotProd;
	//local rotator Direction;

	//Direction.Pitch = B9_AutomationSecurityCamera( Pawn ).fCameraPitch & 65535;
	//Direction.Yaw = ( fCurrentYaw + B9_Automation( Pawn ).Rotation.Yaw);

//	Log("Camera AquireTarget_Yaw:"$Direction.Yaw);
//	Log("Camera AquireTarget_Pitch:"$Direction.Pitch);
//	Log("Camera AquireTarget_Roll:"$Direction.Roll);
	// Set closest target to an impossibly large value.

	assailPawn = None;

	foreach B9_Automation( Pawn ).fGunPart.RadiusActors( class'B9_BasicPlayerPawn', assailPawn, 
		B9_AutomationSecurityCamera( Pawn ).fViewDistance)
	{
		// Target must we within a 45 degree scan area (22.5 degrees per side).
		targetVector = Normal(assailPawn.Location - B9_Automation( Pawn ).fGunPart.Location);
		if (targetVector dot vector(B9_Automation( Pawn ).fGunPart.Rotation) >= CosHalf45Deg)
		{
			// And target must be visible to camera.
			if (assailPawn == Trace(HitLocation, HitNormal, assailPawn.Location, B9_Automation( Pawn ).fGunPart.Location, true))
				break;
		}
		assailPawn = None;
	}

/*
//	extent	= Pawn.CollisionRadius * vect(1,1,0);
//	extent.Z	= Pawn.CollisionHeight;
	finalPoint = B9_Automation( Pawn ).Location + (vector(Direction) * (B9_AutomationSecurityCamera( Pawn ).fViewDistance));
//	Log("Final Point"$finalPoint$": LocationOfCamera:"$B9_Automation( Pawn ).Location);
	HitActor = Trace(HitLocation, HitNormal,finalPoint , B9_Automation( Pawn ).Location, true);
	Log("Hitactor is:"$HitActor);
	assailPawn = B9_BasicPlayerPawn(HitActor);
*/

	//Log("assailPawn is:"$assailPawn);
//	log("Aquire");
	if( assailPawn != None && assailPawn.Health > 0 )
	{
		Log("Enemy Detected");
		Enemy = assailPawn;
	}
	else
	{
		Enemy = none;
	}

	// If a new target has been aquired, attempt to attack immediately
  	if( Enemy != None )
  	{
		GotoState( 'Attack' );
  	}
	else
	{
		GotoState( 'Idle' );
	}
}

simulated function Timer()
{
	local Actor						A;
	local B9_Level_Alarm				alarm;
	local int index;
	super.Timer();
	// Lock onto the best target
	if(	fbJammed == false)
	{
		AcquireTarget();
		if( fIDTargetMode == true )
		{
			fTimeIDingTarget += fThinkTimerInterval;
			log("Targeting enemy in Timer:"$fTimeIDingTarget);
			if( fTimeIDingTarget >= B9_AutomationSecurityCamera( Pawn ).fTimeToIDPlayer )
			{
				log("Firing from Timer");
				fTimeIDingTarget = 0;
				//ForEach DynamicActors( class 'Actor', A, Event )
				//{
				//	A.Trigger(self, Enemy);
				//}
				//B9_Automation( Pawn ).EmitPainMessage(  Enemy  );
				foreach AllActors(class'B9_Level_Alarm', alarm)
				{
					log("MikeT: Camera Spotted the player: " $Enemy);
					for(index = 0; index < B9_AutomationSecurityCamera( Pawn ).fAlarmList.length ;index++)
					{
						if( alarm.fAlarmNumber == B9_AutomationSecurityCamera( Pawn ).fAlarmList[index])
						{
							log("Turning on the Alarm");
							alarm.TurnAlarmOn(Enemy);
						}
					}
				}

				SetRedLight();
				fResetCameraTicks = fTimeToResetCamera;
			}
			else
			{
				if (fResetCameraTicks > 0.0f)
					fResetCameraTicks = fTimeToResetCamera;
			}
		}
		else
		{
			if (fResetCameraTicks > 0.0f)
			{
				fResetCameraTicks -= fThinkTimerInterval;
				if (fResetCameraTicks < 0.0f)
				{
					fResetCameraTicks = 0.0f;
					SetGreenLight();
				}
			}
		}
	}
	else
	{
		log("Camera JAMMED");
		fTimeJammed = fTimeJammed + fThinkTimerInterval;
		log("Jammed For "$fTimeJammed$" of "$fJammCamTime$" seconds!");
		if( fTimeJammed > fJammCamTime )
		{
			log("Camera CLEARED from JAM from Base Timer");
			fTimeJammed = 0;
			fbJammed = false;
			if( fSparkle != None )
			{
				fSparkle.Destroy();
				fSparkle = None;
			}

			if( fIDTargetMode == true )
				SetAmberLight();
			else
				SetGreenLight();
		}
	}
}

auto state Idle
{
	ignores SeePlayer, HearNoise, Bump;
	simulated function Tick( float timeDelta )
	{	
		local Rotator Direction;
		local Rotator EnemyRot;
		Direction.Pitch = B9_AutomationSecurityCamera( Pawn ).fCameraPitch & 65535;
//		log("Pitch"$Direction.Pitch);
		if( fbJammed == false )
		{
			if( Enemy == None )
			{
				if( fSwingingRight )
				{
					
					fCurrentYaw += (timeDelta*(B9_AutomationSecurityCamera( Pawn ).fYawRate));
	//				log("Going Right:"$fCurrentYaw$":"$timeDelta*(B9_AutomationSecurityCamera( Pawn ).fYawRate));
					if( fCurrentYaw > B9_AutomationSecurityCamera( Pawn ).fRight)
					{
						fCurrentYaw = B9_AutomationSecurityCamera( Pawn ).fRight;
						fSwingingRight = false;
					}
				}else
				{
	//				log("Going Left:"$fCurrentYaw$":"$timeDelta);
					fCurrentYaw -= (timeDelta*(B9_AutomationSecurityCamera( Pawn ).fYawRate));
					if( fCurrentYaw < B9_AutomationSecurityCamera( Pawn ).fLeft)
					{
						fCurrentYaw = B9_AutomationSecurityCamera( Pawn ).fLeft;
						fSwingingRight = true;
					}

				}
				Direction.Yaw = (fCurrentYaw + B9_Automation( Pawn ).Rotation.Yaw);
				B9_Automation( Pawn ).Orient( Direction );
	//			log("Pan At:"$Direction.Yaw$":"$fCurrentYaw );


			}else
			{

				EnemyRot = GetRotatorToEnemy();
				SlowRotationToYaw(EnemyRot.Yaw,timeDelta);
			}
		}else
		{
			log("Camera JAMMED in IDle");
		}
	}

Begin:

	if (fIDTargetMode == true && fResetCameraTicks == 0.0f)
		SetGreenLight();

	fIDTargetMode = false;
	fLastTargetIDing = None;
	fTimeIDingTarget = 0;
}

state Attack
{
	ignores SeePlayer, HearNoise, Bump;
	simulated function Tick( float DeltaTime)
	{
		local Rotator EnemyRot;
		if( fbJammed == false )
		{
			EnemyRot = GetRotatorToEnemy();
				
			SlowRotationToYaw( (EnemyRot.Yaw & 65535) ,DeltaTime);
		}

	}
Begin:
	// Start Identify Sequence		
//	log("Begining to Target Enemy:"$Enemy);
//	log("Starting Yaw:"$B9_Automation( Pawn ).Rotation.Yaw);

	if (fIDTargetMode == false && fResetCameraTicks == 0.0f)
		SetAmberLight();

	fIDTargetMode = true;
	if( fLastTargetIDing != Enemy )
	{
//		log("Targeting new enemy:");
		fTimeIDingTarget = 0;
		fLastTargetIDing = Enemy;
	}
}

function SetGreenLight()
{
	B9_AutomationSecurityCamera(Pawn).SetGreenLight();
}

function SetAmberLight()
{
	B9_AutomationSecurityCamera(Pawn).SetAmberLight();
}

function SetRedLight()
{
	B9_AutomationSecurityCamera(Pawn).SetRedLight();
}

defaultproperties
{
	fMinimumJamTime=5
	fTimeToResetCamera=5
	fThinkTimerInterval=0.1
	bAlwaysRelevant=true
}