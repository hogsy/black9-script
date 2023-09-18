/*=============================================================================

 //B9_MonsterController

=============================================================================*/

class B9_MonsterController extends AIController;

// Variables
#exec OBJ LOAD FILE=..\Sounds\B9SoundFX.uax PACKAGE=B9SoundFX

var float	Aggressiveness; //0.0 to 1.0 (typically)
var		float       BaseAggressiveness; 
var   	Pawn		OldEnemy;
var		float		MeanderTime;

var(Combat) class<actor> RangedProjectile;
var(Combat)	float	ProjectileSpeed;
var(Combat) bool	bLeadTarget;		// lead target with projectile attack
var(Combat) bool	bWarnTarget;		// warn target when projectile attack

var protected B9_mgun_muzzle_flash fMuzzleFlash;

// Global Functions

// This should probably be defigned elsewhere so that it can be used by other classes
function Rotator GetEularAngles( vector direction )
{
	local vector up, right;

	up = vect(0,0,1);
	right = up Cross direction;
	return OrthoRotation( direction, right, up );
}

function PawnDied( Pawn P )
{
	Super.PawnDied(P);

	if ( fMuzzleFlash != None )
	{
		Pawn.DetachFromBone( fMuzzleFlash );
		fMuzzleFlash.Destroy();
		fMuzzleFlash = None;
	}
}

function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local int rndDam;

	if ( Other.bWorldGeometry ) 
	{
//		Spawn(class'UT_LightWallHitEffect',,, HitLocation+HitNormal, Rotator(HitNormal));
	}
	else if ( (Other!=self) && (Other!=Pawn) && (Other != None) ) 
	{
		if ( Pawn(Other) == None )
			spawn(class'UT_SpriteSmokePuff',,,HitLocation+HitNormal*9); 
		
		if( FRand() < 0.5f )
		{
			Other.PlaySound(Sound 'bullet_hitting_concrete_1', SLOT_None , 4.0,,100);
		}
		else
		{
			Other.PlaySound(Sound 'bullet_hitting_concrete_2', SLOT_None , 4.0,,100);
		}

//		if ( Other.IsA('Bot') && (FRand() < 0.2) )
//			Pawn(Other).Controller.WarnTarget(Pawn(Owner), 500, X);
		rndDam = 3 + Rand(2);
		if ( FRand() < 0.2 )
			X *= 2.5;
		Other.TakeDamage(rndDam, Pawn(Owner), HitLocation, rndDam*500.0*X, class'shotrifle');
	}
}
/*
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	return (Instigator.Location + Instigator.EyePosition() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z); 
}
*/
function TraceFire( float Accuracy, vector StartOffset )
{
/*
	local vector HitLocation, HitNormal, EndTrace, X,Y,Z, projStart, error;
	local actor Other;
	local rotator AdjustedAim;

	Owner.MakeNoise(1.0);
	GetAxes(Pawn.Rotation,X,Y,Z);
	projStart = Pawn.Location + StartOffset.X * CollisionRadius * X 
					+ StartOffset.Y * CollisionRadius * Y 
					+ StartOffset.Z * CollisionRadius * Z;
	AdjustedAim = AdjustAim(None, projStart, 2*550);	
	EndTrace = StartOffset + Accuracy * (FRand() - 0.5 )* Y * 1000
		+ Accuracy * (FRand() - 0.5 ) * Z * 1000;
	X = vector(AdjustedAim);
	EndTrace += (10000.0 * X); 
	// Change
	error.X = FRand() * 100;
	error.Y = FRand() * 100;
	error.Z = FRand() * 100;
	EndTrace = ( Enemy.Location - Pawn.Location + error ) * 10000.0 + StartOffset;
	projStart = Pawn.Location + StartOffset;
	// end of change
	Other = Trace(HitLocation,HitNormal,EndTrace,projStart,True);

//	if ( VSize(HitLocation - projStart) > 250 )
//		Spawn(class'MTracer',,, projStart,rotator(EndTrace - projStart));

	ProcessTraceHit(Other, HitLocation, HitNormal, X,Y,Z);
*/
}

