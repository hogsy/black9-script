//=============================================================================
// GrapplingHookProjectile.uc
//=============================================================================

class GrapplingHookProjectile extends Projectile;

//#exec OBJ LOAD FILE=..\animations\B9Weapons_models.ukx PACKAGE=B9Weapons_models
#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var bool bRing,bHitWater,bWaterStart;

var Pawn fLockedPawn;
var Pickup fLockedPickup;
var GrapplingHookTarget fGrapplingHookTarget;
var Actor fLockedWall;

var float fPullSpeed;

var GrapplingHookChain HookChain;

var protected Actor fPendulumWeight;
var protected Actor fPendulumAnchor;
var protected vector fWeightLastLocation;
var protected float fSwingVelocity;

var protected bool fDie;

var const float kPI;

function ReleaseHook()
{
	fDie = true;
}

function PostBeginPlay()
{
	local vector Dir;

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	Acceleration = Dir * 50;

	HookChain = Spawn( class'GrapplingHookChain', self,, Instigator.Location );
//	HookChain.SetOwner(self);

	PostNetBeginPlay();
}

function Tick( float DeltaTime )
{
	HookChain.SetLocation(Instigator.Location);
	
	if ( fDie )
	{
		GotoState( 'Dying' );
	}
}

auto state Flying
{

	simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		local waterring w;
		
		if (!NewVolume.bWaterVolume || bHitWater) Return;

		bHitWater = True;
		if ( Level.NetMode != NM_DedicatedServer )
		{
			w = Spawn(class'WaterRing',,,,rot(16384,0,0));
//			w.DrawScale = 0.2;
//			w.RemoteRole = ROLE_None;
			PlayAnim( 'Still', 3.0 );
		}		
		Velocity=0.6*Velocity;
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( Other != Instigator )
		{
			if ( GrapplingHookTarget(Other) != None )
			{
				fGrapplingHookTarget = GrapplingHookTarget(Other);
			}
			else if ( Pawn(Other) != None )
			{
				fLockedPawn = Pawn(Other);
			}
			else if ( Pickup(Other) != None ) 
			{
				fLockedPickup = Pickup(Other);
			}
			
			GotoState('Contracting');
		}
	}

	simulated function HitWall (vector HitNormal, actor Wall)
	{
		if ( Role == ROLE_Authority )
		{
			if ( Mover(Wall) != None )
				Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

			MakeNoise(1.0);
		}
		fLockedWall = Wall;
		GotoState('Contracting');
	}

	function BeginState()
	{
		PlayAnim( 'Idle', 0.2 );
		if ( PhysicsVolume.bWaterVolume )
		{
			bHitWater = True;
			Velocity=0.6*Velocity;
		}
	}
}

function float AngleBetweenVectors( vector A, vector B )
{
	local vector aNormal;
	local float angle;

	A = Normal(A);
	B = Normal(B);

	angle = acos( A Dot B );

	aNormal = A Cross B;

	if ( A Dot aNormal < 0 )
	{
		angle = -angle;
	}

	return -angle;
}

