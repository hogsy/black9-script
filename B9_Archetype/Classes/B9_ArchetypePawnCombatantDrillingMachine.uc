//////////////////////////////////////////////////////////////////////////
//
// Black 9 Combatant Archetype Genesis Intimidator Droid.
//
//////////////////////////////////////////////////////////////////////////
class B9_ArchetypePawnCombatantDrillingMachine extends B9_ArchetypePawnCombatant;

// Load the animations package for the civilian archetype
#exec OBJ LOAD FILE=..\animations\B9_Genesis_Characters PACKAGE=B9_Genesis_Characters

var(AI)	int		fDamageToInflict;
var(AI) float	fDamageFrequency;
var(AI) float	fMaxAttackRange;

var CollisionMesh	fCollisionPart;
var StaticMesh		kCollisionPartMesh;
var Name			kCollisionPartBoneName;


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	// Turn off normal collision.
	SetCollision( false, false, false );
	
	// Make the collision part.
	CreateCollisionPart(kCollisionPartMesh, kCollisionPartBoneName);
	
	// Turn on collision for the part.
	fCollisionPart.SetCollision( true, true, true );
}

simulated function Destroyed()
{
	// clean up collision parts
	fCollisionPart.Destroy();
	Super.Destroyed();
}

simulated function CreateCollisionPart( StaticMesh collisionPartMesh, Name collisionPartBoneName )
{
	local CollisionMesh	collisionPart;

	collisionPart	= Spawn( class'CollisionMesh', Self );
	if ( collisionPart != None )
	{
		collisionPart.SetDrawType( DT_None );// must not be visible
		collisionPart.SetStaticMesh( collisionPartMesh );
		collisionPart.SetCollision( true, true, true );

		AttachToBone( collisionPart, collisionPartBoneName );

		fCollisionPart	= collisionPart;
	}
}


event Bump(Actor Other)
{
	Super.Bump(Other);
	if (B9_AI_ControllerCombatantDrillingMachine(Controller) != None)
		B9_AI_ControllerCombatantDrillingMachine(Controller).NotifyBump(Other);
}




///////////////////////////////////
// AnimateXXX()
// Sets up the movement anims in response to movement type / physics changes
//
simulated function AnimateWalking()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_F';
	MovementAnims[2]	= 'nowpn_Run_F';
	MovementAnims[3]	= 'nowpn_Run_F';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';
}

simulated function AnimateRunning()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_F';
	MovementAnims[2]	= 'nowpn_Run_F';
	MovementAnims[3]	= 'nowpn_Run_F';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';
}

simulated function AnimateCrouchWalking()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_F';
	MovementAnims[2]	= 'nowpn_Run_F';
	MovementAnims[3]	= 'nowpn_Run_F';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';
}

simulated function AnimateSwimming()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_F';
	MovementAnims[2]	= 'nowpn_Run_F';
	MovementAnims[3]	= 'nowpn_Run_F';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';
}

simulated function AnimateFlying()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_F';
	MovementAnims[2]	= 'nowpn_Run_F';
	MovementAnims[3]	= 'nowpn_Run_F';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';
}

simulated function AnimateHovering()
{
	LoopIfNeeded( 'nowpn_Run_F', 1.0, 0.0 );
}

simulated function AnimateClimbing()
{
	MovementAnims[0]	= 'nowpn_Run_F';
	MovementAnims[1]	= 'nowpn_Run_F';
	MovementAnims[2]	= 'nowpn_Run_F';
	MovementAnims[3]	= 'nowpn_Run_F';
	TurnLeftAnim		= 'nowpn_Run_F';
	TurnRightAnim		= 'nowpn_Run_F';

  	ChangeAnimation();
}

simulated function AnimateStoppedOnLadder()
{
	LoopIfNeeded( 'nowpn_Run_F', 1.0, 0.0 );
}

simulated function AnimateTreading()
{
	LoopIfNeeded( 'nowpn_Run_F', 1.0, 0.0 );
}

simulated function AnimateCrouching()
{
	LoopIfNeeded( 'nowpn_Run_F', 1.0, 0.0 );
}

simulated function AnimateStanding()
{
	LoopIfNeeded( 'nowpn_Run_F', 1.0, 0.0 );
}

simulated function name GetFiringAnim()
{
	return 'nowpn_Run_F';
}
simulated function name GetJumpAnim()
{
	return 'nowpn_Run_F';
}
simulated function name GetFallingAnim()
{
	return 'nowpn_Run_F';
}
simulated function name GetLandingAnim()
{
	return 'nowpn_Run_F';
}
simulated function name GetKnockdownAnim( bool fromBehind )
{
	return 'nowpn_Run_F';
}
simulated function name GetStandupAnim( bool fromBehind )
{
	return 'nowpn_Run_F';
}
simulated function name GetDyingAnim( vector HitLoc )
{
	return 'nowpn_Run_F';
}



defaultproperties
{
	fDamageToInflict=50000
	fDamageFrequency=0.5
	fMaxAttackRange=10000
	kCollisionPartMesh=StaticMesh'B9_Vehicle_meshes.drilling_machine.drilling_collision'
	kCollisionPartBoneName=collisionbone
	fWeaponStartingAmmo=1000
	fRetreatOnTakingFireRatio=0
	fRetreatToCoverRatio=0
	fStopShortOfHuntTarget=false
	bIsBig=true
	fCharacterMaxHealth=1000
	bCanCrouch=false
	bCanSwim=false
	bCanClimbLadders=false
	GroundSpeed=215
	WaterSpeed=150
	Health=1000
	MenuName="B9_CombatantDrillingMachine"
	ControllerClass=Class'B9_AI_ControllerCombatantDrillingMachine'
	Mesh=SkeletalMesh'B9_Genesis_characters.drill_mesh'
	Buoyancy=10
	RotationRate=(Pitch=0,Yaw=4200,Roll=2048)
}