final function FireProjectile(vector StartOffset, float Accuracy)
{
	local vector X,Y,Z, projStart;

	MakeNoise(1.0);
	GetAxes(Pawn.Rotation,X,Y,Z);
	projStart = Pawn.Location + StartOffset.X * CollisionRadius * X 
					+ StartOffset.Y * CollisionRadius * Y 
					+ StartOffset.Z * CollisionRadius * Z;
	
//	spawn(RangedProjectile ,self,'',projStart,AdjustAim(ProjectileSpeed, projStart, Accuracy, bLeadTarget, bWarnTarget, false, false));
}

function SpawnRightShot()
{
	FireProjectile( vect(1.2,0.55,0.30), 750);
}

function MoveIt( vector Direction, float speed )
{
	Direction = Normal(Direction);
	Pawn.Acceleration = Pawn.AccelRate * Direction;
	Destination = Pawn.Location + 6 * Pawn.GroundSpeed * Pawn.Acceleration;
	FocalPoint = Destination;
}

function Run( vector Direction )
{
	Pawn.DesiredSpeed = 1.0;
	Pawn.bIsWalking = false;
	MoveIt( Direction, Pawn.GroundSpeed  );
}

function Walk( vector Direction )
{
	Pawn.DesiredSpeed = 0.25;
	Pawn.bIsWalking = true;
	MoveIt( Direction, Pawn.GroundSpeed  );
}

function EnemyAcquired()
{
	//log(Class$" just acquired an enemy - no action");
}

function eAttitude AttitudeTo(Pawn Other)
{
/*	if ( bKamikaze )
		return ATTITUDE_Hate;
	else 
*/
	if ( Other.IsA('TeamCannon') 
		|| (RelativeStrength(Other) > Aggressiveness + 0.44 - skill * 0.06) )
		return ATTITUDE_Fear;
	else
		return ATTITUDE_Hate;
}

/* RelativeStrength()
returns a value indicating the relative strength of other
0.0 = equal to controlled pawn
> 0 stronger than controlled pawn
< 0 weaker than controlled pawn

Since the result will be compared to the creature's aggressiveness, it should be
on the same order of magnitude (-1 to 1)

Assess based on health and weapon
*/

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedOther, bTemp;

	adjustedOther = 0.5 * (Other.health + Other.Default.Health);	
	compare = 0.01 * float(adjustedOther - Pawn.health);
	if ( Pawn.Weapon != None )
	{
//		compare -= Pawn.DamageScaling * (Pawn.Weapon.RateSelf(bTemp) - 0.3);
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.35;
		}
	}
//	if ( Other.Weapon != None )
//		compare += Other.DamageScaling * (Other.Weapon.RateSelf(bTemp) - 0.3);

	if ( Other.Location.Z > Pawn.Location.Z + 400 )
		compare -= 0.2;
	else if ( Pawn.Location.Z > Other.Location.Z + 400 )
		compare += 0.15;
	//log(other.class@"relative strength to"@class@"is"@compare);
	return compare;
}

function float AssessThreat( Pawn NewThreat )
{
	local float ThreatValue, NewStrength, Dist;
	local eAttitude NewAttitude;

	NewStrength = RelativeStrength(NewThreat);

	ThreatValue = FMax(0, NewStrength);
	if ( NewThreat.Health < 20 )
		ThreatValue += 0.3;

	Dist = VSize(NewThreat.Location - Pawn.Location);
	if ( Dist < 800 )
		ThreatValue += 0.3;

	if ( (NewThreat != Enemy) && (Enemy != None) )
	{
		if ( Dist > 0.7 * VSize(Enemy.Location - Location) )
			ThreatValue -= 0.25;
		ThreatValue -= 0.2;

		if ( !LineOfSightTo(Enemy) )
		{
			if ( Dist < 1200 )
				ThreatValue += 0.2;
/*			if ( Pawn.bPreparingMove )
				ThreatValue += 5;*/
			if ( IsInState('Hunting') && (NewStrength < 0.2) 
				&& (Level.TimeSeconds - LastSeenTime < 3)
				&& (relativeStrength(Enemy) < FMin(0, NewStrength)) )
				ThreatValue -= 0.3;
		}
	}

	if ( NewThreat.IsHumanControlled() )
	{
		if ( Level.Game.bTeamGame )
			ThreatValue -= 0.15;
		else
			ThreatValue += 0.15;
	}
	return ThreatValue;
}