state Contracting
{
	function CalcPendulumStart()
	{
		local vector rod;
		local vector planeNormal;

		if ( fLockedPawn != None )
		{
			if ( fLockedPawn.Mass > Instigator.Mass )	// Pull the shooter towards the hook
			{
				fPendulumWeight = Instigator;
				fPendulumAnchor = fLockedPawn;
			}
			else	// Pull the struck pawn and the hook towards the shooter
			{
				fPendulumWeight = fLockedPawn;
				fPendulumAnchor = Instigator;
			}
		}
		else if ( fLockedPickup != None )	// Pull the pickup item and the hook towards the shooter
		{	
			fPendulumWeight = fLockedPickup;
			fPendulumAnchor = Instigator;
		}
		else if ( fGrapplingHookTarget != None )	// Pull the shooter towards the hook
		{
			fPendulumWeight = Instigator;
			fPendulumAnchor = fGrapplingHookTarget;
		}
		else if ( fLockedWall != None )	// Pull the shooter towards the hook
		{
			fPendulumWeight = Instigator;
			fPendulumAnchor = self;
		}
		else	// Pull just the hook back towards the shooter
		{
			fPendulumWeight = self;
			fPendulumAnchor = Instigator;
		}
		
		fWeightLastLocation = fPendulumWeight.Location;
	}

	function vector PendulumMotion()
	{
		// http://www.cds.caltech.edu/~hinke/courses/CDS280/pendulum.html
		// http://www.gmi.edu/~drussell/Demos/Pendulum/Pendula.html
	}

	function MoveWeight( float deltaTime )
	{
		local vector reelDirection;
		local float dist, speed;
		local float angle;
		
		if ( Pawn(fPendulumWeight) != None )
		{
			Pawn(fPendulumWeight).SetPhysics( PHYS_Falling );
			if ( PlayerController(Pawn(fPendulumWeight).Controller) != None )
			{
				PlayerController(Pawn(fPendulumWeight).Controller).GotoState( 'PlayerFlying' );
			}
		}
		
		
		reelDirection = fPendulumAnchor.Location - fPendulumWeight.Location;
		dist = VSize( reelDirection );
		if ( dist < 0.001 )
		{
			ReleaseHook();
			return;
		}
		speed = fPullSpeed;
		if ( dist < speed )
		{
			speed = dist;
		}
		
		fPendulumWeight.Acceleration = vect(0,0,0);	// Not using Unreal Physics
		fPendulumWeight.Velocity = vect(0,0,0);	// Not using Unreal Physics
		
		fWeightLastLocation = fPendulumWeight.Location;
		
		// Move with the pull of the chain
		fPendulumWeight.MoveSmooth( reelDirection * speed / dist );

		// Move with Gravitys influence
		angle = acos( ( fPendulumWeight.PhysicsVolume.Gravity Dot -reelDirection ) / 
			( dist * VSize(fPendulumWeight.PhysicsVolume.Gravity) ) );
/*		angle1 = GetAngleBetweenVectors( fPendulumWeight.PhysicsVolume.Gravity, -reelDirection );
		angle2 = GetAngleBetweenVectors( fPendulumWeight.PhysicsVolume.Gravity  // Be back!
		
		fPendulumWeight.MoveSmooth( fPendulumWeight.PhysicsVolume.Gravity * sin(angle) );
*/
		if ( VSize( fPendulumWeight.Location - fWeightLastLocation ) < 10 )
		{
			ReleaseHook();
			return;
		}
	}

	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ( Other == Instigator )
		{
			ReleaseHook();
		}
	}

	function Tick( float deltaTime )
	{
		MoveWeight( deltaTime );
		HookChain.SetLocation(Instigator.Location);

		Super.Tick(deltaTime);
		
		if ( fDie )
		{
			GotoState( 'Dying' );
		}
	}

	function BeginState()
	{
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
//		fWeightVelocity = vect(0,0,0) + fPendulumWeight.velocity;
		CalcPendulumStart();
	}
}

state Dying
{
	function ReleaseHook()
	{
	}

	function BeginState()
	{
		log( "SCDTemp:  Dying" );
		if ( Pawn(fPendulumWeight) != None )
		{
			Pawn(fPendulumWeight).SetPhysics( PHYS_Falling );
			if ( PlayerController(Pawn(fPendulumWeight).Controller) != None )
			{
				PlayerController(Pawn(fPendulumWeight).Controller).GotoState( 'PlayerWalking' );
			}
		}
		Velocity = vect(0,0,0);
		Acceleration = vect(0,0,0);
		HookChain.Destroy();
		Destroy();		
	}
}

defaultproperties
{
	fPullSpeed=15
	kPI=3.141593
	Speed=3200
	MaxSpeed=3200
	Damage=20
	MomentumTransfer=80
	LifeSpan=8
	Mesh=SkeletalMesh'B9Weapons_models.GrapplingHook_clamp_mesh'
	AmbientGlow=96
	SoundRadius=14
	SoundVolume=255
	SoundPitch=100
	bBounce=true
	bFixedRotationDir=true
	RotationRate=(Pitch=0,Yaw=0,Roll=50000)
	DesiredRotation=(Pitch=0,Yaw=0,Roll=30000)
}