function bool SetEnemy( Pawn NewEnemy )
{
	local bool result, bNotSeen;
	local eAttitude newAttitude, oldAttitude;
	local float newStrength;
	local Controller Friend;

	if (Enemy == NewEnemy)
		return true;
	if ( (NewEnemy == Pawn) || (NewEnemy == None) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == None) )
		return false;

	result = false;
	newAttitude = AttitudeTo(NewEnemy);
	if ( newAttitude == ATTITUDE_Friendly )
	{
		Friend = NewEnemy.Controller;
		if ( Level.TimeSeconds - Friend.LastSeenTime > 5 )
			return false;
		NewEnemy = Friend.Enemy;
		if ( (NewEnemy == None) || (NewEnemy == Pawn) || (NewEnemy.Health <= 0) || NewEnemy.IsA('StationaryPawn') )
			return false;
		if (Enemy == NewEnemy)
			return true;

		bNotSeen = true;
		newAttitude = AttitudeTo(NewEnemy);
	}

	if ( newAttitude >= ATTITUDE_Ignore )
		return false;

	if ( Enemy != None )
	{
		if ( AssessThreat(NewEnemy) > AssessThreat(Enemy) )
		{
			OldEnemy = Enemy;
			Enemy = NewEnemy;
			result = true;
		}
		else if ( OldEnemy == None )
			OldEnemy = NewEnemy;
	}
	else
	{
		result = true;
		Enemy = NewEnemy;
	}

	if ( result )
	{
		if ( bNotSeen )
		{
			LastSeenTime = Friend.LastSeenTime;
			LastSeeingPos = Friend.LastSeeingPos;
			LastSeenPos = Friend.LastSeenPos;
		}
		else
		{
			LastSeenTime = Level.TimeSeconds;
			LastSeeingPos = Pawn.Location;
			LastSeenPos = Enemy.Location;
		}
		EnemyAcquired();
	}
				
	return result;
}

// States

state firing
{
	function AnimEnd(int channel)
	{
		if ( fMuzzleFlash != None )
		{
			Pawn.DetachFromBone( fMuzzleFlash );
			fMuzzleFlash.Destroy();
			fMuzzleFlash = None;
		}
		GotoState('hunting');
	}

	event Tick( float DeltaTime )
	{
		local vector Dir;
		Super.Tick(DeltaTime);
		Dir = Enemy.Location - Pawn.Location;
		Pawn.SetRotation( GetEularAngles(Dir) );
	}

	function EndState()
	{
		if ( fMuzzleFlash != None )
		{
			Pawn.DetachFromBone( fMuzzleFlash );
			fMuzzleFlash.Destroy();
			fMuzzleFlash = None;
		}
	}

Begin:
	Pawn.Acceleration = vect(0,0,0);
	Pawn.PlayFiring(1.0, 'MODE_Normal');
	fMuzzleFlash = spawn( class'B9_mgun_muzzle_flash', Pawn );
	Pawn.AttachToBone( fMuzzleFlash, 'HunterGunTag' );
HitEm:
	TraceFire( 0, vect(1.2,0.55,0.30) );
	PlaySound( Sound'mech_gun_firing_3', SLOT_None );
	sleep(0.26);
	Goto('HitEm');	
}

state charging
{
	function bool CloseRange()
	{
		local vector Dir;
		Dir = Enemy.Location - Pawn.Location;
		Dir.z = 0;
		if ( VSize(Dir) > 1500 )
		{
			return false;
		}
		else
		{
			return true;
		}
	}

	function ChargeEnemy()
	{
		local vector Dir;
		Dir = Enemy.Location - Pawn.Location;
		Dir.z = 0;
		if ( VSize(Dir) > 1500 )
		{
			Run( Dir );
		}
		else
		{
			Walk( Dir );
		}
	}
Begin:
	if ( CloseRange() )
	{
		Pawn.bIsWalking = true;
		Pawn.PlayMoving();
	}
	else
	{
		Pawn.bIsWalking = false;
		Pawn.PlayMoving();
	}

	log( "Monster Controller: Charge state (Begin)" );

Running:
	if ( LineOfSightTo(Enemy) )
	{
		ChargeEnemy();
		if ( Rand(4) == 1 )	// Take start firing...
		{
			GotoState( 'firing' );
		}
		Sleep(0.5);
		Goto( 'Running' );
	}
	else
	{
		Sleep(1+2*FRand());
		GotoState( 'hunting' );
	}

	log( "Monster Controller: Charge state (Running)" );
}

state hunting
{
	function Meander()
	{
		local vector Dir;
		Dir = VRand();
		Dir.z = 0;
		Pawn.SetPhysics(PHYS_Walking);
		Walk( Dir );
	}

	event bool NotifyHitWall(Vector HitNormal, Actor Wall)
	{
		// get pawn moving along wall
		Walk( Pawn.Velocity + HitNormal * (HitNormal Dot Pawn.Velocity) );
		return true;
	}

	event bool NotifyBump(Actor Other)
	{
		local vector Dir;
		
		Dir = Other.Location - Pawn.Location;
		Dir.Z = 0;
		Dir = Normal(Dir);
		Dir = Pawn.Acceleration - Dir * (Pawn.Acceleration Dot Dir);
		Walk( Dir );

		return false;
	}

	event HearNoise( float Loudness, Actor NoiseMaker)
	{
		if ( SetEnemy( NoiseMaker.instigator ) )
		{
			GotoState( 'charging' );
		}
	}

	event SeePlayer( Pawn Seen )
	{
		if ( SetEnemy( Seen ) )
		{
			GotoState( 'charging' );
		}
	}

	event SeeMonster( Pawn Seen )
	{
		if ( SetEnemy( Seen ) )
		{
			GotoState( 'charging' );
		}
	}

Begin:
	MeanderTime = Level.TimeSeconds;

	log( "Monster Controller: Begin Hunting" );
		
Meander:
	Meander();
	Pawn.bIsWalking = true;
	Pawn.PlayMoving();
	Sleep(2*FRand());
	if ( Level.TimeSeconds - MeanderTime > 10 )
	{
		Pawn.Acceleration = vect(0,0,0);
		GotoState( 'idling' );
	}
	else
	{
		Goto( 'Meander' );
	}
}

auto state idling
{
	event SeePlayer( Pawn Seen )
	{
		if ( SetEnemy( Seen ) )
		{
			GotoState( 'charging' );
		}
	}

	event SeeMonster( Pawn Seen )
	{
		if ( SetEnemy( Seen ) )
		{
			GotoState( 'charging' );
		}
	}

	event AnimEnd(int Channel)
	{
		Pawn.PlayWaiting();
		log( "Monster Controller: PlayWaiting again" );
	}

Begin:
	Enable( 'AnimEnd' );
	Pawn.PlayWaiting();
	Sleep(5);
	Disable( 'AnimEnd' );
	GotoState( 'hunting' );	

	log( "Monster Controller: Begin PlayWaiting" );
}


defaultproperties
{
	Aggressiveness=0.3
	BaseAggressiveness=0.3
	ProjectileSpeed=700
	bLeadTarget=true
	bWarnTarget=true
}